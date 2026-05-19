# QA Brief: Story 669 — Component Test Generation

## Tool

MCP tools (`mcp__plugin_codemyspec_local__start_task`, `mcp__plugin_codemyspec_local__evaluate_task`, `mcp__plugin_codemyspec_local__list_requirements`) for the agent-surface scenarios; `curl` for the stop hook (`POST /api/hooks/stop`) and session-start hook (`POST /api/hooks/session-start`).

## Auth

Local endpoint (port 4004) — no auth required. `LocalOnly` plug accepts loopback connections directly.

For hook endpoints, include the working-dir header:
```
-H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox"
-H "Content-Type: application/json"
```

For MCP tool calls, use `mcp__plugin_codemyspec_local__*` tools which handle the SSE channel automatically.

## Seeds

Run Postgres QA seeds to ensure project and user exist:
```
mix run priv/repo/qa_seeds.exs
```

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) is set up with `local_path` pointing at the sandbox:
```
/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
```

MCP tool calls that mutate state must target the sandbox, not the working CodeMySpec checkout.

## What To Test

### Scenario 1: Test file lands at the canonical test path (criterion 5559)
- Call `mcp__plugin_codemyspec_local__start_task` with `requirement_name: "test_file"`, `entity_type: "component"`, for a context-typed component with module name `Story669.TestPath`
- Assert the returned prompt contains "Write the test file to"
- Assert the returned prompt contains "test/story669/test_path_test.exs" (canonical path derived from module name)

### Scenario 2: Missing implementation triggers TDD-mode framing (criterion 5560)
- Call `start_task` for `test_file` on a component with no implementation file on disk
- Assert the prompt contains "doesn't exist yet"
- Assert the prompt contains "TDD"
- Assert the prompt references "Test Assertions section"
- Assert the prompt instructs agent to "modify the design" if more cases are wanted

### Scenario 3: Existing implementation triggers validation-mode framing (criterion 5561)
- Use a synced context component (spec + impl files both on disk and indexed)
- Call `start_task` for `test_file`
- Assert the prompt contains "implementation already exists"
- Assert the prompt matches `~r/validate.*against the.*design/i`
- Assert the prompt does NOT contain "Only write the tests defined in the Test Assertions section"

### Scenario 4: Top-level component renders no-parent placeholder (criterion 5562)
- Call `start_task` for `test_file` on a top-level component with no parent
- Assert the prompt contains "Parent Context Design File: no parent design"

### Scenario 5: Child component prompt references parent context spec (criterion 5563)
- Create a parent context component (module `Story669.ParentCtx`) and a child module component (module `Story669.ParentCtx.Item`) linked to the parent
- Call `start_task` for the child's `test_file` requirement
- Assert the prompt contains "Parent Context Design File: .code_my_spec/spec/story669/parent_ctx.spec.md"

### Scenario 6: Valid test file with no blocking problems passes evaluation (criterion 5564)
- Start a `test_file` task for a synced context component
- POST `/api/hooks/stop` with valid test output (no compile errors, no credo failures, passing tests)
- Assert the response is `{}` (stop allowed)

### Scenario 7: Compilation error on the test file blocks evaluation (criterion 5565)
- Start a `test_file` task for a synced context component
- POST `/api/hooks/stop` with a compile-error fixture
- Assert the response contains `"decision": "block"`
- Assert the reason mentions "compil" and the test file path

### Scenario 8: TDD test failures don't block evaluation (criterion 5566)
- Start a `test_file` task (no impl file on disk = TDD mode)
- POST `/api/hooks/stop` — pipeline must NOT run `mix test --stale`
- Assert the response is `{}` (stop allowed despite would-be failing tests)

### Scenario 9: Invalid test file holds the node and re-fires with diagnostics (criterion 5568)
- Create a synced context component with a misaligned test file (file exists but does not match spec's Test Assertions)
- Call `start_task` for `test_spec_alignment` requirement on the component
- Assert the prompt contains "Previous validation diagnostics"
- Assert the prompt references the test file path

### Scenario 10: Component-type test rules surface in the Test Rules section (criterion 5570)
- Write a rule file at `.code_my_spec/rules/context_test.md` with `component_type: "context"` and `session_type: "test"` frontmatter
- Call `start_task` for `test_file` on a context-type component
- Assert the prompt contains "Test Rules:"
- Assert the prompt includes the rule's content

### Scenario 11: Agent crash leaves test_file unsatisfied for the next pass (criterion 5571)
- Call `start_task` for `test_file` on a context component with no test file on disk
- Without writing any file, call `mcp__plugin_codemyspec_local__list_requirements`
- Assert `test_file` remains unsatisfied (unchecked `[ ]`) in the response

## Setup Notes

All BDD scenarios use the `start_task` MCP tool as their agent surface — this is not a LiveView story. The stop hook (`POST /api/hooks/stop`) is the secondary surface for evaluation scenarios (5564, 5565, 5566).

The spex files use internal `StartTask.execute/2` calls against a test scope, but for QA we drive the same tool via `mcp__plugin_codemyspec_local__start_task`. MCP tool calls automatically resolve scope from the `X-Working-Dir`/session context maintained by the running server.

For stop hook scenarios (6, 7, 8), the hook requires an active task created by a prior `start_task` call and fixture JSONL files for compile/exunit output. Check `test/fixtures/validation/` for the relevant fixture directories referenced in the spex files.

## Result Path

`.code_my_spec/qa/669/result.md`
