# Sessions.Orchestrator Component

## Purpose

Coordinates session workflow by determining the next step to execute, delegating command generation to session-type-specific step modules, and managing interaction lifecycle within active sessions.

## Public API

```elixir
# Workflow Coordination
@spec next_command(Scope.t(), integer(), keyword()) ::
  {:ok, Interaction.t(), Session.t()} | {:error, :session_not_found | :complete | :failed}

# Helper Functions
@spec get_session(Scope.t(), integer()) :: {:ok, Session.t()} | {:error, :session_not_found}
```

## Execution Flow

### next_command/3
1. **Session Lookup**: Call get_session/2 to retrieve session with scope validation
2. **Status Validation**: Call validate_session_status/1 to ensure session is active
   - Return {:error, :complete} if status is :complete
   - Return {:error, :failed} if status is :failed
   - Continue if status is :active
3. **Step Resolution**: Call session.type.get_next_interaction/1 (polymorphic session module)
   - Session type module determines which step module should run next
   - Returns {:ok, step_module} where step_module implements StepBehaviour
4. **Command Generation**: Call step_module.get_command/3 with scope, session, opts
   - Step module generates Command struct appropriate for its responsibility
   - Returns {:ok, command}
5. **Interaction Creation**: Call Interaction.new_with_command/1 to wrap command
   - Creates new Interaction with generated UUID, command, nil result
6. **Session Update**: Call SessionsRepository.add_interaction/3 to persist interaction
   - Appends interaction to session.interactions embedded array
   - Updates session in database
7. **Return Results**: Return {:ok, interaction, updated_session} tuple

### get_session/2
1. **Repository Call**: Delegate to SessionsRepository.get_session/2
2. **Result Mapping**: Convert nil to {:error, :session_not_found}, session to {:ok, session}

### validate_session_status/1 (private)
1. **Pattern Match Status**: Check session.status field
2. **Return Error for Terminal States**: :complete or :failed → {:error, status}
3. **Allow Active State**: :active → :ok

## Design Notes

### Polymorphic Session Types
- Session.type field stores module name (e.g., CodeMySpec.ContextDesignSessions)
- Each session type module implements get_next_interaction/1 callback
- This enables different workflow logic per session type without conditionals

### Step Module Pattern
- Session types delegate to step modules implementing StepBehaviour
- Step modules encapsulate command generation and result handling
- Orchestrator remains generic, delegating domain logic to step modules

### Interaction Lifecycle
- Orchestrator creates interactions with commands but nil results
- Interaction is persisted immediately, creating a pending work item
- ResultHandler later completes the interaction by adding result

### Error Handling
- Returns structured errors for session not found, complete, or failed states
- Calling code can pattern match on error tuples for appropriate handling
- No exceptions raised, following "let it crash" for unexpected errors only