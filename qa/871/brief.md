# QA Brief — Story 871: My repository exists before anything needs to push

## Tool

web

## Auth

Log in as the owner. The GitHub grant is a per-user OAuth integration and only
his account holds one, so no other user can drive the repository step.

1. `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `johns10@gmail.com`
3. Click the submit button, `form button.btn-secondary` ("Email me a login link")
4. `http://127.0.0.1:4000/dev/mailbox` — the mailbox is shared, so confirm the
   message is addressed to that user before opening it
5. The link is issued for `dev.codemyspec.com`; swap the host to `127.0.0.1:4000`

If the email field renders `readonly`, a session is already open — log out via
the `a[href="/users/log-out"]` link (`data-method="delete"`, so navigating to
the URL does nothing), then start again.

The active account resets on a server restart. Re-pick at
`/app/accounts/picker`; entries are `a[phx-value-account-id=...]`. Code My Spec
is `0f27281c-240b-4d6d-8e52-9c5972329522`.

## Seeds

No story-specific seeding.

- QA Fixture Project: `11111111-1111-4111-8111-111111111111`
- Provisioning page: `http://127.0.0.1:4000/app/projects/<project_id>/provisioning`
- The fixture project's repository step is currently `errored`, against the real
  repository `johns10/qa-fixture-project`, with a rejected push. That state is a
  live specimen for two criteria rather than something to clear — read Setup
  Notes before touching it.

## What To Test

- **One repository, carrying the project's docs (8178).** After the step
  succeeds there should be exactly one repository recorded, and it should carry
  the project's docs rather than being empty.
- **An existing repository is adopted rather than duplicated (8179).** Re-run
  the step against a project whose repository already exists. Expect one
  resource, `origin: "adopted"`, and no second repository created at GitHub.
- **The repository belongs to Sam, not to the platform (8180).** The recorded
  location should be under his own account or an org he controls — check at
  GitHub, not only in our rows.
- **A revoked GitHub connection stops the step rather than falling back
  (8181).** With no usable GitHub credential the step must halt and say so, not
  quietly proceed by some other route.
- **The remote is in place before the first build needs it (8182).** repository
  is first in the sequence; confirm nothing that pushes runs ahead of it.
- **The step is proven by a push, not by the repository existing (8183).** A
  repository that exists is not sufficient — the step's own success must depend
  on a push landing.
- **A repository that exists but rejects the push is not done (8184).** The
  fixture project is sitting in exactly this state. Confirm the step reports
  `errored`, not `done`, and that the message names the rejection rather than a
  generic failure.
- **A colliding name is named, and Sam chooses (8185).** When the intended name
  is taken, the collision should be surfaced with a choice, not resolved
  silently — `912bce2e` was filed when the step completed on a taken name and is
  since resolved, so this is the regression check for it.

## Setup Notes

**Do not clear the errored repository step before testing 8184.** It reads:

    The repository exists but the push was rejected — it is not usable as a
    remote yet. git exited 1: ! [rejected] main -> main (fetch first)

against the real `johns10/qa-fixture-project`. That is 8184's subject occurring
in the wild, and it is worth reading as evidence before deciding whether it is a
defect or fixture residue. `johns10/qa-fixture-project` has diverged from the
local working copy, which is an ordinary reason for a rejected push and not
necessarily a product fault.

**This story is cheap.** It touches GitHub only — no Hetzner, no Cloudflare, so
nothing to provision and nothing to tear down. Do not create servers for it.

**Both prior issues are closed.** `912bce2e` (the step completing on a taken
name) was resolved earlier. `b450f46a` (a 500 on repo creation in
`codemy-my-spec-test`) is resolved as overtaken: `ed36f600` moved all eight
criteria onto the GitHub fake, so no credential is resolved and no account is
touched. Its diagnosis was right and is worth keeping — `GITHUB_CLIENT_ID`
begins `Ov23li`, which is a GitHub **App**, and an App not installed on the org
with `Administration: write` is exactly that badly-surfaced 500. If anything
ever drives real GitHub from a spex again, that is the first thing to check.

**The spex are not the QA.** `mix spex --pattern "test/spex/985_*/*_spex.exs"`
passes 8/8 in 1.2 seconds against fakes, which proves the contract, not the
product. Drive the real page.

## Result Path

`.code_my_spec/qa/871/result.md`
