# Sessions.StepBehaviour Component

## Purpose

Defines the behaviour contract for workflow step modules, establishing callbacks that step implementations must provide for command generation and result processing within session orchestration.

## Public API

```elixir
@callback get_command(scope :: Scope.t(), session :: Session.t(), opts :: keyword()) ::
  {:ok, Command.t()} | {:error, String.t()}

@callback handle_result(scope :: Scope.t(), session :: Session.t(), result :: Result.t(), opts :: keyword()) ::
  {:ok, session_updates :: map(), updated_result :: Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/3 Callback
Step modules implement this callback to generate commands for their specific responsibility:

1. **Receive Context**: Accepts scope, session, and opts
2. **Analyze Session State**: Examine session.state, session.interactions, related entities
3. **Determine Command**: Build Command struct with:
   - `module`: Reference to self (step module)
   - `command`: Serialized command configuration
   - `pipe`: Processing pipeline configuration
4. **Return Command**: Return {:ok, command} or {:error, reason}

### handle_result/4 Callback
Step modules implement this callback to process command execution results:

1. **Receive Result**: Accepts scope, session, result, and opts
2. **Interpret Result**: Parse result.data, result.stdout, result.status
3. **Determine Session Updates**: Build map with session field updates:
   - `status`: Update to :complete, :failed, or leave :active
   - `state`: Merge new state data with existing session.state
   - Other session fields as needed
4. **Transform Result**: Optionally modify result (extract parsed data, enrich error messages)
5. **Return Updates**: Return {:ok, session_attrs, final_result} or {:error, reason}

## Design Notes

### Polymorphic Workflow Execution
- Session.type field stores session module (e.g., CodeMySpec.ContextDesignSessions)
- Session module determines which step modules to execute in sequence
- Step modules implement StepBehaviour to provide pluggable workflow steps
- Orchestrator remains generic, delegating to step modules via callbacks

### Step Module Responsibilities
- **Command Generation**: Translate session state into executable commands
- **Result Interpretation**: Parse results and determine next session state
- **Domain Logic**: Encapsulate step-specific business rules
- **Stateless Operations**: Each callback receives full context, returns updates

### Integration Pattern
```elixir
# Session type module determines next step
defmodule CodeMySpec.ComponentDesignSessions do
  def get_next_interaction(%Session{state: %{stage: :analyze}}) do
    {:ok, CodeMySpec.ComponentDesign.AnalyzeStep}
  end
end

# Step module implements behaviour
defmodule CodeMySpec.ComponentDesign.AnalyzeStep do
  @behaviour CodeMySpec.Sessions.StepBehaviour

  def get_command(scope, session, _opts) do
    # Generate command for analysis
    command = Command.new(__MODULE__, %{component_id: session.component_id}, "analyze")
    {:ok, command}
  end

  def handle_result(scope, session, result, _opts) do
    # Parse analysis result, update session state
    session_attrs = %{state: Map.put(session.state, :analysis_complete, true)}
    {:ok, session_attrs, result}
  end
end
```

### Error Handling Convention
- Return {:error, string_message} for business logic errors
- Let unexpected errors crash (supervisor will restart)
- Error messages should be descriptive for debugging
- ResultHandler and Orchestrator propagate errors up the stack

### Pure Functions
- Callbacks receive immutable data structures
- Callbacks return declarative updates
- No side effects (database, external calls) in step modules
- Persistence handled by ResultHandler and Sessions context