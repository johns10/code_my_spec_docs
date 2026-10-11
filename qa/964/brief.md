# Qa Story Brief

## Tool

web

## Auth

Sign in on THIS copy's app at http://127.0.0.1:60642 (the copy's own
instance, serving this branch — not main's 4000):

1. POST the dev sign-in endpoint (curl, single line):

   `curl -sS -X POST http://127.0.0.1:60642/dev/sign-in -H "Content-Type: application/json" -d '{"email":"qa@codemyspec.local","password":"qa-dev-sign-in"}'`

   It answers `{"email":"qa@codemyspec.local","user_id":14,"sign_in_url":"https://dev.codemyspec.com/users/log-in/<token>"}`.

2. Open `sign_in_url` in the MCP browser with the origin REWRITTEN to this
   copy: `http://127.0.0.1:60642/users/log-in/<token>` — never
   `dev.codemyspec.com`, never the login form, never main's 4000. Lands
   on `/app`. Token is single-use; a fresh POST mints a fresh one.

If sign-in answers `no user with that email and password`, re-run the
seed against the copy's own database (single line):

`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

## Seeds

Base fixture already applied on this copy's database
(`code_my_spec_dev_wc_ad7d67d6`; verified this session):

`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

Entities this story needs (all from the seed/cloned data, verified by
direct psql against the copy's DB — read-only queries only, no psql
writes):

- QA user `qa@codemyspec.local` (id 14), owner of **QA Account**
  (`22222222-2222-4222-8222-222222222222`), member of **Code My Spec**
  account (`0f27281c-...`) alongside the owner `johns10@gmail.com` (id 1).
- **QA Fixture Project** `11111111-1111-4111-8111-111111111111` in QA
  Account, `setup_options = {telemetry,backups,content,domain,email,inbound,storage}`
  (all options on except widget — matches the spex fixture shape).
- Its console credentials page:
  `http://127.0.0.1:60642/app/projects/11111111-1111-4111-8111-111111111111/console/credentials`
- No story-specific seeds: the QA account holds NO real provider
  credentials (no github/cloudflare/resend integration rows for user 14
  beyond openai, which the catalogue does not check; no account-grain
  Hetzner token; no S3 pair in this account) — which is exactly what the
  rejection tests need.

## What To Test

The surface moved since the last brief: the provisioning page is retired
(Step 6 gate 2, e08a2d7c0); credentials now live on the console at
`/app/projects/:id/console/credentials` (ConsoleLive action
:credentials, rendering the same `CredentialsForm`). The prior pass
(96168388, 2026-08-21) verified this story on the old page; this pass
re-verifies on the console, which is the same form component wired to
the same events, plus the two issues resolved since (b1d87f01 cassette
leak, 8ec0bd74 read_database_url).

1. **One sitting covers every credential (7981)** — Open the QA Fixture
   Project's console credentials page. Expect ONE
   `[data-test="credentials-form"]` listing every credential the enabled
   options require: github, hetzner_api_token, hetzner_s3_access_key_id,
   hetzner_s3_secret_access_key, cloudflare_token, resend_token — each
   with `data-credential`, `data-credential-kind`, `data-stored`,
   `data-state`. No second page, no per-provider detour. Screenshot.

