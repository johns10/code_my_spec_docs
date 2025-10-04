# Context Design Sessions Orchestrator

## Overview

The orchestrator is a stateless module that manages the execution of context design session workflows. All state lives in the Session record and its embedded Interactions. The orchestrator reads session state, determines the next step, and coordinates execution through pure functions.

### Data Flow

```
Client: next_step(scope, session) → {:command, interaction_id, command_data}
Client: executes command locally
Client: handle_interaction_result(scope, session_id, interaction_id, result)
Client: next_step(scope, session) → next command or {:done, status}
```

## Core Functions

### `next_step/2`
Determines the next step, creates command, stores interaction, and returns command for client:

```elixir
def next_step(scope, session) do
  case get_workflow_status(session) do
    :not_started -> create_command_for_step(scope, session, :initialize)
    :in_progress -> 
      case determine_next_from_interactions(session) do
        {:step, step_atom} -> create_command_for_step(scope, session, step_atom)
        {:retry, step_atom} -> create_command_for_step(scope, session, step_atom)
        {:done, status} -> {:done, status}
      end
    :completed -> {:done, :success}
    :failed -> {:done, :failed}
  end
end

defp create_command_for_step(scope, session, step_module_atom) do
  # Creates command, interaction, persists to session
  # Returns {:command, interaction_id, command_data}
end
```

### `handle_interaction_result/4`
Processes result from client and updates session:

```elixir
def handle_interaction_result(scope, session_id, interaction_id, result) do
  with {:ok, session} <- Sessions.get_session!(scope, session_id),
       {:ok, updated_session} <- process_result(session, interaction_id, result) do
    Sessions.update_session(scope, session, %{interactions: updated_session.interactions})
  end
end
```

### `process_result/3`
Processes interaction result and updates session:

```elixir
def process_result(session, interaction_id, result) do
  with {:ok, interaction} <- find_interaction(session, interaction_id),
       step_module <- get_step_module(interaction.command.module),
       {:ok, updated_session} <- step_module.handle_result(session, result) do
    complete_interaction(updated_session, interaction_id, result)
  end
end
```

## Step Progression Logic

Step progression is determined by examining the Command.module field of the latest interaction:

```elixir
def determine_next_from_interactions(session) do
  case get_latest_completed_step(session) do
    nil -> {:step, :initialize}
    {:initialize, status} -> handle_initialize_result(session, status)
    {:generate_context_design, status} -> handle_generate_context_design_result(session, status)
    {:validate_design, status} -> handle_validate_result(session, status)
    {:finalize, :ok} -> {:done, :success}
    {:finalize, _} -> {:done, :failed}
  end
end

def get_latest_completed_step(session) do
  session.interactions
  |> Enum.filter(&Interaction.completed?/1)
  |> Enum.sort_by(& &1.command.timestamp, {:desc, DateTime})
  |> List.first()
  |> case do
    nil -> nil
    interaction -> 
      step = String.to_atom(interaction.command.module)
      status = interaction.result.status
      {step, status}
  end
end
```

## Workflow Steps

### 1. Initialize
- Uses `CodeMySpec.Environments` to get environment setup commands
- Sets up the development environment for context design
- Command: Environment-specific setup (e.g., install dependencies, configure tools)

### 2. Generate Context Design  
- Gets the project description from session context
- Retrieves user stories related to the target context
- Analyzes context dependencies within the project
- Uses `CodeMySpec.Rules.find_matching_rules/3` to get relevant design rules
- Constructs prompt with gathered information
- Uses `CodeMySpec.Agents.Implementations.ClaudeCode` to execute context design generation
- Stores the generated design results in `handle_result/2`

### 3. Validate Design
- Takes the generated markdown from step 2 results
- Uses `CodeMySpec.Documents.create_component_document/3` with `:context_design` type
- Leverages `ContextDesignParser.from_markdown/1` to parse and validate structure
- Uses `ContextDesign.changeset/3` with scope for validation rules
- Returns validation errors if markdown doesn't conform to expected structure
- Stores validated document structure for finalization

### 4. Finalize
- Marks session as complete

## Step Module Registry

```elixir
@step_modules %{
  initialize: CodeMySpec.ContextDesignSessions.Steps.Initialize,
  generate_context_design: CodeMySpec.ContextDesignSessions.Steps.GenerateContextDesign,
  validate_design: CodeMySpec.ContextDesignSessions.Steps.ValidateDesign,
  finalize: CodeMySpec.ContextDesignSessions.Steps.Finalize
}
```

## Error Handling Strategy

### Failure Recovery
- All state persisted in session record
- Resume from last successful step based on interaction history
- Failed interactions remain in session for debugging

### Result Classification
- **Step Success**: `interaction.result.status == :ok` → advance to next step
- **Step Warning**: `interaction.result.status == :warning` → step module decides next action
- **Step Failure**: `interaction.result.status == :error` → retry or fail session

## Client-Server Workflow

### 1. Client Requests Next Command
```elixir
# Client calls
{:command, interaction_id, command_data} = Orchestrator.next_step(scope, session)

# Or workflow complete
{:done, :success} = Orchestrator.next_step(scope, session)
```

### 2. Client Executes Command Locally
Client runs the `command_data` in their environment (e.g., runs claude CLI, executes shell commands)

### 3. Client Reports Result
```elixir
# Client calls with execution result  
Orchestrator.handle_interaction_result(scope, session_id, interaction_id, result)
```

### 4. Client Requests Next Command
Cycle repeats until `{:done, status}` is returned

## State Management

### Session State Updates
- All workflow state stored in session.interactions
- Session.status tracks overall workflow status (:active, :complete, :failed)
- Command.module field identifies which step executed

### Recovery Strategy
- Load session from database to get current state
- Examine interactions to determine workflow position
- Resume from next logical step based on latest results

## Integration Points

### Context Design Sessions Context
- Orchestrator manages sessions through `ContextDesignSessions` context
- Updates broadcast to subscribers via PubSub
- Coordinates with `Sessions` context for persistence

### Step Module Coordination
- Dynamic step loading based on session configuration
- Standardized command/result interface
- Error propagation and handling

This orchestrator design follows functional principles with stateless operations, explicit data transformations, and session-based state persistence while coordinating the complex workflow of context design sessions through pure functions and pattern matching.