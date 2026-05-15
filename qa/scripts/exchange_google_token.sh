#!/usr/bin/env bash
# Exchange Google OAuth client credentials for a user access token via the
# authorization-code flow. Requests offline access so a refresh token is
# returned.
#
# Usage:
#   ./exchange_google_token.sh [scope]
#
# Default scope: "openid email profile".
set -eu

if [[ -z "${GOOGLE_CLIENT_ID:-}" || -z "${GOOGLE_CLIENT_SECRET:-}" ]]; then
  echo "GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET must be set." >&2
  exit 1
fi

scope=${1:-"openid email profile"}
redirect_uri=${GOOGLE_REDIRECT_URI:-"http://localhost:4000/auth/google/callback"}
state=$(uuidgen 2>/dev/null || od -An -N16 -tx1 /dev/urandom | tr -d ' \n')

urlenc() { python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"; }

authorize_url="https://accounts.google.com/o/oauth2/v2/auth?client_id=${GOOGLE_CLIENT_ID}&redirect_uri=$(urlenc "$redirect_uri")&scope=$(urlenc "$scope")&response_type=code&access_type=offline&prompt=consent&state=${state}"

echo
echo "1. Open this URL in your browser and approve the app:"
echo
echo "   $authorize_url"
echo
echo "2. Google will redirect to ${redirect_uri}?code=...&state=${state}"
echo "3. Paste the value of the 'code' query parameter here:"
read -r code

response=$(curl --silent --request POST \
  --data "client_id=${GOOGLE_CLIENT_ID}" \
  --data "client_secret=${GOOGLE_CLIENT_SECRET}" \
  --data "code=${code}" \
  --data "grant_type=authorization_code" \
  --data "redirect_uri=${redirect_uri}" \
  https://oauth2.googleapis.com/token)

echo
echo "Response:"
echo "$response"
