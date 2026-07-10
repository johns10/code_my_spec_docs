# Qa Story Brief

## Tool

MCP tools (`mcp__plugin_codemyspec_local__start_task`, `mcp__plugin_codemyspec_local__show_component_requirements`) for the agent-surface scenarios; `curl` for the stop hook (`POST /api/hooks/stop`).

## Auth

Local endpoint (port 4004) — no auth required. `LocalOnly` plug accepts loopback connections directly.

For hook endpoints:
```
-H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec"
-H "Content-Type: application/json"
```

## Seeds

No additional seeds — testing uses `start_task` MCP tool calls with `module_name` to specify the component target. Existing live project components (e.g. `CodeMySpecWeb.UserAuth`) are used for validation-mode scenarios.

## What To Test

- **5559 canonical path**: Call `start_task` for `test_file` on `module_name: "Story669.TestPath"` — assert prompt contains "Write the test file to" and "test/story669/test_path_test.exs"
- **5560 TDD mode**: Call `start_task` for `test_file` on `module_name: "Story669.TddTest"` (no impl file on disk) — assert prompt contains "doesn't exist yet", "TDD", "Test Assertions section", and "modify the design"
- **5561 validation mode**: Call `start_task` for `test_file` on `module_name: "CodeMySpecWeb.UserAuth"` (impl exists at `lib/code_my_spec_web/user_auth.ex`) — assert prompt contains "implementation already exists" and validates-against-design framing; does NOT contain TDD-only section
- **5562 top-level placeholder**: Call `start_task` for `test_file` on `module_name: "Story669.TddTest"` — assert prompt contains "Parent Context Design File: no parent design"
- **5563 child references parent**: Call `start_task` for `test_file` on `module_name: "Story669.ParentCtx.Item"` — assert prompt contains "Parent Context Design File: .code_my_spec/spec/story669/parent_ctx.spec.md"
- **5564 valid test passes evaluation**: POST `/api/hooks/stop` with no test_output_files for an active test_file task — assert response is `{}`
- **5565 compile error blocks**: NOT testable via live stop hook surface. The compilation pipeline is skipped when `changed_files == []` (pipeline short-circuits before reading any fixture). The spex test uses `use_cmd_cassette` to intercept `System.cmd` — this is a cassette-level test, not a live surface test. Document only.
- **5566 TDD failures don't block**: POST `/api/hooks/stop` in TDD mode (no impl) — assert response is `{}` (exunit_stale excluded from ComponentTest analyzer list)
- **5568 invalid test re-fires with diagnostics**: NOT testable without a prior failed validation run. Requires persisted `spec_alignment` problems in the DB — no seed mechanism exists. Document only.
- **5570 test rules surface**: Call `start_task` for `test_file` on `module_name: "Story669.TddTest"` — assert prompt contains "Test Rules:" section with content from `elixir_test.md` rule
- **5571 crash leaves unsatisfied**: Call `start_task` for `test_file` on `module_name: "Story669.TddTest"`, then call `show_component_requirements` — assert `test_file` remains `[ ]` (unsatisfied)

## Setup Notes

Criteria 5565 and 5568 are covered by passing spex tests (cassette-level) but are not testable via the live QA surface without destructive writes to the project or DB surgery. These are documented as non-testable per the team lead's pre-existing guidance and filed as QA-scope info issues.

## Result Path

`.code_my_spec/qa/669/`
