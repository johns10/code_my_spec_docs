# Qa Result

## Status

fail

## Scenarios

### Scenario 1: Issues list page renders with filter controls

pass

Navigated to `http://127.0.0.1:4000/app/issues` while authenticated as `qa@codemyspec.local`. The page returned HTTP 200. HTML inspection confirmed:
- 3 issue cards rendered with `id="issue-{uuid}"` structure
- Filter controls (status and severity dropdowns) present as `<select>` elements with `phx-change="filter"` binding
- Issue titles visible: "QA-600: Export button missing from story detail view", "QA-600: Story acceptance criteria should be editable inline", "QA-600: Login page has typo in header text"
- Badge elements present for severity and status

Evidence: `.code_my_spec/qa/600/screenshots/issues_list_page.html`

### Scenario 2: Accept an incoming issue changes status to accepted

pass

Called `Issues.accept_issue/3` (the same function invoked by the LiveView `phx-click="accept"` handler) against issue `6505a64f-dc45-40e1-9db7-0cadb5ca5bab` (severity: high, status: incoming). Confirmed:
- Before: status = incoming, category = nil
- After: status = accepted, category = nil (plain bug acceptance)
- Issue show page confirmed via HTTP GET that badge class changed to badge-info for accepted state

### Scenario 3: Dismiss an incoming issue records reason

pass

Called `Issues.dismiss_issue/3` against issue `d52e19a6-32a7-4d18-91c7-2394c6cb2e7a` with reason "Expected behavior - by design". Confirmed:
- Before: status = incoming
- After: status = dismissed, resolution = "Expected behavior - by design"
- Issue show page (HTTP 200) contains "dismissed" badge and the resolution text
- No action buttons present on the dismissed issue page (correct per `available_actions/1` which returns `[]` for dismissed)

Evidence: `.code_my_spec/qa/600/screenshots/issue_dismissed_show_page.html`

### Scenario 4: Resolve an accepted issue records resolution note

pass

Called `Issues.resolve_issue/3` against the accepted issue `6505a64f-dc45-40e1-9db7-0cadb5ca5bab` with resolution "Fixed in PR #123 - added export button to story detail view". Confirmed:
- Before: status = accepted
- After: status = resolved, resolution = "Fixed in PR #123 - added export button to story detail view"
- Issue show page shows `badge-success` class with "resolved" text
- Resolution text appears on the page
- No action buttons present (correct for resolved issues)

Evidence: `.code_my_spec/qa/600/screenshots/issue_resolved_show_page.html`

### Scenario 5: MCP accept_issue with requirements_change category links to story

pass

Called `Issues.accept_issue/3` (invoked by the `AcceptIssue` MCP tool module) with `opts: [category: :requirements_change, story_id: 1]` against issue `618d4011-7b9e-41cf-9663-e678f74a9c0b`. Confirmed:
- Before: status = incoming, category = nil, story_id = nil
- After: status = accepted, category = :requirements_change, story_id = 1
- The category field is correctly persisted to the database

### Scenario 6: MCP accept_issue requirements_change without story_id is rejected

pass

Called `Issues.accept_issue/3` with `opts: [category: :requirements_change]` (no story_id) against a fresh incoming issue `6504017e-3353-4e8f-b1a1-45a019b4ae2e`. Confirmed:
- The call returned `{:error, %Ecto.Changeset{}}` with error: `[story_id: {"is required when category is :requirements_change", []}]`
- The issue remained in :incoming status (not updated)
- This validation is confirmed by the spex test in `test/spex/599_issue_triage/criterion_5332_agent_attempts_requirements_change_accept_without_a_story_id_spex.exs` (528 tests, 0 failures)

### Scenario 7: MCP dismiss_issue with reason records the reason

pass

Called `Issues.dismiss_issue/3` (invoked by the `DismissIssue` MCP tool module) with reason "Not applicable - existing feature works as intended" against issue `6504017e-3353-4e8f-b1a1-45a019b4ae2e`. Confirmed:
- Before: status = incoming
- After: status = dismissed, resolution = "Not applicable - existing feature works as intended"

### Scenario 8: Filter issues by status in LiveView

partial

Attempted to test status filter by passing URL query parameters. LiveView filter state is managed by WebSocket events (`phx-change="filter"`) and URL query params are ignored by the LiveView mount. The filter controls (status/severity dropdowns) are present in the HTML, but their state changes cannot be tested via HTTP GET requests — they require a live WebSocket connection (Vibium browser tools, which were unavailable in this execution context).

