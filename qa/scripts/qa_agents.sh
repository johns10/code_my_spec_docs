#!/usr/bin/env bash
#
# Stand up disposable agents on a project, so multi-agent behaviour can be
# tested without borrowing a live working copy.
#
# Story 727's criteria are about what happens when two agents share a project:
# separate file state, identity that survives a restart, an agent that loses
# its identity, a human editing outside every workspace. Every one of those is
# reachable, and none of them was reachable in practice, because the only
# agents on this machine were other people's live sessions. Testing 736 meant
# deleting a working agent's identity file; testing 740 meant finding a
# directory no agent watched. So they went untested.
#
# This mints agents that belong to nobody. Each is a scratch directory with a
# `.code_my_spec/config.yml` naming the project and a server-issued id in
# `.cms_harness.json` — the same two files `mix cms.harness.onboard` writes,
# because that is what the harness actually reads.
#
#   qa_agents.sh up 2      mint two agents and print their ids and roots
#   qa_agents.sh list      show what this fixture has minted
#   qa_agents.sh serve 1   run agent 1's harness in the foreground on a free port
#   qa_agents.sh down      remove the scratch directories
#
# Credentials, in preference order: CMS_TOKEN, then CMS_DEPLOY_KEY, then
# whichever of those is in envs/.env. The deploy key is traded for a token at
# POST /api/sprite/token. Note the token comes back scoped to the deploy key's
# own project — you cannot mint agents on a project whose key you do not hold,
# which is a property of the credential rather than of this script.
#
# WHAT TEARDOWN CANNOT DO. The harness API is GET and POST only; there is no
# DELETE. `down` removes the directories, and the harness rows stay on the
# server forever, reporting whatever files they last saw. That residue is not
# cosmetic — a retired agent's file rows keep components alive for every other
# agent (issue 3c6b6b63), which is how a phantom orphan context survived four
# days. Until a delete exists, clean up deliberately:
#
#   psql -d code_my_spec_dev -c \
#     "delete from files where harness_id in (select id from harnesses where label like 'qa-fixture-%');
#      delete from harnesses where label like 'qa-fixture-%';"
#
# Every agent this script mints is labelled `qa-fixture-<n>` so that query can
# find them and nothing else.

set -euo pipefail

SERVER="${CMS_SERVER_URL:-http://localhost:4000}"
FIXTURE_DIR="${QA_AGENTS_DIR:-/tmp/cms-qa-agents}"
MANIFEST="$FIXTURE_DIR/manifest.tsv"

die() { echo "qa_agents: $*" >&2; exit 1; }

# envs/.env is Dotenvy's, loaded into config for `env!/2` and never into the
# process environment — so it has to be read here rather than assumed present.
credential() {
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

  if [ -n "${CMS_TOKEN:-}" ]; then echo "token:$CMS_TOKEN"; return; fi
  if [ -n "${CMS_DEPLOY_KEY:-}" ]; then echo "key:$CMS_DEPLOY_KEY"; return; fi

  local from_file
  from_file=$(grep -E '^CMS_(TOKEN|DEPLOY_KEY)=' "$root/envs/.env" 2>/dev/null | head -1 || true)
  [ -n "$from_file" ] || die "no credential. Set CMS_TOKEN or CMS_DEPLOY_KEY, or put one in envs/.env"

  case "$from_file" in
    CMS_TOKEN=*)      echo "token:$(echo "$from_file" | cut -d= -f2- | tr -d '\"')" ;;
    CMS_DEPLOY_KEY=*) echo "key:$(echo "$from_file" | cut -d= -f2- | tr -d '\"')" ;;
  esac
}

