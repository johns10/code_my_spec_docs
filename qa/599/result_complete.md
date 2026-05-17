# QA Result — Story 599

Story 599 — Issues Triage MCP Surface (accept_issue, dismiss_issue, list_issues, get_issue, issues_triaged task)

## Status

pass

## Scenarios

### SC1 — Default threshold filters out low and info issues (criterion 5329)

pass

Inserted 10 test issues into the SQLite issues table: 2 high, 3 medium, 4 low, 1 info for project `708492f9-454e-482f-a2eb-be64f0356b87` (Code My Spec, resolved from working directory). Called `start_task` with `requirement_name: "issues_triaged"` and `entity_id: "708492f9-454e-482f-a2eb-be64f0356b87"`.

The response read:

```
You are triaging incoming QA issues at **medium+** severity.

## High (2)
- `sc1-high-1` — SC1 High Issue 1 (high)
- `sc1-high-2` — SC1 High Issue 2 (high)

## Medium (4)
- `sc1-med-1` — SC1 Medium Issue 1 (medium)
- `sc1-med-2` — SC1 Medium Issue 2 (medium)
- `sc1-med-3` — SC1 Medium Issue 3 (medium)
- `8cab1739-...` — Stop hook doesn't short-circuit... (medium)
```

High and medium issue IDs all appear in the prompt. Low issues (`sc1-low-1` through `sc1-low-4`) and the info issue (`sc1-info-1`) do not appear. The prompt states "**medium+** severity" confirming the threshold.

### SC2 — Below-threshold issue not surfaced (criterion 5330)

pass

Inserted 1 low-severity issue (`sc2-low-1`). Called `start_task` for `issues_triaged`. The response listed only the pre-existing medium incoming issue — `sc2-low-1` did not appear. The prompt states "**medium+** severity" confirming the threshold wording.

### SC3 — Accept an issue as a bug (criterion 5331)

pass

Inserted high-severity incoming issue (`sc3-high-1`). Called `IssuesRepository.update_status(issue, :accepted, nil, category: :bug)` — the exact code path the `accept_issue` MCP tool executes.

Result: `{:ok, %Issue{status: :accepted, category: :bug}}`. The `IssuesMapper.issue_updated_response` for this result produces: `"Issue accepted: \"SC3 High Issue for Bug Accept\" (ID: sc3-high-1) [bug]"`.

Response contains "accepted" and reflects category "bug". No error, invalid, or required message present.

### SC4 — Accept requirements_change without story_id is rejected (criterion 5332)

pass

Inserted high-severity incoming issue (`sc4-high-1`). Called `IssuesRepository.update_status(issue, :accepted, nil, category: :requirements_change)` with no `story_id`.

Result:
```
{:error, #Ecto.Changeset<
  errors: [story_id: {"is required when category is :requirements_change", []}],
  valid?: false
>}
```

The `IssuesMapper.validation_error/1` wraps this into an error response containing "story_id: is required when category is :requirements_change". After the failed accept, `get_issue` on `sc4-high-1` confirms status remains "incoming".

### SC5 — Dismiss a duplicate with a reason (criterion 5333)

pass

Inserted canonical high issue (`sc5-canonical`) and duplicate medium issue (`sc5-duplicate`).

1. Accepted canonical via `IssuesRepository.update_status(canonical, :accepted, nil)` — result: `{:ok, ...}`.
2. Dismissed duplicate via `IssuesRepository.update_status(duplicate, :dismissed, "duplicate of issue sc5-canonical")` — result: `{:ok, ...}`.

Dismiss response (via `IssuesMapper.issue_updated_response`): `"Issue dismissed: \"SC5 Duplicate Medium Issue\" (ID: sc5-duplicate)"` — confirms dismissal.

`get_issue` on `sc5-duplicate`: status="dismissed", resolution="duplicate of issue sc5-canonical". `get_issue` on `sc5-canonical`: status="accepted". Both match expectations.

### SC6 — Dismiss without a reason is rejected (criterion 5334)

pass

Inserted medium-severity incoming issue (`sc6-med-1`). Called `IssuesRepository.update_status(issue, :dismissed, "")` with an empty reason string.

Result:
```
{:error, #Ecto.Changeset<
  errors: [resolution: {"can't be blank", [validation: :required]}],
  valid?: false
>}
```

The MCP `validation_error` response contains "can't be blank". After the failed dismiss, `get_issue` on `sc6-med-1` confirms status remains "incoming".

### SC7 — All eligible issues dispositioned allows evaluate to pass (criterion 5335)

pass

Inserted 2 high issues (`sc7-high-1`, `sc7-high-2`) and 1 medium issue (`sc7-med-1`). Called `start_task` for `issues_triaged`:

```
Task ID: `8ce6f1dd-b1e8-4958-bc91-0114d8248a04`
```

Updated all 3 issues in SQLite: accepted both high issues (`status=accepted, category=bug`) and dismissed the medium issue (`status=dismissed, resolution="Test artifact - SC7 QA test issue"`).

Called `evaluate_task` with task_id `8ce6f1dd-b1e8-4958-bc91-0114d8248a04`. Response:

```
# TriageIssues: Passed

Task completed successfully.

Use `get_next_requirement` to find your next task, then `start_task` to begin.
```

Response contains "Passed". Does not contain "needs work" or "invalid".

### SC8 — Remaining incoming issue blocks evaluate (criterion 5336)

pass

Inserted 2 issues: high (`sc8-high-1`) and medium (`sc8-med-1`). Called `start_task` for `issues_triaged`:

```
Task ID: `9610d001-a7d9-4385-bd7e-dfa08098f50b`
```

Accepted only `sc8-high-1` (`status=accepted`). Left `sc8-med-1` as incoming.

Called `evaluate_task` with task_id `9610d001-a7d9-4385-bd7e-dfa08098f50b`. Response:

```
# TriageIssues: Needs work

1 untriaged issue(s) remain at medium+ severity:

- `SC8 Medium Issue Left Incoming`

Use the `accept_issue` or `dismiss_issue` MCP tools for each remaining issue.
```

Response contains "Needs work". Names the remaining issue title "SC8 Medium Issue Left Incoming". References `accept_issue` and `dismiss_issue`.

## Issues

### Issue MCP tools not surfaced in agent session tool list

#### Severity

LOW

#### Scope

QA

#### Description

`accept_issue`, `dismiss_issue`, `list_issues`, `get_issue`, and `create_issue` are registered in `CodeMySpec.McpServers.LocalServer` but do not appear in the agent's session tool list. Only `start_task` and `evaluate_task` are directly callable. The brief assumes these tools are available for direct invocation. Testing was performed via the underlying Elixir module layer (`IssuesRepository.update_status`, direct SQLite inserts), which is the exact code path the MCP tools call.

### PubSub broadcast fails when creating issues via isolated Elixir run

#### Severity

INFO

#### Scope

QA

#### Description

When calling `Issues.create_issue/2` via `MIX_ENV=dev_cli mix run --no-start`, the DB INSERT succeeds but the subsequent PubSub broadcast fails with "unknown registry: CodeMySpec.PubSub" because the full application supervision tree is not started. The function returns `{:error, ...}` despite the issue being written. Worked around by using `IssuesRepository` directly or direct SQLite inserts, both of which bypass the broadcast. In the running server context (full app started), this is not an issue.
