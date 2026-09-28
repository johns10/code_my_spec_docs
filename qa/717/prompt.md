# QA Story 836: Engineer sees a DAG of project progress

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an Elixir engineer, I'd like to see a directed acyclic graph representing progress through the project so I can track what's complete and incomplete, and help the agent navigate the project.

The graph surface is `GraphProjector` (lib/code_my_spec/requirements/graph_projector.ex) feeding the Sigma view in `architecture_live`. Today the layout is governed by unit tests in `test/code_my_spec/requirements/graph_projector_test.exs` (topology-flow properties), but no story-level contract covers the visual invariants — which is how 2026-05-16's regression slipped through (commit `a774e35b` removed qa_preflight, leaving no project node receiving cross-entity edges, which collapsed the entire project chain into the bottom band).

Likely rules to surface in Three Amigos:
- Project chain renders as a contiguous band above the story zone when stories exist; degenerate-cases (no late_project, no early_project) lay out cleanly without collapse
- Intra-entity dependency edges flow downward in vertical bands or rightward in horizontal bands — never up or left
- Component tiers stack in dependency-depth order; orphans don't drift into the surface band
- Schema changes that add or remove cross-entity sinks/sources don't silently rearrange the layout
- Satisfied / actionable / blocked nodes color-code consistently across all bands

## Acceptance criteria

- Project chain edges flow downward toward later gates
- Component zone edges flow downward toward later tiers
- Removing the only story-to-project edge keeps the project chain at the top
- All five bands populated stack in pre-story-project → pre-component-story → components → post-component-story → post-story-project order
- Empty post-story-project band leaves the remaining four bands in correct order
- Component layers stack top-to-bottom in increasing dependency depth
- Satisfaction state maps to brand color tokens consistently across bands
- Large-project layout keeps distinct bands and non-overlapping nodes

## BDD spec files

- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6416_project_chain_edges_flow_downward_toward_later_gates_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6417_component_zone_edges_flow_downward_toward_later_tiers_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6420_removing_the_only_story-to-project_edge_keeps_the_project_chain_at_the_top_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6421_all_five_bands_populated_stack_in_pre-story-project_pre-component-story_components_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6422_empty_post-story-project_band_leaves_the_remaining_four_bands_in_correct_order_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6423_component_layers_stack_top-to-bottom_in_increasing_dependency_depth_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6424_satisfaction_state_maps_to_brand_color_tokens_consistently_across_bands_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6425_large-project_layout_keeps_distinct_bands_and_non-overlapping_nodes_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6541_a_watched_file_change_refreshes_the_open_graph_in_place_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6542_a_burst_of_rapid_changes_coalesces_into_a_single_refresh_spex.exs`
- `test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6543_a_change_in_another_project_leaves_this_graph_untouched_spex.exs`

## Linked component: RequirementsLive

This story is implemented by `CodeMySpecWeb.RequirementsLive` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/requirements_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/requirements_live.spec.md`
- Source: `lib/code_my_spec_web/requirements_live.ex`

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

Write the brief to `.code_my_spec/qa/836/brief.md` matching this spec exactly.
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