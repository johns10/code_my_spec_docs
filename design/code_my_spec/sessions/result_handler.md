# Sessions.ResultHandler Component

## Purpose

Processes command execution results by delegating to step-specific result handlers, allowing step modules to interpret results and update session state before marking interactions as complete.

## Public API

```elixir
# Result Processing
@spec handle_result(Scope.t(), integer(), binary(), map(), keyword()) ::
  {:ok, Session.t()} | {:error, term()}

# Helper Functions
@spec get_session(Scope.t(), integer()) :: {:ok, Session.t()} | {:error, :session_not_found}
@spec find_interaction(Session.t(), binary()) :: {:ok, Interaction.t()} | {:error, :interaction_not_found}
```

## Execution Flow

### handle_result/5
1. **Session Lookup**: Call get_session/2 to retrieve session with scope validation
   - Returns {:error, :session_not_found} if session doesn't exist
2. **Result Creation**: Call Sessions.create_result/2 to build Result struct from result_attrs
   - Validates result attributes through Result.changeset/2
   - Returns {:ok, result} or {:error, changeset}
3. **Interaction Lookup**: Call find_interaction/2 to locate target interaction by ID
   - Searches session.interactions array for matching interaction_id
   - Returns {:error, :interaction_not_found} if not present
4. **Delegate Result Processing**: Call interaction.command.module.handle_result/4
   - Step module interprets result and determines session updates
   - Step module can modify result (e.g., extract data, change status)
   - Returns {:ok, session_attrs, final_result}
5. **Complete Interaction**: Call Sessions.complete_session_interaction/5
   - Updates session fields per session_attrs (status, state, etc.)
   - Marks interaction as complete with final_result
   - Sets completed_at timestamp
   - Persists to database
6. **Return Updated Session**: Return {:ok, final_session}

### get_session/2
1. **Repository Call**: Delegate to SessionsRepository.get_session/2
2. **Result Mapping**: Convert nil to {:error, :session_not_found}, session to {:ok, session}

### find_interaction/2
1. **Search Interactions**: Use Enum.find/2 to locate interaction by ID in session.interactions
2. **Result Mapping**: Convert nil to {:error, :interaction_not_found}, interaction to {:ok, interaction}

## Design Notes

### Step Module Responsibility
- Each step module (implementing StepBehaviour) defines handle_result/4
- Step module interprets result in domain-specific context
- Step module can update session.state with step-specific data
- Step module can change session.status (e.g., mark :complete or :failed)
- Step module returns modified result if needed (e.g., extract parsed data)

### Separation of Concerns
- ResultHandler orchestrates the result processing flow
- Step modules contain domain logic for interpreting results
- Session context handles persistence and broadcasting

### Error Pipeline
- With-clause chains ensure early return on any error
- Errors propagate up with descriptive atoms or tuples
- No exceptions for expected error cases (not found, validation failures)

### Transaction Safety
- complete_session_interaction wraps updates in Repo.update/1
- Embedded interactions updated atomically with session
- No partial updates possible

### Integration with Orchestrator
- Orchestrator creates interactions with commands (nil results)
- ResultHandler completes interactions by adding results
- This creates clear separation between command generation and result processing