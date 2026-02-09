# CodeMySpec.AgentTasks.LiveViewSpec

**Type**: module

Generates a specification for a LiveView page or component following the UI spec format: route, params, child components, user interactions (action → behavior + context calls), dependencies, and a Design section containing reference DaisyUI/HTML markup. Like ComponentSpec but for UI components — produces specs that LiveViewTest can write assertions against and LiveViewCode can implement to.

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Environments
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Components
- CodeMySpec.Components.Component

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
7. Build spec prompt with UI-specific format guidance: route, params, child components, interactions, dependencies, Design HTML section
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
- includes UI spec format guidance with route, interactions, and Design sections
- returns error if rules cannot be loaded

### evaluate/3

Validate the generated spec file and provide feedback if needed.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Read the spec file from the component's spec path via `Environments.read_file/2`
2. Validate the spec content against document schema using `Documents.create_dynamic_document/2`
3. Return `:valid` if validation passes
4. Build revision feedback with validation errors if validation fails
5. Return error tuple if spec file is missing or unreadable

**Test Assertions**:
- returns {:ok, :valid} when spec file is valid
- returns {:ok, :invalid, feedback} when spec file has validation errors
- includes validation error details in feedback
- returns error when spec file does not exist
- returns error when spec file is empty
- returns error when spec file cannot be read
