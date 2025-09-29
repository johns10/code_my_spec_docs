# Component Design Sessions Orchestrator

## Overview

The Component Design Sessions Orchestrator is a stateless workflow coordinator that manages the lifecycle of AI-driven component design sessions. It determines the sequence of design steps, handles validation feedback loops, and coordinates the transition between different phases of component documentation generation.

## Architecture Principles

### Stateless Design
The orchestrator itself holds no state - all session state lives in the `Session` record and its embedded `Interaction` records. This eliminates race conditions and makes the system predictable and easy to reason about.

### Functional Composition
Workflow logic is built through pure function composition:
- `get_next_interaction/1` is a pure function that transforms interaction state to next step
- Pattern matching drives control flow rather than conditional logic
- State transitions are explicit and auditable

## Component Structure

**Key Functions**:
- `steps/0` - Returns the ordered list of workflow step modules
- `get_next_interaction/1` - Determines the next step based on current interaction state

## Workflow Steps

The orchestrator manages a fixed sequence of steps, each implementing the `StepBehaviour`:

```elixir
@step_modules [
  Steps.Initialize,           # Environment setup and session state preparation
  Steps.ReadContextDesign,    # Load existing context design for reference
  Steps.GenerateComponentDesign, # AI-driven component design generation
  Steps.ReadComponentDesign,  # Load generated design into session state
  Steps.ValidateDesign,       # Validate design against rules and requirements
  Steps.ReviseDesign,         # Iterative design improvement based on validation
  Steps.Finalize             # Environment teardown and session completion
]
```

### Step Relationships

#### Linear Progression
Most steps follow a linear progression on success:
- `Initialize` → `ReadContextDesign` → `GenerateComponentDesign` → `ReadComponentDesign` → `ValidateDesign` → `Finalize`

#### Revision Loop
The orchestrator implements a validation-revision feedback loop:
- `ValidateDesign` (success) → `Finalize`
- `ValidateDesign` (error) → `ReviseDesign`
- `ReviseDesign` (success) → `ValidateDesign`

This creates an iterative improvement cycle where designs are refined until they pass validation.

#### Error Handling
Failed steps remain on the same step, allowing for retry:
- Any step with `status: :error` or `status: :pending` stays on the current step
- Only successful steps (`status: :ok`) advance to the next step

## Design Patterns

### State Machine Implementation
While not using `GenStateMachine` directly, the orchestrator implements explicit state machine logic:
- States are represented by the current step module
- Transitions are explicit functions with clear conditions
- Invalid transitions return errors rather than attempting recovery

### Command Pattern
Each step implements the Command pattern through `StepBehaviour`:
- `get_command/2` generates executable commands
- `handle_result/3` processes command results and updates session state
- Commands are immutable and can be replayed for debugging

### Strategy Pattern
Different step implementations provide varying strategies:
- Environment setup strategies (local vs VSCode)
- AI agent strategies (different prompting approaches)
- Validation strategies (rule-based vs AI-driven)

## Error Handling

### Explicit Error States
The orchestrator makes errors explicit rather than hiding them:
- Invalid module types return `{:error, :invalid_interaction}`
- Unknown states return `{:error, :invalid_state}`
- Completed sessions return `{:error, :session_complete}`

## Dependencies

### Internal Dependencies
- `CodeMySpec.Sessions.{Interaction, Result}` - Session state management
- `CodeMySpec.ComponentDesignSessions.Steps.*` - Individual step implementations