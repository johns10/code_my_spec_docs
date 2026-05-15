# CodeMySpec.AgentTasks.FixIssues

## Type

skill

## Intent

Take every accepted QA issue and work through fixes, marking each
resolved via `resolve_issue`. The working set is everything that
made it past `triage_issues` — no severity filter at this layer.
Scope-aware: `app` issues fix application code, `qa` issues fix
test infrastructure, `docs` issues fix documentation. Regressions
must be fixed in source, never silenced.

## Done signal

`Issues.list_by_status(scope, :accepted)` returns `[]`. The
evaluator re-queries the DB on each session end; if any accepted
issues remain, it names them in the feedback and instructs the
agent to call `resolve_issue` per id.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the
requirement graph as `issues_resolved` (id 7), gated by
`issues_triaged` (id 6).

## Out of scope

- The task does not classify or accept issues. That's `triage_issues`
  (which promotes from `incoming` → `accepted` or `dismissed`).
- The task does not write QA results or file new issues. That's
  qa_story / qa_journey work.
- The task does not introduce severity filters. Whatever triage
  accepted gets fixed.

## Failure modes the agent should avoid

- Adding `@tag :pending` or `@tag :skip` to a failing test instead
  of fixing it.
- Weakening assertions to make a failing test pass.
- Deleting a failing test rather than diagnosing the cause.
- Fixing application code for a `qa`-scoped issue (or vice versa).
- Calling `resolve_issue` without verifying the fix with `mix test`.

## Resources

Required input:
- The project's accepted issues — `Issues.list_by_status(scope, :accepted)`.
- The QA plan at `.code_my_spec/qa/plan.md` — for server / seeds / auth.
- Per-story QA evidence at `.code_my_spec/qa/<story_id>/` — failed
  results and screenshots referenced by issues.

Required reading:
- `priv/knowledge/fix_issues/workflow.md` — per-issue procedure,
  scope-aware fixing rules, regression handling (no-silencing),
  MCP tool usage.

Produced (in the DB, not on disk):
- Each accepted issue resolved with a `resolution` field describing
  the fix.

## Tools

- **`get_issue`** — read full issue details by id.
- **`resolve_issue`** — mark resolved with `id` and `resolution`.
- **`list_issues`** — re-check the accepted list against the DB.

Built-ins (Read, Write, Edit, Bash for `mix test`) handle the fix
work. The Agent tool (subagent spawning) is used to parallelize
related fixes per the workflow.

## Dependencies

- CodeMySpec.Issues
- CodeMySpec.Issues.Issue
- CodeMySpec.Paths
