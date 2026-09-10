# QA Story 870: Watch what a background sprite is actually doing

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

A sprite's agent works for hours with no visible record of what it was told or what it concluded. When a run goes wrong the only evidence is container logs and hook payloads, which is how a run that reported a green suite went unchallenged for a day.

## Acceptance criteria

- A completed turn leaves a request and a response on the conversation
- A sub-agent's work is distinguishable from its parent's
- A turn that only calls tools is still legible afterwards
- The run survives the recorder failing
- The operator watches a running sprite without waiting for it to finish
- Watching a sprite does not put a machine in the support inbox
- A tool result stored with role user is not shown as the operator's words
- A failed tool result is distinguishable from one that succeeded
- A tool call the recorder wrote renders as a call, not a wall of JSON
- Two writers store a call differently and it renders one way
- Prose from each side stays attributed to whoever said it
- The tool name reads at a glance and its arguments stay out of the way
- A file-sized payload is cut, and says so
- A call with no arguments offers nothing to expand
- Five calls in a row read as one line saying five
- Opening the group lists the calls; opening a call shows only that one
- A lone call is not dressed up as a group
- Output stored with role tool is not passed off as a tool name
- A long qualified tool name stays readable

## BDD spec files

- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2362_a_tool_result_stored_with_role_user_is_not_shown_as_the_operators_words_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2363_a_failed_tool_result_is_distinguishable_from_one_that_succeeded_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2364_a_tool_call_the_recorder_wrote_renders_as_a_call_not_a_wall_of_json_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2365_two_writers_store_a_call_differently_and_it_renders_one_way_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2366_prose_from_each_side_stays_attributed_to_whoever_said_it_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2367_the_tool_name_reads_at_a_glance_and_its_arguments_stay_out_of_the_way_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2368_a_file_sized_payload_is_cut_and_says_so_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2369_a_call_with_no_arguments_offers_nothing_to_expand_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2371_five_calls_in_a_row_read_as_one_line_saying_five_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2372_opening_the_group_lists_the_calls_opening_a_call_shows_only_that_one_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2373_a_lone_call_is_not_dressed_up_as_a_group_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2374_output_stored_with_role_tool_is_not_passed_off_as_a_tool_name_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_2375_a_long_qualified_tool_name_stays_readable_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8171_a_completed_turn_leaves_a_request_and_a_response_on_the_conversation_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8172_a_sub-agents_work_is_distinguishable_from_its_parents_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8173_a_turn_that_only_calls_tools_is_still_legible_afterwards_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8175_the_run_survives_the_recorder_failing_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8176_the_operator_watches_a_running_sprite_without_waiting_for_it_to_finish_spex.exs`
- `test/spex/984_watch_what_a_background_sprite_is_actually_doing/criterion_8177_watching_a_sprite_does_not_put_a_machine_in_the_support_inbox_spex.exs`

## Linked component: AgentConversationLive

This story is implemented by `CodeMySpecWeb.AgentConversationLive` (live_context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/agent_conversation_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/agent_conversation_live.spec.md`
- Source: `lib/code_my_spec_web/live/agent_conversation_live.ex`

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

Write the brief to `.code_my_spec/qa/870/brief.md` matching this spec exactly.
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