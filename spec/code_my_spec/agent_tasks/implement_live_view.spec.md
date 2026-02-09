# CodeMySpec.AgentTasks.ImplementLiveView

**Type**: context

Orchestrates implementing a single LiveView and its child components via subagents. Mirrors ContextImplementation's command/evaluate pattern: generates LiveViewTest and LiveViewCode prompt files for the parent LiveView, and ComponentTest/ComponentCode prompt files for each child component. The orchestration prompt guides the agent through dependency order — child components first, then the parent LiveView that composes them. Screenshot artifacts produced by LiveView tests provide visual feedback during the code implementation phase.

## Dependencies

- CodeMySpec.AgentTasks.LiveViewTest
- CodeMySpec.AgentTasks.LiveViewCode
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.Requirements
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments

## Functions

### command/3

Generate prompt files and orchestration instructions for implementing a LiveView and its children.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

### evaluate/3

Validate the LiveView and all child components pass quality gates.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```
