# CodeMySpec.AgentTasks.RefactorModule

Agent task for guiding interactive refactoring sessions with Claude Code. Routes to component or context-specific refactoring based on the component type.

## Purpose

Provides an open-ended, conversational refactoring workflow where the agent:
1. Reviews existing spec, tests, and implementation
2. Asks the user what they want to refactor
3. Has a conversation with the user to understand requirements
4. Modifies the spec first, then tests, then implementation
5. Relies on standard validate_edits hook for validation

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

## Implementation Notes

- This is an open-ended conversational task, not a structured code generation task
- The agent should be free to have a multi-turn conversation with the user
- No special stop hook validation is needed
- The standard validate_edits hook will catch any spec or code issues
- For context refactoring, the agent should have access to all child component information
- The prompt should emphasize: spec first, then tests, then code
