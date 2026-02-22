# CodeMySpec.AgentTasks.ManageImplementation

State machine that orchestrates the full implementation lifecycle of a project. Directly delegates to WriteBddSpecs, DevelopContext, and DevelopLiveView — tracking the current task via a status file and returning delegated prompts directly. No LLM orchestration decisions.

The orchestration is **story-focused** and driven by **BDD spec execution results**:

1. **Run all BDD specs** globally
2. If specs are **failing** → map failures to stories → find the **highest-priority failing story** → develop its component dependency chain in order
3. If specs are **passing** → write BDD specs for the next incomplete story (creating new failing specs)
4. If all specs pass and no stories remain → **done**

This creates an interleaved loop: write specs for one story, develop its full dependency chain until those specs pass, then write specs for the next story. Development stays focused on a single story at a time. All development is at the context/liveview level — DevelopContext and DevelopLiveView handle their own children internally.

## Dependencies

- CodeMySpec.BddSpecs — spec execution and story coverage checking
- CodeMySpec.BddSpecs.Parser — extracting story IDs from spec file paths
- CodeMySpec.Components — querying components with dependencies and requirements
- CodeMySpec.Components.DependencyTree — topological sorting of component chains
- CodeMySpec.Stories — story priority ordering
- CodeMySpec.Environments — file I/O for status tracking and spec file globbing
- CodeMySpec.AgentTasks.WriteBddSpecs — delegated BDD spec writing
- CodeMySpec.AgentTasks.DevelopContext — delegated context development
- CodeMySpec.AgentTasks.DevelopLiveView — delegated LiveView development

## Functions

### command/3

Sync the project, run BDD specs, and delegate to the appropriate task.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:

1. Sync project state (unless `skip_sync: true`)
2. Run all BDD specs globally to determine current state
3. If specs failing → map failures to story IDs via `Parser.derive_story_id/1` → find the highest-priority story among those with failing specs → `find_next_developable_for_story/2` → delegate to DevelopContext or DevelopLiveView
4. If specs passing → find next incomplete story → delegate to WriteBddSpecs
5. If all complete → return done message
6. Write status file tracking the delegated task (includes `target_story_id` for develop tasks)
7. Return the delegated task's prompt wrapped with a heading that includes story title

**Test Assertions**:

- writes specs when no BDD spec files exist for a story (specs trivially pass, stories incomplete)
- develops component linked to a story when that story's specs are failing
- develops dependency before target component when the target's `dependencies_satisfied` requirement is unsatisfied
- develops liveview component linked to story (dispatches to DevelopLiveView)
- returns all_complete message when no stories and no failing specs
- writes status file with task type, component IDs, and `target_story_id`
- prioritizes stories by priority field when multiple stories have failing specs

### evaluate/3

Read the status file, evaluate the delegated task, then run BDD specs to decide what's next.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) ::
  {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:

1. Read `docs/status/implementation_status.json` to determine the current task
2. Evaluate the delegated task (WriteBddSpecs.evaluate, DevelopContext.evaluate, or DevelopLiveView.evaluate)
3. If delegated task returns `:invalid` → pass through feedback (agent keeps working on current task)
4. If delegated task returns `:valid` → clear status → run BDD specs → decide next task:
   - Same story's specs still failing → develop next component in its chain (return `{:ok, :invalid, prompt}`)
   - Specs passing, stories remain → advance to writing BDD specs (return `{:ok, :invalid, prompt}`)
   - All complete → return `{:ok, :valid}`
5. If no status file exists → return `{:ok, :valid}` (nothing in progress)

**Test Assertions**:

- returns `{:ok, :valid}` when no status file exists
- evaluates WriteBddSpecs when status indicates bdd task
- evaluates DevelopContext when status indicates context task
- passes through `:invalid` feedback from delegated tasks
- advances to next task when delegated task completes
- handles errors gracefully (rescue around the whole flow)
