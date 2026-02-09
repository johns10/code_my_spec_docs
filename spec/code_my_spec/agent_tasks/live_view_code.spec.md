# CodeMySpec.AgentTasks.LiveViewCode

**Type**: module

Implements a LiveView module to pass its tests, with visual feedback from screenshots. Like ComponentCode but the evaluate step also reads screenshot artifacts produced by the test suite and feeds them back to the agent for visual review. When tests pass, the agent still sees the screenshots to confirm the UI looks correct before declaring done. Uses LiveView-specific coding rules: inline HEEx in render/1, core_components.ex, DaisyUI/Tailwind patterns.

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Tests

## Functions

### command/3

Generate the implementation prompt for a LiveView, referencing spec, tests, and coding rules.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

### evaluate/3

Run tests, check screenshots, and provide visual + functional feedback.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```
