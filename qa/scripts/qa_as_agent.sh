#!/usr/bin/env bash
#
# Make one MCP tool call *as* a named agent, so the agent -> main agent -> user
# routing stories can be driven from a QA session.
#
#   qa_as_agent.sh <agent-id> <tool> ['<json-arguments>']
#
#   qa_as_agent.sh 880c7713-... list_tasks '{}'
#   qa_as_agent.sh <fixture-id> ask_user_question '{"questions":[{"question":"Which?","options":[{"label":"A","description":"first"},{"label":"B","description":"second"}]}],"title":"QA routing check"}'
#   qa_as_agent.sh <fixture-id> check_answer '{"question_id":"..."}'
#
# WHY THIS EXISTS
#
# Issue e2b72303. Story 1009/1052 is about an agent asking a question, the
# project's main agent answering or escalating it, and the asker collecting the
# reply. Five of its ten criteria need the *asker* side, and a QA session could
# not reach it: `AskUserQuestion` takes no `agent_id` parameter — it reads
# `frame.assigns[:agent_id]`, which comes off the connection — and
# `MainAgent.holder_for/2` routes straight to "user" when that is nil or names
# a `role: :main` agent. So every question a QA session asked went to the
# project owner's personal inbox instead of through the main agent, four times,
# and the criteria stayed unverifiable.
#
# The identity rides on `X-Agent-Id`, which the harness proxy forwards and the
# server's `Plugs.AgentScope` resolves *within the project the request is
# already scoped to*. That check is what makes this safe rather than
# impersonation-for-anyone: you cannot name an agent on a project you are not
# already authenticated for.
#
# HOW TO USE IT WITHOUT BORROWING A WORKING AGENT
#
# Do not pass the id of an agent that is doing something. Attributing a
# synthetic question to a real, mid-task agent corrupts the main agent's and
# the owner's read of that agent's state, which is exactly what a QA pass must
# not do. Use the standing fixture agent in qa/plan.md, or on a candidate copy
# app provision your own with POST <instance>/dev/qa-agents (plan.md,
# "Provisioning agents on a candidate"). In-app QA cannot create or offboard
# working copies; those are main's tools. Then:
#
#   1. qa_as_agent.sh <id> ask_user_question '...'
#   2. ... observe routing, answer as the main agent, collect with check_answer
#   3. leave any copy you did not make alone; tell main about leftovers
#
# A coding role is the point. `holder_for/2` treats `:main` as "user", so a
# main-role fixture routes exactly like no fixture at all — which is how the
# sandbox project's existing agents came to be useless for this.
#
# WHAT IT DOES NOT DO
#
# It makes one call and exits. It does not create the agent, does not clean one
# up, and has no opinion about which one you name — deliberately, because the
# thing it is standing in for is a single tool call from an agent that exists.
# Creating and destroying are already MCP tools; only calling *as* somebody was
# missing.
#
# The handshake is per invocation, so two calls are two sessions. That is fine
# for the tools this exists for and wrong for anything stateful.
#
# TRAP. The default URL is the harness proxy on :4004, not the server on :4000.
# The proxy is what forwards `X-Agent-Id` and supplies the harness identity, so
# a call sent straight to :4000 needs a bearer token and `X-Project-ID` instead
# and will 401 without them. Override with CMS_MCP_URL only if you have those.
set -uo pipefail

WT="${QA_WORKTREE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
URL="${CMS_MCP_URL:-http://localhost:4004/mcp}"

AGENT="${1:-}"
TOOL="${2:-}"
ARGS="${3:-{\}}"

die() { echo "qa_as_agent: $*" >&2; exit 1; }

[ -n "$AGENT" ] || die "usage: qa_as_agent.sh <agent-id> <tool> ['<json-arguments>']"
[ -n "$TOOL" ]  || die "usage: qa_as_agent.sh <agent-id> <tool> ['<json-arguments>']"

[ -f "$WT/.cms_harness.json" ] ||
  die "no .cms_harness.json at $WT — set QA_WORKTREE to a checkout the harness serves"

HID=$(python3 -c "import json;print(json.load(open('$WT/.cms_harness.json'))['harness_id'])")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

hdr=(-H "Content-Type: application/json"
     -H "Accept: application/json, text/event-stream"
     -H "X-Harness-Id: $HID"
     -H "X-Agent-Id: $AGENT")

curl -s -X POST "$URL" "${hdr[@]}" -D "$TMP/h" -o "$TMP/body" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"qa-as-agent","version":"1"}}}'

SID=$(grep -i '^mcp-session-id:' "$TMP/h" | tr -d '\r' | cut -d' ' -f2)
if [ -z "$SID" ]; then
  # The server declines to open a session for an initialize that names no
  # working copy, answering with a JSON-RPC error saying exactly that (code
  # -32000) and no mcp-session-id header. That is the documented contract, not
  # a liveness fault — and the body is the whole diagnosis, so report it rather
  # than guessing. Issue e6b4792b: the guess sent QA to :4004/health, the one
  # thing that was never wrong, while the real cause (a checkout that was never
  # onboarded) sat unread in this body.
  echo "qa_as_agent: $URL declined to open a session. The server said:" >&2
  cat "$TMP/body" >&2
  echo >&2
  echo "qa_as_agent: if that names a missing working copy, onboard this checkout:" >&2
  echo "qa_as_agent:   (cd \"$WT\" && mix cms.harness.onboard)" >&2
  exit 1
fi

curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" -o /dev/null \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'

curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"$TOOL\",\"arguments\":$ARGS}}" |
  python3 -c '
import sys, json, re

raw = sys.stdin.read()
# Streamable HTTP answers as SSE; a plain JSON body is also valid and both are
# seen in practice, so neither shape is assumed.
match = re.search(r"^data: (.*)$", raw, re.M)
body = match.group(1) if match else raw.strip()

if not body:
    print("qa_as_agent: empty response — the tool call reached nothing", file=sys.stderr)
    raise SystemExit(1)

try:
    payload = json.loads(body)
except json.JSONDecodeError:
    print(raw)
    raise SystemExit(1)

if "error" in payload:
    print("error: " + json.dumps(payload["error"], indent=2), file=sys.stderr)
    raise SystemExit(1)

result = payload.get("result", {})
for part in result.get("content", []):
    print(part.get("text", json.dumps(part)))

# An isError result is a refusal the tool chose, not a transport failure. Said
# out loud and exited non-zero so a script driving this can tell the two apart.
if result.get("isError"):
    print("qa_as_agent: the tool refused (above)", file=sys.stderr)
    raise SystemExit(2)
'
