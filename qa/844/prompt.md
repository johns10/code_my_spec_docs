# QA Story 844: Mark Stories Ready for Development to Control Pace

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a user, I want to organize my stories into epics and mark stories ready for development individually or in bulk, so I control the pace at which stories enter the build queue.

## Acceptance criteria

- User groups loose stories into a named epic
- Assigning a story to a new epic moves it out of the old one
- A newly created story is not ready for development
- Bulk-releasing an epic stamps each story once
- Marking a story ready releases it into the graph
- Un-readying a story with work already in flight
- Product management agent sees the parked backlog
- User flips a story ready from the project UI
- Three Amigos cannot start on a story that is not ready
- Releasing a story starts the chain at the beginning
- User renames an epic from the board without disturbing its stories
- Parking an epic takes its stories back out of the graph
- Deleting an epic returns its stories to the unfiled column

## BDD spec files

- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7938_user_groups_loose_stories_into_a_named_epic_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7939_assigning_a_story_to_a_new_epic_moves_it_out_of_the_old_one_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7940_a_newly_created_story_is_not_ready_for_development_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7941_bulk-releasing_an_epic_stamps_each_story_once_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7942_marking_a_story_ready_releases_it_into_the_graph_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7943_un-readying_a_story_with_work_already_in_flight_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7944_product_management_agent_sees_the_parked_backlog_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7945_user_flips_a_story_ready_from_the_project_ui_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7952_three_amigos_cannot_start_on_a_story_that_is_not_ready_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7953_releasing_a_story_starts_the_chain_at_the_beginning_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7956_user_renames_an_epic_from_the_board_without_disturbing_its_stories_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7957_parking_an_epic_takes_its_stories_back_out_of_the_graph_spex.exs`
- `test/spex/958_mark_stories_ready_for_development_to_control_pace/criterion_7958_deleting_an_epic_returns_its_stories_to_the_unfiled_column_spex.exs`

## Linked component: Index

This story is implemented by `CodeMySpecWeb.EpicsLive.Index` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/epics_live/index_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/epics_live/index.spec.md`
- Source: `lib/code_my_spec_web/live/epics_live/index.ex`

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

Write the brief to `.code_my_spec/qa/844/brief.md` matching this spec exactly.
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