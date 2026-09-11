# QA Story 837: Agent submits QA outcomes through validated tool calls

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an agent running per-story QA, I want to plan probes, record findings, and submit a final pass/fail outcome through dedicated MCP tool calls rather than writing markdown files parsed by an evaluator, so my work cannot be lost to format drift, my findings are not dropped when I skip a step, and the harness sees every QA action as a typed event rather than a filesystem side effect.

The intended landing context is a new top-level Qa bounded context that owns the submit, findings, and outcome surface. create_issue continues to live in Issues.

## Acceptance criteria

- Agent submits a completed QA pass with one tool call
- Submit with all required fields returns an attempt id
- Submit without status is rejected at the tool boundary
- Finding flows through create_issue then is referenced by id in submit
- Submit succeeds when no brief file exists on disk
- Submit ignores any brief file that is present
- Resubmitting creates a new attempt and the latest wins for qa_complete
- Structured scenarios are queryable individually after submit
- Submit with scenarios as a single string is rejected
- Status pass satisfies qa_complete
- Status partial records an attempt but leaves qa_complete unsatisfied
- Status fail records an attempt but leaves qa_complete unsatisfied

## BDD spec files

- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6440_agent_submits_a_completed_qa_pass_with_one_tool_call_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6441_submit_with_all_required_fields_returns_an_attempt_id_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6442_submit_without_status_is_rejected_at_the_tool_boundary_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6443_finding_flows_through_create_issue_then_is_referenced_by_id_in_submit_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6444_submit_succeeds_when_no_brief_file_exists_on_disk_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6445_submit_ignores_any_brief_file_that_is_present_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6446_resubmitting_creates_a_new_attempt_and_the_latest_wins_for_qa_complete_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6447_structured_scenarios_are_queryable_individually_after_submit_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6448_submit_with_scenarios_as_a_single_string_is_rejected_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6449_status_pass_satisfies_qa_complete_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6450_status_partial_records_an_attempt_but_leaves_qa_complete_unsatisfied_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6451_status_fail_records_an_attempt_but_leaves_qa_complete_unsatisfied_spex.exs`
- `test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/criterion_6487_submit_with_fail_or_partial_status_and_empty_issue_ids_is_rejected_at_the_tool_boundary_spex.exs`

## Linked component: Qa

This story is implemented by `CodeMySpec.Qa` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/qa_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/qa.spec.md`
- Source: `lib/code_my_spec/qa.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/announce_device.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_code_mode.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_spine.sh`
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

Write the brief to `.code_my_spec/qa/837/brief.md` matching this spec exactly.
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