# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Patch mode: evaluate does not auto-execute (criterion 5829)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5829_architect_patches_existing_architecture_without_redesigning_it_spex.exs`.

Steps: A project was set up with a populated `proposal.md` (patch mode marker written at
session start via `start_task`). The spex created an existing component (`MyApp.Existing`)
by executing a proposal, then added an unsatisfied story. The architect called
`create_component` for `MyApp.NewFeature` and linked the story via `set_story_component`.
`evaluate_task` was then called without rewriting the proposal.

Observations: The evaluator returned "Passed" in its response. No "Component removed from
proposal but preserved in DB: MyApp.NewFeature" warning appeared. The pre-existing
`proposal.md` still contained `MyApp.Existing` and did not contain `MyApp.NewFeature`,
confirming the proposal was left untouched. All assertions passed.

### Scenario 2 — Reuse existing component to satisfy new story (criterion 5830)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5830_architect_reuses_an_existing_component_to_satisfy_a_new_story_spex.exs`.

Steps: An existing component (`MyApp.Accounts`) was created via proposal execution. A new
story was created without a component link. The component count was recorded. The architect
called `set_story_component` to link the story to the existing component.

Observations: The link succeeded without errors. `list_components` returned the same count
after the link as before — no new component was created. All assertions passed.

### Scenario 3 — Link story via component linker tool (criterion 5831)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5831_architect_links_a_story_to_a_component_via_the_component_linker_tool_spex.exs`.

Steps: An existing component (`MyApp.Notifications`) was created via proposal execution. An
unlinked story was created. The architect called `set_story_component` with the story ID and
module name `MyApp.Notifications`.

Observations: The tool reported success without errors. The response text contained
"Component assigned to story" and the story title "Story — needs notifications". All
assertions passed.

### Scenario 4 — Create stub component via create_component tool (criterion 5832)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5832_architect_creates_a_stub_component_via_the_create_component_tool_spex.exs`.

Steps: No spec file existed at the conventional path for the new component. The architect
called `create_component` with module name, type `context`, and description for
`MyApp.Notifications`.

Observations: The tool reported success. The new component appeared in `list_components`
output with its module name. A stub spec file was created at the conventional path. The stub
spec content referenced the module name and the type `context`. All assertions passed.

### Scenario 5 — Rewrite proposal in patch mode and trigger execution manually (criterion 5833)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5833_architect_rewrites_proposal_in_patch_mode_and_triggers_execution_manually_spex.exs`.

Steps: A project was set up with an existing component (`MyApp.Existing`) and an unsatisfied
story. The architect wrote a new `proposal.md` end-to-end (adding `MyAppWeb.FeatureLive`,
`MyApp.Feature`, and keeping `MyApp.Existing`). The architect called `execute_proposal`
explicitly to apply the rewrite.

Observations: The tool reported success without errors. `list_components` showed both
`MyAppWeb.FeatureLive` and `MyApp.Feature` as new entries. `MyApp.Existing` was preserved.
Stub spec files existed for all new components at their conventional paths. All assertions
passed.

### Scenario 6 — Architecture prompt only references registered tools (criterion 5874)

pass

Executed via `mix spex test/spex/682_architect_agent_surface/criterion_5874_architecture_prompt_only_references_tools_registered_on_local_server_spex.exs`.

Steps: A fully satisfied project was set up with an orphan context synced in. The architect
called `start_task` for `architecture_designed` to retrieve the prompt.

Observations: Every backtick-quoted `snake_case` token in the prompt was either a tool
registered on `CodeMySpec.McpServers.LocalServer` or on the explicit non-tool whitelist
(`architecture_proposal`, `infrastructure_paths`, and component type values like `context`,
`liveview`, etc.). The tool `set_story_component` was both registered on LocalServer and
referenced in backticks in the prompt. All assertions passed.

Manual verification of prompt tokens against LocalServer registration confirmed:
- `analyze_stories` — registered (`Architecture.Tools.AnalyzeStories`)
- `create_component` — registered (`Components.Tools.CreateComponent`)
- `execute_proposal` — registered (`Architecture.Tools.ExecuteProposal`)
- `set_story_component` — registered (`Stories.Tools.SetStoryComponent`)
- `update_component` — registered (`Components.Tools.UpdateComponent`)
- `validate_dependency_graph` — registered (`Architecture.Tools.ValidateDependencyGraph`)
- `start_task` — registered (`Tasks.Tools.StartTask`)
- `architecture_proposal` — on non-tool whitelist (document type identifier)
- `infrastructure_paths` — on non-tool whitelist (config key)

## Evidence

All criteria were validated via the spex BDD test suite. Three consecutive runs produced
the same result: 528 tests, 0 failures (completed in approximately 17-18 seconds each).

Test suite: `mix spex test/spex/682_architect_agent_surface/`
Result: 528 tests, 0 failures

## Issues

None
