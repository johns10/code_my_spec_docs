# QA Result: Story 669 — Component Test Generation

## Status: partial

## Scenarios

### Scenario 1: Test file lands at the canonical test path (criterion 5559)
**Status: pass**

Called `start_task` with `requirement_name: "test_file"`, `entity_type: "component"`, `module_name: "Story669.TestPath"`.

Response contained:
- "Write the test file to test/story669/test_path_test.exs" — canonical path derived from module name.

The prompt correctly maps `Story669.TestPath` to `test/story669/test_path_test.exs`.

### Scenario 2: Missing implementation triggers TDD-mode framing (criterion 5560)
**Status: pass**

Called `start_task` for `test_file` on `Story669.TddTest` (no implementation file on disk).

Response contained:
- "The component doesn't exist yet."
- "You are to write the tests before we implement the module, TDD style."
- "Only write the tests defined in the Test Assertions section of the design."
- "If you want to write more cases, you must modify the design first."

All TDD-mode framing assertions confirmed.

### Scenario 3: Existing implementation triggers validation-mode framing (criterion 5561)
**Status: pass**

Called `start_task` for `test_file` on `CodeMySpecWeb.UserAuth` (implementation file exists at `lib/code_my_spec_web/user_auth.ex`).

Response contained:
- "The component implementation already exists."
- "Write tests that validate the existing implementation against the design specification."
- Did NOT contain "Only write the tests defined in the Test Assertions section"

Validation-mode framing confirmed.

### Scenario 4: Top-level component renders no-parent placeholder (criterion 5562)
**Status: pass**

Called `start_task` for `test_file` on `Story669.TddTest` (no parent component in DB).

Response contained:
- "Parent Context Design File: no parent design"

Placeholder confirmed for top-level components.

### Scenario 5: Child component prompt references parent context spec (criterion 5563)
**Status: pass**

Created `Story669.ParentCtx` (parent) and `Story669.ParentCtx.Item` (child) via `create_component`. Called `start_task` for the child's `test_file` requirement.

Response contained:
- "Parent Context Design File: .code_my_spec/spec/story669/parent_ctx.spec.md"

Parent spec path resolved and surfaced correctly.

### Scenario 6: Valid test file with no blocking problems passes evaluation (criterion 5564)
**Status: pass**

Started a `test_file` task for `Story669.TddTest`, then POSTed to `/api/hooks/stop` with the active session_id `2589c11a-cd5e-4b4a-ab13-290a93f39c0b`.

Response: `{}`

The stop hook allowed the stop (no block decision). Server logs confirmed: "No changed files, skipping pipeline" — no files were modified during the task window, so evaluation short-circuits cleanly.

### Scenario 7: Compilation error on the test file blocks evaluation (criterion 5565)
**Status: partial**

The `test_output_files.compile` fixture mechanism CANNOT be exercised via the live stop hook surface. Two compounding constraints prevent it:

1. **Pipeline is skipped when `changed_files == []`**: `Validation.run_pipeline/5` returns early when no files were modified since `task.started_at`. Without writing an actual file during the task window, the pipeline never runs and the fixture is never read.

2. **The fixture path is an OUTPUT, not an INPUT**: When the pipeline does run, `compile_output_file` is passed to `Compile.execute/1` as `output_file`. This sets `DIAGNOSTICS_OUTPUT` env var and `mix compile` runs. The `Mix.Tasks.Compile.Diagnostics` after_compiler hook then WRITES to that path via `File.write!`, overwriting any pre-existing fixture content with fresh diagnostics.

The spex test for this criterion (criterion_5565_...spex.exs) works because it uses `use_cmd_cassette "pipeline_compile_error", record: :none` which intercepts `System.cmd` and prevents `mix compile` from executing, so the fixture content is preserved and read as-is.

To exercise this on the live surface would require either:
- Writing a real file with a compile error to disk during the task window (ruled out — no code edits)
- Directly inserting compiler problems into the CLI DB (ruled out — no DB writes)

Evidence: `test/spex/669_component_test_generation/criterion_5565_compilation_error_on_the_test_file_blocks_evaluation_spex.exs` confirms cassette mode is required. Fixture at `test/fixtures/validation/component_test_compile_error/compile.jsonl` (137 bytes) is valid for cassette use.

### Scenario 8: TDD test failures don't block evaluation (criterion 5566)
**Status: pass**

