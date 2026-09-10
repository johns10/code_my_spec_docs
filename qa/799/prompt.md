# QA Story 799: Validation Pipeline Redesign — Stop Hook Core Behaviors

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer relying on the stop hook to gate the agent, I want the hook's core pipeline behaviors (sync scope, compile-first, analyzer gates, task-type short-circuits, continuous mode) to match the documented rules — so blocking is predictable and the agent neither gets stuck on stale state nor waves through broken code.

## Acceptance criteria

- When a task has started and no files have changed since its started_at, the stop hook skips the pipeline and the stop is allowed.
- When an implementation file has changed, the stop hook enqueues the relevant analyzers in the background and the stop decision is made immediately from persisted problems — the response returns well under the hook timeout regardless of how long analyzers take.
- When a background compile completes with errors, the errors are persisted as compiler problems and block the next stop; if the agent's turn already ended, the engineer receives a push notification about them.
- When a background credo run finds violations on files changed during the task, the violations are persisted as problems and the next stop blocks with the credo problems listed.
- When no active task exists but files have changed on disk, the stop hook still runs the pipeline and analyzers, but task evaluation is skipped and the stop is allowed if no blocking problems are found.
- When the active task is a subagent task (execution_type: :sub_agent), the stop hook skips validation entirely and allows the stop immediately.
- When the active task has validation_type: :manual, the stop hook skips validation and task evaluation and allows the stop.
- Problems on files this session did not edit do not block the stop. When the stop hook fires for session A, any analyzer problem whose file was last edited by a different session (or a different agent inside session A) is filtered out of the block decision; only problems on files attributed to (session_id, agent_id) of the current stop count toward block/allow.
- Persisted unresolved problems block the stop even when no files changed this turn
- Stop hook filters analyzer problems by PostToolUse attribution
- A dropped or timed-out hook connection can never strand problems: analyzer runs and their clear-then-insert reconcile complete in a supervised background task regardless of whether the HTTP caller is still listening, and the reconcile is atomic (all-or-nothing).
- When an analyzer's inputs are unchanged since its last completed run (input fingerprint matches the run ledger), the stop hook does not re-run that analyzer — persisted problems from the recorded run stand as-is.
- A stop that finds analysis still running is a distinct pending outcome: it never counts toward repeated-feedback stuck detection (R8), and the "all work complete" terminus (R6) never fires while runs are in flight — the agent is directed to await the running analysis instead.

## BDD spec files

- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5097_when_a_task_has_started_and_no_files_have_changed_since_its_started_at_the_stop_hook_skips_the_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5098_when_an_implementation_file_has_changed_and_the_pipeline_runs_cleanly_compile_and_tests_pass_the_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5099_when_compilation_fails_with_errors_the_stop_hook_blocks_with_the_compiler_diagnostics_and_no_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5100_when_credo_finds_violations_on_files_changed_during_the_task_the_stop_hook_blocks_with_the_credo_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5101_when_no_active_task_exists_but_files_have_changed_on_disk_the_stop_hook_still_runs_the_pipeline_and_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5102_when_the_active_task_is_a_subagent_task_execution_type_sub_agent_the_stop_hook_skips_validation_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_5103_when_the_active_task_has_validation_type_manual_the_stop_hook_skips_validation_and_task_evaluation_spex.exs`
- `test/spex/555_validation_pipeline_redesign_stop_hook_core_behaviors/criterion_6237_stop_hook_filters_problems_by_session_attribution_spex.exs`

## Linked component: Validation

This story is implemented by `CodeMySpec.Validation` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/validation_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/validation.spec.md`
- Source: `lib/code_my_spec/validation.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/stripe_get_subs.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_github.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_google.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_resend.sh`

## Required reading: QA plan

Read `.code_my_spec/qa/plan.md` first. It contains the App Overview, Tools
Registry, auth strategy, and Seed Strategy you need before writing the
brief. The plan is produced and maintained by the `qa_setup` task; if
it's missing or incomplete, the evaluator will tell you to run that
task first.

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/799/brief.md` matching this spec exactly.
The evaluator validates the brief structure on stop.

# Qa Story Brief

Per-story QA testing brief. Written by the QA planner after reading the story's prompt file and the QA plan. Gives the tester exact instructions — tool, auth, seeds, what to test.

## Required Sections

### Tool

Format:
- Use H2 heading
- Single line: tool name (web, curl, or script path)

Content:
- Which tool to use for this story's testing
- `web` for LiveView pages, `curl` or script path for controller/API routes


### Auth

Format:
- Use H2 heading
- Exact commands or instructions the tester copies verbatim

Content:
- Login URL, credentials, headers — whatever the tool needs
- Reference auth scripts from the QA plan if applicable
- Tester should not need to figure out auth on their own


### Seeds

Format:
- Use H2 heading
- Exact commands to run

Content:
- Seed script references (`mix run priv/repo/qa_seeds.exs`)
- Any story-specific seed commands beyond the base seeds
- Entity IDs or values the tester will need


### What To Test

Format:
- Use H2 heading
- Bullet list of specific test scenarios

Content:
- Specific URLs to visit
- Interactions to perform (click, fill form, submit)
- Expected outcomes (what the tester should see)
- Map to acceptance criteria from the story


### Result Path

Format:
- Use H2 heading
- Single line: file path

Content:
- Where the tester writes the result document


## Optional Sections

### Setup Notes

Format:
- Use H2 heading
- Free-form paragraphs

Content:
- Additional context, prerequisites, known issues



## Findings and done signal

Every finding you uncover during execution gets filed via
`mcp__plugin_codemyspec_local__create_issue` **as you find it** — not
written into a markdown file. Capture the title, severity, scope, and a
short description; the call returns an issue id. Hold those ids.

When you finish the session, call
`mcp__plugin_codemyspec_local__submit_qa_result` with the structured
scenarios payload **and** every issue id you filed:

    mcp__plugin_codemyspec_local__submit_qa_result(
      task_id: <task_id>,
      status: "pass" | "partial" | "fail",
      scenarios: [%{name: "...", status: "pass|partial|fail", observation: "..."}, ...],
      issue_ids: [<every id returned from create_issue>]
    )

Discipline:

- **`status: "pass"`** with `issue_ids: []` is fine.
- **`status: "partial"` or `"fail"`** with `issue_ids: []` is **rejected
  by the tool**. A failure with no filed issue is a finding that just
  disappeared when your session ended — there's nowhere else for it to
  live. File the issues first, then submit.
- The bare `submit_qa_result` (without the `mcp__plugin_codemyspec_local__`
  prefix) does NOT resolve — use the fully-qualified name.
- Attribution follows automatically: on submit, every `scope: app` issue
  you listed is attached to this story, and `story_issues_resolved` holds
  the story's release until they're fixed. `framework`, `qa` and `docs`
  findings are about the tooling rather than the story, so they queue at
  the project level instead. If an issue belongs to a *different* story,
  pass that `story_id` on the `create_issue` call — an explicit
  attribution is never overwritten.
- Don't write findings into a result.md file. The harness doesn't read it.
  Screenshots and other evidence still belong on disk, but the canonical
  record is the DB attempt + linked issues.