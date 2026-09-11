# QA Story 849: Setup runs as a routine I can watch

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

Sam starts basic infrastructure setup and watches each step run to completion, seeing what succeeded, what failed, and exactly where it stopped.

## Acceptance criteria

- Sam sees the whole plan before anything runs
- A step's state changes under Sam's eyes
- A failing step halts the run instead of pressing on
- The provider's own error reaches the agent session
- A re-run picks up where it stopped
- A resource deleted behind setup's back is rebuilt, not skipped
- Running a step twice leaves one of everything
- Coming back without doing the thing keeps setup paused
- An option turned off never appears in the run
- Sam reads back what he now owns
- A step's state is checked against the provider, not remembered
- Sam retries one errored step without re-running the rest

## BDD spec files

- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7959_sam_sees_the_whole_plan_before_anything_runs_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7960_a_steps_state_changes_under_sams_eyes_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7961_a_failing_step_halts_the_run_instead_of_pressing_on_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7962_the_providers_own_error_reaches_the_agent_session_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7963_a_re-run_picks_up_where_it_stopped_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7964_a_resource_deleted_behind_setups_back_is_rebuilt_not_skipped_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7965_running_a_step_twice_leaves_one_of_everything_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7966_the_domain_purchase_round-trip_resumes_on_return_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7967_coming_back_without_doing_the_thing_keeps_setup_paused_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7968_an_option_turned_off_never_appears_in_the_run_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7969_sam_reads_back_what_he_now_owns_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7970_a_steps_state_is_checked_against_the_provider_not_remembered_spex.exs`
- `test/spex/963_setup_runs_as_a_routine_i_can_watch/criterion_7971_sam_retries_one_errored_step_without_re-running_the_rest_spex.exs`

## Linked component: ProvisioningLive

This story is implemented by `CodeMySpecWeb.ProvisioningLive` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/provisioning_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/provisioning_live.spec.md`
- Source: `lib/code_my_spec_web/live/provisioning_live.ex`

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

Write the brief to `.code_my_spec/qa/849/brief.md` matching this spec exactly.
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