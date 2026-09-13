# Test plan — cloud-plan customers stop seeing self-hosted provisioning as required

Ad-hoc fix, not tied to a story's `qa_complete` task. Follows from the
onboarding smoke test's finding (issue `ac7a510b`'s split-off provisioning
half) and the approved plan at
`.claude/plans/virtual-juggling-dawn.md` in the main repo.

## What changed

`ProvisioningLive` (routes `/app/projects/:id/provisioning[/credentials|/environments|/secrets]`)
and the sidebar "Provisioning" nav link now branch on
`scope.active_account.plan`. A managed-cloud account (any plan other than
`:free`) sees a short "your cloud plan handles this for you" message instead
of the GitHub/Hetzner/Cloudflare/Resend credential checklist. A `:free`-plan
(self-hosted) account sees the page exactly as before — unchanged behavior.

Deliberately NOT changed: `Credentials.required/1`, `Provisioning.setup_options/1`,
`Workspaces.*`, `PreviewAddress`, `PreviewTunnel`, `CodeMySpec.Host`. This is a
page/nav-level gate, not a change to what self-hosted provisioning itself
requires.

## Tool

web

## Auth

Two accounts needed, one on each side of the branch:

- A `:free`-plan account (the default for a freshly registered user with no
  Stripe subscription) — sign up normally via `/users/register` or the
  guided-intake local path (never pay).
- A paid-plan account — either complete a real Stripe test-mode payment via
  the guided-intake cloud path (card `4242 4242 4242 4242`, any future
  expiry, any CVC), or check whether a seed/fixture account with
  `plan: :light` or `:pro` already exists via `mix run priv/repo/qa_seeds.exs`
  before creating a new one by hand.

## Seeds

None required beyond the two accounts above.

## What To Test

- **Free-plan account, nav**: sidebar shows "Provisioning" as today; clicking
  it lands on the credential checklist ("Still needed: ...") unchanged.
- **Free-plan account, direct URL**: visiting `/app/projects/:id/provisioning`,
  `/provisioning/credentials`, `/provisioning/environments`, and
  `/provisioning/secrets` directly all show the same unchanged page for each
  live_action.
- **Paid-plan account, nav**: sidebar either hides "Provisioning" or it no
  longer reads as a required/red item (per whichever the implementation
  picks — check the actual committed diff for which).
- **Paid-plan account, direct URL**: visiting any of the four provisioning
  routes directly shows the new explanatory message ("your cloud plan
  handles this for you" or equivalent) and a working link back to the
  project's agent conversation — NOT the credential checklist.
- **Regression**: `/app/projects/:id/setup` (ProjectSetupLive — a different
  LiveView, NOT in scope for this change) is unaffected on both plan types.
- **Regression**: a free-plan account's existing provisioning flow (adding a
  credential, running a step) still works end-to-end — this fix must not
  break the self-hosted path it deliberately leaves alone.

## Result Path

File findings via `create_issue` as discovered (scope: app, story 1033 unless
a finding is clearly unrelated). No `qa_complete` task_id applies to this
ad-hoc check — note results directly to the user/session rather than via
`submit_qa_result`.

## Setup Notes

This is a narrow, low-risk UI/nav gate on top of an already-shipped, already
-verified paid onboarding flow (workspace boot + agent start + preview URL
all confirmed working in the prior smoke test round). The main regression
risk is scope creep into `Credentials.required/1`/`Provisioning.setup_options/1`
themselves, which must stay untouched — a self-hosted (free-plan) customer's
provisioning experience should be byte-for-byte identical to before this
change.
