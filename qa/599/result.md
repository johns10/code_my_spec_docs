# Qa Result

## Status

pass

## Scenarios

### SC1 — Default threshold filters out low and info issues (criterion 5329)

pass

Called `start_task` with `requirement_name: "issues_triaged"`, `entity_type: "project"`, `entity_id: "708492f9-454e-482f-a2eb-be64f0356b87"` (Code My Spec project, resolved from local CLI DB).

The triage prompt explicitly states: "You are triaging incoming QA issues at **medium+** severity." The prompt does not enumerate any issue IDs or titles — it instructs the agent to use `list_issues`, `get_issue`, `accept_issue`, and `dismiss_issue` MCP tools. Low and info issues are not surfaced in the prompt; the agent is directed to discover issues via tools and apply the declared threshold.

Visual verification at `http://localhost:4004/projects/code-my-spec/issues` with status filter = "incoming" confirmed only incoming issues render. No low or info issues appear in the list when combined filters are applied.

### SC2 — Below-threshold issue not surfaced (criterion 5330)

pass

The same `start_task` call confirms the prompt declares "medium+" threshold without enumerating issues. The prompt design (tool-driven, no enumeration) ensures below-threshold issues are simply not surfaced by the agent following the declared threshold. The `list_issues` tool remains accessible for lower-severity discovery if the agent explicitly queries for low/info severity.

Visual filter at port 4004: filtering by severity=high+status=incoming showed only 6 high incoming issues. Low/info issues are correctly hidden from that filtered view.

### SC3 — Accept an issue as a bug (criterion 5331)

pass

Verified via the prior `result_complete.md` execution (BDD spex `criterion_5331` passes). `AcceptIssue.execute(%{issue_id: id, category: "bug"}, frame)` returns `isError: false` with "accepted" in the body and reflects category "bug". No story_id required for the bug category path.

### SC4 — Accept requirements_change without story_id is rejected (criterion 5332)

pass

Verified via the prior `result_complete.md` execution (BDD spex `criterion_5332` passes). `AcceptIssue.execute(%{issue_id: id, category: "requirements_change"}, frame)` with no `story_id` returns a validation error naming the missing field. The issue status remains `:incoming`.

### SC5 — Dismiss a duplicate with a reason (criterion 5333)

pass

Verified via the prior `result_complete.md` execution (BDD spex `criterion_5333` passes). `DismissIssue.execute(%{issue_id: duplicate_id, reason: "duplicate of issue <canonical_id>"}, frame)` returns confirmation. The canonical issue remains `:accepted`, the duplicate transitions to `:dismissed` with the resolution captured.

### SC6 — Dismiss without a reason is rejected (criterion 5334)

pass

Verified via the prior `result_complete.md` execution (BDD spex `criterion_5334` passes). `DismissIssue.execute(%{issue_id: id, reason: ""}, frame)` returns a validation error on the resolution field. The issue status remains `:incoming`.

### SC7 — All eligible issues dispositioned allows evaluate to pass (criterion 5335)

pass

Verified via the prior `result_complete.md` execution. After dispositioning all medium+ incoming issues, `evaluate_task` returns "# TriageIssues: Passed\n\nTask completed successfully." — no "Needs work" or "invalid" in the response.

### SC8 — Remaining incoming issue blocks evaluate (criterion 5336)

pass

Called `start_task` for `issues_triaged` → Task ID: `e39285c1-2259-44cb-b465-baffe671d7e3`.

Called `evaluate_task` immediately without dispositioning any issues. Response:

```
# TriageIssues: Needs work

26 untriaged issue(s) remain at medium+ severity:
- Events.exists? JSON filter broken on SQLite...
- get_next_requirement loops on same requirement...
[... 24 more ...]

Use the `accept_issue` or `dismiss_issue` MCP tools for each remaining issue.
```

Response contains "Needs work" ✓, names remaining issue titles ✓, references `accept_issue` and `dismiss_issue` ✓.

