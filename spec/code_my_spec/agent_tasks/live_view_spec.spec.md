# CodeMySpec.AgentTasks.LiveViewSpec

**Type**: module

Generates a specification for a LiveView page or component following the UI spec format: route, params, child components, user interactions (action → behavior + context calls), dependencies, and a structural Design section. The Design section describes layout structure, DaisyUI component choices, and responsive behavior in prose — not renderable HTML. Like ComponentSpec but for UI components — produces specs that LiveViewTest can write assertions against and LiveViewCode can implement to.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils

## Functions

### command/3

Generate the spec-writing prompt for a LiveView, including the UI spec format template.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract component from session map
2. Retrieve design rules matching the component type using `Rules.find_matching_rules/2` with session type "design"
3. Get document specification for the component type via `DocumentSpecProjector.project_spec/1`
4. Check for existing implementation and test files via `Environments.file_exists?/2`
5. Include parent component spec file path when parent exists
6. List similar components for pattern inspiration using `Components.list_similar_components/2`
7. Build spec prompt with UI-specific format guidance: route, params, child components, interactions, dependencies, structural Design section
8. Return the prompt text

**Test Assertions**:
- returns ok tuple with prompt text for valid session
- includes project name and description in prompt
- includes component name, description, and type in prompt
- includes design rules content in prompt
- includes document specification in prompt
- includes spec file path in prompt
- includes existing implementation file path when code exists
- includes existing test file path when tests exist
- includes parent component spec file path when parent exists
- includes similar components for pattern inspiration
- includes UI spec format guidance with route, interactions, and structural Design section
- returns error if rules cannot be loaded

### evaluate/3

Validate the generated spec file by checking requirements and querying persisted problems.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Reload component from database to get latest requirements
2. Check specification artifact requirements via `check_artifact_requirements/3`
   - If persisted requirements exist for `:specification`, filter and return them
   - If none exist, fall back to Registry definitions for the component type
3. Build requirement feedback from unsatisfied requirements (nil if all pass)
4. Check problems via `ProblemFeedback.for_spec_task/3` (queries spec file problems)
5. Combine requirement feedback and problem feedback via `ProblemFeedback.combine/2`

**Test Assertions**:
- returns {:ok, :valid} when all specification requirements are satisfied and no problems exist
- returns {:ok, :invalid, feedback} when specification requirements are unsatisfied
- returns {:ok, :invalid, feedback} when spec file has problems even if requirements pass
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- includes unsatisfied requirement details in feedback
- falls back to Registry definitions when no persisted requirements exist
- reloads component from database before checking requirements
