# QA Story 823: AI-Assisted Story Management

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an AI coding agent, I want tools to create, read, update, and delete stories, manage acceptance criteria, tag and organize them, start refinement sessions, and triage issues, so that I can handle the bookkeeping of product management — capturing, tagging, linking, and triaging — on the PM's behalf.

## Acceptance criteria

- Agent creates a story, story appears in the active project's backlog
- Agent updates a story's title and description, changes are reflected on next read
- Agent deletes a story with rules and linked issues, rules are removed but issues remain with story_id cleared
- Agent adds a criterion, criterion appears on the story
- Agent lists existing tags, creates a new tag, and applies it to a story, tag appears in the project taxonomy and on the story
- Agent starts a story interview session on the project, session is created and ready for the PM to join
- Agent starts a Three Amigos session on a story, session is created and ready for rule and scenario capture
- Agent links a persona, adds a rule and scenario, and parks a question, all records appear on the story
- Agent accepts an issue as a requirements change linked to a story, issue is closed and the story is updated
- Agent accepts an issue as a bug without a story link, issue is recorded for later resolution
- Agent dismisses an issue with a reason, issue is closed without changes to any story
- Agent creates a story with a story sentence and separate notes
- Downstream tasks read the story sentence, not the notes
- Agent releases a single story for development
- Agent bulk-releases an epic's stories
- Story reads expose the ready-for-development state
- Agent filters the backlog to stories not yet ready

## BDD spec files

- `test/spex/686_ai_assisted_story_management/criterion_5907_agent_creates_a_story_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5908_agent_updates_a_story_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5909_agent_deletes_a_story_with_cascade_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5910_agent_adds_a_criterion_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5912_agent_creates_and_applies_a_tag_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5913_agent_starts_a_story_interview_session_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5914_agent_starts_a_three_amigos_session_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5915_agent_runs_full_three_amigos_workflow_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5916_agent_accepts_an_issue_as_a_requirements_change_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5917_agent_accepts_an_issue_as_a_bug_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_5918_agent_dismisses_an_issue_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7948_agent_creates_a_story_with_a_story_sentence_and_separate_notes_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7949_downstream_tasks_read_the_story_sentence_not_the_notes_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7950_agent_releases_a_single_story_for_development_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7951_agent_bulk_releases_an_epics_stories_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7954_story_reads_expose_the_ready_for_development_state_spex.exs`
- `test/spex/686_ai_assisted_story_management/criterion_7955_agent_filters_the_backlog_to_stories_not_yet_ready_spex.exs`

## Linked component: Stories

This story is implemented by `CodeMySpec.Stories` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/stories_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/stories.spec.md`
- Source: `lib/code_my_spec/stories.ex`

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

Write the brief to `.code_my_spec/qa/823/brief.md` matching this spec exactly.
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