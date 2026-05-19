# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — All stories linked (criterion 5289)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The spex writes a proposal mapping all unsatisfied stories to surface (liveview) components, calls `evaluate_task`, and asserts the response contains "Passed" and no "needs work" text. Spec stubs are created for all new components. Test passed.

### Scenario 2 — Story left unlinked (criterion 5290)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The spex writes a proposal that omits one of three stories, calls `evaluate_task`, and asserts the response contains "needs work" and names the unlinked story's ID. No spec stubs are created. Test passed.

### Scenario 3 — Link story to surface component (criterion 5291)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The spex writes a proposal linking the story to a `liveview` type component. `evaluate_task` accepts it ("Passed") with no "non-surface" warning for that story. Test passed.

### Scenario 4 — Link story to non-surface component (criterion 5292)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The spex writes a proposal linking the story to a `context` type component (not a surface). `evaluate_task` accepts it ("Passed") and includes a "warning" mentioning the story ID. Test passed.

### Scenario 5 — Component removed from proposal (criterion 5307)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
A component (`Stories.RemoteClient`) is pre-created in the DB. The proposal omits it. `evaluate_task` passes (no deletion error) and includes a warning mentioning "RemoteClient" and "preserved" or "removed from proposal". Test passed.

### Scenario 6 — Schema-only cycle allowed (criterion 5308)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal declares `User -> Account` and `Account -> User` both as `schema` children. `evaluate_task` accepts it ("Passed") with no cycle error. Test passed.

### Scenario 7 — Non-schema cycle rejected (criterion 5309)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal declares a three-way context cycle (`Stories -> AcceptanceCriteria -> Rules -> Stories`). `evaluate_task` rejects it ("needs work"), mentions "circular" or "cycle", and names "Stories". No spec stubs are created. Test passed.

### Scenario 8 — New component with no spec file (criterion 5310)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal includes `Stories.RemoteSync` as a new child module with no pre-existing spec. `evaluate_task` accepts it ("Passed") and creates a spec stub at the conventional path containing the module name and type. Test passed.

### Scenario 9 — Component with existing spec file (criterion 5311)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
An existing spec file is written for `Stories.RemoteClient` before the task. The proposal includes that component. `evaluate_task` accepts it ("Passed") and does NOT overwrite the existing spec content. Test passed.

### Scenario 10 — All dependencies resolve (criterion 5312)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The `Stories` component is pre-created in DB. The proposal declares `StoryLive.Index -> Stories`. `evaluate_task` accepts it ("Passed") with no "dangling" or "unresolved" text. Test passed.

### Scenario 11 — Dangling dependency rejected (criterion 5313)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal declares `StoryLive.Index -> Stroies` (typo, doesn't exist). `evaluate_task` rejects it ("needs work"), names "Stroies" and "StoryLive.Index" in the feedback. No spec stubs created. Test passed.

### Scenario 12 — Orphan classified as infrastructure (criterion 5657)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal includes `Web.Application` typed `infrastructure`. The `config.yml` lists the application file path in `infrastructure_paths`. `evaluate_task` accepts it ("Passed") and no spec stub is created for `Web.Application`. Test passed.

### Scenario 13 — Orphan resolved by dependency edge (criterion 5658)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal wires `SharedKit` as a transitive dep of the story-linked surface (`FeatureLive -> Features -> SharedKit`). `evaluate_task` accepts it ("Passed") and creates a spec stub for `SharedKit`. Test passed.

### Scenario 14 — Orphan blocks execution (criterion 5659)

pass

Surface: `start_task` + `evaluate_task` MCP tools (via spex).
The proposal includes `LeftoverKit` context with no story link and no dep edges. `evaluate_task` rejects it ("needs work"), names `LeftoverKit`. No spec stubs created. Test passed.

### Scenario 15 — Post-execution orphan unsatisfies gate (criterion 5871)

pass

Surface: `/projects/:name/requirements/graph` LiveView (via spex) and browser observation.
The spex syncs an orphan context spec into a fully-satisfied project, then renders the requirements graph. The `architecture_designed` node is NOT rendered as the satisfied color (red `#ff3838`). Confirmed in the live app: the Math Test Project (which has no valid proposal) shows `architecture_designed` in yellow (Blocked) in the graph screenshot. Test passed.

### Scenario 16 — Task prompt surfaces orphan details (criterion 5873)

pass

Surface: `start_task` MCP tool (via spex).
When `architecture_designed` is unsatisfied because an orphan context exists, calling `start_task` returns a prompt that names the orphan by module name (`MyOrphanContext`) and lists the resolution menu — `set_story_component`/link a story, `create_dependency`/dependency edge, `infrastructure_paths`, and delete/remove the component. Test passed.

## Evidence

- `.code_my_spec/qa/70/screenshots/70_math_test_project_requirements_graph.png` — Math Test Project requirements graph showing `architecture_designed` in yellow (not satisfied color) when no valid proposal exists
- `.code_my_spec/qa/70/screenshots/70_math_test_project_requirements_graph_preload.png` — Same graph with preload=true parameter
- Spex test suite: `mix spex test/spex/70_architecture_design/` — 525 tests, 1 failure (unrelated story 717 criterion 6425 DAG layout overlap bug)

## Issues

### Sandbox project cannot be used for architecture_designed MCP dogfooding

#### Severity
MEDIUM

#### Scope
QA

#### Description
The QA sandbox project (`code_my_spec_test_repos/qa_sandbox`, id `11111111-1111-4111-8111-111111111111`) cannot be used to dogfood the `start_task`/`evaluate_task` MCP surface for `architecture_designed`. Two separate issues block it:

1. Stories in the sandbox DB had a stale `"draft"` status value that doesn't match the current `[:in_progress, :completed, :dirty]` enum, causing `ArgumentError: cannot load "draft"` when `RequirementGraph.compute_all/1` tries to query stories. (Fixed inline during this QA run via `update_all set: [status: :in_progress]`, but the root cause is that old test data with legacy enum values was never cleaned up.)

2. Even after fixing the story status, the sandbox project's requirement graph does NOT include `architecture_designed` because that node has prerequisites (`code_generation` → `qa_integration_plan` → `architecture_designed`) that are not satisfied for the sandbox. The `start_task` call returns "Requirement architecture_designed not found for project 11111111-1111-4111-8111-111111111111".

The QA plan should document that story 70 MCP-surface tests must run against a project with the full requirement chain satisfied (e.g., `Math Test Project`), or the sandbox needs to be set up with these prerequisites. In the interim, the spex suite (`mix spex test/spex/70_architecture_design/`) provides full coverage of the `start_task`/`evaluate_task` surface via in-process calls.

### Story 717 criterion 6425 — DAG node position collision (pre-existing)

#### Severity
MEDIUM

#### Scope
APP

#### Description
When running `mix spex test/spex/70_architecture_design/`, the test suite includes all spex tests (including story 717). Criterion 6425 (`large-project_layout_keeps_distinct_bands_and_non-overlapping_nodes`) consistently fails with node position collisions: pairs like `component_*_test_file` and `component_*_implementation_file` are positioned at the same `(x, y)` coordinates (e.g., `{-325.0, -7750}`). This is a pre-existing bug unrelated to story 70 but observed across multiple test runs.

Reproduction: `mix spex test/spex/717_engineer_sees_a_dag_of_project_progress/criterion_6425_large-project_layout_keeps_distinct_bands_and_non-overlapping_nodes_spex.exs`
