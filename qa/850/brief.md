# Qa Story Brief

Story 850 — My provider credentials go in once and get checked.

Second pass. The first (attempt `3210d3df`, 2026-08-03) came back **partial** on
three criteria and filed two real issues, both since **resolved**: `06883742`
(the panel not re-rendering when an option is toggled) and `51255335` (the spex
driving a `/credentials` route that does not exist). This pass re-tests what
those issues broke, closes the one criterion that was never exercised, and
re-confirms the six that passed.

## Tool

web

## Auth

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]` with
   `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → open the **newest message addressed to
   that address specifically**. The mailbox is shared across QA users, so the
   newest message overall may log you in as somebody else.
3. Follow the link.

## Seeds

Base seeds only — do not re-run them with the server up (the compile lock 500s
the app under test):

```
mix run priv/repo/qa_seeds.exs
```

Read seed state while the server runs with:

```
psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"
```

Story-specific state: two projects, one with real Hetzner credentials stored and
one without, and the harness serving **two working copies** of this repo
(`devops-qa` and `phx-new-generator`) — `curl -sS localhost:4004/health` lists
them. Both resolve the same project, which is what 8050 needs.

## What To Test

- **7982 — an option turned off does not ask for its credential.** On the
  provisioning page, untick every option that uses object storage (storage,
  backups, content, widget) and read the credential panel **without reloading**.
  The two `hetzner_s3_*` fields must disappear as the options change. This is
  the exact defect `06883742` fixed; before it, the panel was correct only
  after a reload.
- **8050 — credentials follow the project, wherever the agent runs.** The prior
  pass could not exercise this from a single working copy. Resolve the same
  project through each of the two harness ids on `:4004` and confirm both see
  the same stored credentials, and that nothing credential-shaped lives in
  either working copy.
- **7981** — one panel lists every credential the enabled options need.
- **7983** — paste a syntactically valid but wrong Hetzner token; the field must
  reach `data-state="rejected"` with the provider's own message.
- **7985** — on a project missing Hetzner credentials, the gate names what is
  still needed and `[data-test='start-setup']` provisions nothing when clicked.
- **7986** — the `hetzner_s3_*` fields carry console directions.
- **7987** — grep the working copy for the stored values; they must appear
  nowhere outside `.git`.
- **8051** — a second project's page does not show the first project's stored
  credentials.

## Setup Notes

**7984 (an under-scoped token names the permission it lacks) is accepted as
structurally verified**, on the owner's decision of 2026-08-17. Proving it
needs a genuinely read-only Hetzner token, which only the account owner can
mint; the rejection *message* was demonstrated in the first pass by an invalid
token, and the code path that produces it is the same one. What remains
unproven is that Hetzner answers a read-only token the way the page says it
will.

No provisioning happens in this story — it is the credential gate, before
anything is built. Nothing here creates or destroys real resources.

## Result Path

Findings are filed with `create_issue` as they are found, and the session ends
with `submit_qa_result`. Screenshots go in `.code_my_spec/qa/850/screenshots/`.
