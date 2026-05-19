# Qa Story Brief

Story 597 — Verified third-party integrations

## Tool

MCP tools (`mcp__plugin_codemyspec_local__start_task` and `mcp__plugin_codemyspec_local__evaluate_task`)

The surface for all acceptance criteria is the local MCP server. All scenarios use `start_task` against the `qa_integration_plan` task (criteria 5277–5281, 5287–5288) or `evaluate_task` (criteria 5282–5286). No browser UI is involved.

## Auth

No authentication required. The local MCP server (`mcp__plugin_codemyspec_local__*`) tools handle auth automatically via the session context. The sandbox project is used for all MCP-surface tests.

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) has `local_path` set to `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`.

## Seeds

Run the server seeds to ensure the QA fixture project exists:

```
mix run priv/repo/qa_seeds.exs
```

No additional story-specific seeds are required. The `qa_integration_plan` task is a project-level setup task — test scenarios manipulate files in the sandbox directory directly to set up the various states required.

## What To Test

### Criterion 5277 — Twilio ADR produces integrations directory prompt

- Call `start_task` with `requirement_name: "qa_integration_plan"` and `entity_type: "project"` against the sandbox project (id `11111111-1111-4111-8111-111111111111`)
- Place a Twilio decision record file at `.code_my_spec/decisions/twilio.md` in the sandbox project first
- Expect the returned prompt to contain `.code_my_spec/integrations/`
- Expect the prompt to contain "integration spec" (case insensitive)
- Expect the prompt to reference `priv/knowledge/qa_integration_plan/workflow.md`
- Expect the prompt to contain "Technical Decisions" section header
- Expect the prompt to contain "twilio" (the service name from the ADR)

### Criterion 5278 — No ADRs: prompt points back at technical strategy

- Call `start_task` for `qa_integration_plan` against the sandbox project with NO decision records in `.code_my_spec/decisions/`
- Expect the returned prompt to mention "technical strategy" (case insensitive)
- Expect the prompt to mention "no integrations" (the empty-pipeline escape hatch)

### Criterion 5279 — Prompt names verify-script path and JSON output contract

- Call `start_task` for `qa_integration_plan` with a baseline project
- Expect the returned prompt to contain "verify script" (case insensitive)
- Expect the prompt to reference `priv/knowledge/qa_integration_plan/workflow.md` (where the verify-script path pattern and JSON contracts live)

### Criterion 5280 — OAuth2 integrations: token-exchange script instruction

- Call `start_task` for `qa_integration_plan` with a baseline project
- Expect the returned prompt to reference `priv/knowledge/qa_integration_plan/workflow.md` (where the `exchange_<name>_token.sh` OAuth2 path pattern lives)

### Criterion 5281 — Pending status and verified-on-success promotion

- Call `start_task` for `qa_integration_plan` with a baseline project
- Expect the returned prompt to contain "verified"
- Expect the prompt to reference `priv/knowledge/qa_integration_plan/workflow.md` (where the initial-pending → verified-after-success promotion rule lives)

### Criterion 5282 — Empty pipeline (no specs, no index) passes evaluation

- Call `evaluate_task` for a started `qa_integration_plan` task on a project with NO integration specs and NO integration index
- Expect the response to indicate the task passed (match `passed|completed|satisfied|valid`)
- Expect the response NOT to match `needs work|incomplete`

### Criterion 5283 — Specs exist but index missing yields needs-work with index path

- Place a verified twilio spec at `.code_my_spec/integrations/twilio.md` in the sandbox (with `## Verify Script` section and a verify script on disk)
- Do NOT create `.code_my_spec/integrations.md` (the index)
- Call `evaluate_task` for the `qa_integration_plan` task
- Expect the response to match `needs work|incomplete|missing|invalid`
- Expect the response to name the path `.code_my_spec/integrations.md`

### Criterion 5284 — Spec without Verify Script section yields needs-work naming the spec

- Place a twilio spec at `.code_my_spec/integrations/twilio.md` WITHOUT a `## Verify Script` section
- Create `.code_my_spec/integrations.md` (the index)
- Call `evaluate_task` for the `qa_integration_plan` task
- Expect the response to match `needs work|incomplete|invalid|no verify script`
- Expect the response to name "twilio"

### Criterion 5285 — Verified spec plus index passes evaluation

- Place a fully verified twilio spec (with `## Verify Script` section, a verify script on disk, and "verified" in the content) plus the integration index
- Call `evaluate_task` for the `qa_integration_plan` task
- Expect the response to match `passed|completed|satisfied|valid`
- Expect the response NOT to match `needs work|incomplete`

### Criterion 5286 — Pending spec (no verified status) yields needs-work naming the spec

- Place a twilio spec with `status: pending` (no "verified" text in content), with `## Verify Script` section, a verify script on disk, and the index
- Call `evaluate_task` for the `qa_integration_plan` task
- Expect the response to match `needs work|incomplete|not yet verified|invalid`
- Expect the response to name "twilio"

### Criterion 5287 — Bare project: minimal prompt without optional sections

- Call `start_task` for `qa_integration_plan` on a project with NO integration specs and NO integration index
- Expect the prompt NOT to contain "Existing Integration Specs"
- Expect the prompt NOT to contain "## Existing Index"

### Criterion 5288 — Re-runner: prompt surfaces existing specs and index for update guidance

- Place a verified twilio spec at `.code_my_spec/integrations/twilio.md` AND create `.code_my_spec/integrations.md` (the index) in the sandbox project
- Call `start_task` for `qa_integration_plan`
- Expect the prompt to contain "Existing Integration Specs"
- Expect the prompt to contain "twilio"
- Expect the prompt to contain "## Existing Index"
- Expect the prompt to match `update.*rather than` (case insensitive)

## Result Path

`.code_my_spec/qa/597/result.md`

## Setup Notes

All tests operate against the MCP surface — the `start_task` and `evaluate_task` MCP tools on the local server. These are called directly via `mcp__plugin_codemyspec_local__*` tool calls (not curl).

The sandbox project directory `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` is the test target. Before each scenario group that requires specific file state, the relevant files must be created or removed in that directory.

The `qa_integration_plan` task is a project-level setup task. A task must be started (via `start_task`) before `evaluate_task` can be called. `evaluate_task` requires a `task_id` from `start_task`.

Key paths in the sandbox:
- Decisions dir: `.code_my_spec/decisions/`
- Integrations dir: `.code_my_spec/integrations/`
- Integration index: `.code_my_spec/integrations.md`
- Verify scripts: `.code_my_spec/qa/scripts/verify_<name>.sh`

The spex suite (all 12 criteria) passes cleanly — `mix spex test/spex/597_verified_third-party_integrations/` shows 528 tests, 0 failures. QA verification here is a black-box confirmation that the running MCP server behaves as specified.
