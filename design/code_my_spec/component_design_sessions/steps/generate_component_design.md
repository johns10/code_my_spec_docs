# GenerateComponentDesign

## Purpose

Generates comprehensive component documentation using AI agents by composing prompts from session state, design rules, and document specifications. Creates documentation that aligns with parent context architecture and follows project design patterns. Implements StepBehaviour to generate commands for AI agent execution and process results.

## Public API

```elixir
@callback get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, String.t()}
@callback handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()} | {:error, String.t()}
```

## Execution Flow

### Command Generation (get_command/2)

1. **Load Design Rules**: Query Rules context for rules matching component type and "design" session type
2. **Compose Generation Prompt**: Build structured prompt containing:
   - Component metadata (name, type, description)
   - Parent context design from session state (if available)
   - Design rules content concatenated with separators
   - Document specification projected from ComponentDesign schema
   - Target design file path from component utilities
3. **Create AI Agent**: Initialize component_designer agent with "component-design-generator" name using claude_code provider
4. **Build Agent Command**: Delegate to Agents context to build executable command with prompt
5. **Return Command**: Wrap agent command in Command struct with module reference for result handling

### Result Processing (handle_result/3)

1. **Pass Through Result**: Accept result from agent execution without transformation
2. **Return Empty Updates**: Return empty map for session updates and unmodified result
3. **Allow Orchestrator**: Let session orchestrator handle result persistence and next step determination