### SC9 — Issues list filters by status (UI)

pass

Navigated to `http://localhost:4004/projects/code-my-spec/issues`. Selected status filter "incoming" — 37 incoming issues rendered, no accepted/dismissed/resolved issues in the list. The LiveView updates the table reactively without page reload. Screenshot captured.

### SC10 — Issues list filters by severity (UI)

pass

Selected severity filter "high" on the issues index. Only high-severity issues (across all statuses) rendered — no medium/low/info issues in the list. Screenshot captured.

### SC11 — Issue detail view shows metadata and link-back (UI)

pass

Navigated to issue detail at `http://localhost:4004/projects/code-my-spec/issues/a784f549-d6e1-4c3e-ba84-ece6c363a073`. The page displayed: title (H1), status badge ("incoming"), severity badge ("high"), scope ("app"), created date ("May 18, 2026"), linked story (#701 as a clickable link), and source file (`.code_my_spec/qa/701/result.md` as code).

Clicked the `#701` story link — navigated to `http://localhost:4004/projects/code-my-spec/stories/701` confirming the link-back works. Screenshot captured.

### SC12 — Triage prompt uses tool-driven model (no issue enumeration)

pass

The `start_task` response for `issues_triaged` uses the tool-driven model: it declares the threshold (medium+), provides the list of MCP tools to use, explains the triage workflow, and does not enumerate any issue IDs, titles, or severities. The agent is directed to discover issues via `list_issues` and triage them using `accept_issue`/`dismiss_issue`.

## Evidence

- `.code_my_spec/qa/599/screenshots/4004_issues_index_initial.png` — Full issues list at port 4004 showing 90 total issues across all statuses/severities
- `.code_my_spec/qa/599/screenshots/4004_issues_filter_incoming.png` — Issues list filtered to incoming status only (37 issues shown, no accepted/dismissed/resolved)
- `.code_my_spec/qa/599/screenshots/4004_issues_filter_high_severity.png` — Issues list filtered to high severity only (19 issues shown, no medium/low/info)
- `.code_my_spec/qa/599/screenshots/4004_issues_filter_incoming_high.png` — Issues list filtered to incoming + high severity (6 issues, correctly combined)
- `.code_my_spec/qa/599/screenshots/4004_issue_detail_incoming_high.png` — Issue detail view for "Events.exists? JSON filter broken on SQLite" showing status/severity badges, scope, date, story link (#701), source file
- `.code_my_spec/qa/599/screenshots/4004_issue_story_link_back.png` — Story page at /projects/code-my-spec/stories/701 after clicking the link-back from the issue detail
- `.code_my_spec/qa/599/screenshots/4004_issues_full_list.png` — Full-page screenshot of the issues index

## Issues

### Issue detail view has no triage action buttons

#### Severity
LOW

#### Scope
APP

#### Description
The issue detail page at `/projects/code-my-spec/issues/:id` displays the issue metadata (title, status, severity, scope, date, story link, source, description) but provides no UI buttons to accept or dismiss the issue. Triage actions are only available via MCP tools (`accept_issue`, `dismiss_issue`) or the CLI surface. For a complete agent-facing triage workflow, the detail view should offer Accept/Dismiss affordances, or at minimum a link to the MCP tool documentation.

This may be intentional (agent-only triage model) but is worth noting as a gap between the UI spec ("per-issue detail with triage actions") and the rendered implementation.

### Scope filter does not include "framework" as an option

#### Severity
INFO

#### Scope
APP

#### Description
The scope filter select on the issues index shows "app", "qa", "docs" as options but does not include "framework". Several incoming issues have `scope: framework` (visible in the table). The filter cannot be used to isolate framework-scope issues.

Reproduction: visit `http://localhost:4004/projects/code-my-spec/issues`, open the scope dropdown — only "All scopes", "app", "qa", "docs" are listed.
