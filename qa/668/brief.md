# Qa Story Brief

Story 668 — Plan QA infrastructure for every surface of the app.

This story is meta: the artifact under test is `.code_my_spec/qa/plan.md` and the
`AgentTasks.QaSetup` module that produces and validates it. All criteria exercise
either the `start_task` prompt (which routes the agent to `priv/knowledge/qa_setup/workflow.md`)
or the `evaluate_task` path (which validates the plan against the `qa_plan` doc spec).

Testing is done via `mix spex` (the BDD test suite) plus targeted `iex` inspection of
the source modules. No browser testing is required — the acceptance criteria are
about prompt content and evaluate behavior, not UI.

## Tool

mix spex (Elixir BDD test runner) for criterion validation. Direct source inspection
for structural checks.

## Auth

No auth required. These are unit/integration tests running against the test database
via `mix spex`. The shared given `:qa_setup_task_started` drives session-start + start_task
via `StartTask.execute/2` internally; no manual credentials needed.

## Seeds

No seed scripts needed. The spex tests use `register_log_in_setup_account` and
`setup_active_project` setup hooks that create isolated test fixtures per test run.

## What To Test

### Criterion 5480 — Probe section references qa_setup workflow playbook

- Run `mix spex` for the story 668 directory.
- Assert criterion 5480 passes: the `start_task` prompt for `qa_setup` references
  `priv/knowledge/qa_setup/workflow.md` (which contains all five discovery steps).
- Verify the playbook file exists and contains all five probe steps (lsof, curl per port,
  browser_map for auth, Ecto.Repo grep, Vibium screenshot dir verification).

### Criterion 5481 — MCP 202 Accepted behavior is flagged in the probe instructions

- Assert criterion 5481 passes: the prompt references `priv/knowledge/qa_setup/workflow.md`,
  which covers the Anubis Streamable HTTP "202 Accepted on tools/call" behavior.
- Verify `priv/knowledge/qa_setup/workflow.md` contains the 202 Accepted warning text.

### Criterion 5482 — Valid plan validates clean

- Assert criterion 5482 passes: `evaluate_task` on a task with a plan containing
  non-empty App Overview, Tools Registry, and Seed Strategy returns a passing response
  (matches `/passed|task completed/i`).

### Criterion 5483 — Missing Tools Registry section gives friendly feedback

- Assert criterion 5483 passes: `evaluate_task` with a plan missing Tools Registry
  returns `needs work`, names `` `## Tools Registry` `` in backtick form, and includes
  "QA Plan Format" for self-correction.
- Confirm `translate_error/1` in `QaSetup` produces the backtick-formatted section name.

### Criterion 5484 — Bare H2 headers with empty bodies are rejected

- Assert criterion 5484 passes: `evaluate_task` with a plan that has all three required
  H2 headers but empty bodies returns `needs work` (not `passed`).
- This exercises `Documents.validate_section_bodies/2` which checks for `String.trim(value) == ""`.

### Criterion 5485 — Existing plan triggers update-rather-than-rewrite mode

- Assert criterion 5485 passes: when a plan, `priv/repo/qa_seeds.exs`, and
  `.code_my_spec/qa/scripts/authenticated_curl.sh` exist in the environment,
  the `start_task` prompt matches `/(update|patch) rather than rewrite/i` and
  instructs the agent to `preserve\s+working\s+scripts`.
- Verify the Inventory section lists both the seed script and the helper script.

### Criterion 5486 — No existing plan omits Existing Plan section

- Assert criterion 5486 passes: with no plan on disk, the `start_task` prompt
  does not contain `## Existing Plan` or `update rather than rewrite` instructions.

### Plan validation against current plan.md

- Run `Documents.create_dynamic_document/2` against the actual `.code_my_spec/qa/plan.md`
  to confirm it validates clean against the `qa_plan` doc spec.
- Verify the plan has non-empty content under App Overview, Tools Registry, and Seed Strategy.
- Verify the plan covers all five surfaces listed in the acceptance criteria:
  hosted UI, hosted API, hosted MCP, local UI, local hooks, local MCP.

## Result Path

`.code_my_spec/qa/668/result.md`
