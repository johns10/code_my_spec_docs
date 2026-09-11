# QA Story 891: A working copy comes onto the harness fully configured

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer putting a working copy on a harness, I want onboarding to establish its identity, its databases and its proxy once and write them down, so that nothing downstream derives them and no agent has to discover them.

## Acceptance criteria

- A worktree the agent made is configured by one command run inside it
- A generated application onboards itself with the same command
- The harness address lands in the untracked settings file
- A clone does not inherit the identity of the copy it was cloned from
- Every consumer reads one recorded partition name
- The analyzer and the engineer do not disagree about the database
- Onboarding twice is the same as onboarding once
- Not-onboarded is reported as itself
- The commands are handed over, not run
- The output is sufficient to finish the job
- Submodules follow the working copy without being asked
- A consumer resolves the recorded partition, not one it derives
- Minting a fresh id reads the project's own deploy key, not a copy of it in the environment
- A first run makes the database it needs
- A run that cannot name its own database acts on none
- I ask for a copy and get somewhere to work
- A copy I cannot have is refused, not half-made
- There is no half-made copy to find
- Onboarding that fails leaves nothing behind
- The copy I asked for arrives staffed
- A copy nothing is serving does not report itself ready
- The copy lands where the disk is
- One call, two halves
- A half that fails does not leave the other half standing

## BDD spec files

- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2350_a_worktree_the_agent_made_is_configured_by_one_command_run_inside_it_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2351_a_generated_application_onboards_itself_with_the_same_command_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2352_the_harness_address_lands_in_the_untracked_settings_file_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2353_a_clone_does_not_inherit_the_identity_of_the_copy_it_was_cloned_from_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2354_every_consumer_reads_one_recorded_partition_name_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2355_the_analyzer_and_the_engineer_do_not_disagree_about_the_database_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2356_onboarding_twice_is_the_same_as_onboarding_once_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2357_not-onboarded_is_reported_as_itself_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2358_the_commands_are_handed_over_not_run_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2360_the_output_is_sufficient_to_finish_the_job_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2361_submodules_follow_the_working_copy_without_being_asked_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2370_a_consumer_resolves_the_recorded_partition_not_one_it_derives_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3093_i_ask_for_a_copy_and_get_somewhere_to_work_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3094_a_copy_i_cannot_have_is_refused_not_half_made_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3095_there_is_no_half_made_copy_to_find_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3096_onboarding_that_fails_leaves_nothing_behind_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3097_the_copy_i_asked_for_arrives_staffed_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3098_a_copy_nothing_is_serving_does_not_report_itself_ready_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3099_the_copy_lands_where_the_disk_is_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3100_one_call_two_halves_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_3101_a_half_that_fails_does_not_leave_the_other_half_standing_spex.exs`

## Linked component: Onboard

This story is implemented by `Mix.Tasks.Cms.Harness.Onboard` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/mix/tasks/cms/harness/onboard_test.exs`
- Spec: `.code_my_spec/spec/mix/tasks/cms/harness/onboard.spec.md`
- Source: `lib/mix/tasks/cms/harness/onboard.ex`

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

Write the brief to `.code_my_spec/qa/891/brief.md` matching this spec exactly.
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