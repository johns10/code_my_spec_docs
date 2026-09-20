# QA Story 803: Connected Requirement Graph Across Entities

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want requirements to form one connected graph across the whole project — fanning out from the project to its stories, from each story to the surface component it exercises (and the context dependencies that surface relies on), from each bounded context down to the child modules that implement it, and fanning back in the same way — so that every requirement has real prerequisites traceable to the code that satisfies it, no requirement becomes actionable before its upstream work exists, siblings that don't depend on each other can be worked in parallel, and nothing can be marked done by vacuous truth.

## Acceptance criteria

- Every rendered edge traces back to a prerequisites entry on its source node
- A prerequisite pointing at a deleted node surfaces as an orphan reference
- A leaf turns green on its own check; a deep node stays red until its full chain is green
- tests_passing with no failures recorded but missing implementation_file renders as not satisfied
- Failing context dep blocks the story transitively through the surface, not directly
- Context tests_passing depends on every child's terminal requirement
- One missing child implementation blocks the parent context even when the others are complete
- A single failing story blocks project qa_preflight even when other stories are green
- Two independent sibling schemas are both highlighted as actionable simultaneously
- A sibling depending on another stays blocked while the depended-on and unrelated siblings remain actionable
- Stories context children's implementation work is gated on the Users context terminal requirement
- Unsatisfied Users context blocks Stories implementation even when Stories spec_valid is green
- Every node in a healthy graph traces back to the project root
- A component with no parent context and no story linkage surfaces as an orphan, not as a root task
- Context implementation_file's shortcut from a child's implementation_file is elided when the child's tests_passing provides the longer route
- Edges with no alternative path are preserved
- Story kickoff resolves to a dep when the surface has a cross-context dependency
- Story kickoff resolves to the deepest transitive dep in a dep chain
- When the surface has no dependencies, the kickoff lands directly on the surface
- Independent deps each receive a kickoff edge
- Container surface kickoff fans out to children when first surviving def is child-scoped

## BDD spec files

- `test/spex/562_connected_requirement_graph_across_entities/criterion_5597_every_rendered_edge_traces_to_a_real_node_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5598_orphan_prereq_reference_surfaces_indicator_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5599_leaf_turns_green_deep_node_stays_red_until_chain_green_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5600_tests_passing_with_missing_implementation_renders_unsatisfied_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5603_context_tests_passing_depends_on_every_childs_terminal_requirement_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5604_one_missing_child_implementation_blocks_the_parent_context_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5607_two_independent_sibling_schemas_are_both_actionable_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5608_a_sibling_depending_on_another_stays_blocked_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5609_stories_context_implementation_is_gated_on_users_context_terminal_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5610_unsatisfied_users_context_blocks_stories_implementation_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5611_every_node_traces_back_to_the_project_root_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5612_orphan_component_surfaces_as_orphan_not_root_task_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5646_context_implementation_shortcut_elided_through_child_tests_passing_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5647_linear_chain_edges_preserved_when_no_alternative_path_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5649_story_kickoff_resolves_to_dep_when_surface_has_dependency_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5650_story_kickoff_resolves_to_deepest_transitive_dep_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5651_standalone_surface_kickoff_lands_on_surface_directly_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_5652_independent_deps_each_receive_kickoff_edge_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_6074_container_surface_kickoff_fans_out_to_children_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_6494_fresh_project_surfaces_only_project_chain_work_as_actionable_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_6495_a_reopened_project_requirement_returns_to_the_head_over_downstream_component_work_in_flight_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_6496_a_reopened_story_requirement_returns_to_the_head_over_its_surface_components_downstream_work_spex.exs`
- `test/spex/562_connected_requirement_graph_across_entities/criterion_6497_an_unsatisfied_project_requirement_blocks_parent_chain_descendants_of_cross_context_deps_too_spex.exs`

## Linked component: Requirements

This story is implemented by `CodeMySpec.Requirements` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/requirements_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/requirements.spec.md`
- Source: `lib/code_my_spec/requirements.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/announce_device.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_code_mode.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_spine.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/stripe_get_subs.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_github.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_google.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_resend.sh`

## Required reading: QA plan

Read `.code_my_spec/qa/plan.md` first. It contains the App Overview, Tools
Registry, auth strategy, and Seed Strategy you need before writing the
brief. The plan is produced and maintained by the `qa_setup` task; if
it's missing or incomplete, the evaluator will tell you to run that
task first.

## Repros that consume themselves

Before reusing a concrete input from an earlier attempt's brief, ask whether
running it *changed* what a second run would measure. Anything the system
remembers — a question it has answered, a decision it recorded, a name it has
already taken — is spent once it has been used.

The failure this prevents is the expensive kind: a system that correctly
declines to re-answer a settled question looks exactly like one that failed
to escalate it, and a re-test then reports a working fix as broken.

Where an input is consumable, choose a fresh one and say in the brief which
you used, so the next pass knows what is spent. Where you inherit a repro
from a previous attempt, check it is still unused before trusting the
result.

## If your tools stop answering, say so before you stop

The dev server and the harness both restart under you without warning. The
box is shared, several sessions ship fixes to it, and a plain deploy takes
the harness serving every checkout on the machine with it. You will see
`:econnrefused`, `:harness_not_connected`, or "No session_id and no agent id
on this call".

None of that is your story failing. Retry — the session's enrichment comes
back within a call or two once the harness rejoins — and carry on.

What matters is the case where you cannot carry on. Submit what you have
with the interruption named as the reason, rather than going quiet. Nobody
can tell a subagent that died from one that is mid-browser-check: both
produce no brief, no attempt and no notification. A pass that ended at
05:22 was reported as "still running" for three hours on exactly that
evidence (733ac788).

An interruption is also a finding about the QA loop, so file it.

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/803/brief.md` matching this spec exactly.
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