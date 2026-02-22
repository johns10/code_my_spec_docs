# CodeMySpec.AgentTasks.DevelopLiveView

**Type**: context

Orchestrates the full lifecycle of a LiveView from specification through implementation. Mirrors DevelopContext's phased approach: spec the LiveView, spec child components, then implement (tests + code) in dependency order — child components first, then the parent LiveView that composes them. Uses LiveViewSpec/LiveViewTest/LiveViewCode for the parent LiveView and ComponentSpec/ComponentTest/ComponentCode for child components.

Writes prompt files to `docs/status/{root}/{live_view}/` — the same directory tree that StatusWriter uses for status markdown. Paths are derived from the component's module_name, making the whole thing idempotent.

Lifecycle phases:
1. LiveView spec (LiveViewSpec)
2. Component specs (ComponentSpec) for each child
3. Implementation (LiveViewTest + LiveViewCode for parent, ComponentTest + ComponentCode for children in dependency order)

Two main functions:
- `command/3` - Generates prompt files for incomplete phases, returns orchestration prompt
- `evaluate/3` - Validates all phases complete and cleans up prompt files

## Dependencies

- CodeMySpec.AgentTasks.LiveViewSpec
- CodeMySpec.AgentTasks.LiveViewTest
- CodeMySpec.AgentTasks.LiveViewCode
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.Requirements
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments

## Functions

### command/3

Generate prompt files and orchestration instructions for the full LiveView lifecycle.

Checks each phase (spec, implementation) and generates prompt files
for incomplete phases. Files are written to `docs/status/{root}/{live_view}/`.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract LiveView component from session
2. Reload component from repository to ensure requirements and children are preloaded
3. Get all child components (descendants) of the LiveView
4. Check lifecycle phases to determine which are complete vs missing:
   - LiveView spec via LiveViewSpec.evaluate/3
   - Component specs via ComponentSpec.evaluate/3 for each child
   - Implementation via Requirements.check_requirements/4 (artifact_types: [:tests] and [:code])
5. Generate prompt files for incomplete phases only:
   - LiveView spec: LiveViewSpec.command/3
   - Component specs: ComponentSpec.command/3 per child
   - Implementation tests: LiveViewTest.command/3 for parent, ComponentTest.command/3 for children
   - Implementation code: LiveViewCode.command/3 for parent, ComponentCode.command/3 for children
6. Respect phase ordering — implementation only when all specs complete
7. Build orchestration prompt with current phase instructions and subagent guidance
8. Write orchestration file to `docs/status/{root}/{live_view}/develop_live_view.md`

**Test Assertions**:
- returns completion message when all phases are complete
- generates LiveView spec prompt when LiveView spec is missing
- generates component spec prompts for each child with missing spec
- generates LiveViewTest prompt for parent when implementation phase and tests needed
- generates LiveViewCode prompt for parent when implementation phase and code needed
- generates ComponentTest prompts for children when implementation phase and tests needed
- generates ComponentCode prompts for children when implementation phase and code needed
- does not generate implementation prompts when specs are incomplete
- skips prompt generation for phases already complete
- writes prompt files to correct status directory structure
- returns orchestration prompt with current phase and prompt file list
- includes dependency order guidance for implementation phase (children first, parent last)

### evaluate/3

Validate all lifecycle phases are complete for the LiveView.

Cleans up completed phase prompt files and returns validation status.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract LiveView component from session
2. Reload component from repository to ensure requirements and children are preloaded
3. Get all child components (descendants) of the LiveView
4. Check lifecycle phases to determine completion status:
   - LiveView spec via LiveViewSpec.evaluate/3
   - Component specs via ComponentSpec.evaluate/3 for each child
   - Implementation via Requirements.check_requirements/4 (artifact_types: [:tests] and [:code])
5. Clean up prompt files for completed phases
6. If all phases complete, cleanup status directory and return `{:ok, :valid}`
7. If phases incomplete, regenerate prompt files for current phase and build feedback with missing phase details

**Test Assertions**:
- returns {:ok, :valid} when all phases are complete
- returns {:ok, :invalid, feedback} when LiveView spec phase is incomplete
- returns {:ok, :invalid, feedback} when component specs phase is incomplete
- returns {:ok, :invalid, feedback} when implementation phase is incomplete
- feedback includes list of incomplete phases and affected components
- feedback includes status directory path and subagent instructions
- cleans up prompt files for completed phases
- removes status directory when all phases complete
- regenerates prompt files for current incomplete phase on invalid
