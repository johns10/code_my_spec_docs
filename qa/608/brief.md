# Qa Story Brief

## Tool

MCP tools (`mcp__plugin_codemyspec_local__*`) — the `fix_issues` / `issues_resolved`
requirement is surfaced exclusively via the `start_task` and `evaluate_task` MCP tools
on the local server. There is no LiveView or REST route to test separately.

## Auth

No auth required for the local MCP server (port 4004). The server uses
`Plugs.LocalOnly` — loopback IP is trusted. The `X-Working-Dir` header provides
project scope.

For hook calls:
- Header: `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`
- All MCP tool calls use the `mcp__plugin_codemyspec_local__*` tool family

## Seeds

Run server (Postgres) seeds to ensure QA fixture project exists:

```
mix run priv/repo/qa_seeds.exs
```

For MCP-surface tests, target the sandbox project to avoid polluting the working checkout:
- Sandbox path: `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`
- QA Fixture Project ID: `11111111-1111-4111-8111-111111111111`

To seed issues for testing, use Elixir in-process through the MCP tools or
the spex fixtures. The `FixIssues` module reads from the DB at call time,
so seeding issues before calling `start_task` for `issues_resolved` is sufficient.

## What To Test

### Scenario 1: Prompt includes all accepted issues regardless of severity

Start the `issues_resolved` task when accepted issues span all five severity levels
(`:critical`, `:high`, `:medium`, `:low`, `:info`). Verify the prompt lists all
five issue IDs — confirming no severity filter is applied.

- Call `start_task` with `requirement_name: "issues_resolved"` on the sandbox project
- Observe the returned prompt text
- Expected: all five issue IDs appear in the prompt regardless of severity
- Maps to AC: "Five accepted issues spanning every severity all appear in the fix prompt"

### Scenario 2: resolve_issue flips status from accepted to resolved

Create an accepted issue. Call `resolve_issue` with the issue ID and a resolution
containing what/files/verification. Then call `list_issues` filtering by status
`accepted` and confirm the issue no longer appears.

- Call `mcp__plugin_codemyspec_local__start_task` for `issues_resolved`
- Call `resolve_issue` with the issue id and a complete resolution body
- Call `list_issues` with `status: "accepted"` and confirm the issue is absent
- Expected: issue status flips to `:resolved`; response confirms "resolved"
- Maps to AC: "Agent fixes the bug, calls resolve_issue with what / files / verification, status flips accepted → resolved"

### Scenario 3: Missing resolve_issue call causes evaluate to fail

Create an accepted issue but do NOT call `resolve_issue`. Call `evaluate_task`
on the active `issues_resolved` task. Verify the response signals needs-work and
names the unresolved issue.

- Start a `issues_resolved` task via `start_task`
- Do not call `resolve_issue`
- Call `evaluate_task` with the task_id
- Expected: response contains "needs work" or "not met" and references "unresolved" issues
- Maps to AC: "Agent fixes the code but skips resolve_issue, evaluate fails listing the still-accepted issue"

### Scenario 4: All issues resolved — evaluate passes and graph advances

Create a project with only resolved issues (no accepted ones). Start the
`issues_resolved` task. Fire the stop hook. Verify `get_next_requirement` no longer
returns `issues_resolved`.

- Call `start_task` for `issues_resolved` on a project with no accepted issues
- Call the stop hook at `/api/hooks/stop`
- Call `get_next_requirement` and confirm `issues_resolved` is not returned
- Maps to AC: "mix test passes clean after fixes, evaluate marks the task done"

### Scenario 5: Prompt references regression-handling playbook and forbids silencing

Start the `issues_resolved` task with at least one accepted issue. Inspect the
prompt for: reference to `priv/knowledge/fix_issues/workflow.md`, the word
"regression", and the word "silencing" or "silence".

- Call `start_task` for `issues_resolved`
- Read the returned prompt
- Expected: prompt mentions "regression", "silencing"/"silence", and `priv/knowledge/fix_issues/workflow.md`
- Maps to AC: "A fix breaks an unrelated test, agent fixes the regression rather than tagging it pending or claiming completion"

### Scenario 6: Prompt groups accepted issues by scope with section headers

Create 5 accepted issues across three scopes (`:app` x3, `:qa` x1, `:docs` x1).
Start `issues_resolved`. Verify the prompt has `## Scope: app`, `## Scope: qa`,
`## Scope: docs` headers, and each issue block contains `**Scope:** <scope>`.

- Call `start_task` for `issues_resolved`
- Inspect the prompt for scope section headers and per-issue scope lines
- Expected: three scope sections, each issue block has `**Scope:** <scope>`
- Maps to AC: "Five accepted issues across three scopes — prompt has three scope sections, each issue lists its scope"

## Result Path

`.code_my_spec/qa/608/result.md`
