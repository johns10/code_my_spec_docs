# QA Story 983: I choose which model each agent runs on

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the person paying for this, I want to say which provider and model each kind of agent uses, so that QA runs on something cheap and the agent doing the thinking does not.

## Acceptance criteria

- QA runs cheap while the coder does not
- Nothing in the launcher knows what a QA agent is
- An account with only one provider still gets a sensible model
- The preferred default is skipped when its key is missing
- A fresh account can run every type without visiting a settings page
- A running agent keeps the model it started on
- You cannot choose a provider you have not connected
- The cheap one is identifiable as the cheap one
- A type that does not exist cannot be created by typing it

## BDD spec files

- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3005_qa_runs_cheap_while_the_coder_does_not_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3006_nothing_in_the_launcher_knows_what_a_qa_agent_is_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3007_an_account_with_only_one_provider_still_gets_a_sensible_model_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3008_the_preferred_default_is_skipped_when_its_key_is_missing_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3009_a_fresh_account_can_run_every_type_without_visiting_a_settings_page_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3010_a_running_agent_keeps_the_model_it_started_on_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3011_you_cannot_choose_a_provider_you_have_not_connected_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3012_the_cheap_one_is_identifiable_as_the_cheap_one_spex.exs`
- `test/spex/1039_i_choose_which_model_each_agent_runs_on/criterion_3013_a_type_that_does_not_exist_cannot_be_created_by_typing_it_spex.exs`

## Linked component: Agents

This story is implemented by `CodeMySpecWeb.AccountLive.Agents` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/account_live/agents_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/account_live/agents.spec.md`
- Source: `lib/code_my_spec_web/live/account_live/agents.ex`

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

Write the brief to `.code_my_spec/qa/983/brief.md` matching this spec exactly.
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