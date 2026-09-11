# QA Story 793: Project Setup

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a developer, I want to bootstrap a Phoenix project with CodeMySpec tooling so that I can start using agent-driven development.

## Acceptance criteria

- Fully-configured project renders every step checked
- Completing an incomplete step is reflected on re-render
- Every incomplete step's full prompt is inlined on one page
- Reverse-order completion still lands on 12/12
- Interleaved completion still lands on 12/12
- Every step valid renders 12/12 with no incomplete prompts
- One incomplete step is named and its prompt inlined
- Multiple incomplete steps are named and their prompts inlined
- Partial progress shows accurate done/total in the header
- Fully complete shows 12/12 with every step checked and no prompts
- A completed step renders as checked with no prompt body
- Happy path renders without an error banner
- A step command error surfaces as a page-level error banner with the reason

## BDD spec files

- `test/spex/124_project_setup/criterion_5256_fully-configured_project_renders_every_step_checked_spex.exs`
- `test/spex/124_project_setup/criterion_5257_completing_an_incomplete_step_is_reflected_on_re-render_spex.exs`
- `test/spex/124_project_setup/criterion_5258_every_incomplete_steps_full_prompt_is_inlined_on_one_page_spex.exs`
- `test/spex/124_project_setup/criterion_5259_reverse-order_completion_still_lands_on_1212_spex.exs`
- `test/spex/124_project_setup/criterion_5260_interleaved_completion_still_lands_on_1212_spex.exs`
- `test/spex/124_project_setup/criterion_5261_every_step_valid_renders_1212_with_no_incomplete_prompts_spex.exs`
- `test/spex/124_project_setup/criterion_5262_one_incomplete_step_is_named_and_its_prompt_inlined_spex.exs`
- `test/spex/124_project_setup/criterion_5263_multiple_incomplete_steps_are_named_and_their_prompts_inlined_spex.exs`
- `test/spex/124_project_setup/criterion_5264_partial_progress_shows_accurate_donetotal_in_the_header_spex.exs`
- `test/spex/124_project_setup/criterion_5265_fully_complete_shows_1212_with_every_step_checked_and_no_prompts_spex.exs`
- `test/spex/124_project_setup/criterion_5266_a_completed_step_renders_as_checked_with_no_prompt_body_spex.exs`
- `test/spex/124_project_setup/criterion_5267_happy_path_renders_without_an_error_banner_spex.exs`
- `test/spex/124_project_setup/criterion_5268_a_step_command_error_surfaces_as_a_page-level_error_banner_with_the_reason_spex.exs`

## Linked component: AgentTasks

This story is implemented by `CodeMySpec.AgentTasks` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agent_tasks_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agent_tasks.spec.md`
- Source: `lib/code_my_spec/agent_tasks.ex`

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

Write the brief to `.code_my_spec/qa/793/brief.md` matching this spec exactly.
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