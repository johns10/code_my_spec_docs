# CodeMySpec.AgentTasks.LiveViewTest

**Type**: module

Writes tests for a LiveView module, including screenshot capture for visual validation. Like ComponentTest but specialized for LiveView concerns: mounts the view via `live/2`, tests handle_event callbacks, validates rendered HTML structure, and captures screenshots via elogram at key visual states. The test rules guide the agent to produce tests that serve as both functional assertions and visual evidence — rendered HTML and screenshots are saved as test artifacts that LiveViewCode's evaluate step can feed back for visual review.

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Tests
- CodeMySpec.Compile
- CodeMySpec.StaticAnalysis

## Functions

### command/3

Generate the test-writing prompt for a LiveView, including screenshot capture guidance.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

### evaluate/3

Validate LiveView tests compile, align with spec assertions, and capture required screenshots.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```
