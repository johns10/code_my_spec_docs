# QA Brief — Story 563: Story Priority Propagation Through Component Tree

## Tool

MCP surface: `mcp__plugin_codemyspec_local__*` tools (specifically `get_next_requirement`) exercised via the `mix spex` test runner, which drives `GetNextRequirement.execute/2` in-process using the real Anubis frame/scope pipeline. The requirements LiveView at `http://127.0.0.1:4004/projects/code-my-spec/requirements` is used for visual evidence of the live wave state.

## Auth

Local endpoint (port 4004): no user auth required. `WorkingDirScope` resolves from `X-Working-Dir` header or process cwd. Spex tests use `register_log_in_setup_account` + `setup_active_project` setup callbacks to build a sandboxed scope for each scenario.

## Seeds

No seeds required for the BDD scenarios — each spex scenario builds its own fixture environment using `Environments.write_file/3` + the sync LiveView in-process. The live project uses the standard checkout at `/Users/johndavenport/Documents/github/code_my_spec`.

## What To Test

### Scenario 1 — Lower priority number leads (criterion 5900)

Drive `GetNextRequirement` with two unrelated contexts synced — one linked to priority-1 story, one to priority-5 story. Assert the priority-1 component's `entity_id` appears in the response and either the priority-5 id does not appear, or appears after the priority-1.

### Scenario 2 — Same priority, oldest created_at wins (criterion 5901)

Drive `GetNextRequirement` with two contexts each linked to a priority-1 story, created in sequence. Assert the older story's component leads.

### Scenario 3 — Components with no inherited priority sort last (criterion 5902)

Drive `GetNextRequirement` with a priority-1 linked context and an orphan component with no story link. Assert the linked context appears and the orphan does not eclipse it.

### Scenario 4 — Surface dependency inherits its dependent story's priority (criterion 5903)

Drive `GetNextRequirement` with a graph where Stories depends on Users (linked story priority 1) and unrelated Reports is linked at priority 9. Assert the response scopes to Users or Stories, never Reports.

### Scenario 5 — Parent-chain inheritance propagates priority down (criterion 5904)

Drive `GetNextRequirement` with parent contexts (HighContext priority 1, LowContext priority 9), each having a child schema component. Assert HighContext.Item appears in the wave (proving parent-chain priority inheritance), and LowContext.Other does not appear.

### Scenario 6 — High-priority story chain appears first (criterion 5905)

Drive `GetNextRequirement` with HighContext (priority 1) and LowContext (priority 5). Assert HighContext's `entity_id` appears before LowContext's.

### Scenario 7 — Story-linked contexts sort before orphan contexts (criterion 5906)

Drive `GetNextRequirement` with a LinkedContext (story priority 1) and OrphanContext (no story). Assert LinkedContext appears and orphan does not eclipse it.

## Result Path

`.code_my_spec/qa/563/result.md`
