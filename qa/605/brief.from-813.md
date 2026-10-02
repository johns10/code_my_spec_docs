# QA Brief — Story 813: Non-technical user watches the agent work in a live progress view

## Tool

web (Vibium MCP browser tools)

## Auth

Local app on port 4004 — no authentication required. `LocalOnly` plug accepts loopback connections directly. Navigate straight to the URL.

## Seeds

No seed script needed. The page reads live data from the running CodeMySpec dev DB. The project slug `code-my-spec` is the working project itself.

If the timeline is empty (no sessions with activity), the test still covers the empty/idle state and requirements rail.

## What To Test

Target URL: http://localhost:4004/projects/code-my-spec/progress

### Scenario 1 — Page loads and requirements rail renders (criterion 6545)

1. Navigate to `http://localhost:4004/projects/code-my-spec/progress`
2. Capture initial screenshot
3. Assert `[data-test="requirements-list"]` is present
4. Assert requirement rows with `[data-test="requirement-row"]` are visible
5. Assert each row shows a status token (`done`, `in progress`, or `not started`)

### Scenario 2 — Tasks nest under their session (criterion 6546)

1. On the same page, inspect the timeline section `[data-test="timeline"]`
2. Locate any `[data-test="session"]` elements
3. Verify that `[data-test="task"]` elements appear as children inside session elements
4. Capture screenshot showing session+task nesting

### Scenario 3 — Sessions with no activity are hidden (criterion 6548)

1. Inspect all rendered `[data-test="session"]` elements in the DOM
2. For each visible session, check `data-started-at` vs `data-updated-at` attributes via `data-test="session-extent"`
3. Assert no session is rendered where start == last updated
4. (If timeline is empty, verify the empty state is shown instead — no sessions rendered means no idle sessions are leaking through)

### Scenario 4 — Session spans from start to last update (criterion 6549)

1. For any rendered session, locate `[data-test="session-extent"]`
2. Verify it carries both `data-started-at` and `data-updated-at` attributes with ISO timestamps

### Scenario 5 — Highest-precedence active task is expanded (criterion 6550)

1. If any sessions are present in the timeline, check for tasks with `data-active="true"`
2. If multiple active tasks exist, verify exactly one has `data-expanded="true"`
3. Verify that expanded task is the one with higher precedence in the project chain (project_setup > architecture_designed > etc.)
4. If no active tasks exist, verify nothing is expanded (`data-expanded="true"` appears zero times)

### Scenario 6 — Nothing is expanded when agent is idle (criterion 6551)

1. If no active tasks are present, assert no `[data-test="task"][data-expanded="true"]` elements exist in the DOM

### Scenario 7 — User expands an older task to inspect it (criterion 6552)

1. If any tasks are rendered in the timeline, click the task toggle button `[data-test="task-toggle"]` on a collapsed task
2. Assert that task's container gets `data-expanded="true"` after click
3. Capture screenshot showing the expanded state

### Scenario 8 — Focused task shows its artifact (criterion 6553)

1. If any task is expanded (`data-expanded="true"`), locate the `[data-test="task-artifact"]` inside it
2. Assert the artifact region is present and shows text (file list or requirement name)

### Scenario 9 — Major task shows curated help and video (criterion 6554)

1. If a focused task renders with `[data-test="task-help-body"]`, the task type has curated help
2. Check for optional `[data-test="task-help-video"]` link presence

### Scenario 10 — Non-major task falls back to generic explanation (criterion 6555)

1. If a focused task renders with `[data-test="task-help-generic"]`, the fallback is working

### Scenario 11 — Empty session renders muted (criterion 6557)

1. Look for any `[data-test="session"][data-empty="true"]` elements
2. Verify they render with reduced opacity (CSS class `opacity-50` should be present)
3. If no empty sessions are visible in live data, note the state is not observable in this run

### Scenario 12 — Timeline cap (criterion 6547)

1. Count the total number of `[data-test="session"]` elements rendered
2. Assert the count does not exceed 10

### Scenario 13 — Live updates (criterion 6556)

Note: Live update testing via PubSub is an automatic state. The subscription wires up on connect; a real in-flight agent session would trigger it. Observe only whether the page is connected (LiveView session attribute present).

## Result Path

`.code_my_spec/qa/813/`

Screenshots save to `~/Pictures/Vibium/` and must be copied to `.code_my_spec/qa/813/screenshots/` after capture.
