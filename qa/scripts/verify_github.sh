#!/usr/bin/env bash
# Verify GitHub client credentials (works for OAuth Apps AND GitHub Apps).
#
# POSTs to https://github.com/login/oauth/access_token with a deliberately
# invalid `code`. GitHub returns one of:
#
#   error=bad_verification_code        — client_id/secret are valid, code is bad (success)
#   error=incorrect_client_credentials — client_id or client_secret is wrong
#
# Emits a single JSON line on stdout.
set -u

emit() {
  printf '%s\n' "$1"
}

if [[ -z "${GITHUB_CLIENT_ID:-}" || -z "${GITHUB_CLIENT_SECRET:-}" ]]; then
  emit '{"integration":"github","status":"error","error":"missing_env","details":"GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET must be set"}'
  exit 1
fi

response=$(curl --silent --request POST \
  --header 'Accept: application/json' \
  --data "client_id=${GITHUB_CLIENT_ID}" \
  --data "client_secret=${GITHUB_CLIENT_SECRET}" \
  --data "code=verify-only-bogus-code" \
  https://github.com/login/oauth/access_token)

error=$(printf '%s' "$response" | python3 -c 'import json,sys;d=json.load(sys.stdin);print(d.get("error",""))' 2>/dev/null || echo "")

case "$error" in
  bad_verification_code)
    emit '{"integration":"github","status":"ok","details":"client credentials accepted by github.com/login/oauth/access_token (server returned bad_verification_code for the bogus code)"}'
    exit 0
    ;;
  incorrect_client_credentials)
    emit '{"integration":"github","status":"error","error":"bad_credentials","details":"GitHub rejected the client_id/client_secret pair (incorrect_client_credentials)"}'
    exit 1
    ;;
  "")
    emit "{\"integration\":\"github\",\"status\":\"error\",\"error\":\"unexpected_response\",\"details\":\"could not parse GitHub response: $(printf '%s' "$response" | tr -d '\n' | head -c 200)\"}"
    exit 1
    ;;
  *)
    emit "{\"integration\":\"github\",\"status\":\"error\",\"error\":\"${error}\",\"details\":\"GitHub returned an unexpected error code\"}"
    exit 1
    ;;
esac
