# QA Story 811 — User sees the agent's task queue at a glance

## Tool

web (Vibium MCP browser tools — the TaskQueueLive is a LiveView behind the `:browser` pipeline on port 4004)

## Auth

No authentication required for the local endpoint. Port 4004 uses `Plugs.LocalOnly` (loopback trust) with no user session. Navigate directly to the URL.

Base URL: `http://127.0.0.1:4004`

## Seeds

The local CLI seed may have migration issues per the QA plan. The page works with any project
that has an unsatisfied requirements graph. Use the `code-my-spec` project which is already
present and has unsatisfied requirements.

To verify a project is available:
```
curl -s http://127.0.0.1:4004/health
```

No additional seed commands are required — the CodeMySpec checkout has a live requirements graph.

## What To Test

### Scenario 1: Active task and upcoming tasks render on the same screen

- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/tasks`
- Take a screenshot of the initial page load
- Assert the page renders a region with `data-test="active-task"` — this is the currently active task
- Assert the page renders a region with `data-test="upcoming-tasks"` — this is the upcoming list
- Assert at least one `data-test="upcoming-task-item"` element exists inside the upcoming-tasks region
- Both regions must be visible in the same rendered page without any navigation or clicking

### Scenario 2: Empty queue shows an explicit "nothing to do" state

- This requires a project where all requirements are satisfied (no actionable requirements)
- The `data-test="empty-queue"` region should appear
- The `data-test="active-task"` region must NOT appear
- The `data-test="upcoming-task-item"` elements must NOT appear
- Note: This state is hard to reproduce with the live CodeMySpec project (which always has unsatisfied requirements). Verify this path by reading the implementation source (which shows the conditional rendering) and note that the spex suite covers this with a fully-satisfied fixture. Document as partial if a live empty-state project is not available.

### Scenario 3: Head of displayed queue matches get_next_requirement return

- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/tasks`
- Read the `data-requirement` attribute from the `data-test="active-task"` element
- Call `mcp__plugin_codemyspec_local__get_next_requirement` from the working directory
- Compare: the requirement_name returned by the MCP tool should match the `data-requirement` on the active-task element
- Take a screenshot showing the active task requirement name

### Scenario 4: Queue shifts up when the agent completes the active task

- This scenario requires mutating live state (satisfying a requirement) and observing a LiveView re-render without a page reload
- The spex spec exercises this by writing a `CLAUDE.md` file and waiting for PubSub fan-out
- For live QA, observe that the active task displayed matches what `get_next_requirement` returns at load time
- Completing a task in real-time would modify the working project; this is covered by spex coverage
- Document as partial if live queue-shift cannot be safely observed without mutating the production project

## Result Path

`.code_my_spec/qa/811/result.md`
