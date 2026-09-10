# QA Story 891: A working copy comes onto the harness fully configured

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer putting a working copy on the harness, I want onboarding to establish its identity, its databases and its proxy once and write them down, so that nothing downstream derives them and no agent has to discover them.

Onboarding is currently not a step — it is a set of values every consumer re-derives, and each derivation has failed in production.

**Test partitions.** Two independent derivations of one identity: `config/test.exs` derives a name from the worktree path when `MIX_TEST_PARTITION` is unset, and `TestDatabase.partition_for/2` digests the cwd to `h<sha8>`, appending `s` for spex. `analyzer_env.ex` states the consequence outright — "different databases, by accident of two mechanisms rather than by design". Nothing creates them, nothing migrates them, no command names them, and the guard that refuses on a stale one printed advice for a different database entirely. One agent followed that advice and stayed blocked three days across 50 rejected runs (6f89b278). A name assigned once and read by both removes the class.

**Identity on the wire.** Three hook configs disagree about how a harness names itself: the installed marketplace plugin sends no `X-Harness-Id` and posts to a decommissioned port, the repo source sends the header, the generated per-harness config bakes the id into the path. Three agents measured three files and each generalised to "the plugin" (315fa5a8, 746e5c32, c1e6adbd).

**The Anthropic base URL.** Onboarding sets it so agent messages relay through the harness and land on the server. Building that relay is not this story; configuring it is. It carries the working copy's harness id, which is why it goes to `.claude/settings.local.json` — `settings.json` is tracked, so writing it there would stage one machine's identity for commit and the next clone would inherit it (ff18c21f).

**Shape, decided.** A single `mix harness.onboard`, shipped in `client_utils` rather than here. `client_utils` is already a dependency (`mix.exs:109`), so CodeMySpec can onboard its own copies — and a generated application depends on `client_utils` and not on CodeMySpec, so this is the only placement where both can run it. It also inverts the dependency correctly: `client_utils` writes the partition name and CodeMySpec reads it, so `client_utils` never learns a digest algorithm that should no longer exist. Same precedent as `mix.exs:113`, where the one place that shells a generator runs it in the provisioned project, which carries its own copy.

**Scope, decided.** The command runs from inside a worktree the agent has already created — it does not create worktrees. It never creates, migrates or drops a database; it names what is missing and hands over the exact commands. That keeps intact the rule written after a background process with `MIX_ENV` scrubbed out emptied the shared development database three times on 2026-08-13, rather than carving an exception into it.

Success is a working copy where `mix test`, `mix spex` and the analyzer all run, with agent messages recorded server-side, reached by an agent following only what the command printed — no source file, no digest function, no second agent.

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
- A missing database is reported, not created
- The output is sufficient to finish the job
- Submodules follow the working copy without being asked
- A consumer resolves the recorded partition, not one it derives
- Minting a fresh id reads the project's own deploy key, not a copy of it in the environment

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
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2359_a_missing_database_is_reported_not_created_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2360_the_output_is_sufficient_to_finish_the_job_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2361_submodules_follow_the_working_copy_without_being_asked_spex.exs`
- `test/spex/1013_a_working_copy_comes_onto_the_harness_fully_configured/criterion_2370_a_consumer_resolves_the_recorded_partition_not_one_it_derives_spex.exs`

## Linked component: Onboard

This story is implemented by `Mix.Tasks.Cms.Harness.Onboard` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/mix/tasks/cms/harness/onboard_test.exs`
- Spec: `.code_my_spec/spec/mix/tasks/cms/harness/onboard.spec.md`
- Source: `lib/mix/tasks/cms/harness/onboard.ex`

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