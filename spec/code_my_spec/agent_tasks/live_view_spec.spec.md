# CodeMySpec.AgentTasks.LiveViewSpec

**Type**: module

Generates a specification for a LiveView page or component following the UI spec format: route, params, child components, user interactions (action → behavior + context calls), dependencies, and a structural Design section. The Design section describes layout structure, DaisyUI component choices, and responsive behavior in prose — not renderable HTML. Like ComponentSpec but for UI components — produces specs that LiveViewTest can write assertions against and LiveViewCode can implement to.

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Environments
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter

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

Validate the generated spec file and provide feedback if needed.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Reload component from database to get latest requirements
2. Check specification artifact requirements via `Requirements.check_requirements/4` with `artifact_types: [:specification]`
3. When no persisted requirements match, fall back to Registry definitions for the component type
4. Return `:valid` if all specification requirements are satisfied
5. Build revision feedback with unsatisfied requirements via `RequirementsFormatter.format_unsatisfied/2` if any fail

**Test Assertions**:
- returns {:ok, :valid} when all specification requirements are satisfied
- returns {:ok, :invalid, feedback} when specification requirements are unsatisfied
- includes unsatisfied requirement details in feedback
- returns {:ok, :invalid, feedback} when spec file does not exist (via fallback checker)
- returns {:ok, :invalid, feedback} when spec content is invalid (via fallback checker)
