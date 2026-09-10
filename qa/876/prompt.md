# QA Story 876: Take my work with me when I move to the cloud harness

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As Sam, I want to move the data I built up on the free local harness to the cloud harness, so that upgrading to a paid plan costs me nothing I have already done.

## Acceptance criteria

- Sam's stories and their scenarios arrive intact
- Scanned and computed records are not carried over
- An interrupted migration costs Sam nothing
- Sam is told what moved, by kind and count
- Running the migration again adopts the existing project
- Sam's local harness is untouched by a successful migration
- A free account is told what it needs before anything moves
- Work done locally after migrating does not appear on the cloud
- Migrating one project leaves his others alone
- A failure part-way leaves nothing behind on the cloud

## BDD spec files

- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8222_sams_stories_and_their_scenarios_arrive_intact_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8223_scanned_and_computed_records_are_not_carried_over_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8224_an_interrupted_migration_costs_sam_nothing_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8225_sam_is_told_what_moved_by_kind_and_count_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8226_running_the_migration_again_adopts_the_existing_project_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8227_sams_local_harness_is_untouched_by_a_successful_migration_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8228_a_free_account_is_told_what_it_needs_before_anything_moves_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8229_work_done_locally_after_migrating_does_not_appear_on_the_cloud_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8230_migrating_one_project_leaves_his_others_alone_spex.exs`
- `test/spex/991_take_my_work_with_me_when_i_move_to_the_cloud_harness/criterion_8231_a_failure_part-way_leaves_nothing_behind_on_the_cloud_spex.exs`

## Linked component: Migration

This story is implemented by `CodeMySpec.Migration` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/migration_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/migration.spec.md`
- Source: `lib/code_my_spec/migration.ex`

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

Write the brief to `.code_my_spec/qa/876/brief.md` matching this spec exactly.
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