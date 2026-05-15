#!/usr/bin/env bash
# Verify Google OAuth client credentials.
#
# POSTs to https://oauth2.googleapis.com/token with the client_id/secret pair
# and a deliberately invalid authorization code. Google returns a JSON error:
#
#   error=invalid_grant  — client credentials are valid, code is bad (our success)
#   error=invalid_client — client_id or client_secret is wrong
#
# Emits a single JSON line on stdout.
set -u

emit() {
  printf '%s\n' "$1"
}

if [[ -z "${GOOGLE_CLIENT_ID:-}" || -z "${GOOGLE_CLIENT_SECRET:-}" ]]; then
  emit '{"integration":"google","status":"error","error":"missing_env","details":"GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET must be set"}'
  exit 1
fi

response=$(curl --silent --request POST \
  --data "client_id=${GOOGLE_CLIENT_ID}" \
  --data "client_secret=${GOOGLE_CLIENT_SECRET}" \
  --data "code=verify-only-bogus-code" \
  --data "grant_type=authorization_code" \
  --data "redirect_uri=urn:ietf:wg:oauth:2.0:oob" \
  https://oauth2.googleapis.com/token)

error=$(printf '%s' "$response" | python3 -c 'import json,sys;d=json.load(sys.stdin);print(d.get("error",""))' 2>/dev/null || echo "")

case "$error" in
  invalid_grant)
    emit '{"integration":"google","status":"ok","details":"client credentials accepted by oauth2.googleapis.com/token (server returned invalid_grant for the bogus code)"}'
    exit 0
    ;;
  invalid_client)
    emit '{"integration":"google","status":"error","error":"bad_credentials","details":"Google rejected the client_id/client_secret pair (invalid_client)"}'
    exit 1
    ;;
  "")
    emit "{\"integration\":\"google\",\"status\":\"error\",\"error\":\"unexpected_response\",\"details\":\"could not parse Google response: $(printf '%s' "$response" | tr -d '\n' | head -c 200)\"}"
    exit 1
    ;;
  *)
    emit "{\"integration\":\"google\",\"status\":\"error\",\"error\":\"${error}\",\"details\":\"Google returned an unexpected error code\"}"
    exit 1
    ;;
esac
