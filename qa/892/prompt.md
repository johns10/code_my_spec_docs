# QA Story 892: An agent that has gone quiet stops holding state for everyone else

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer whose project several agents work on, I want an agent that has been offline for a couple of hours to have its derived state reclaimed, so that a checkout nobody is running stops holding components and problems that block the agents still working.

## Acceptance criteria

- A quiet agent's files and problems are reclaimed
- A working agent is never reclaimed out from under itself
- A returning agent is the same agent
- An orphan component stops blocking a gate no edit could clear
- Authored links are never spent to reclaim derived rows
- An unswept checkout is not a quiet agent
- Idle time does not depend on the machine's timezone
- Coming back is onboarding, not recovery
- A live agent's sync is what reclaims a quiet one
- The sweep is not scoped to the agent doing the syncing

## BDD spec files

- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2376_a_quiet_agents_files_and_problems_are_reclaimed_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2377_a_working_agent_is_never_reclaimed_out_from_under_itself_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2377_a_working_agent_survives_a_third_agents_sweep_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2378_a_returning_agent_is_the_same_agent_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2379_an_orphan_component_stops_blocking_a_gate_no_edit_could_clear_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2380_authored_links_are_never_spent_to_reclaim_derived_rows_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2381_an_unswept_checkout_is_not_a_quiet_agent_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2382_idle_time_does_not_depend_on_the_machines_timezone_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2383_coming_back_is_onboarding_not_recovery_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2384_a_live_agents_sync_is_what_reclaims_a_quiet_one_spex.exs`
- `test/spex/1014_an_agent_that_has_gone_quiet_stops_holding_state_for_everyone_else/criterion_2385_the_sweep_is_not_scoped_to_the_agent_doing_the_syncing_spex.exs`

## Linked component: Harnesses

This story is implemented by `CodeMySpec.Harnesses` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/harnesses_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/harnesses.spec.md`
- Source: `lib/code_my_spec/harnesses.ex`

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

Write the brief to `.code_my_spec/qa/892/brief.md` matching this spec exactly.
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