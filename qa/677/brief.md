# Qa Story Brief

## Tool

MCP tool surface: `mcp__plugin_codemyspec_local__start_task` and `mcp__plugin_codemyspec_local__evaluate_task` for gate evaluation. The `install_credo_checks` bootstrap tool is called via curl against `http://127.0.0.1:4004/mcp` SSE channel (or exercised by reading its filesystem output directly after a start_task call).

Primary surfaces:
- `evaluate_task` MCP tool — tested by calling `mcp__plugin_codemyspec_local__evaluate_task` with varied artifact state in the sandbox
- `install_credo_checks` bootstrap tool — tested via `start_task` on the sandbox and inspecting filesystem output

## Auth

No auth required for the local MCP server. The `mcp__plugin_codemyspec_local__*` tool calls are scoped automatically via the PreToolUse hook using the working directory. Mutation tests target the QA sandbox:

```
/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
```

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) has `local_path` pointing to the sandbox. MCP calls targeting the sandbox are routed by passing `X-Working-Dir` or by having the agent `cd` into the sandbox.

## Seeds

Verify the local app is responding before testing:

```bash
curl -s http://127.0.0.1:4004/health
# Expected: {"status":"ok"}
```

No additional seeds needed. The sandbox directory at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` is the mutation target. Artifacts are set up and torn down by writing/deleting files in that directory tree before each scenario.

The sandbox `mix.exs` declares `app: :qa_sandbox`, so:
- Framework checks go in `.code_my_spec/credo_checks/framework/`
- Local check goes in `.code_my_spec/credo_checks/local/`
- Fixtures bridge path: `test/support/fixtures/qa_sandbox_spex_fixtures.ex`
- BDD plan location: `.code_my_spec/knowledge/bdd/spex/`

## What To Test

Drive all scenarios by calling `mcp__plugin_codemyspec_local__start_task` (for a `spex_boundary_ready` task) and `mcp__plugin_codemyspec_local__evaluate_task` (to observe pass/fail behavior) against varied sandbox file states.

### Scenario 1: Gate passes with empty fixtures bridge (criterion 5751)
- Set up all four required artifacts in the sandbox (write files directly to sandbox path)
- Start `spex_boundary_ready` task on the sandbox project via `start_task` with `entity_type="project"`
- Call `evaluate_task` with the returned task ID
- Assert response text contains "SpexBoundaryReady: Passed"
- Assert response does NOT contain "Needs work" or "missing"

### Scenario 2: Missing artifact reported without inspecting others (criterion 5752)
- Set up three artifacts in sandbox, omit `.code_my_spec/credo_checks/framework/spex_denied_calls.ex`
- Start `spex_boundary_ready` task on the sandbox project
- Call `evaluate_task`
- Assert response contains "SpexBoundaryReady: Needs work"
- Assert response names `.code_my_spec/credo_checks/framework/spex_denied_calls.ex`
- Assert response does NOT mention `no_direct_send_in_spex.ex`, bridge path, or plan path

### Scenario 3: First install copies framework checks (criterion 5753)
- Ensure no `.code_my_spec/credo_checks/` directory exists in the sandbox
- Call `install_credo_checks` MCP tool (via `mcp__plugin_codemyspec_local__start_task` routing to the bootstrap server, or inspect the running app's tool directly)
- Verify `spex_denied_calls.ex` appears at `sandbox/.code_my_spec/credo_checks/framework/spex_denied_calls.ex`
- Verify `no_direct_send_in_spex.ex` appears at the same dir
- Verify `local/` exists and is empty

### Scenario 4: Re-install preserves locally modified framework file (criterion 5754)
- Write a custom-content `spex_denied_calls.ex` with marker text to sandbox framework dir
- Call `install_credo_checks` again
- Verify the file still contains the custom marker text (not overwritten)

### Scenario 5: Gate passes when fixtures bridge exists (criterion 5755)
- All four artifacts present in sandbox (including bridge)
- Call `evaluate_task` → assert "SpexBoundaryReady: Passed"
- Assert response does NOT name the bridge path

### Scenario 6: Gate blocks with bridge-specific message when bridge missing (criterion 5756)
- Framework checks, local check, BDD plan present in sandbox; omit bridge file
- Call `evaluate_task` → assert "SpexBoundaryReady: Needs work"
- Assert response names `test/support/fixtures/qa_sandbox_spex_fixtures.ex`
- Assert response does NOT mention framework files or plan

### Scenario 7: Gate passes when project BDD spec plan exists (criterion 5757)
- All four artifacts present including `.code_my_spec/knowledge/bdd/spex/index.md`
- Call `evaluate_task` → assert "SpexBoundaryReady: Passed"
- Assert response does NOT name the BDD plan dir as missing

### Scenario 8: Gate blocks with plan-specific message when BDD plan missing (criterion 5758)
- Framework checks, local check, bridge present in sandbox; omit BDD plan
- Call `evaluate_task` → assert "SpexBoundaryReady: Needs work"
- Assert response names `.code_my_spec/knowledge/bdd/spex`
- Assert response does NOT mention bridge or framework files

### Scenario 9: Health check — local app responding
- `curl -s http://127.0.0.1:4004/health` → `{"status":"ok"}`

## Result Path

`.code_my_spec/qa/677/`