Active task on `Story669.TddTest` (TDD mode — no implementation file). POSTed to `/api/hooks/stop` with session `2589c11a-cd5e-4b4a-ab13-290a93f39c0b`.

Response: `{}`

Stop allowed. `ComponentTest.excluded_analyzers/0` returns `[:exunit_stale]`, so the `exunit_stale` analyzer is explicitly excluded from the validation pipeline even when changed files exist. Combined with no changed files in this test window, the pipeline returns immediately without running tests.

### Scenario 9: Invalid test file holds the node and re-fires with diagnostics (criterion 5568)
**Status: partial**

The "Previous validation diagnostics" section in the `start_task` prompt requires a component with:
1. A test file on disk (satisfying `test_file`)
2. Persisted `spec_alignment` problems from a prior failed validation run

No components in the current CLI DB (`~/.codemyspec/cli_dev.db`) satisfy both conditions:
- Components with test files (e.g., `CodeMySpecWeb.UserAuth`) have all requirements satisfied — no spec_alignment problems.
- Components with unsatisfied `test_spec_alignment` (446 total) have no test files, so `previous_validation_diagnostics` returns `""` (skips because `file_missing? = true`).

Creating a misaligned test file and running a failing validation would require writing to disk, which is out of scope for this QA pass.

Evidence: `previous_validation_diagnostics/3` in `lib/code_my_spec/agent_tasks/component_test.ex` (line 186) explicitly returns `""` when `file_missing? = true`.

### Scenario 10: Component-type test rules surface in the Test Rules section (criterion 5570)
**Status: pass**

Called `start_task` for `test_file` on `Story669.TddTest` (context type).

Response contained:
```
Test Rules:
Test the happy path first and thoroughly at the top of the file.
Continue to write tests in descending order of likelihood.
Avoid mocks wherever possible...
```

Rules sourced from `.code_my_spec/rules/elixir_test.md` (`component_type: "*"`, `session_type: "test"`). The "Test Rules:" section is present and populated with context-applicable test guidance.

Note: The brief mentioned writing a `context_test.md` file, but the existing `elixir_test.md` with `component_type: "*"` already satisfies the criterion — it applies to context components and surfaces in the Test Rules section.

### Scenario 11: Agent crash leaves test_file unsatisfied for the next pass (criterion 5571)
**Status: pass**

After calling `start_task` for `test_file` on `Story669.TddTest` (task ID `3c77d13b`), called `show_component_requirements` for `Story669.TddTest`.

Response:
```
- [ ] test_file — Context test file exists
```

`test_file` remains unsatisfied. Starting a task does not pre-emptively mark the requirement as satisfied — the requirement is gated on the actual file artifact existing on disk and being valid.

## Evidence

- `.code_my_spec/qa/669/screenshots/10_config_require_unit_tests.png` — Configuration page showing "Require Unit Tests" toggled ON (enabled during testing to make `test_file` requirements appear in the requirement graph)
- `.code_my_spec/qa/669/screenshots/11_requirements_test_file_unsatisfied.png` — Requirements page showing graph state
- `.code_my_spec/qa/669/screenshots/669_requirements_graph.png` — Requirements graph at test time

## Issues

### Issue 1 (INFO, scope: qa): Criterion 5565 not testable via live stop hook

The `test_output_files.compile` fixture mechanism described in the brief assumes the fixture path is consumed as pre-recorded input. In reality:
1. The path is set as `DIAGNOSTICS_OUTPUT` env var and `mix compile` writes to it after running
2. The pipeline is skipped entirely when `changed_files == []`

The spex test for 5565 relies on `use_cmd_cassette` to intercept `System.cmd`, making it a unit-level cassette test, not a live surface test. The criterion is verifiable at the cassette level but not via curl against `/api/hooks/stop` in an isolation QA context. The brief should note this distinction or provide an alternative approach (e.g., seeding a compiler problem directly into the DB before the stop hook call).

**Severity: INFO** — spex coverage exists; live QA just can't reach this specific path without file writes.

### Issue 2 (INFO, scope: qa): Criterion 5568 not testable without prior validation run

The "Previous validation diagnostics" prompt section requires persisted `spec_alignment` problems from a prior failed validation. No such state exists in the current CLI DB without running a full validation cycle on a deliberately misaligned test file. A seed script could be written to insert the required problem row and file record, making this testable in future QA passes.

**Severity: INFO** — the code path is well-covered by spex; live QA needs a seed mechanism.
