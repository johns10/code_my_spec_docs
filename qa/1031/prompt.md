# QA Story 1031: Every process an agent is expected to follow is written down

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an agent picking up a task, I want the process behind it written down in the knowledge base, so that I learn it by reading rather than by getting it wrong in front of the owner.

## Acceptance criteria

- An agent finds the process without reading the code
- Why nobody is being offered a story
- Which number names the spex directory
- A playbook hands off rather than restating
- An unfamiliar task has a playbook
- The prompt points at the detail it assumes
- An agent handed a component to build finds the order
- An agent testing a story finds how a result is recorded
- An agent promoting work finds what the gate does
- An agent onboarding somebody finds how

## BDD spec files

- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3379_an_agent_finds_the_process_without_reading_the_code_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3380_why_nobody_is_being_offered_a_story_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3381_which_number_names_the_spex_directory_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3383_a_playbook_hands_off_rather_than_restating_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3392_an_unfamiliar_task_has_a_playbook_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3393_the_prompt_points_at_the_detail_it_assumes_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3394_an_agent_handed_a_component_to_build_finds_the_order_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3395_an_agent_testing_a_story_finds_how_a_result_is_recorded_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3396_an_agent_promoting_work_finds_what_the_gate_does_spex.exs`
- `test/spex/1065_every_process_an_agent_is_expected_to_follow_is_written_down/criterion_3397_an_agent_onboarding_somebody_finds_how_spex.exs`

## Linked component: Knowledge

This story is implemented by `CodeMySpec.Knowledge` (logic).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/knowledge_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/knowledge.spec.md`
- Source: `lib/code_my_spec/knowledge.ex`

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

Write the brief to `.code_my_spec/qa/1031/brief.md` matching this spec exactly.
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