#!/usr/bin/env bash
# Verify Resend API key.
#
# Calls GET https://api.resend.com/domains with Bearer auth. Resend returns:
#   200 — key is valid (data array may be empty for a fresh account)
#   401 — key is invalid or revoked
#   403 — key is valid but lacks scope
#
# Emits a single JSON line on stdout.
set -u

emit() {
  printf '%s\n' "$1"
}

if [[ -z "${RESEND_API_KEY:-}" ]]; then
  emit '{"integration":"resend","status":"error","error":"missing_env","details":"RESEND_API_KEY must be set"}'
  exit 1
fi

http_status=$(curl --silent --output /dev/null --write-out '%{http_code}' \
  --header "Authorization: Bearer ${RESEND_API_KEY}" \
  --header 'Accept: application/json' \
  https://api.resend.com/domains)

case "$http_status" in
  200)
    emit '{"integration":"resend","status":"ok","http_status":200,"details":"GET /domains accepted the API key"}'
    exit 0
    ;;
  401)
    emit '{"integration":"resend","status":"error","http_status":401,"error":"bad_credentials","details":"Resend rejected the API key"}'
    exit 1
    ;;
  403)
    emit '{"integration":"resend","status":"error","http_status":403,"error":"insufficient_scope","details":"API key is valid but lacks domains:read; check the key permissions in the Resend dashboard"}'
    exit 1
    ;;
  *)
    emit "{\"integration\":\"resend\",\"status\":\"error\",\"http_status\":${http_status},\"error\":\"unexpected_status\",\"details\":\"unexpected HTTP status from Resend\"}"
    exit 1
    ;;
esac
