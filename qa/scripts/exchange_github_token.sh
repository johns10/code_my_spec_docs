#!/usr/bin/env bash
# Exchange GitHub OAuth client credentials for a user access token by walking
# the authorization-code flow interactively. There is no headless flow for
# GitHub OAuth Apps — the engineer must approve the app in a browser.
#
# Usage:
#   ./exchange_github_token.sh [scope]
#
# Default scope: "read:user user:email repo".
set -eu

if [[ -z "${GITHUB_CLIENT_ID:-}" || -z "${GITHUB_CLIENT_SECRET:-}" ]]; then
  echo "GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET must be set." >&2
  exit 1
fi

scope=${1:-"read:user user:email repo"}
redirect_uri=${GITHUB_REDIRECT_URI:-"http://localhost:4000/auth/github/callback"}
state=$(uuidgen 2>/dev/null || od -An -N16 -tx1 /dev/urandom | tr -d ' \n')

authorize_url="https://github.com/login/oauth/authorize?client_id=${GITHUB_CLIENT_ID}&redirect_uri=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe=""))' "$redirect_uri")&scope=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe=""))' "$scope")&state=${state}"

echo
echo "1. Open this URL in your browser and approve the app:"
echo
echo "   $authorize_url"
echo
echo "2. GitHub will redirect to ${redirect_uri}?code=...&state=${state}"
echo "3. Paste the value of the 'code' query parameter here:"
read -r code

response=$(curl --silent --request POST \
  --header 'Accept: application/json' \
  --data "client_id=${GITHUB_CLIENT_ID}" \
  --data "client_secret=${GITHUB_CLIENT_SECRET}" \
  --data "code=${code}" \
  --data "redirect_uri=${redirect_uri}" \
  https://github.com/login/oauth/access_token)

echo
echo "Response:"
echo "$response"
