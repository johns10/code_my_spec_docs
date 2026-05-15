# Google OAuth

## Auth Type

oauth2

## Required Credentials

- `GOOGLE_CLIENT_ID` — OAuth 2.0 Client ID. Create at https://console.cloud.google.com/apis/credentials → "Create Credentials" → "OAuth client ID" → "Web application". Add authorized redirect URIs matching the Assent callback path on each host (typically `/auth/google/callback`).
- `GOOGLE_CLIENT_SECRET` — OAuth 2.0 Client Secret. Generated alongside the client ID. Visible in the Cloud Console under the same credential record; download or copy at creation time.

## Verify Script

.code_my_spec/qa/scripts/verify_google.sh

## Token Exchange Script

.code_my_spec/qa/scripts/exchange_google_token.sh

## Status

verified

Verified 2026-05-14 against `envs/dev.env` credentials. `verify_google.sh` POSTed to `oauth2.googleapis.com/token` with a bogus authorization code and got `invalid_grant` back — confirming the client_id/client_secret pair is recognized.

## Notes

Google's token endpoint returns distinct errors for bad client credentials vs. bad authorization codes. The verify script POSTs to `https://oauth2.googleapis.com/token` with a deliberately invalid `code` and inspects the `error` field: `invalid_client` means the client_id/client_secret pair is wrong; `invalid_grant` means the client is valid but the code is (expectedly) bad — that's our success signal.

The token exchange script implements the standard authorization-code flow with a loopback redirect URI (the engineer paste-backs the `code` query param). Refresh tokens are issued only when `access_type=offline` and `prompt=consent` are set; the script includes both.
