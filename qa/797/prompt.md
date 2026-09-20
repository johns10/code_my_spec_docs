# QA Story 797: Project Configuration — Local quality gate settings

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an Engineer, I want to control what quality gates are imposed on the LLM when it writes my application.

## Acceptance criteria

- When an engineer turns off specs for rapid prototyping, they are no longer required in the requirements graph
- When an engineer turns off design reviews but keeps specs required, specs still appear in the requirements graph but reviews do not.
- When an engineer turns off unit tests, the test file and tests_passing requirements no longer appear in the requirements graph.
- When an engineer turns off specs, reviews, and unit tests, only implementation file requirements remain in the requirements graph.
- When an engineer re-enables unit tests after turning them off, test requirements reappear in the requirements graph.
- When a ProjectConfiguration does not yet exist, the first time it is accessed it is auto-created with the documented defaults.
- When an engineer sets credo to off, credo does not run during the stop hook and no credo problems are persisted.
- When exunit is set to block_changed, test failures on components outside the task's scope are persisted but do not block the stop.
- When exunit is set to dont_block, test failures are persisted as problems but the stop is allowed regardless.
- When an engineer enables spex, mix spex --stale runs on every stop hook and any spex failure blocks the stop.
- When credo is set to block_all, mix credo runs against the whole project (no file path arguments) and any violation blocks the stop, even when the violation lives in a file the agent did not touch this turn.
- When credo is set to block_changed, mix credo runs only on files the agent touched (file paths passed as arguments) and only those violations block the stop. Violations in files outside the changed set are not surfaced.
- When credo is set to dont_block, mix credo still runs against the changed files and any violations are persisted as problems, but the stop is allowed regardless.
- When spec_validation is set to off, the spec validator does not run during the stop hook and no spec_validation problems are persisted; the stop is allowed. Mirrors 5087 (credo off) for the spec_validation source.
- When qa_validation is set to block_changed (the default), persisted qa_validation problems for qa briefs the agent did not modify this turn do not block the stop. Parallel to spec_validation block_changed for the qa_validation source.
- When spec_validation is set to block_changed (the default), spec_validation problems persisted from prior turns do not block the stop when the agent did not modify those spec files this turn.
- When spec_validation is set to block_all, persisted spec_validation problems block the stop every turn until the spec file is fixed — even on turns that do not touch the file.
- When spec_validation is set to dont_block, spec validator problems are still persisted but the stop is always allowed.
- Engineer turns off compile warning blocking
- Spec file with missing required section blocks when changed
- No changes but outstanding compiler errors block

## BDD spec files

- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5081_when_an_engineer_turns_off_specs_for_rapid_prototyping_they_are_no_longer_required_in_the_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5082_when_an_engineer_turns_off_design_reviews_but_keeps_specs_required_specs_still_appear_in_the_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5083_when_an_engineer_turns_off_unit_tests_the_test_file_and_tests_passing_requirements_no_longer_appear_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5084_when_an_engineer_turns_off_specs_reviews_and_unit_tests_only_implementation_file_requirements_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5085_when_an_engineer_re-enables_unit_tests_after_turning_them_off_test_requirements_reappear_in_the_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5086_when_a_projectconfiguration_does_not_yet_exist_the_first_time_it_is_accessed_it_is_auto-created_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5087_when_an_engineer_sets_credo_to_off_credo_does_not_run_during_the_stop_hook_and_no_credo_problems_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5088_when_exunit_is_set_to_block_changed_test_failures_on_components_outside_the_tasks_scope_are_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5089_when_exunit_is_set_to_dont_block_test_failures_are_persisted_as_problems_but_the_stop_is_allowed_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5090_when_an_engineer_enables_spex_mix_spex_--stale_runs_on_every_stop_hook_and_any_spex_failure_blocks_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5108_when_spec_validation_is_off_the_validator_does_not_run_and_no_problem_is_persisted_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_5109_when_qa_validation_is_block_changed_stale_problems_on_untouched_qa_files_do_not_block_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6028_when_credo_is_block_all_credo_scans_the_whole_project_and_violations_in_untouched_files_block_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6029_when_credo_is_block_changed_credo_runs_only_on_changed_files_and_violations_outside_them_do_not_block_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6030_when_credo_is_dont_block_violations_are_persisted_but_the_stop_is_allowed_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6071_when_spec_validation_is_block_changed_stale_problems_on_untouched_spec_files_do_not_block_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6072_when_spec_validation_is_block_all_stale_problems_on_untouched_spec_files_still_block_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6073_when_spec_validation_is_dont_block_problems_are_persisted_but_the_stop_is_allowed_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6075_engineer_turns_off_compile_warning_blocking_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6076_spec_file_with_missing_required_section_blocks_when_changed_spex.exs`
- `test/spex/553_project_configuration_local_quality_gate_settings/criterion_6077_no_changes_but_outstanding_compiler_errors_block_spex.exs`

## Linked component: Configurations

This story is implemented by `CodeMySpec.Configurations` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/configurations_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/configurations.spec.md`
- Source: `lib/code_my_spec/configurations.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/announce_device.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_code_mode.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_spine.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/stripe_get_subs.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_github.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_google.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_resend.sh`

## Required reading: QA plan

Read `.code_my_spec/qa/plan.md` first. It contains the App Overview, Tools
Registry, auth strategy, and Seed Strategy you need before writing the
brief. The plan is produced and maintained by the `qa_setup` task; if
it's missing or incomplete, the evaluator will tell you to run that
task first.

## Repros that consume themselves

Before reusing a concrete input from an earlier attempt's brief, ask whether
running it *changed* what a second run would measure. Anything the system
remembers — a question it has answered, a decision it recorded, a name it has
already taken — is spent once it has been used.

The failure this prevents is the expensive kind: a system that correctly
declines to re-answer a settled question looks exactly like one that failed
to escalate it, and a re-test then reports a working fix as broken.

Where an input is consumable, choose a fresh one and say in the brief which
you used, so the next pass knows what is spent. Where you inherit a repro
from a previous attempt, check it is still unused before trusting the
result.

## If your tools stop answering, say so before you stop

The dev server and the harness both restart under you without warning. The
box is shared, several sessions ship fixes to it, and a plain deploy takes
the harness serving every checkout on the machine with it. You will see
`:econnrefused`, `:harness_not_connected`, or "No session_id and no agent id
on this call".

None of that is your story failing. Retry — the session's enrichment comes
back within a call or two once the harness rejoins — and carry on.

What matters is the case where you cannot carry on. Submit what you have
with the interruption named as the reason, rather than going quiet. Nobody
can tell a subagent that died from one that is mid-browser-check: both
produce no brief, no attempt and no notification. A pass that ended at
05:22 was reported as "still running" for three hours on exactly that
evidence (733ac788).

An interruption is also a finding about the QA loop, so file it.

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/797/brief.md` matching this spec exactly.
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