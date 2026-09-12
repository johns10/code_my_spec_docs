# QA Story 964: I approve an epic and it gets built somewhere else

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

The hand-off. The main agent (story 963) shapes stories and groups them into an epic; this is what happens when the user agrees to build one. An epic goes to a working copy, agents there do the detailed design and the code, and the main agent's job turns into reporting on work it is not doing. The mechanic already half exists: `ready_for_dev` is a flag on a story today and nothing consumes it as a hand-off.

## Acceptance criteria

- Agreeing is agreement, and placement is its own act
- A proposal I ignore changes nothing
- Ready for development is not the same as started
- A busy project is not given more work
- An idle project with nothing left to assign is finished, not stuck
- The detailed design happens where the code will be written
- A second epic can go to a copy that already has one
- Asking about dispatched work gets a report
- Work that went wrong is reported as wrong, not as silence
- An idle project with work waiting gets an epic put in front of me
- I watch the epic take shape and approve it where it is
- An epic goes where the context already is
- A fresh copy when nothing fits
- A new copy arrives with its three agents
- An agent that never came up is not a copy that is ready
- The same three take the next epic
- I discard the copy and its agents go with it
- A new epic gets a new copy, not the old one's agents

## BDD spec files

- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2930_agreeing_is_agreement_and_placement_is_its_own_act_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2931_a_proposal_i_ignore_changes_nothing_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2932_ready_for_development_is_not_the_same_as_started_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2933_a_busy_project_is_not_given_more_work_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2934_an_idle_project_with_nothing_left_to_assign_is_finished_not_stuck_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2935_the_detailed_design_happens_where_the_code_will_be_written_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2936_a_second_epic_can_go_to_a_copy_that_already_has_one_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2938_asking_about_dispatched_work_gets_a_report_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2939_work_that_went_wrong_is_reported_as_wrong_not_as_silence_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2941_an_idle_project_with_work_waiting_gets_an_epic_put_in_front_of_me_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_2942_i_watch_the_epic_take_shape_and_approve_it_where_it_is_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3085_an_epic_goes_where_the_context_already_is_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3086_a_fresh_copy_when_nothing_fits_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3087_a_new_copy_arrives_with_its_three_agents_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3088_an_agent_that_never_came_up_is_not_a_copy_that_is_ready_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3090_the_same_three_take_the_next_epic_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3091_i_discard_the_copy_and_its_agents_go_with_it_spex.exs`
- `test/spex/1026_i_approve_an_epic_and_it_gets_built_somewhere_else/criterion_3092_a_new_epic_gets_a_new_copy_not_the_old_ones_agents_spex.exs`

## Linked component: EpicDispatch

This story is implemented by `CodeMySpec.EpicDispatch` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/epic_dispatch_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/epic_dispatch.spec.md`
- Source: `lib/code_my_spec/epic_dispatch.ex`

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

Write the brief to `.code_my_spec/qa/964/brief.md` matching this spec exactly.
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