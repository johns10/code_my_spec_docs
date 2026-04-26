# CodeMySpec.AgentTasks.RefactorModule

Agent task for guiding interactive refactoring sessions with Claude Code. Routes
to component or context-specific refactoring based on the component type.

Provides an open-ended, conversational refactoring workflow: the agent reviews
existing spec/tests/implementation, asks the user what they want to refactor,
discusses requirements, then modifies spec first, then tests, then
implementation. The standard `validate_edits` hook handles validation; no
custom stop-hook check is needed. For context refactors, the agent has access
to all child component files.

## Functions

### command/3

Generates the initial prompt for Claude to start the refactoring session.

```elixir
@spec command(scope :: term(), session :: map(), opts :: keyword()) :: {:ok, String.t()}
```

**Process**:
1. Determine if this is a context or component refactor from session.component.type
2. For component refactor:
   - Read the spec file, test file, and implementation file
   - Build a prompt that includes all current code
   - Instruct the agent to review the code and ask the user what they want to refactor
3. For context refactor:
   - Read the context spec file
   - List all child components and their files
   - Build a prompt that includes context overview and child components
   - Instruct the agent to review the context and ask the user what they want to refactor
4. Return {:ok, prompt_text}

**Test Assertions**:
- Returns {:ok, prompt} with prompt containing instruction to ask user about refactor goals
- For component: prompt includes spec file, test file, and code file paths
- For context: prompt includes context spec and all child component paths
- Prompt instructs agent to modify spec first, then tests, then code

### evaluate/3

Evaluates the refactoring session after completion.

```elixir
@spec evaluate(scope :: term(), session :: map(), opts :: keyword()) :: {:ok, :valid}
```

**Process**:
1. Always returns {:ok, :valid}
2. No special validation - relies on standard validate_edits hook to check modified files

**Test Assertions**:
- Always returns {:ok, :valid}
- Does not perform any custom validation

## Dependencies

- CodeMySpec.Rules - for loading refactoring design rules
- CodeMySpec.Utils - for component file path resolution
- CodeMySpec.Environments - for file reading
- CodeMySpec.Components - for listing child components of a context
