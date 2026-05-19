# Qa Story Brief

## Tool

MCP tool surface (`mcp__plugin_codemyspec_local__*`) — all criteria exercise MCP server tools
(start_task, evaluate_task, create_component, set_story_component, execute_proposal,
list_components) called in-process via the spex BDD test suite.

## Auth

No auth required for the MCP tool surface. The local MCP server (port 4004) uses
`LocalOnly` (loopback-only) and resolves scope from the `X-Working-Dir` header. The
spex suite uses `register_log_in_setup_account` + `setup_active_project` helpers to
create an isolated test scope in-process.

For verifying LocalServer tool registration at the process level:
```
iex -S mix
iex> CodeMySpec.McpServers.LocalServer.__components__(:tool) |> Enum.map(& &1.name) |> Enum.sort()
```

## Seeds

Run base server seeds before any manual inspection:
```
mix run priv/repo/qa_seeds.exs
```

The BDD spec suite creates its own isolated fixtures via `register_log_in_setup_account` +
`setup_active_project` — no additional story-specific seeds needed for the spex run.

## What To Test

All six criteria exercise the local MCP tool surface. The primary test execution
is `mix spex test/spex/682_architect_agent_surface/`. Verify all scenarios pass.

### Scenario 1 — Patch mode: evaluate does not auto-execute (criterion 5829)
- A project starts with a populated `proposal.md` (patch mode marker is set at session start)
- Agent calls `create_component` for a new component and `set_story_component` to link a story
- Agent calls `evaluate_task` without rewriting the proposal
- Expected: evaluator reports "passed", no false "Component removed from proposal but preserved
  in DB" warning for the new component, and the pre-existing `proposal.md` remains unchanged

### Scenario 2 — Reuse existing component (criterion 5830)
- A project has an existing component (e.g. `MyApp.Accounts`)
- A new story arrives without a `component_id`
- Agent calls `set_story_component` to link the story to the existing component
- Expected: `list_components` count is unchanged (no new component created), link succeeds

### Scenario 3 — Link story via component linker tool (criterion 5831)
- An unlinked story exists; an existing component (`MyApp.Notifications`) is available
- Agent calls `set_story_component` with story ID and module name
- Expected: tool reports success, response contains "Component assigned to story" and the
  story title

### Scenario 4 — Create stub component (criterion 5832)
- No spec file exists at the conventional path for `MyApp.Notifications`
- Agent calls `create_component` with module name, type `context`, and description
- Expected: tool reports success, new component appears in `list_components`, stub spec file
  is created at the conventional path, stub references the module name and type

### Scenario 5 — Rewrite proposal and trigger execution manually (criterion 5833)
- Project has an existing component; a new unsatisfied story exists
- Agent rewrites `proposal.md` end-to-end (adding new contexts and a LiveView surface)
- Agent calls `execute_proposal` explicitly
- Expected: tool reports success, new components appear in `list_components`, existing component
  is preserved, stub spec files exist for all new components

### Scenario 6 — Prompt only references registered tools (criterion 5874)
- A fully satisfied project is set up with an orphan context synced in
- Agent calls `start_task` for `architecture_designed` requirement
- Every backtick-quoted `snake_case` token in the returned prompt must be either:
  - A tool registered on `CodeMySpec.McpServers.LocalServer`, or
  - On the explicit non-tool whitelist (`architecture_proposal`, `infrastructure_paths`,
    component type values)
- The prompt must reference `set_story_component` in backticks AND that tool must be
  registered on LocalServer

## Result Path

`.code_my_spec/qa/682/result.md`
