# Orchestrator Component Design

## Overview

**Component Name**: Orchestrator
**Type**: Other
**Module**: `CodeMySpec.ComponentDesignSessions.Orchestrator`
**Project**: Code My Spec

## Purpose

Stateless orchestrator managing the sequence of component documentation steps, determining workflow progression based on completed interactions. Handles revision loops by returning to ReviseDesign when validation fails.

## Architecture

### Core Principles

- **Stateless Design**: All state lives in the Session record and its embedded Interactions
- **Pure Functions**: Transforms input interactions to determine next workflow steps
- **Fail Fast**: Uses pattern matching to detect invalid states immediately
- **Immutable Data**: Operates on immutable Session and Interaction structures

### Workflow Steps

The orchestrator manages a fixed sequence of steps:

```elixir
@step_modules [
  Steps.Initialize,
  Steps.ReadContextDesign,
  Steps.GenerateComponentDesign,
  Steps.ReadComponentDesign,
  Steps.ValidateDesign,
  Steps.ReviseDesign,
  Steps.Finalize
]
```

### State Machine Logic

The orchestrator implements workflow progression through pattern matching on interaction status and current module:

- **Success Status**: Advances to next step in sequence
- **Error Status**: Triggers revision loop (ValidateDesign → ReviseDesign)
- **Pending Status**: Retries current step

### Revision Loop Handling

Critical workflow feature for quality assurance:

1. `ValidateDesign` returns error → transitions to `ReviseDesign`
2. `ReviseDesign` succeeds → returns to `ValidateDesign`
3. Loop continues until validation passes
4. Successful validation → proceeds to `Finalize`

## Interface

### Public Functions

#### `steps/0`
Returns the complete list of step modules in execution order.

#### `get_next_interaction/1`
Determines the next step module based on current interaction state.

**Parameters:**
- `nil` - Returns first step (Initialize)
- `%Interaction{}` - Analyzes status and current module to determine progression

**Returns:**
- `{:ok, step_module}` - Next step to execute
- `{:error, :session_complete}` - Workflow finished
- `{:error, :invalid_interaction}` - Unknown module
- `{:error, :invalid_state}` - Unexpected state combination

## Implementation Details

### Status Extraction

```elixir
defp extract_status(%Interaction{result: nil}), do: :pending
defp extract_status(%Interaction{result: %Result{status: :ok}}), do: :success
defp extract_status(%Interaction{result: %Result{status: :error}}), do: :error
```

### Step Progression Logic

Each step has specific progression rules based on status:

- **Initialize**: Success → ReadContextDesign, otherwise retry
- **ReadContextDesign**: Success → GenerateComponentDesign, otherwise retry
- **GenerateComponentDesign**: Success → ReadComponentDesign, otherwise retry
- **ReadComponentDesign**: Success → ValidateDesign, otherwise retry
- **ValidateDesign**: Success → Finalize, Error → ReviseDesign, otherwise retry
- **ReviseDesign**: Success → ValidateDesign, otherwise retry
- **Finalize**: Success → session complete

## Design Patterns

### Functional Core
- Pure functions for workflow logic
- No side effects or state mutations
- Predictable input/output transformations

### Pattern Matching Control Flow
- Primary control mechanism for step progression
- Self-documenting workflow rules
- Compile-time exhaustiveness checking

### Fail Fast Behavior
- Invalid states detected immediately
- Clear error responses for debugging
- Prevents silent failures in workflow

## Error Handling

### Invalid Interaction
Returned when interaction references unknown step module, indicating data corruption or programming error.

### Invalid State
Catch-all for unexpected status/module combinations, ensuring workflow integrity.

### Session Complete
Indicates successful workflow completion after Finalize step.

## Testing Considerations

- Test each step progression path
- Verify revision loop behavior
- Validate error conditions
- Ensure stateless operation
- Test with various interaction states

## Dependencies

- `CodeMySpec.Sessions.{Interaction, Result}`
- `CodeMySpec.ComponentDesignSessions.Steps.*`

## Future Considerations

- Potential for configurable step sequences
- Workflow metrics and monitoring
- Parallel step execution capabilities
- Dynamic step injection for custom workflows