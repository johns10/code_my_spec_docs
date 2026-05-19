# Qa Story Brief

## Tool

`mcp__plugin_codemyspec_local__get_next_requirement` for MCP surface scenarios; `mcp__vibium__browser_*` for the `/next-task` LiveView at port 4004.

## Auth

Local app (port 4004): no auth required — `LocalOnly` plug accepts loopback connections automatically.

MCP tool (`mcp__plugin_codemyspec_local__*`): available to the agent directly without additional auth setup. The tool is pre-scoped to `/Users/johndavenport/Documents/github/code_my_spec` via the working directory.

## Seeds

No seeds required. The live CodeMySpec project (at the current working directory) provides a real requirements graph with satisfied and unsatisfied requirements.

Verify app health before testing:

```
curl -s http://127.0.0.1:4004/health
```

## What To Test

### Scenario 1 — MCP tool returns actionable requirement with dispatch signature
- Call `mcp__plugin_codemyspec_local__get_next_requirement` directly (no parameters)
- Assert: response text is non-empty
- Assert: response includes "start_task" keyword
- Assert: response includes `requirement_name=` parameter
- Assert: response includes `entity_id=` parameter
- Maps to AC: "A requirement with all three conditions met appears in the actionable list" and "Every returned requirement has execution_type, orchestrated_by, and validation_type populated"

### Scenario 2 — MCP tool — orchestration metadata on every advertised line
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Filter lines in the response containing "start_task"
- Assert: each such line has a requirement reference (`requirement_name=` or `requirement \``)
- Assert: each such line has an entity reference (`entity_id=` or `component \``, `story \``, `project \``)
- Maps to AC: criterion 5627 — every advertised item carries dispatch metadata

### Scenario 3 — MCP tool — satisfied requirement does not appear
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Inspect returned requirement IDs
- Confirm none of the returned items is a requirement already known to be satisfied (cross-check against the requirements graph if needed)
- Maps to AC: "A requirement that has been satisfied no longer appears in subsequent calls"

### Scenario 4 — LiveView `/next-task` renders actionable task
- Launch Vibium; navigate to `http://127.0.0.1:4004/projects/code-my-spec/next-task`
- Screenshot the page at initial load (save as `4004_next_task_initial.png`)
- Assert: page title is "Next Task"
- Assert: the markdown content area contains either a `start_task` signature or "All requirements satisfied"
- Assert: "Sync" button is present on the page (`data-test="sync-button"`)
- Maps to AC: visual rendering of what the agent sees from `get_next_requirement`

### Scenario 5 — LiveView Sync button triggers recompute
- On the `/next-task` page, click the "Sync" button
- Screenshot immediately after click to capture the loading state (save as `4004_next_task_syncing.png`)
- Wait for sync to complete; screenshot the final state (save as `4004_next_task_after_sync.png`)
- Assert: content re-renders after sync (still shows tasks or "all done")
- Maps to AC: liveness of the "next task" display

### Scenario 6 — MCP tool response shape when project is live (non-empty state)
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Assert: response is text, not nil
- Assert: if requirements remain, the response is not a bare empty string
- Maps to AC: "The function returns an empty list when no requirement is actionable, never nil or a singleton"

## Result Path

`.code_my_spec/qa/561/`

Screenshots saved to `~/Pictures/Vibium/` with port-prefix filenames, then copied to `.code_my_spec/qa/561/screenshots/`.