Confirmed: Filter controls are present. The `handle_event("filter", ...)` handler in `IssuesLive.Index` correctly builds filters and passes them to `Issues.list_filtered/2`. This code path is exercised.

### Scenario 9: Project graph does NOT surface requirements_review task for accepted requirements_change issues

fail

Inspected `RequirementDefinitionData.project_graph/0` and `RequirementDefinitionData.story_graph/0`. The project graph contains the following nodes:
- project_setup, personas_complete, stories_exist, technical_strategy, code_generation, qa_integration_plan, architecture_designed, spex_boundary_ready, issues_triaged, issues_resolved, qa_setup, all_bdd_specs_passing, qa_journey_plan, qa_journey_execute, qa_journey_wallaby

**No node exists for surfacing a project-level review task when accepted requirements_change issues are open.** The `issues_resolved` node uses `IssuesChecker.resolved?/2` which counts ALL accepted issues regardless of category. Requirements_change issues are not distinguished from bug issues in the graph, and no separate review pathway exists.

This is the core missing feature described in story 600. The story acceptance criteria state: "Accepted requirements_change issue surfaces the review task" — this behavior does not exist. Accepted requirements_change issues fall into the same `issues_resolved` requirement node as bugs, with no dedicated review task or grouping by story.

Also confirmed absent:
- "Issues group by story; unlinked issues form their own group" — no grouping logic exists in the project graph or IssuesChecker
- "Agent picks 'add criterion' for a feature-gap feedback issue" — no task prompt exists for this flow
- "Description amendments flow through update_story, not direct DB writes" — no enforcement mechanism
- "Applied change resolves the source issue with a concrete note" — no linked resolution flow
- "Task evaluates complete when the last accepted issue is resolved" — the generic issues_resolved works for ALL accepted issues; no requirements_change-specific task completion

## Evidence

- `.code_my_spec/qa/600/screenshots/issues_list_page.html` — Issues index page HTML (3 QA issues rendered with filter controls)
- `.code_my_spec/qa/600/screenshots/issue_resolved_show_page.html` — Resolved issue show page (badge-success, resolution text, no action buttons)
- `.code_my_spec/qa/600/screenshots/issue_dismissed_show_page.html` — Dismissed issue show page (dismissed badge, reason text, no action buttons)

## Issues

### Core feature not implemented: No project-level requirements_review task in the requirement graph

#### Severity
HIGH

#### Description
Story 600's central acceptance criterion — "Accepted requirements_change issue surfaces the review task" — is not implemented. The `project_graph()` in `RequirementDefinitionData` has no node for a project-level requirements review task. Accepted issues with `category: :requirements_change` are treated identically to `category: :bug` issues in the requirement graph: they fall under `issues_resolved` (which requires resolving them) but no dedicated "review requirements changes" task is surfaced.

The `IssuesChecker.resolved?/2` checks all accepted issues regardless of category. There is no checker, graph node, or agent task that:
- Surfaces when requirements_change issues are accepted
- Groups issues by story with unlinked issues forming their own group
- Provides a review prompt guiding the agent to update story criteria or descriptions
- Checks that the last accepted requirements_change issue is resolved before the task completes

The `category: :requirements_change` field exists on the Issue schema, the `accept_issue` MCP tool supports the parameter, and the changeset validation requiring `story_id` for this category is implemented. Only the graph-level surfacing of the review task is missing.

File locations to modify:
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — add a new graph node for `requirements_review`
- `lib/code_my_spec/agent_tasks/` — create a `ReviewRequirementsChanges` agent task module
- `lib/code_my_spec/requirements/` — create a checker for accepted requirements_change issues

### Vibium browser tools not available in QA subagent context

#### Severity
MEDIUM

#### Scope
QA

#### Description
The Vibium MCP server is registered in `~/.claude.json` but the `mcp__vibium__browser_*` tools are not accessible in the QA subagent execution context. Calling `mcp__vibium__browser_navigate` returned: "No such tool available: mcp__vibium__browser_navigate". 

This prevented interactive testing of the LiveView filter controls (phx-change events) and capturing browser screenshots showing the visual state of the issues pages. Workaround: tested via curl for page-level HTTP responses and via direct Elixir module calls for state verification. The filter behavior could not be fully tested without browser automation.

Impact: Scenarios 1, 2, 3, 4, 8 were tested via curl/Elixir rather than browser interaction. The core LiveView phx-click event handlers (accept, dismiss, resolve) could not be tested through the actual browser surface.
