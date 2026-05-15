# Third-Party Integrations

Identified from `.code_my_spec/architecture/decisions/`. Each row links to the
per-integration spec and tracks verification status.

| Integration | Auth     | Spec                              | Verify Script                                            | Status  |
|-------------|----------|-----------------------------------|----------------------------------------------------------|---------|
| github      | oauth2   | [github.md](integrations/github.md) | `.code_my_spec/qa/scripts/verify_github.sh`              | verified |
| google      | oauth2   | [google.md](integrations/google.md) | `.code_my_spec/qa/scripts/verify_google.sh`              | verified |
| resend      | api_token| [resend.md](integrations/resend.md) | `.code_my_spec/qa/scripts/verify_resend.sh`              | verified |

## Out of scope

The following ADRs were reviewed but produce no integration spec:

- **Web Push (`web-push.md`)** — Uses self-generated VAPID keys (asymmetric keypair owned by this project). No third-party credential to verify.
- **Hetzner Deployment (`hetzner-deployment.md`)** — Deployment-time infrastructure. The Hetzner Cloud API is not consumed at application runtime per the current ADR.
- **All "pre-made" stack ADRs without external services** — Elixir, Phoenix, LiveView, Tailwind, DaisyUI, Bandit, Ecto SQLite3, Dotenvy, ExVCR, Wallaby, MDEx, Oban, Cloak Ecto, PaperTrail, Boundary, BDD testing, phx.gen.auth — local libraries; no third-party credentials.

## Next step

Provide the credentials listed in each spec, then run each `verify_*.sh` script. Each must print `"status":"ok"` before the integration's row can move to `verified`.
