# QA Story 802: Next Actionable Requirements

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the agent, I want the harness to return the next actionable requirement — the highest-priority unsatisfied node whose incoming prerequisites are all satisfied — so that I always have exactly one correct thing to work on and can't accidentally work on vacuously-satisfied leaves.

Parallel dispatch and in-progress filtering are out of scope for this story; a future orchestration story will cover multi-instance dispatch (likely via a `:role` field on requirements rather than subagents). The function returns an ordered list so that future scope is preserved, but today the caller consumes the head.

## Acceptance criteria

- A requirement with all three conditions met appears in the actionable list
- A requirement missing any one of the three conditions is excluded
- When multiple requirements are actionable, the list is returned in full with head first
- The function returns an empty list when no requirement is actionable, never nil or a singleton
- A requirement that has been satisfied no longer appears in subsequent calls
- Re-unsatisfying a previously-completed node puts it back in the list
- A node whose own check would pass but with one unsatisfied prereq does not appear
- Once the prereq turns green, the previously-blocked node appears at the head of the list
- A regular component's spec_file with satisfied_by appears in actionable when ready
- A node with satisfied_by nil is filtered, never returned even when otherwise actionable
- A project where everything unsatisfied is blocked also returns an empty list
- Every returned requirement has execution_type, orchestrated_by, and validation_type populated
- A sub_agent requirement signals dispatch through the orchestrator, not direct execution
- Single actionable node returns a one-element wave
- Children sharing parent_entity_id fan out as one wave
- Sibling orchestrated trees do not merge into one wave
- Orphan component without inherited priority does not lead when priority-bearing work is actionable
- All done when every requirement is satisfied
- A non-context child component under an orphan bounded context does not appear in the next-actionable wave. The orphan parent inherits no priority, so the child inherits none either; the untethered filter drops it.
- Linked context priority does not leak past a non-container intermediate to a grandchild
- Linked context priority cascades to a grandchild via a non-container intermediate

## BDD spec files

- `test/spex/561_next_actionable_requirements/criterion_5613_actionable_requirement_appears_in_the_list_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5614_missing_condition_requirements_are_excluded_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5615_list_returned_in_full_with_head_first_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5616_empty_list_when_no_requirement_is_actionable_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5617_satisfied_requirement_no_longer_appears_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5618_re_unsatisfying_a_completed_node_puts_it_back_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5619_blocked_node_does_not_appear_until_prereq_met_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5620_unblocking_a_prereq_promotes_the_node_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5621_component_with_satisfied_by_appears_when_ready_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5622_satisfied_by_nil_nodes_are_filtered_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5626_fully_blocked_project_returns_empty_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5627_orchestration_metadata_on_returned_items_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5628_sub_agent_requirement_signals_orchestrator_dispatch_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5813_single_actionable_node_returns_a_one_element_wave_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5814_children_sharing_parent_entity_id_fan_out_as_one_wave_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5815_sibling_orchestrated_trees_do_not_merge_into_one_wave_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5816_orphan_does_not_lead_when_priority_bearing_work_is_actionable_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_5817_all_done_when_every_requirement_is_satisfied_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_6212_child_of_orphan_context_does_not_lead_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_6259_priority_cascades_to_grandchild_via_non_container_intermediate_spex.exs`
- `test/spex/561_next_actionable_requirements/criterion_6486_priority_cascades_through_unregistered_namespace_spex.exs`

## Linked component: Requirements

This story is implemented by `CodeMySpec.Requirements` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/requirements_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/requirements.spec.md`
- Source: `lib/code_my_spec/requirements.ex`

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

Write the brief to `.code_my_spec/qa/802/brief.md` matching this spec exactly.
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