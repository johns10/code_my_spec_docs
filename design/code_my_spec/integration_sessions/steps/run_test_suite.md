# RunTestSuite

## Purpose

Executes the entire project test suite and stores the results in session state. Runs all tests without filtering, captures output from ExUnitJsonFormatter, and stores the complete test run data for the orchestrator to analyze and pass to subsequent steps.

## Public API

```elixir
@spec get_command(scope :: Scope.t(), session :: Session.t(), opts :: Keyword.t()) ::
  {:ok, Command.t()}

@spec handle_result(scope :: Scope.t(), session :: Session.t(), result :: Result.t(), opts :: Keyword.t()) ::
  {:ok, state_updates :: map(), result :: Result.t()}
```

## Execution Flow

1. **Command Generation**: Build test command for entire suite
   - Use `mix test --formatter ExUnitJsonFormatter` without file path filtering
   - Include optional seed parameter if provided in opts
   - Return Command struct with module reference and command string

2. **Result Processing**: Extract and validate test run data
   - Check if result.data contains pre-parsed test data
   - If not, extract JSON from stdout (filter compilation messages)
   - Parse JSON using Jason.decode/1
   - Validate parsed data against TestRun schema

3. **Test Run Storage**: Store validated test run in result and session state
   - Update result record with validated TestRun struct in data field
   - Add test_run to state_updates map for session state
   - Return success tuple with state updates and updated result

4. **Error Handling**: Handle parsing or validation failures
   - Format error message describing failure reason
   - Update result status to :error with error_message
   - Return empty state_updates map with error result
   - Log validation errors for debugging

## Implementation Notes

- Does NOT analyze test failures or categorize them
- Does NOT make decisions about architectural issues
- Simply captures complete test suite output and stores it
- Orchestrator will handle failure analysis and decision-making
- Reuses TestRun schema and validation logic from Tests context
- Uses same JSON extraction approach as component-level RunTests step