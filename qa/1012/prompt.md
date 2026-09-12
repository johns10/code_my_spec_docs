# QA Story 1012: The main agent sees what each of its agents is working on

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the main agent, I want to see what each of my agents is currently working on, so that I know where the project's effort is going without asking each one.

## Acceptance criteria

- Every agent's current work in one view
- The work is named, not just the state
- Idle and broken do not look the same
- A question about all the agents at once is answerable
- An agent that stopped reporting is not shown as working
- The main agent reasons from the parts rather than reading a verdict
- A task opened an hour ago with nothing said for forty-five minutes
- An agent waiting on an answer says so
- An agent that tapped out is not mistaken for one that stalled
- A long silence with a live connection is not a stall
- An agent mid-response shows work in flight
- An agent with nothing to do says exactly that
- A coding agent's working-copy problems are shown with it
- A clean working copy shows no problems against its agent

## BDD spec files

- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3270_every_agents_current_work_in_one_view_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3271_the_work_is_named_not_just_the_state_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3272_idle_and_broken_do_not_look_the_same_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3273_a_question_about_all_the_agents_at_once_is_answerable_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3274_an_agent_that_stopped_reporting_is_not_shown_as_working_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3275_the_main_agent_reasons_from_the_parts_rather_than_reading_a_verdict_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3276_a_task_opened_an_hour_ago_with_nothing_said_for_forty-five_minutes_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3277_an_agent_waiting_on_an_answer_says_so_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3278_an_agent_that_tapped_out_is_not_mistaken_for_one_that_stalled_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3279_a_long_silence_with_a_live_connection_is_not_a_stall_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3297_an_agent_mid-response_shows_work_in_flight_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3298_an_agent_with_nothing_to_do_says_exactly_that_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3299_a_coding_agents_working-copy_problems_are_shown_with_it_spex.exs`
- `test/spex/1054_the_main_agent_sees_what_each_of_its_agents_is_working_on/criterion_3300_a_clean_working_copy_shows_no_problems_against_its_agent_spex.exs`

## Linked component: MainAgent

This story is implemented by `CodeMySpec.MainAgent` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/main_agent_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/main_agent.spec.md`
- Source: `lib/code_my_spec/main_agent.ex`

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

Write the brief to `.code_my_spec/qa/1012/brief.md` matching this spec exactly.
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