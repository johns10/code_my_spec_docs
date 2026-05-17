# Qa Story Brief

## Tool

`mcp__plugin_codemyspec_local__start_task` and `mcp__plugin_codemyspec_local__evaluate_task` for SC1/SC2/SC7/SC8. Unit tests (`mix test`) for SC3-SC6 changeset validation. Vibium browser for visual evidence.

## Auth

This story tests the MCP layer — the `start_task` / `evaluate_task` tools for the `issues_triaged` project requirement, and the issues tools (`accept_issue`, `dismiss_issue`, `list_issues`, `get_issue`). The `start_task` / `evaluate_task` tools are available via `mcp__plugin_codemyspec_local__*`. The issues tools are registered in the local MCP server but not exposed as plugin tools — test them via unit tests.

**Important**: The local MCP server runs under `MIX_ENV=dev_cli` using SQLite at `~/.codemyspec/cli.db`. It is a SEPARATE database from the hosted app (Postgres at port 4000). The project that resolves from `/Users/johndavenport/Documents/github/code_my_spec` in the CLI DB is the **Code My Spec** project (id `708492f9-454e-482f-a2eb-be64f0356b87`), NOT the QA Fixture Project. Use this entity_id for `start_task` calls.

The hosted web (port 4000/Postgres) uses a different DB — issue operations there do not affect the `issues_triaged` requirement evaluation.

No browser auth needed for MCP calls. For Vibium screenshots, use the local web at port 4003 (no auth required) or the hosted web at port 4000 with `qa@codemyspec.local` / `qa-password-123!`.

## Seeds

Run the base QA seed to ensure the QA user exists on the hosted DB:

```
mix run priv/repo/qa_seeds.exs
```

No CLI DB seeds are needed — the Code My Spec project already exists in the CLI DB with existing issues. Check incoming issues before testing SC7/SC8.

## What To Test

### SC1 — Default threshold filters out low and info issues (criterion 5329)

1. Call `start_task` with `requirement_name: "issues_triaged"`, `entity_type: "project"`, `entity_id: "708492f9-454e-482f-a2eb-be64f0356b87"`
2. Assert: prompt mentions "medium+" as the threshold
3. Assert: prompt lists high and medium incoming issues (if any exist)
4. Assert: prompt does NOT include low or info issues
5. Verify via issues list at `http://127.0.0.1:4003/projects/code-my-spec/issues`

### SC2 — Below-threshold issue not surfaced (criterion 5330)

1. Call `start_task` for `issues_triaged` with default threshold
2. Assert: the prompt does NOT list any low-severity issues
3. Assert: the prompt states "medium+" threshold

### SC3 — Accept an issue as a bug (criterion 5331)

Run via unit tests:
```
mix test test/code_my_spec/mcp_servers/issues/tools/lifecycle_test.exs
```
Assert: `AcceptIssue.execute(%{issue_id: id, category: "bug"}, frame)` returns isError=false with "accepted" in response.

Also verify changeset:
```
mix run -e 'IO.inspect(CodeMySpec.Issues.Issue.status_changeset(%CodeMySpec.Issues.Issue{status: :incoming}, %{status: :accepted, category: :bug}).valid?)'
```

### SC4 — Accept requirements_change without story_id is rejected (criterion 5332)

Run via changeset validation:
```
mix run -e '
issue = %CodeMySpec.Issues.Issue{id: "test", title: "t", severity: :high, description: "d", status: :incoming}
cs = CodeMySpec.Issues.Issue.status_changeset(issue, %{status: :accepted, category: :requirements_change})
IO.puts("valid: #{cs.valid?}, errors: #{inspect(cs.errors)}")
'
```
Assert: `valid: false`, errors include `story_id: "is required when category is :requirements_change"`.

### SC5 — Dismiss a duplicate with a reason (criterion 5333)

Run lifecycle test:
```
mix test test/code_my_spec/mcp_servers/issues/tools/lifecycle_test.exs
```
Assert: `DismissIssue.execute(%{issue_id: id, reason: "Not a real bug"}, frame)` returns isError=false with "dismissed" in response.

### SC6 — Dismiss without a reason is rejected (criterion 5334)

Verify changeset:
```
mix run -e '
issue = %CodeMySpec.Issues.Issue{id: "test", title: "t", severity: :medium, description: "d", status: :incoming}
cs = CodeMySpec.Issues.Issue.status_changeset(issue, %{status: :dismissed, resolution: ""})
IO.puts("valid: #{cs.valid?}, errors: #{inspect(cs.errors)}")
'
```
Assert: `valid: false`, errors include `resolution: "can't be blank"`. The MCP response wraps this as `## Validation Error` which satisfies `~r/error|invalid|required/i`.

### SC7 — All eligible issues dispositioned allows evaluate to pass (criterion 5335)

1. Call `start_task` for `issues_triaged` — capture task_id from response footer
2. Disposition all incoming medium+ issues (accept or dismiss)
3. Call `evaluate_task` with the task_id
4. Assert: response contains "Passed" (not "Needs work")

### SC8 — Remaining incoming issue blocks evaluate (criterion 5336)

1. Call `start_task` for `issues_triaged` — capture task_id
2. Leave at least one incoming medium+ issue undispositioned
3. Call `evaluate_task` with task_id
4. Assert: response contains "Needs work" and names the remaining issue
5. Assert: response references `accept_issue` or `dismiss_issue`

## Setup Notes

The local MCP server uses SQLite (`~/.codemyspec/cli.db`). Direct writes via `sqlite3` while the server is running will block or fail due to WAL write lock. Use the MCP tools (via the plugin) or unit tests instead.

The `mcp__plugin_codemyspec_local__*` plugin only exposes `start_task` and `evaluate_task` — not the issues tools. Test `accept_issue`, `dismiss_issue`, `get_issue`, and `create_issue` via unit tests (`lifecycle_test.exs`, `issue_test.exs`).

The `issues_triaged` requirement is a project-level requirement in the computed graph, found under `entity_type: "project"` with `entity_id: "708492f9-454e-482f-a2eb-be64f0356b87"` (Code My Spec project).

## Result Path

.code_my_spec/qa/599/result.md
