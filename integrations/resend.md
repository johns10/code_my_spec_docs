# Resend Transactional Email

## Auth Type

api_token

## Required Credentials

- `RESEND_API_KEY` — Resend API key. Create at https://resend.com/api-keys → "Create API Key". Choose "Full access" for production keys or "Sending access" for restricted send-only keys. The full key is shown once at creation — copy immediately.

## Verify Script

.code_my_spec/qa/scripts/verify_resend.sh

## Status

verified

Verified 2026-05-14 against `envs/dev.env` credentials. `verify_resend.sh` got a `200 OK` from `GET https://api.resend.com/domains` — confirming the API key is accepted.

## Notes

The verify script calls `GET https://api.resend.com/domains` with `Authorization: Bearer $RESEND_API_KEY`. A 200 response (even with an empty `data` array for a brand-new account) proves the key is valid and has at least sending-access scope. A 401 means the key is wrong or revoked.

Email delivery itself is gated by domain verification in the Resend dashboard. The verify script does not confirm a verified sending domain — that's a separate operational step done in the Resend UI before the first production email.