2. **A credential is proven by a real call (7983)** — On the QA Fixture
   Project (QA Account holds no real credentials), paste a
   syntactically-plausible but invalid Hetzner API token
   (e.g. `qa964-invalid-token-` + a fresh timestamp) into
   `hetzner_api_token`, click **Save credentials**, then **Check them
   against the providers**. Expect `data-state="rejected"` on that field
   — a real call to Hetzner answered 401/403 — never `verified`. FRESH
   input this run (the prior attempt's garbage token is spent).

3. **An under-scoped token names the permission it lacks (7984)** — The
   live under-scoped Cloudflare case needs an owner-minted read-only
   token; structurally: after the check in scenario 2, the rejection
   must read `Rejected by the provider. Missing: <permission>` naming
   the specific permission (`[data-test="credential-rejection"]`),
   not "token invalid". The real-call rejection from scenario 2 carries
   the same structure — the classify/2 path in
   `lib/code_my_spec/provisioning/credentials.ex` names the permission
   it was checking ("Read & Write on Hetzner Cloud"). Verify by reading
   the rendered rejection text live.

4. **The console-only key pair is asked for with directions (7986)** —
   On the same page, the `hetzner_s3_access_key_id` field's
   `[data-test="credential-directions"]` must name the console path
   ("Object Storage → S3 credentials"), say there is no API for it, and
   warn the secret half is shown once and cannot be read again. The API
   token's directions must name the read-only trap. Screenshot.

5. **The repo stays clean of credential values (7987)** — After saving
   the invalid token in scenario 2 (a value that went through the real
   write path), grep the tracked working tree for that exact literal
   (git grep). Expect zero matches — the value lives in the encrypted
   store, not on disk. Also confirm the saved token never appears in
   any flash/message text (labels only, per the save handler). And
   re-verify the b1d87f01 regression stays closed: sweep the tracked
   tree for credential-shaped values from `envs/` (filenames only, never
   print values); the gitleaks pre-commit hook
   (`.githooks/pre-commit`, `core.hooksPath`) is present.

6. **Credentials follow the project (8050)** — The invalid token saved
   in scenario 2 (account-grain, saved under QA Account) must be visible
   from a second project in the same account: create or reuse a second
   QA-account project, open its console credentials page, and
   `hetzner_api_token` reads `data-stored="true"` — the store followed
   the account, not the browser session. (Cross-machine is the spex's
   in-memory claim; cross-session-per-project is the live observable.)

7. **Another account's credentials are not reachable (8051)** — As the
   QA user, switch to a DIFFERENT account (via `/app/accounts/picker`)
   that has no Hetzner token, open one of its projects' credentials
   page: `hetzner_api_token` reads `data-stored="false"` (or the
   account's own state), and the QA account's token value appears
   nowhere in the page HTML. The isolation claim is cross-account — an
   account-grain credential is deliberately visible to every project in
   its OWN account (confirmed with the owner 2026-08-17; criterion 585's
   moduledoc says the same).

Cleanup after testing: delete the invalid token written in scenario 2
via `ProjectSecrets.delete_value` is NOT reachable from the browser UI —
instead overwrite it by saving a blank? No: the form skips blank fields
("leave blank to keep"). So delete via the console if a delete control
exists on the credentials page; if none, leave the invalid token (it is
QA-account-grain, QA account holds nothing real, and the prior attempt
left exactly this state — the field reading "set" is the documented QA
state, per attempt 0c548d03's own notes). Record what was left.

Expected outcomes: all seven criteria pass on the console surface; the
only writes this run makes are the QA account's own credential rows.

## Result Path

.code_my_spec/qa/964/result.md

## Setup Notes

- Prior pass 96168388 (2026-08-21) was on the now-retired provisioning
  page; the console retarget is the change to re-verify. Issues resolved
  since: b1d87f01 (cassette leak — verify the regression stays closed),
  8ec0bd74 (read_database_url moduledoc — no live surface here).
- The Hetzner API token is **account-grain** (catalogue `grain: :account`):
  writes go to AccountSecrets (account_id-keyed rows in project_secrets),
  reads for the S3 pair stay project-grain. A bad token pasted under the
  QA account overwrites nothing real — QA Account holds no Hetzner token
  (verified by psql this session).
- Never paste test credentials into a project under the **Code My Spec**
  account — that account holds the owner's real Hetzner token
  (account-grain, verified present in the DB).
- `mix spex --only story:964` was attempted this session and timed out
  at 10 minutes (a mix spex run contends on the compile lock while this
  copy's app is serving; the box also carries 232k stale spex temp
  dirs). The story's promote gates run the spex; QA's job is the live
  surface per the plan's "spex are the contract layer, not a QA tool".
- Screenshots go to `.code_my_spec/qa/964/screenshots/` via
  `browser_screenshot` with a bare filename (they land in
  `~/Pictures/Vibium/`), then `cp` into the story dir.
