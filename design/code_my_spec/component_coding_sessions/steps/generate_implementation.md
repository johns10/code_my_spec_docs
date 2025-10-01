# GenerateImplementation

## Purpose

Generates the component implementation code using AI agents, applying the component design document and relevant coding rules. Creates all necessary module files, schemas, and supporting code to satisfy the tests written in the previous step.

## Public API

```elixir
defmodule CodeMySpec.ComponentCodingSessions.Steps.GenerateImplementation do
  @spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, term()}
  @spec handle_result(Scope.t(), Session.t(), String.t()) :: {:ok, map(), String.t()}
end
```

## Execution Flow

1. **Retrieve Implementation Rules**: Query coding rules matching the session and component type
2. **Load Component Design**: Extract component design document content from session state
3. **Build Implementation Prompt**: Compose prompt including:
   - Project name and description
   - Component name, description, and type
   - Component design document content
   - Implementation-specific coding rules
   - Target file paths for implementation
4. **Create AI Agent**: Initialize a context_designer agent with claude_code model
5. **Build Command**: Generate command string and pipe for agent execution
6. **Return Command**: Wrap command in Session.Command struct for orchestrator execution
7. **Handle Result**: Process agent response and return unchanged result with empty state updates