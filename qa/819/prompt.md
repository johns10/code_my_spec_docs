# QA Story 819: Component Code Generation

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo founder, I want the system to generate component implementations aligned with the spec and tests so coding agents can satisfy the requirement graph without me hand-tuning the prompt.

## Acceptance criteria

- Prompt names every artifact path and project anchor
- Component without a description still produces a labeled prompt
- Only the matching component-type code rules appear
- No matching rules leaves the rules section empty rather than padded
- All code requirements satisfied with no problems passes evaluation
- Unsatisfied code requirement holds the node with requirement feedback
- Persisted problem on the code file holds the node even when requirements pass
- Persisted problem on the test file holds the node even when requirements pass
- Analyzer-written problem after command fired surfaces in evaluation
- Stale in-memory component state never gates evaluation
- Orchestrate prompt names the requirement and the entity
- Passing test suite leaves no problems and evaluation passes
- Failing test suite persists problems and evaluation returns invalid

## BDD spec files

- `test/spex/670_component_code_generation/criterion_5582_prompt_names_every_artifact_path_and_project_anchor_spex.exs`
- `test/spex/670_component_code_generation/criterion_5583_component_without_a_description_still_produces_a_labeled_prompt_spex.exs`
- `test/spex/670_component_code_generation/criterion_5584_only_the_matching_component-type_code_rules_appear_spex.exs`
- `test/spex/670_component_code_generation/criterion_5585_no_matching_rules_leaves_the_rules_section_empty_rather_than_padded_spex.exs`
- `test/spex/670_component_code_generation/criterion_5586_all_code_requirements_satisfied_with_no_problems_passes_evaluation_spex.exs`
- `test/spex/670_component_code_generation/criterion_5587_unsatisfied_code_requirement_holds_the_node_with_requirement_feedback_spex.exs`
- `test/spex/670_component_code_generation/criterion_5588_persisted_problem_on_the_code_file_holds_the_node_even_when_requirements_pass_spex.exs`
- `test/spex/670_component_code_generation/criterion_5589_persisted_problem_on_the_test_file_holds_the_node_even_when_requirements_pass_spex.exs`
- `test/spex/670_component_code_generation/criterion_5590_analyzer-written_problem_after_command_fired_surfaces_in_evaluation_spex.exs`
- `test/spex/670_component_code_generation/criterion_5591_stale_in-memory_component_state_never_gates_evaluation_spex.exs`
- `test/spex/670_component_code_generation/criterion_5592_orchestrate_prompt_names_the_requirement_and_the_entity_spex.exs`
- `test/spex/670_component_code_generation/criterion_5594_passing_test_suite_leaves_no_problems_and_evaluation_passes_spex.exs`
- `test/spex/670_component_code_generation/criterion_5595_failing_test_suite_persists_problems_and_evaluation_returns_invalid_spex.exs`

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

Write the brief to `.code_my_spec/qa/819/brief.md` matching this spec exactly.
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