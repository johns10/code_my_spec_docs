# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Prompt includes all accepted issues regardless of severity

pass

Called `FixIssues.command/2` after seeding five accepted issues at severities
`:critical`, `:high`, `:medium`, `:low`, and `:info` against the QA Fixture Project
(id `11111111-1111-4111-8111-111111111111`). All five issue IDs appeared in the
returned prompt. No severity filter is applied — the working set is every accepted
issue.

The spex criterion 5387 ("Five accepted issues spanning every severity all appear
in the fix prompt") passed in the full `mix spex` run (528 tests, 0 failures).

### Scenario 2: resolve_issue flips status from accepted to resolved

pass

Criterion 5390 exercises `ResolveIssue.execute/2` directly. The `then_` steps
verify that (a) the response contains "resolved" and (b) calling
`ListIssues.execute(%{status: "accepted"}, frame)` no longer returns the resolved
issue's ID. Both assertions passed in the spex suite.

Manual probe confirmed `FixIssues.evaluate/2` returns `{:ok, :invalid, <msg>}`
when an accepted issue exists (message contains "unresolved"), and returns
`{:ok, :valid}` once all issues are resolved.

### Scenario 3: Missing resolve_issue call causes evaluate to fail

pass

Criterion 5391 exercises `EvaluateTask.execute/2` on an active `issues_resolved`
task that has an unresolved accepted issue. The response must contain
"needs work" or "not met" and "unresolved". Spex passed.

`FixIssues.evaluate/2` manual probe: calling it when an accepted issue exists
returned `{:ok, :invalid, "1 unresolved accepted issue(s):\n..."}` — confirming
the feedback names the gap.

### Scenario 4: All issues resolved — evaluate passes and graph advances

pass

Criterion 5392 exercises the stop hook path: starts the `issues_resolved` task
on a project with only a resolved issue, fires `/api/hooks/stop`, then calls
`GetNextRequirement.execute/2` and asserts `issues_resolved` is not in the
response. Spex passed.

### Scenario 5: Prompt references regression-handling playbook and forbids silencing

pass

Manual probe of `FixIssues.command/2` output with one accepted issue:

- `String.contains?(prompt, "regression")` → `true`
- `String.contains?(prompt, "silencing")` → `true`
- `String.contains?(prompt, "priv/knowledge/fix_issues/workflow.md")` → `true`

The prompt's "Read the playbook" section points at `priv/knowledge/fix_issues/workflow.md`,
which contains the "Regression handling — strict no-silencing rules" section explicitly
prohibiting `@tag :pending`, `@tag :skip`, and weakening/deleting tests.

Criterion 5393 spex passed in the full `mix spex` run.

### Scenario 6: Prompt groups accepted issues by scope with section headers

pass

Manual probe seeding 5 accepted issues (3 `:app`, 1 `:qa`, 1 `:docs`) confirmed:

- `String.contains?(prompt, "## Scope: app")` → `true`
- `String.contains?(prompt, "## Scope: qa")` → `true`
- `String.contains?(prompt, "## Scope: docs")` → `true`
- All 5 issue blocks contained `**Scope:** <scope>` with their declared scope value

Criterion 5394 spex passed in the full `mix spex` run.

## Evidence

- Spex run: `mix spex test/spex/608_fix_accepted_qa_issues/` — 528 tests, 0 failures, 17.2 seconds
- Manual probe Scenario 1: all 5 severity levels (critical, high, medium, low, info) confirmed present in prompt
- Manual probe Scenario 5: regression/silencing/workflow.md confirmed in prompt output
- Manual probe Scenario 6: scope section headers and per-issue scope lines confirmed in prompt output
- Manual probe Scenario 3: `FixIssues.evaluate/2` returns `:invalid` with "unresolved" when accepted issues exist

## Issues

None
