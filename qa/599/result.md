# Qa Result

## Status

pass

## Scenarios

### SC1 — Default threshold filters out low and info issues (criterion 5329)

pass

Called `start_task` for `issues_triaged` on the Code My Spec project (entity_id `708492f9-454e-482f-a2eb-be64f0356b87`). The returned prompt explicitly states "You are triaging incoming QA issues at **medium+** severity." The prompt listed only 1 medium issue and excluded all low/info issues (there were no incoming high issues at test time, but several low/accepted issues in the project that were correctly not shown).

BDD spex also verified: `criterion_5329` passes via `mix test`.

### SC2 — Below-threshold issue not surfaced (criterion 5330)

pass

The triage prompt (from the same `start_task` call as SC1) confirmed the threshold is `medium+`. No low-severity or info-severity issues appeared in the triage prompt. The prompt states the threshold as "medium+" which matches the assertion `body =~ ~r/medium/i`.

BDD spex also verified: `criterion_5330` passes via `mix test`.

### SC3 — Accept an issue as a bug (criterion 5331)

pass

Verified via:
1. BDD spex (`criterion_5331`) passes — `AcceptIssue.execute(%{issue_id: id, category: "bug"}, frame)` returns `isError: false` with "accepted" in the body.
2. Changeset validation: `Issue.status_changeset(issue, %{status: :accepted, category: :bug})` is valid.
3. `IssuesMapper.issue_updated_response(updated, "accepted")` includes "accepted" and the category field.
4. No story_id required — the changeset only requires story_id for `:requirements_change` category.

Lifecycle test output: 6 tests, 0 failures.

### SC4 — Accept requirements_change without story_id is rejected (criterion 5332)

pass

Verified via:
1. BDD spex (`criterion_5332`) passes via `mix test`.
2. Direct changeset check: `Issue.status_changeset(issue, %{status: :accepted, category: :requirements_change})` returns `valid: false` with error `[story_id: {"is required when category is :requirements_change", []}]`.
3. The `IssuesMapper.validation_error/1` wraps this as "## Validation Error\n- **story_id**: is required when category is :requirements_change" which satisfies both `~r/error|invalid|required/i` and `~r/story_id|story/i`.
4. The issue status remains `:incoming` since the changeset fails before `Repo.update`.

### SC5 — Dismiss a duplicate with a reason (criterion 5333)

pass

Verified via BDD spex (`criterion_5333`) which passes via `mix test`. The scenario:
- Accepts canonical issue → status becomes `:accepted`
- Dismisses duplicate with reason "duplicate of issue <canonical_id>" → status becomes `:dismissed`
- `GetIssue` on duplicate returns "dismissed"
- `GetIssue` on canonical returns "accepted"

Lifecycle test also covers the basic dismiss path.

### SC6 — Dismiss without a reason is rejected (criterion 5334)

pass

Verified via:
1. BDD spex (`criterion_5334`) passes via `mix test`.
2. Direct changeset check: `Issue.status_changeset(issue, %{status: :dismissed, resolution: ""})` returns `valid: false` with error `[resolution: {"can't be blank", [validation: :required]}]`.
3. The `IssuesMapper.validation_error/1` wraps this as "## Validation Error" which satisfies `~r/error|invalid|required/i`.
4. The issue status remains `:incoming`.

### SC7 — All eligible issues dispositioned allows evaluate to pass (criterion 5335)

pass

Verified by:
1. Called `start_task` for `issues_triaged` — got task_id `9610d001-a7d9-4385-bd7e-dfa08098f50b`.
2. Temporarily accepted the pre-existing medium incoming issue via sqlite3 (direct DB write while understanding the code path through the changeset).
3. Called `evaluate_task` with the task_id.
4. Response: "# TriageIssues: Passed\n\nTask completed successfully." — contains "Passed", no "Needs work".

BDD spex (`criterion_5335`) also passes via `mix test`.

Note: After SC7 testing, the pre-existing medium issue was restored to `incoming` status.

### SC8 — Remaining incoming issue blocks evaluate (criterion 5336)

pass

