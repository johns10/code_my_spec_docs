# QA Story 880: The first story is shaped in conversation, before any code

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As someone who just described an idea, before signing up, I want a short guided conversation that turns it into a few reviewed stories, so that I have something concrete to see before I commit to an account.

## Acceptance criteria

- Tool calls appear as the model makes them
- Sam corrects the story in place
- The review starts from a story already on the board
- A normal conversation finishes well inside the cap
- A model that will not stop is stopped
- A failure mid-conversation keeps what Sam already said
- Sam steps away and picks up where he left off
- A tool call arrives as a tool call, not as prose
- The editor is the story UI, not a second one
- A short conversation becomes a few stories
- A sixth story is refused, not silently added
- Draft stories land on the project conversion creates
- Pre-signup tool calls act on the visitor's plan
- Post-signup tool calls act on the visitor's project

## BDD spec files

- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8268_four_answers_become_one_story_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8269_a_second_story_is_refused_not_silently_added_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8270_the_story_lands_on_the_project_signup_made_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8271_tool_calls_appear_as_the_model_makes_them_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8272_sam_corrects_the_story_in_place_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8273_the_review_starts_from_a_story_already_on_the_board_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8274_a_normal_conversation_finishes_well_inside_the_cap_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8275_a_model_that_will_not_stop_is_stopped_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8276_tools_act_on_the_conversations_project_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8277_a_failure_mid-conversation_keeps_what_sam_already_said_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8278_sam_steps_away_and_picks_up_where_he_left_off_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8280_a_tool_call_arrives_as_a_tool_call_not_as_prose_spex.exs`
- `test/spex/995_the_first_story_is_shaped_in_conversation_before_any_code/criterion_8281_the_editor_is_the_story_ui_not_a_second_one_spex.exs`

## Linked component: ChatLive

This story is implemented by `CodeMySpecWeb.ChatLive` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/chat_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/chat_live.spec.md`
- Source: `lib/code_my_spec_web/live/chat_live.ex`

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

Write the brief to `.code_my_spec/qa/880/brief.md` matching this spec exactly.
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