# Returns "<token>\t<project_id>". The project comes from the exchange rather
# than from an argument on purpose: a token is scoped to one project, so taking
# a project id here would let a caller ask for something the credential cannot
# do and get a confusing 401 instead of a clear one.
resolve() {
  local cred token body
  cred="$(credential)"

  case "$cred" in
    token:*)
      token="${cred#token:}"
      [ -n "${QA_PROJECT_ID:-}" ] || die "CMS_TOKEN given without QA_PROJECT_ID; a bare token does not name its project"
      printf '%s\t%s\n' "$token" "$QA_PROJECT_ID"
      ;;
    key:*)
      body=$(curl -sS -X POST "$SERVER/api/sprite/token" \
               -H "authorization: Bearer ${cred#key:}" \
               -H 'content-type: application/json' --max-time 20)
      token=$(echo "$body" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
      [ -n "$token" ] || die "token exchange failed: $body"
      printf '%s\t%s\n' "$token" "$(echo "$body" | sed -n 's/.*"project_id":"\([^"]*\)".*/\1/p')"
      ;;
  esac
}

up() {
  local count="${1:-2}" token project root label id body
  IFS=$'\t' read -r token project < <(resolve)
  mkdir -p "$FIXTURE_DIR"

  echo "project $project on $SERVER"
  for i in $(seq 1 "$count"); do
    root="$FIXTURE_DIR/agent-$i"
    label="qa-fixture-$i"
    mkdir -p "$root/.code_my_spec"

    # The two files a harness reads. config.yml is how ProjectIdentity.resolve
    # answers "which project is this?"; .cms_harness.json is what the server
    # issued, and is what makes a restart resume rather than mint again.
    printf 'project_id: %s\n' "$project" > "$root/.code_my_spec/config.yml"

    body=$(curl -sS -X POST "$SERVER/api/harnesses" \
             -H "authorization: Bearer $token" -H 'content-type: application/json' \
             --max-time 20 \
             -d "{\"project_id\":\"$project\",\"root\":\"$root\",\"label\":\"$label\"}")
    id=$(echo "$body" | sed -n 's/.*"harness_id":"\([^"]*\)".*/\1/p')
    [ -n "$id" ] || die "onboarding $label failed: $body"

    printf '{\n  "root": "%s",\n  "harness_id": "%s",\n  "project_id": "%s"\n}\n' \
      "$root" "$id" "$project" > "$root/.cms_harness.json"

    printf '%s\t%s\t%s\n' "$label" "$id" "$root" >> "$MANIFEST"
    echo "  $label  $id  $root"
  done
}

list() {
  [ -f "$MANIFEST" ] || { echo "nothing minted yet"; return; }
  column -t "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
}

# Runs in the foreground so the caller sees the banner and can stop it. The
# port is explicit because two harnesses on one machine cannot share one, and
# a collision reads as :eaddrinuse rather than as anything about agents.
serve() {
  local n="${1:?which agent}" port="${2:-$((4020 + ${1:-0}))}" root repo
  root=$(awk -v n="qa-fixture-$n" '$1==n {print $3}' "$MANIFEST" 2>/dev/null || true)
  [ -n "$root" ] || die "no agent $n — run `up` first"
  repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

  echo "serving $root on :$port (ctrl-c to stop)"
  cd "$repo"
  CMS_HARNESS=1 CMS_HARNESS_PORT="$port" CMS_SERVER_URL="$SERVER" \
    CMS_HARNESS_ROOT="$root" MIX_ENV=dev_cli elixir -S mix run --no-halt
}

down() {
  [ -d "$FIXTURE_DIR" ] || { echo "nothing to remove"; return; }
  if [ -f "$MANIFEST" ]; then
    echo "removing $(wc -l < "$MANIFEST" | tr -d ' ') scratch root(s)"
    echo "server-side rows remain — see the header of this script for the cleanup query"
  fi
  rm -rf "$FIXTURE_DIR"
}

case "${1:-}" in
  up)    shift; up "$@" ;;
  list)  list ;;
  serve) shift; serve "$@" ;;
  down)  down ;;
  *)     echo "usage: qa_agents.sh {up [n] | list | serve <n> [port] | down}" >&2; exit 2 ;;
esac
