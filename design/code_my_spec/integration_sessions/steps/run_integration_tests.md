# RunIntegrationTests

## Purpose

Executes the integration test suite for a Phoenix context and analyzes results to validate component interactions and acceptance criteria satisfaction. Captures integration failures, component interaction issues, and acceptance criteria violations. Unlike component unit tests which expect failures in TDD workflows, integration tests validate that designed components work together correctly—failures here indicate integration problems requiring fixes or session reactivation.

## Public API

```elixir
@spec get_command(Scope.t(), Session.t(), keyword()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t(), keyword()) :: {:ok, map(), Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/3

1. **Extract Context Component**: Get the context component from session (session.component represents the context being integrated)
2. **Determine Test File Path**: Use Utils.component_files/2 to get integration test file path for the context
   - Integration tests should be in `test/<project>/<context>_integration_test.exs` format
   - For coordination contexts, integration tests validate external context orchestration
   - For domain contexts, integration tests validate component interactions within the context
3. **Build Test Command**: Construct mix test command:
   - Command format: `mix test <test_file_path> --formatter ExUnitJsonFormatter`
   - Optional seed parameter for reproducibility: `--seed #{opts[:seed]}` if provided
4. **Return Command**: Create and return Command struct for test execution

### handle_result/3

1. **Extract Test Run Data**: Parse test results from Result struct
   - Check if `result.data` already contains parsed test run (map with test data)
   - If not, extract JSON from `result.stdout` using helper function
   - Handle compilation messages and other noise in stdout by locating JSON boundaries
2. **Parse JSON Output**: Decode ExUnitJsonFormatter JSON output
   - Extract test statistics (failures, passes, excluded, skipped)
   - Parse individual test results with failure details
   - Capture test file locations and line numbers for failures
3. **Validate Test Run Schema**: Validate parsed data against TestRun schema
   - Ensure all required fields present (stats, tests, etc.)
   - Return changeset errors if validation fails
4. **Store Test Run in Result**: Update Result record with parsed TestRun data via Sessions.update_result/3
5. **Analyze Test Results**: Determine integration test outcome based on statistics
   - **All Tests Passing** (`failures: 0, passes: > 0`):
     - This is SUCCESS for integration tests (components integrate correctly)
     - Store test_run in session state
     - Return `{:ok, state_updates, result}` with success status
   - **Tests Failing** (`failures: > 0`):
     - This indicates INTEGRATION PROBLEMS (components don't work together)
     - Store test_run with failure details in session state
     - Return `{:ok, state_updates, result}` - orchestrator will route to fix step
   - **No Tests Found** (`failures: 0, passes: 0`):
     - Integration test file may not exist or has no tests
     - Update result with error status explaining missing tests
     - Return `{:ok, state_updates, result}` with error
6. **Error Handling**: Handle JSON parsing failures and invalid output
   - Update result with error status if JSON malformed
   - Include stdout content in error for debugging
   - Return state updates with error result

## Dependencies

- Sessions
- Tests
- Components
- Utils

## Error Handling

- **Compilation Failures**: Treated as errors, not test failures
  - Update result status to `:error`
  - Include compilation error details in error_message
  - Return error result for orchestrator routing
- **Malformed JSON Output**: Indicates test formatter issues
  - Attempt to extract JSON from stdout using boundary detection
  - If extraction fails, return error with stdout content
  - Log JSON parsing errors for debugging
- **Missing Test File**: Command execution will fail
  - Bash command returns non-zero exit code
  - Result captures exit code and stderr
  - Orchestrator can route to appropriate recovery step
- **Test Schema Validation Failures**: Parsed JSON doesn't match TestRun schema
  - Extract changeset error details
  - Update result with validation error message
  - Return error result with schema validation context

## Integration Test Expectations

Unlike ComponentTestSessions where test failures are expected (TDD), integration tests validate that designed components work together:

- **Expected Outcome**: Tests should PASS after components have been designed and implemented
- **Failure Indicates**: Integration problems, not missing implementation
- **Success Criteria**:
  - All integration tests compile without errors
  - Test runner executes successfully
  - Test results parse correctly from JSON
  - All tests pass (failures = 0, passes > 0)

## JSON Extraction Strategy

Following the pattern from ComponentTestSessions.Steps.RunTests:

1. **Locate JSON Boundaries**:
   - Search for `{"` to find start of JSON object (avoiding Elixir tuples like `{:ok, ...}`)
   - Find all `}` characters and select the last one as JSON end
2. **Extract Substring**: Use binary operations to extract JSON portion from stdout
3. **Handle Edge Cases**:
   - No JSON found (compilation failures, no test output)
   - Multiple JSON objects in output (use boundaries to find complete object)
   - Mixed output with compilation messages and test results
4. **Binary Operations**: Use `:binary.match/2` and `:binary.part/3` for efficient extraction from large stdout strings