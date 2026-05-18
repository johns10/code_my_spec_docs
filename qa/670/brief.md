# Qa Story Brief

Story 670 — Component Code Generation. Tests the agent task module
`CodeMySpec.AgentTasks.ComponentCode` which drives the full codegen loop:
prompt generation, requirement evaluation, problem persistence, and
orchestration output. All 13 criteria are exercised via the MCP agent
surface (`start_task`, stop hook) rather than the browser.

## Tool

mix (spex test runner) — all criteria test the MCP/hook surface, not LiveView pages

## Auth

No browser auth required. All scenarios drive the local hook API at port 4003
with the `X-Working-Dir` header resolved from the test's own scope. The spex
test suite handles auth setup internally via `register_log_in_setup_account` and
`setup_active_project` shared givens.

For the seed step below, the QA fixture seeds use `MIX_ENV=dev` (Postgres).

## Seeds

Run the server-side QA fixture seed to ensure the QA user and project exist:

```
mix run priv/repo/qa_seeds.exs
```

No story-specific seed data is required beyond the base seeds — the spex
scenarios create their own isolated components in temporary environments via
`Briefly.create` + `Fixtures` helpers.

## What To Test

All 13 criteria are covered by the BDD spex suite. The primary test method is:

```
mix spex test/spex/670_component_code_generation/
```

This exercises each criterion end-to-end through the real application surface.

### Scenario 1 — Prompt content: artifact paths and project anchor (criterion 5582)

- Call `start_task` for the `implementation_file` requirement on a synced context component
- Assert prompt contains: spec file path, code file path, test file path, project name, component name, component type

### Scenario 2 — Prompt fallback for nil description (criterion 5583)

- Sync a component from a spec file that has no description prose (no paragraph after `## Type`)
- Call `start_task` for `implementation_file`
- Assert prompt contains `"No description provided"` rather than a blank or missing description line

### Scenario 3 — Rule filtering by component type and session type (criterion 5584)

- Plant three rule files: `context+code` (matching), `liveview+code` (wrong type), `context+test` (wrong session)
- Call `start_task` for `implementation_file` on a context component
- Assert only the `context+code` rule body appears; the other two are absent

### Scenario 4 — Empty rules section when no rules match (criterion 5585)

- Plant only non-matching rules: `liveview+code` and `context+test`
- Call `start_task` for `implementation_file` on a context component
- Assert neither rule body appears in the prompt

### Scenario 5 — Clean evaluation passes (criterion 5586)

- Synced context component with impl file on disk
- Stop hook fires with a clean pipeline run fixture (compile clean, exunit all-pass)
- Assert stop response is `{}` (allowed)

### Scenario 6 — Unsatisfied requirement blocks with feedback (criterion 5587)

- Sync component from spec only — no implementation file on disk
- Stop hook fires with a clean pipeline run
- Assert `decision == "block"`, reason contains `"Requirement not met:"` and the expected impl file path

### Scenario 7 — Code file compile error blocks (criterion 5588)

- Synced component, impl on disk; agent writes a malformed code file during the task
- Stop hook fires with compile-error fixture
- Assert `decision == "block"`, reason matches `~r/compil|syntax/i` and references the code file path

### Scenario 8 — Test file compile error blocks (criterion 5589)

- Synced component, impl on disk; agent writes a malformed test file during the task
- Stop hook fires with compile-error fixture targeting the test file
- Assert `decision == "block"`, reason matches `~r/compil|terminator/i` and references the test file path

### Scenario 9 — Analyzer-written problem surfaces in evaluation (criterion 5590)

- `start_task` fires with a clean component; agent then writes malformed code
- Stop hook fires — analyzer persists a problem; `evaluate/2` reloads and reads it
- Assert `decision == "block"` with the code file referenced in the reason

### Scenario 10 — Stale in-memory state never gates evaluation (criterion 5591)

- `start_task` fires with a clean component (no problems); agent then writes malformed test file
- Stop hook fires — analyzer persists a test-file problem; evaluator must reload, not use stale snapshot
- Assert `decision == "block"` with the test file referenced in the reason

### Scenario 11 — Orchestrate prompt names requirement and entity (criterion 5592)

- Synced context component in a satisfied project; then impl file removed and design review written; re-sync
- `get_next_requirement` called
- Assert response contains `@code-writer`, `start_task`, `implementation_file`, component ID, and component name

### Scenario 12 — Passing test suite allows stop (criterion 5594)

- Active `implementation_file` task; stop hook fires with clean pipeline (compile + exunit all-pass)
- Assert stop response is `{}` (allowed)

### Scenario 13 — Failing test suite blocks (criterion 5595)

- Project configured with `exunit: block_all`; agent edits impl file; stop hook fires with exunit failure fixture
- Assert `decision == "block"`, reason references the failing test file

## Setup Notes

The scenarios in criteria 5586–5595 use `ExCliVcr` cassettes for the compile
and exunit command outputs. Cassettes are pre-recorded under
`test/fixtures/validation/`. The `record: :none` mode means no live `mix
compile` or `mix test` commands are run — the fixture JSON/JSONL is replayed
deterministically.

The sandbox project at
`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` is
not needed for these criteria since all MCP surface mutations happen inside the
spex's isolated temporary environments, not against the live working project.

## Result Path

`.code_my_spec/qa/670/result.md`
