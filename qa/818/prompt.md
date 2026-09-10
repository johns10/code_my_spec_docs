# QA Story 818: Component Test Generation

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo founder, I want the system to generate component tests aligned with the design's test assertions so coding agents can drive implementation TDD-style or validate existing code against the spec without me babysitting the prompt.

## Acceptance criteria

- Test file lands at the canonical test path
- Missing implementation triggers TDD-mode framing
- Existing implementation triggers validation-mode framing
- Top-level component renders no-parent placeholder
- Child component prompt references parent context spec
- Valid test file with no blocking problems passes evaluation
- Compilation error on the test file blocks evaluation
- TDD test failures don't block evaluation
- Invalid test file holds the node and re-fires next pass with diagnostics
- Component-type test rules surface in the Test Rules section
- Agent crash leaves test_file unsatisfied for the next pass

## BDD spec files

- `test/spex/669_component_test_generation/criterion_5559_test_file_lands_at_the_canonical_test_path_spex.exs`
- `test/spex/669_component_test_generation/criterion_5560_missing_implementation_triggers_tdd-mode_framing_spex.exs`
- `test/spex/669_component_test_generation/criterion_5561_existing_implementation_triggers_validation-mode_framing_spex.exs`
- `test/spex/669_component_test_generation/criterion_5562_top-level_component_renders_no-parent_placeholder_spex.exs`
- `test/spex/669_component_test_generation/criterion_5563_child_component_prompt_references_parent_context_spec_spex.exs`
- `test/spex/669_component_test_generation/criterion_5564_valid_test_file_with_no_blocking_problems_passes_evaluation_spex.exs`
- `test/spex/669_component_test_generation/criterion_5565_compilation_error_on_the_test_file_blocks_evaluation_spex.exs`
- `test/spex/669_component_test_generation/criterion_5566_tdd_test_failures_dont_block_evaluation_spex.exs`
- `test/spex/669_component_test_generation/criterion_5568_invalid_test_file_holds_the_node_and_re-fires_next_pass_with_diagnostics_spex.exs`
- `test/spex/669_component_test_generation/criterion_5570_component-type_test_rules_surface_in_the_test_rules_section_spex.exs`
- `test/spex/669_component_test_generation/criterion_5571_agent_crash_leaves_test_file_unsatisfied_for_the_next_pass_spex.exs`

## Linked component: AgentTasks

This story is implemented by `CodeMySpec.AgentTasks` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agent_tasks_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agent_tasks.spec.md`
- Source: `lib/code_my_spec/agent_tasks.ex`

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

Write the brief to `.code_my_spec/qa/818/brief.md` matching this spec exactly.
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