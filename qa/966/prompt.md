# QA Story 966: I watch my project and talk to its agent on one screen

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a non-technical founder, I want my project's progress, its running preview and my conversation with its agent laid out on one screen, so that I can watch what is being built while I ask about it.

## Acceptance criteria

- The header survives a long conversation
- Both halves are there on arrival
- A desktop screen puts the talking on the left
- A phone stacks the panels above the talking
- Opening a panel does not cost Sam his place
- A panel with no preview yet explains itself
- The dynamic tab swaps its contents without becoming a fourth tab
- Opening one tab on a phone closes the others
- A stored desktop layout with several tabs open resolves to the preview on a phone
- A blocked agent is visible while Sam is looking at something else
- Ordinary progress does not ask for attention

## BDD spec files

- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2943_the_header_survives_a_long_conversation_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2944_both_halves_are_there_on_arrival_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2945_a_desktop_screen_puts_the_talking_on_the_left_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2946_a_phone_stacks_the_panels_above_the_talking_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2947_opening_a_panel_does_not_cost_sam_his_place_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2948_a_panel_with_no_preview_yet_explains_itself_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2949_the_dynamic_tab_swaps_its_contents_without_becoming_a_fourth_tab_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2951_opening_one_tab_on_a_phone_closes_the_others_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2952_a_stored_desktop_layout_with_several_tabs_open_resolves_to_the_preview_on_a_phone_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2953_a_blocked_agent_is_visible_while_sam_is_looking_at_something_else_spex.exs`
- `test/spex/1028_i_watch_my_project_and_talk_to_its_agent_on_one_screen/criterion_2954_ordinary_progress_does_not_ask_for_attention_spex.exs`

## Linked component: Show

This story is implemented by `CodeMySpecWeb.AgentConversationLive.Show` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/agent_conversation_live/show_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/agent_conversation_live/show.spec.md`
- Source: `lib/code_my_spec_web/live/agent_conversation_live/show.ex`

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

Write the brief to `.code_my_spec/qa/966/brief.md` matching this spec exactly.
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