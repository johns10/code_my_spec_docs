# CodeMySpec.Tests.TestServer

**Type**: genserver

Manages asynchronous test execution with request batching. Only one test run per project at a time - if tests are already running and new requests arrive, the requested files are queued and merged into the next run. Executes tests via the Tests context, converts failures to Problems for persistence, and delivers results via callbacks. One server process per application, registered by module name.

## State Structure

Per-project state tracked by project_id:
- `task` - Task.t() | nil, the currently running test task
- `task_ref` - reference() | nil, monitor reference for the task
- `interaction_id` - String.t(), interaction ID for the current run
- `callback` - function, callback to invoke when current run completes
- `queued_files` - [String.t()], files accumulated for the next run
- `queued_callback` - function | nil, callback to invoke after queued run

## Functions

### start_link/1

Start the TestServer GenServer.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Initialize GenServer with empty state map for tracking per-project state
2. Register process with module name

**Test Assertions**:
- starts the server process successfully
- registers process with module name
- initializes with empty project state

### run_tests/4

Execute tests asynchronously for a project, queuing if already running.

```elixir
@spec run_tests(Scope.t(), [String.t()], String.t(), (map() -> any())) :: :ok | :queued
```

**Process**:
1. Check if project has a running test task
2. If not running:
   - Store scope, interaction_id, and callback in project state
   - Spawn Task.async calling Tests.execute with args and interaction_id
   - Monitor the task
   - Return :ok
3. If already running:
   - Merge requested files into queued_files (deduplicated)
   - Store/replace queued_callback
   - Return :queued

**Test Assertions**:
- returns :ok and spawns test execution task when not running
- returns :queued when tests already running for project
- merges files into queue without duplicates
- replaces queued callback with latest
- allows concurrent runs for different projects

### get_status/1

Get current test execution status for a project.

```elixir
@spec get_status(Scope.t()) :: :idle | :running | {:running, queued_count :: non_neg_integer()}
```

**Process**:
1. Look up project state by project_id
2. If no state or no task, return :idle
3. If task running with empty queue, return :running
4. If task running with queued files, return {:running, length(queued_files)}

**Test Assertions**:
- returns :idle for unknown project
- returns :idle after run completes
- returns :running during test execution
- returns {:running, count} when files are queued

### clear_queue/1

Clear queued files for a project without cancelling the current run.

```elixir
@spec clear_queue(Scope.t()) :: :ok
```

**Process**:
1. Look up project state by project_id
2. Clear queued_files and queued_callback
3. Return :ok

**Test Assertions**:
- clears queued files
- does not affect running task
- returns :ok for unknown project

### handle_info({ref, result}, state)

Handle successful task completion.

```elixir
{reference(), map()}
```

**Process**:
1. Match ref to find project_id from state
2. Demonitor the task with [:flush]
3. Parse test results JSON into TestRun struct
4. Convert test failures to Problems via Problems.from_test_failure
5. Persist problems via Problems.replace_project_problems
6. Invoke the stored callback with result map
7. Check if queued_files exist for this project:
   - If queued: start new run with queued files and queued_callback, clear queue
   - If not queued: clear project state
8. Return {:noreply, updated_state}

**Test Assertions**:
- parses test results and converts failures to problems
- persists problems to database via Problems context
- invokes callback with result
- automatically starts queued run after completion
- clears project state when no queue
- handles empty test results gracefully

### handle_info({:DOWN, ref, :process, pid, reason}, state)

Handle task failure.

```elixir
{:DOWN, reference(), :process, pid(), term()}
```

**Process**:
1. Match ref to find project_id from state
2. Build error result: %{status: :error, reason: reason}
3. Invoke stored callback with error result
4. Check if queued_files exist:
   - If queued: start new run with queued files
   - If not queued: clear project state
5. Return {:noreply, updated_state}

**Test Assertions**:
- invokes callback with error result
- still processes queued run after failure
- clears project state when no queue
- handles task crashes gracefully

## Dependencies

- CodeMySpec.Tests
- CodeMySpec.Tests.TestRun
- CodeMySpec.Problems
- CodeMySpec.Scope
- Logger
- Task
