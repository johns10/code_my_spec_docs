# QA Story 796: LLM Agent Autonomous Task Execution

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the LLM agent, I receive tasks from the orchestrator, complete them, and am automatically directed to the next task so that I can work through the project requirements without user intervention.

## Acceptance criteria

- When continuous mode is off and the current task passes, the stop is allowed.
- When get_next_requirement names a sub-agent task type, the agent spawns a sub-agent instead of calling start_task itself.
- When a manual-validation task completes and the human signals done in conversation, the agent calls evaluate_task and on a passing evaluation the loop continues.
- When a manual-validation task completes and the human signals done but evaluate_task fails, the agent receives feedback and iterates on the same task.
- When the last actionable requirement is satisfied, the next stop is allowed and the user is notified.
- When evaluate_task returns the same feedback hash five times in a row in a session, the autonomous loop terminates and escalates.
- When the agent voluntarily taps out of continuous mode, the request is routed to PermissionSocket for human approval.
- Loop terminus emits a retrospective prompt
- Block-with-feedback includes a harness-reporting hint
- When evaluate_task returns invalid feedback whose hash differs from the previously stored hash, or returns valid, the stuck-detection counter resets.
- An open task with an alive idle sub-agent directs the main agent to assign it
- The loop names a class of work and a tool call, and picks nothing
- Outstanding findings are offered before new work
- A coding agent is not held open by product's queue
- Finishing work that unblocks another role wakes that role
- A working copy is put to work in one call, and stopped the same way

## BDD spec files

- `test/spex/538_llm_agent_autonomous_task_execution/criterion_3106_a_coding_agent_is_not_held_open_by_products_queue_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_3108_finishing_work_that_unblocks_another_role_wakes_that_role_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_3109_a_working_copy_is_put_to_work_in_one_call_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5110_continuous_off_passing_task_stop_allowed_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5113_sub_agent_directive_does_not_invite_direct_start_task_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5115_manual_task_passing_evaluation_continues_loop_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5116_manual_task_failing_evaluation_iterates_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5120_last_requirement_satisfied_stop_allowed_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5122_five_consecutive_failures_terminate_loop_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_5124_voluntary_tap_out_routed_to_permission_socket_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_6219_loop_terminus_emits_retrospective_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_6220_block_with_feedback_includes_harness_hint_spex.exs`
- `test/spex/538_llm_agent_autonomous_task_execution/criterion_6485_subagent_owned_active_task_short_circuits_stop_spex.exs`

## Linked component: Sessions

This story is implemented by `CodeMySpec.Sessions` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/sessions_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/sessions.spec.md`
- Source: `lib/code_my_spec/sessions.ex`

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

Write the brief to `.code_my_spec/qa/796/brief.md` matching this spec exactly.
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