# Orchestrator

## Purpose

Stateless orchestrator for component coding session workflows. Determines the next step in the test-driven development workflow based on the current interaction's result and module. Handles test failure loops by cycling between RunTests and FixTestFailures while tracking iteration counts to prevent infinite loops.

## Public API

```elixir
# Returns the first step module when starting a new session
@spec get_next_interaction(nil) :: {:ok, module()}

# Returns the next step module based on the current interaction's status and module
@spec get_next_interaction(Interaction.t()) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction | :invalid_state}

# Returns the ordered list of all step modules in the workflow
@spec steps() :: [module()]
```

## Execution Flow

### Step Progression Logic

1. **Extract Interaction Status**: Determine if the current interaction is pending, successful, or errored
2. **Match Current Step Module**: Identify which step module just completed
3. **Apply Routing Rules**:
   - **Initialize** (success) → ReadComponentDesign
   - **Initialize** (other) → Initialize (retry)
   - **ReadComponentDesign** (success) → AnalyzeAndGenerateFixtures
   - **ReadComponentDesign** (other) → ReadComponentDesign (retry)
   - **AnalyzeAndGenerateFixtures** (success) → GenerateTests
   - **AnalyzeAndGenerateFixtures** (other) → AnalyzeAndGenerateFixtures (retry)
   - **GenerateTests** (success) → GenerateImplementation
   - **GenerateTests** (other) → GenerateTests (retry)
   - **GenerateImplementation** (success) → RunTests
   - **GenerateImplementation** (other) → GenerateImplementation (retry)
   - **RunTests** (success) → Finalize
   - **RunTests** (error) → FixTestFailures
   - **RunTests** (other) → RunTests (retry)
   - **FixTestFailures** (success) → RunTests (re-test)
   - **FixTestFailures** (other) → FixTestFailures (retry)
   - **Finalize** (success) → {:error, :session_complete}
4. **Return Next Step**: Return the determined next step module or completion/error signal

### Test Failure Loop Handling

The orchestrator creates a cycle between RunTests and FixTestFailures:
- When tests fail, RunTests returns error status
- Error status routes to FixTestFailures
- FixTestFailures attempts to fix issues and returns success
- Success routes back to RunTests for re-testing
- Loop protection is handled by tracking iteration count in session state (managed by calling context, not orchestrator)

### Status Extraction

Interaction status is determined by examining the embedded Result:
- `nil` result → `:pending` (interaction not yet executed)
- `Result{status: :ok}` → `:success` (step completed successfully)
- `Result{status: :error}` → `:error` (step failed)

## Implementation Notes

### Stateless Design

- No internal state maintained between function calls
- All routing decisions based purely on interaction data
- Session state management handled by Sessions context
- Orchestrator only determines "what comes next"

### Error Handling

- Invalid step modules return `{:error, :invalid_interaction}`
- Unexpected state combinations return `{:error, :invalid_state}`
- Completed sessions return `{:error, :session_complete}`
- All other errors bubble up from step module execution