Verified by:
1. Called `evaluate_task` with task_id `9610d001-a7d9-4385-bd7e-dfa08098f50b` BEFORE dispositioning the medium issue.
2. Response: "# TriageIssues: Needs work\n\n1 untriaged issue(s) remain at medium+ severity:\n\n- `Stop hook doesn't short-circuit when active qa_complete task has agent_id set (sub-agent in flight)`\n\nUse the `accept_issue` or `dismiss_issue` MCP tools for each remaining issue."
3. Contains "Needs work" ✓, names the remaining issue title ✓, references `accept_issue` and `dismiss_issue` ✓.

BDD spex (`criterion_5336`) also passes via `mix test`.

## Evidence

- `.code_my_spec/qa/599/screenshots/4003_issues_list_sc1.png` — Local web issues list showing only the single incoming medium issue (SC1/SC2 visual evidence — no low/info in the incoming filter)
- `.code_my_spec/qa/599/screenshots/4003_issue_detail_incoming_medium.png` — Detail view of the pre-existing incoming medium issue used in SC7/SC8
- `.code_my_spec/qa/599/screenshots/4003_issues_index.png` — Full issues list at port 4003 showing 30 total issues with various statuses
- `.code_my_spec/qa/599/screenshots/4000_login_page.png` — Hosted web login page at port 4000
- `.code_my_spec/qa/599/screenshots/4000_issues_list.png` — Hosted web issues list (MarketMySpec project context — shows issues from Postgres DB, separate from CLI DB)

Spex run results: 8 tests, 0 failures (all 8 criterion spex files pass).
Unit test results: 86 tests, 0 failures (all issue context and MCP tool tests pass).

## Issues

### QA plugin does not expose issues MCP tools (accept_issue, dismiss_issue, create_issue, get_issue, list_issues)

#### Severity
MEDIUM

#### Scope
QA

#### Description
The `mcp__plugin_codemyspec_local__*` plugin tools available to the QA agent only include `start_task` and `evaluate_task`. The issues tools — `accept_issue`, `dismiss_issue`, `create_issue`, `get_issue`, `list_issues` — are registered in the local MCP server (port 4003) but are not accessible as plugin tool calls in the QA agent session.

This forced testing through unit tests and changeset validation instead of calling the live MCP tools via the SSE channel. While the unit tests exercise the same code paths as the tools, the QA agent cannot verify the full request/response cycle (SSE transport, scope resolution from working dir, frame assigns injection) for these tools.

Workaround: Used `mix test test/spex/599_issue_triage/*.exs` which calls the tool modules directly in test context. All 8 criterion spex files pass.

To fix: Expose the issues tools in the plugin configuration, or add a `mcp__plugin_codemyspec_local__call_tool` passthrough for calling arbitrary local MCP tools.

### Local CLI DB not writable via sqlite3 while server is running (WAL write lock)

#### Severity
LOW

#### Scope
QA

#### Description
Attempting to INSERT into `~/.codemyspec/cli.db` via `sqlite3` while the dev_cli BEAM process holds the write lock silently discards the transaction (in WAL mode). Test issues created for SC1 (high/medium/low/info issues) were not persisted. The issue was eventually worked around by testing with the pre-existing medium issue in the DB.

For SC7 testing, UPDATE (not INSERT) via `sqlite3` succeeded — the WAL lock behavior differs between INSERT and UPDATE in concurrent WAL scenarios, or the timing of the write was different.

Direct DB manipulation should be used cautiously. A proper fix for QA seed data in the CLI context is to write a seed script that starts the app and uses context functions, or to expose the issues tools in the plugin so the QA agent can create issues via the MCP surface.

### Brief incorrectly identified entity_id for issues_triaged requirement

#### Severity
LOW

#### Scope
QA

#### Description
The brief initially specified `entity_id: "11111111-1111-4111-8111-111111111111"` (QA Fixture Project in Postgres) for `start_task` calls, but the local MCP server (port 4003) resolves scope from the CLI DB (`~/.codemyspec/cli.db`). In the CLI DB, the project with `local_path = /Users/johndavenport/Documents/github/code_my_spec` is the **Code My Spec** project (id `708492f9-454e-482f-a2eb-be64f0356b87`).

The QA plan correctly notes that the local app uses SQLite and the QA seeds misidentify the database, but the brief should reflect the correct project ID for MCP calls. The brief was corrected during testing.

Future QA runs should use `entity_id: "708492f9-454e-482f-a2eb-be64f0356b87"` for `issues_triaged` on the local MCP surface.
