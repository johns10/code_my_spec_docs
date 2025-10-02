# RunTests Step

## Purpose
Executes the project's ExUnit test suite for the implemented component. Captures test failures, errors, and stack traces. Stores on state with status

## Public API

```elixir
# Step behavior implementation
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, term()}
@spec handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()}
```

### get_command/2
- **Parameters**: `scope` (user scope), `session` (current session with component and project)
- **Returns**: `{:ok, %Command{}}` with test execution command targeting component test file
- **Purpose**: Constructs a command to instruct the client to run ExUnit tests for the specific component

### handle_result/3
- **Parameters**: `scope`, `session`, `result` (containing TestRun data from client)
- **Returns**:
  - `{:ok, %{state: updated_state}, %Result{status: :ok}}` if all tests pass
  - `{:ok, %{state: updated_state}, %Result{status: :error, data: test_failures}}` if component tests fail
- **Purpose**: Receives TestRun data from client, and determines next workflow step
- **Side Effects**: Updates session state with test results

## Execution Flow

### 1. Command Generation (get_command/2)
1. Extract component and project from session state
2. Use `CodeMySpec.Utils.component_files/2` to determine test file path
3. Create Command that instructs client to run tests for the specific test file
4. Return command with module reference for orchestrator tracking

### 2. Result Processing (handle_result/3)
1. **Extract TestRun Data**: Parse incoming result containing TestRun JSON from client
2. **Validate TestRun**: Use `CodeMySpec.Tests.TestRun.changeset/2` to validate and structure test data
3. **Analyze Test Results**:
   - Check `execution_status` field (`:success`, `:failure`, `:timeout`, `:error`)
   - If `:success` → all tests passed, return success result
   - If `:failure` or `:error` → store details on state
5. **Store Results and Return**:
   - Store TestRun in session state for FixTestFailures step reference
   - Return appropriate Result status (`:ok`, `:error`, or `:warning`)

## Test Execution Details

### Command Format
The command instructs the client to:
- Run ExUnit with `--formatter` set to JSON formatter
- Target specific test file: `test/path/to/component_test.exs`
- Capture execution status, failures, and full output
- Return structured TestRun JSON to server

### TestRun Data Structure
See:
lib/code_my_spec/tests/test_result.ex
lib/code_my_spec/tests/test_run.ex

## State Management

### Session State Updates
The step stores in session state:
```elixir
%{
  "test_run" => %TestRun{}
}
```

## Error Handling
- **Invalid TestRun Data**: Return error result with validation changeset errors
- **Missing Component/Project**: Return error result indicating session state corruption
- **Test Execution Timeout**: Captured in TestRun `execution_status: :timeout`, treated as error
- **Test Process Error**: Captured in TestRun `execution_status: :error`, analyzed like failures