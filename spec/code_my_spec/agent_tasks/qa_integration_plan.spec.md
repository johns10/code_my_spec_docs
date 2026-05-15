# CodeMySpec.AgentTasks.QaIntegrationPlan

## Type

skill

## Intent

Identify third-party integrations from the project's technical
decisions and produce: one integration spec per service, a runnable
verify script per integration, an OAuth2 token-exchange script where
applicable, and an integration index summarizing everything.

The status of each spec moves from `pending` → `verified` only after
its verify script runs against real credentials and returns
`"status": "ok"`. Credential collection is human-bound — the engineer
provides values; the agent runs the verify scripts.

## Done signal

`Requirements.QaIntegrationPlanChecker` (implicit via this task's
`evaluate/2` state machine) returns valid when either:

- No integration specs exist (no integrations needed).
- OR all of: `.code_my_spec/integrations/index.md` exists with
  content; every spec under `.code_my_spec/integrations/*.md` has a
  verify script on disk at the path referenced in its
  `## Verify Script` section; every spec contains the word
  "verified" (case-insensitive).

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `qa_integration_plan` (id 4), gated by `code_generation`
(id 3). Manual validation — the engineer-in-the-loop nature
(credential gathering) doesn't fit auto-evaluation.

## Out of scope

- The task does not generate the integration code in the app. That's
  `code_generation`'s `cms_gen.integrations` /
  `cms_gen.integration_provider` step.
- The task does not test the integration end-to-end through the
  running app. That's downstream (e.g. story-level QA).
- The task does not invent integrations the ADRs don't reference.
  If a decision doesn't say "use Service X", don't plan an integration
  for X.

## Failure modes the agent should avoid

- Marking specs `verified` without running the verify script.
- Hardcoding credentials in verify scripts — env vars only.
- Writing a verify script that doesn't actually call the service
  (e.g. one that just echoes "ok").
- Skipping the integration index even when all specs are verified.
- Drafting specs for services the ADRs don't reference.

## Resources

Required input:
- ADRs at `.code_my_spec/architecture/decisions/*.md` — the source
  of integration requirements.
- The `integration_spec` document type — projected via
  `DocumentSpecProjector.project_spec("integration_spec")` and
  embedded in the prompt.

Optional input:
- Existing integration specs at `.code_my_spec/integrations/*.md`
  — for idempotent reruns (preserve content, update status).
- Existing integration index at `.code_my_spec/integrations/index.md`.
- Engineer-provided credentials (env vars).

Required reading:
- `priv/knowledge/qa_integration_plan/workflow.md` — full six-step
  procedure (identify → draft → verify-script → request → verify →
  index), JSON-output contract for verify scripts, OAuth2 specifics.

Produced:
- `.code_my_spec/integrations/<name>.md` — one per integration.
- `.code_my_spec/qa/scripts/verify_<name>.sh` — per integration,
  executable.
- `.code_my_spec/qa/scripts/exchange_<name>_token.sh` — per OAuth2
  integration, executable.
- `.code_my_spec/integrations/index.md` — summary of every
  integration and its status.

## Tools

No task-specific MCP tools. Built-ins (Read, Write, Bash for
`chmod +x` and running verify scripts) handle the work. The agent
also drives the human credential-collection conversation in chat.

## Dependencies

- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Paths
