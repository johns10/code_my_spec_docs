# QA Story 820: Project Configuration Filters the Graph Cleanly

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want disabling categories of work in `ProjectConfiguration` (`require_specs`, `require_reviews`, `require_unit_tests`) to remove the corresponding requirement nodes from the graph and rewire any prerequisites that referenced them onto the surviving upstream node — so toggling a config flag never produces orphan edges, never leaves a downstream requirement permanently blocked, and never makes a downstream requirement vacuously actionable. This story is the safety net for Story 562: filtering rewrites a graph that 562 just locked down, and is the most likely place for silent breakage in the harness loop.

## Acceptance criteria

- With require_specs false, no spec_file or spec_valid node appears in the graph
- With require_specs true (default), spec nodes are present
- With require_reviews false, no review_file or review_valid node appears
- With require_reviews true (default), review nodes are present in context-type components
- With require_unit_tests false, test nodes are removed but BDD nodes survive
- With require_unit_tests true (default), test nodes are present and BDD nodes are present in either config
- Disabling reviews splices implementation_file's prereq onto spec_valid
- Disabling specs splices review_file to a sensible upstream (or makes it a root)
- Every edge endpoint is in the rendered node set when a single filter is active
- All three filters disabled at once still produces a coherent graph
- Disabling reviews on an in-progress project keeps implementation_file actionability tied to spec_valid
- Disabling reviews on an unsatisfied-spec project keeps implementation_file blocked, not magically actionable
- Toggling require_reviews off then back on returns the original graph shape
- Multiple toggles produce graph state matching only the current config
- Disabling reviews leaves spec and test nodes untouched
- All three flags at default true produces the full graph with no over-filtering
- Child component nodes still appear in the graph when all three require_* filters are disabled

## BDD spec files

- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5629_with_require_specs_false_no_spec_nodes_appear_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5630_with_require_specs_default_spec_nodes_present_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5631_with_require_reviews_false_no_review_nodes_appear_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5632_with_require_reviews_default_review_nodes_present_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5633_with_require_unit_tests_false_test_nodes_removed_bdd_survives_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5634_with_require_unit_tests_default_test_nodes_present_bdd_present_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5635_disabling_reviews_splices_implementation_onto_spec_valid_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5636_disabling_specs_review_file_rewires_or_becomes_root_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5637_single_filter_every_edge_endpoint_in_node_set_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5638_all_three_filters_disabled_coherent_graph_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5639_disabling_reviews_satisfied_spec_keeps_implementation_actionable_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5640_disabling_reviews_unsatisfied_spec_keeps_implementation_blocked_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5641_toggling_reviews_off_then_on_returns_baseline_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5642_multiple_toggles_match_current_config_only_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5643_only_reviews_disabled_leaves_specs_and_tests_untouched_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5644_all_defaults_full_graph_no_overfiltering_spex.exs`
- `test/spex/671_project_configuration_filters_the_graph_cleanly/criterion_5765_child_component_nodes_survive_all_filters_disabled_spex.exs`

## Linked component: Configurations

This story is implemented by `CodeMySpec.Configurations` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/configurations_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/configurations.spec.md`
- Source: `lib/code_my_spec/configurations.ex`

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

Write the brief to `.code_my_spec/qa/820/brief.md` matching this spec exactly.
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