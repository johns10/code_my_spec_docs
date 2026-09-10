# QA Story 864: Non-technical user watches the agent work in a live progress view

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a non-technical user, I want a live screen showing all my project requirements alongside a timeline of what the agent is doing right now — the active work in focus, with plain-language explanations of each major step — so I can follow and trust progress without reading code.

## Acceptance criteria

- Requirements list reflects current status
- Tasks nest under their session
- Timeline caps at the ten most recent sessions
- Sessions with no activity are hidden
- Session spans from start to last update
- Active session's current step is expanded
- Nothing is expanded when the agent is idle
- User expands an older task to inspect it
- Focused task shows its artifact
- Major task shows its educational explainer and video
- Non-major task falls back to a generic explanation
- Screen updates live as the agent starts new work
- Sessions with no tasks are hidden
- A session with many tasks collapses its middle
- Each task is labelled by its own type

## BDD spec files

- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6545_requirements_list_reflects_current_status_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6546_tasks_nest_under_their_session_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6547_timeline_caps_at_the_ten_most_recent_sessions_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6548_sessions_with_no_activity_are_hidden_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6549_session_spans_from_start_to_last_update_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6550_active_sessions_current_step_is_expanded_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6551_nothing_is_expanded_when_the_agent_is_idle_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6552_user_expands_an_older_task_to_inspect_it_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6553_focused_task_shows_its_artifact_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6554_major_task_shows_curated_help_and_video_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6555_non_major_task_falls_back_to_a_generic_explanation_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6556_screen_updates_live_as_the_agent_starts_new_work_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6557_empty_session_is_hidden_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6558_a_session_with_many_tasks_collapses_its_middle_spex.exs`
- `test/spex/813_non_technical_user_watches_the_agent_work_in_a_live_progress_view/criterion_6559_each_task_is_labelled_by_its_own_type_spex.exs`

## Linked component: AgentProgressLive

This story is implemented by `CodeMySpecWeb.AgentProgressLive` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/agent_progress_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/agent_progress_live.spec.md`
- Source: `lib/code_my_spec_web/live/agent_progress_live.ex`

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

Write the brief to `.code_my_spec/qa/864/brief.md` matching this spec exactly.
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