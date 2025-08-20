# ProcessExecutor

## Purpose
Executes external system commands with timeout handling and comprehensive result capture, designed as a functional core with explicit side effect boundaries.

## Responsibilities
- Execute shell commands in specified working directories
- Handle process timeouts with graceful termination
- Capture complete output (stdout/stderr combined)
- Return structured execution results with clear status classification

## Public API

```elixir
@type execution_result :: %{
  output: String.t(),
  exit_code: non_neg_integer() | nil,
  execution_status: :success | :failure | :timeout,
  executed_at: NaiveDateTime.t()
}

@type execute_opts :: [
  timeout: pos_integer(),
  env: %{String.t() => String.t()},
  stderr_to_stdout: boolean()
]

@spec execute(String.t(), String.t(), execute_opts()) :: {:ok, execution_result()} | {:error, execution_result()}
@spec execute_async(String.t(), String.t(), execute_opts()) :: Task.t()
```

## Design Philosophy

### Functional Core with Imperative Shell
Following the functional core/imperative shell pattern:
- **Functional Core**: Pure functions for result processing and status determination
- **Imperative Shell**: System.cmd interface handles actual process execution side effects
- Clear boundary between pure logic and system interactions

### Fail Fast with Structured Recovery
- Let processes fail predictably with timeout exceptions
- Capture all failure modes as structured data rather than crashing
- Return comprehensive error information for external recovery strategies

### Single Responsibility
- Only handles command execution - no command construction or result parsing
- Clear separation from CommandBuilder and JsonParser components
- Focused on process lifecycle management and result capture

## Implementation Strategy

### Process Execution Flow
```elixir
defp execute_system_command(command, working_dir, opts) do
  executed_at = NaiveDateTime.utc_now()
  timeout = Keyword.get(opts, :timeout, 30_000)
  env = Keyword.get(opts, :env, %{})
  stderr_to_stdout = Keyword.get(opts, :stderr_to_stdout, true)

  try do
    System.cmd("sh", ["-c", command], [
      cd: working_dir,
      env: env,
      stderr_to_stdout: stderr_to_stdout,
      timeout: timeout
    ])
    |> build_success_result(executed_at)
  catch
    :exit, {:timeout, _} ->
      build_timeout_result(executed_at)
  rescue
    error ->
      build_error_result(error, executed_at)
  end
end
```

### Result Processing
```elixir
defp build_success_result({output, 0}, executed_at) do
  {:ok, %{
    output: output,
    exit_code: 0,
    execution_status: :success,
    executed_at: executed_at
  }}
end

defp build_success_result({output, exit_code}, executed_at) do
  {:ok, %{
    output: output,
    exit_code: exit_code,
    execution_status: :failure,
    executed_at: executed_at
  }}
end
```

### Timeout Handling
- Uses System.cmd timeout parameter for automatic process termination
- Catches timeout exits and converts to structured error responses
- Preserves execution timestamp for debugging and analysis

### Environment Management
- Accepts optional environment variables for command execution
- Inherits parent process environment by default
- Supports environment isolation for testing scenarios

## Error Classification

### Success (exit_code: 0)
- Command executed and completed normally
- Standard output captured completely
- Process terminated cleanly

### Failure (exit_code: > 0)  
- Command executed but returned non-zero exit code
- Both stdout/stderr captured for analysis
- Process completed but indicates error condition

### Timeout
- Command execution exceeded specified timeout
- Process forcibly terminated by system
- Partial output may be available depending on timing

### System Error
- Unable to spawn process or execute command
- File system permission issues
- Invalid working directory or command path

## Async Execution Support

### Task-Based Concurrency
```elixir
def execute_async(command, working_dir, opts \\ []) do
  Task.async(fn ->
    execute(command, working_dir, opts)
  end)
end

def await_execution(task, timeout \\ 60_000) do
  Task.await(task, timeout)
end
```

### Process Isolation
- Each async execution runs in isolated Task process
- Failures don't cascade to calling process
- Allows multiple concurrent command executions

## Usage Patterns

### Synchronous Execution
```elixir
{:ok, result} = ProcessExecutor.execute(
  "mix test --formatter ExUnitJsonFormatter",
  "/path/to/project",
  timeout: 30_000
)

case result.execution_status do
  :success -> handle_success(result)
  :failure -> handle_command_failure(result) 
  :timeout -> handle_timeout(result)
end
```

### Concurrent Execution
```elixir
tasks = [
  ProcessExecutor.execute_async("mix test", project_path),
  ProcessExecutor.execute_async("mix format --check-formatted", project_path)
]

results = Task.await_many(tasks, 60_000)
```

### Environment Configuration
```elixir
ProcessExecutor.execute(
  "mix test",
  project_path,
  env: %{"MIX_ENV" => "test", "SEED" => "12345"},
  timeout: 45_000
)
```

This design maintains clear separation of concerns while providing robust process execution with comprehensive error handling and result capture.