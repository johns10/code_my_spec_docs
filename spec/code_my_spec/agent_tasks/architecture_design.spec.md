# CodeMySpec.AgentTasks.ArchitectureDesign

## Type

skill

## Intent

Map user stories to application components — surfaces (LiveViews,
Controllers), contexts (Phoenix context modules), and children
(schemas, sub-modules). The output is a proposal that, when
executed, scaffolds spec files for every component and wires each
story to its surface component.

The task runs in one of two modes depending on whether
`.code_my_spec/architecture/proposal.md` exists at session start:

- **Initial mode** — agent designs end-to-end, writes the proposal,
  evaluator auto-executes (creates specs, links stories) as one
  transaction.
- **Revision mode** — proposal pre-exists. Agent applies
  incremental mutations via architecture MCP tools
  (`create_component`, `set_story_component`,
  `validate_dependency_graph`) without rewriting the proposal.
  Evaluator only verifies every story is linked.

Mode is determined at session start (proposal existence is
checkpointed via a marker file). The marker is cleared after
evaluate runs, so a re-run with a fresh proposal can re-enter
initial mode.

## Done signal

`Requirements.ArchitectureChecker.complete?/2` returns success.
The check requires:

- Every project story has `component_id` set (non-nil).
- No orphan contexts remain (contexts not story-linked, not
  transitively depended on, not classified as infrastructure).

In initial mode, the evaluator validates the proposal against the
`architecture_proposal` document spec AND executes it as part of
the satisfaction check (creating specs and linking stories
atomically). In revision mode, the evaluator skips execute —
the agent has already mutated the DB via tools.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the
requirement graph as `architecture_designed` (id 5), gated by
`qa_integration_plan` (id 4). Downstream `spex_boundary_ready`
(id 16) reads the proposal to derive the project-local Credo
deny list, so the proposal must exist and be executed before
that task runs.

## Out of scope

- The task does not write component implementations. Those are
  driven later by `develop_context` / `component_code` /
  `component_test` per the component graph.
- The task does not write or modify acceptance criteria. Those are
  the inputs (from `three_amigos`), not outputs.
- The task does not write story implementation code. Architecture
  → spec files → implementation; this task only produces the spec
  scaffolds.
- The task does not own dependency-edge management at the tool
  level. Dependencies are spec-file-derived (`## Dependencies`
  section) so ComponentSync stays the single source of truth.

## Failure modes the agent should avoid

- Rewriting the proposal in revision mode without calling
  `execute_proposal`. The evaluator does NOT auto-execute in
  revision mode — stale text just sits on disk.
- Creating components by writing spec files directly instead of
  calling `create_component`. The DB stays out of sync.
- Wiring dependencies by mutating components. Dependencies live in
  the source spec's `## Dependencies` section. Edit the spec file.
- Running `validate_dependency_graph` only once at the end. Run it
  after every structural change so cycles are caught early.
- In revision mode: skipping orphan resolution. An orphan context
  blocks the requirement even if every story is technically
  linked.

## Resources

Required input:
- The project record (`scope.active_project`) — name, module name,
  description.
- Stories — listed via `Stories.list_unsatisfied_stories/1` in
  the prompt's User Stories section. Their `criteria` drive
  surface design.
- Existing components (if any) — `Components.count_components/1`
  + `Components.list_components/1` for naming-collision checks
  and reuse opportunities.
- Orphan contexts — `ArchitectureChecker.orphans/1`. Surfaced in
  the prompt's Architectural Issues section.

Required reading:
- `priv/knowledge/architecture_design/workflow.md` — full
  procedure for both modes, MCP tool reference, dependency-edge
  conventions, orphan resolution options.

Produced:
- `.code_my_spec/architecture/proposal.md` — proposal matching
  the `architecture_proposal` document spec (initial mode).
- `.code_my_spec/spec/<context>/...md` — one spec file per
  component, scaffolded by `Proposal.execute/3` (initial mode) or
  by `create_component` (revision mode).
- Story → component links — set by `Proposal.execute/3` (initial
  mode) or by `set_story_component` (revision mode).

## Tools

Task-specific MCP tools (the architecture-mutation surface):

- **`analyze_stories`** — surface story groupings and suggested
  context names. First step in initial mode.
- **`create_component`** — add a context / child / surface to the
  DB; spec file is scaffolded automatically.
- **`update_component`** — edit an existing component's metadata;
  spec file is re-projected.
- **`validate_dependency_graph`** — check for circular
  dependencies after edits. Run after every structural change.
- **`set_story_component`** (Stories) — link a story to a
  component.
- **`execute_proposal`** — force a full read-validate-execute
  cycle on `proposal.md`. Use in revision mode when a fresh
  design pass is needed.

Built-ins (Read, Write, Edit) for spec-file edits — used when
adding dependency edges (edit the `## Dependencies` section
under `.code_my_spec/spec/`).

## Dependencies

- CodeMySpec.Architecture.Proposal
- CodeMySpec.Components
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Environments.Environment
- CodeMySpec.Paths
- CodeMySpec.Requirements.ArchitectureChecker
- CodeMySpec.Stories
