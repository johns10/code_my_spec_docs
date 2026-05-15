# GitHub OAuth

## Auth Type

oauth2

## Required Credentials

- `GITHUB_CLIENT_ID` — Client ID for either a GitHub App or an OAuth App. The current `envs/dev.env` value is a GitHub App (client_id prefix `Ov23…`). Manage at https://github.com/settings/apps (GitHub Apps) or https://github.com/settings/developers (OAuth Apps). The user-authorization callback URL must match the redirect URI Assent is wired to use (typically `/auth/github/callback` on each environment host).
- `GITHUB_CLIENT_SECRET` — Client secret for the same app. Shown once at creation; regenerate from the app settings if lost. For GitHub Apps the secret is paired with a private key (`.pem`) used for JWT-signed app-to-server calls; the OAuth flow used here needs only the client_id/secret pair.

## Verify Script

.code_my_spec/qa/scripts/verify_github.sh

## Token Exchange Script

.code_my_spec/qa/scripts/exchange_github_token.sh

## Status

verified

Verified 2026-05-14 against `envs/dev.env` credentials. `verify_github.sh` POSTed to `github.com/login/oauth/access_token` with a bogus code and got `bad_verification_code` back — confirming the client_id/client_secret pair is recognized.

## Notes

The verify script proves the client_id/client_secret pair is recognized by GitHub by attempting an authorization-code exchange with a deliberately invalid code at `https://github.com/login/oauth/access_token`. The endpoint accepts credentials from both OAuth Apps and GitHub Apps, so the script works regardless of which app type is configured. Success = `error=bad_verification_code` (creds OK, code bad); failure = `error=incorrect_client_credentials`.

An earlier version used `/applications/{client_id}/token`, but that endpoint is OAuth-Apps-only and returns 404 for GitHub App client IDs.

User-scoped access tokens (used by the GitHub API via `oapi_github`) require an interactive authorization-code flow. The token exchange script captures the manual round trip: it prints the authorize URL, waits for the engineer to paste the returned `code`, then exchanges it for an access token.
