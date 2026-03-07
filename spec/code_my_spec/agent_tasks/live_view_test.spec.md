# CodeMySpec.AgentTasks.LiveViewTest

## Type

module

Writes tests for a LiveView module. Like ComponentTest but specialized for LiveView concerns: mounts the view via `live/2`, tests handle_event callbacks, and validates rendered HTML structure. Produces tests that verify functional correctness of the LiveView against its spec — visual validation (HTML artifact capture and screenshots) is handled separately by BDD specs.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils

## Functions

### command/3

Generate the test-writing prompt for a LiveView, with LiveView-specific testing guidance.

```elixir
@spec command(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component from session map
2. Get test rules for the component type using `Rules.find_matching_rules/2` with session type "test"
3. List similar components for test pattern inspiration using `Components.list_similar_components/2`
4. Check if implementation exists by checking `:code` artifact requirements to determine TDD vs validation mode
5. Build test prompt with:
   - Project name and description
   - Component name, type, and description
   - Parent component spec file path when parent exists
   - Spec file path (for reading test assertions) and test file path (where to write)
   - TDD context: TDD mode when implementation doesn't exist, validation mode when it does
   - LiveView-specific guidance: mount via `live/2`, test `handle_event` callbacks, validate rendered HTML structure
   - Similar components formatted with their spec/code/test file paths
   - Test rules content
6. Return prompt text prefixed with `TaskMarker.build("LiveViewTest", component.module_name)`

**Test Assertions**:
- returns ok tuple with prompt string containing task marker
- includes project name and description in prompt
- includes component name, type, and description in prompt
- includes spec file path and test file path in prompt
- includes parent component spec file path when parent exists
- includes TDD mode guidance when implementation doesn't exist
- includes validation mode guidance when implementation exists
- includes LiveView-specific test guidance (live/2, handle_event, rendered HTML)
- includes test rules content in prompt
- includes similar components with file paths when available
- handles empty similar components list with fallback text

### evaluate/3

Validate LiveView tests by checking test requirements and querying persisted problems. Follows the same pattern as ComponentTest: check test artifact requirements, then check for blocking problems (compilation, credo) while filtering out test failures which are expected in TDD mode.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component and project from session map
2. Reload component from database via `ComponentRepository.get_component/2` to get latest requirements
3. Check test artifact requirements via `Requirements.check_requirements/4` with `artifact_types: [:tests]`
4. Build requirement feedback from unsatisfied requirements (nil if all pass)
5. Check problems via `ProblemFeedback.for_test_task/3` (queries test file problems, filters out test failures)
6. Combine requirement feedback and problem feedback via `ProblemFeedback.combine/2`

**Test Assertions**:
- returns {:ok, :valid} when all test requirements are satisfied and no blocking problems exist
- returns {:ok, :invalid, feedback} when test file does not exist
- returns {:ok, :invalid, feedback} when test spec alignment fails
- returns {:ok, :invalid, feedback} when compilation errors exist in test file
- returns {:ok, :valid} even when test failures exist (TDD mode — test failures are filtered out)
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- includes unsatisfied requirement details in feedback
- includes problem details in feedback for non-test problems
- reloads component from database before checking requirements
