# QA Result — Story 858: Agent does my DevOps for me

Session: 2026-07-11, main-thread QA against :4004 (dev build `5a7ee192`).
Canonical record: DB attempt via submit_qa_result (task b8971e0b) + issues.

## Evidence

### Prompt contracts (curl, HTTP requirement-prompt surface)
`GET /api/projects/Code%20My%20Spec/requirements/devops_setup/prompt` → 4,107
bytes; all 15 contract markers verified: Hetzner/AWS/Cloudflare, own accounts,
uat, prod, Parameter Store, fail fast, naming the missing key, /health,
backup, Uptime, idempotent, halt, "which credential failed and which
permission it needs", "without further input".

### Prod opt-out
- Configuration LiveView: form present, **no devops_prod control** → issue
  e642aeef (medium).
- Downstream contract (field set directly): prompt flips to "opted out of the
  second environment: stand up UAT only", done signal "for UAT", no prod
  demanded. Reverted after test.

### Graph placement (real project: Todo test-bed)
`GET /api/projects/Todo/requirements`: code_generation [x] →
qa_integration_plan [x] → **devops_setup [ ]** exactly in position (10/16).
Requirements LiveView renders the node. Detail view shows the evaluator's
reason: "No DevOps setup record at .code_my_spec/devops/setup.md…".

### Deploy in the loop
Todo story 542 listing shows `deploy` — "Story deployed through the loop —
UAT first, health-verified, then prod" — after qa_complete. Listing's
"(actionable)" tag ignores prerequisites (pre-existing) → issue 60bbc1b5
(low). Real gating is edge-aware (next_actionable), verified by spex 538/562/7307.

## Out of scope here
Live infra provisioning (real Hetzner/DNS/TLS/SSM) — exercised by the first
real dogfood run on the todo project.
