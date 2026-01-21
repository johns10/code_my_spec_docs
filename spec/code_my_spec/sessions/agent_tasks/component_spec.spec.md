# ComponentSpec

Agent task module for generating component specification documents via Claude Code slash commands.

This module orchestrates the workflow of creating component spec documents through AI agents. It provides two main entry points: `command/3` builds the initial prompt for Claude with design rules and document specifications, while `evaluate/3` validates the generated spec file against the document schema and provides feedback for revision if needed.

## Delegates

None

## Functions

### command/3

Generate the prompt for Claude to create a component specification document.

```elixir
@spec command(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract component from session map
2. Retrieve design rules matching the component type using `Rules.find_matching_rules/2`
3. Build the complete spec prompt via `build_spec_prompt/2` with rules
4. Return the prompt text

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
- returns error if rules cannot be loaded

### evaluate/3

Validate the generated spec file and provide feedback if needed.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Read the spec file from the session's component spec path
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

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Environments
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Components.Component
