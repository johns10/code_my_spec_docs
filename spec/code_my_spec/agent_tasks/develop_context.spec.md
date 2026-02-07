# CodeMySpec.AgentTasks.DevelopContext

Orchestrates the full lifecycle of a context from specification through implementation.

Creates prompt files for all subagent tasks in order:
1. Context spec (ContextSpec)
2. Component specs (ComponentSpec) for each child
3. Design review (ContextDesignReview)
4. Tests for each component (ComponentTest)
5. Code for each component (ComponentCode)

The module generates prompt files in `.code_my_spec/internal/sessions/{external_id}/subagent_prompts/`
and provides orchestration instructions for AI agents to invoke appropriate subagents for each phase.

## Dependencies

- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.ContextDesignReview
- CodeMySpec.AgentTasks.ContextSpec
- CodeMySpec.Utils

## Functions

### command/3

Generate prompt files and orchestration instructions for the full context lifecycle.

Checks each phase (spec, design review, test, code) and generates prompt files
for incomplete phases. Returns an orchestration prompt guiding the AI agent
through the current phase.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:

1. Extract context component and external_id from session
2. Reload component from repository to ensure requirements and children are preloaded
3. Get all child components (descendants) of the context
4. Check lifecycle phases to determine which are complete vs missing
5. Generate prompt files for incomplete phases only
6. Build orchestration prompt with current phase instructions and subagent guidance

**Test Assertions**:

- returns completion message when all phases are complete
- generates context spec prompt when context spec is missing
- generates component spec prompts for each missing child spec
- generates design review prompt only when context and component specs are complete
- generates test prompts only when design review is complete
- generates code prompts only when tests are complete
- writes prompt files to correct directory structure
- returns orchestration prompt with current phase and prompt file list

### evaluate/3

Validate all lifecycle phases are complete for the context.

Cleans up completed phase prompt files and returns validation status.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) ::
  {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:

1. Extract context component and external_id from session
2. Reload component from repository to ensure requirements and children are preloaded
3. Get all child components (descendants) of the context
4. Check lifecycle phases to determine completion status
5. Clean up prompt files for completed phases
6. If all phases complete, cleanup prompt directory and return `{:ok, :valid}`
7. If phases incomplete, build feedback with missing phase details and return `{:ok, :invalid, feedback}`

**Test Assertions**:

- returns `{:ok, :valid}` when all phases are complete
- returns `{:ok, :invalid, feedback}` when phases are incomplete
- feedback includes list of incomplete phases and affected components
- feedback includes prompt directory path and subagent instructions
- cleans up prompt files for completed phases
- removes empty prompt directory when all phases complete
