# CodeMySpec.Sessions.Orchestrator

**Type**: logic

Orchestrates session execution, always completing full cycle (next_command → execute → handle_result). Appears synchronous but handles long-running external commands via messaging pattern.

## Functions

### execute_step/3

Execute one complete step of a session (next command + execution + result handling).

```elixir
@spec execute_step(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Call CommandResolver.next_command to get next interaction
2. Call Executor.execute to run the command
3. Pattern match on execution result and handle accordingly:
   - `{:ok, result}` (sync like read_file):
     - Call ResultHandler.handle_result immediately
     - Return updated session
   - `{:ok, pid}` (task like run_checks):
     - Block and await Task completion via Task.await
     - Call ResultHandler.handle_result with task result
     - Return updated session
   - `:ok` (external/async like claude):
     - Use `receive` to wait for `{:interaction_result, interaction_id, result}` message
     - Message delivered via SessionServer when hook callback received
     - Call ResultHandler.handle_result with received result
     - Return updated session
4. Always returns `{:ok, session}` after completing full cycle

**Test Assertions**:
- executes full cycle for all execution strategies
- sync commands complete immediately
- task commands block until task completes
- external commands block until message received
- always calls ResultHandler before returning
- returns updated session after result processing

### handle_result/5

Process an interaction result (used for manual result delivery).

```elixir
@spec handle_result(Scope.t(), integer(), integer(), map(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Call ResultHandler.handle_result to process result
2. Return updated session

**Test Assertions**:
- processes result via ResultHandler
- returns updated session

## Dependencies

- CodeMySpec.Sessions.Executor
- CodeMySpec.Sessions.CommandResolver
- CodeMySpec.Sessions.ResultHandler
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.SessionsRepository
