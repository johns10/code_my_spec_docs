# CodeMySpec.Sessions.SessionServer

**Type**: genserver

Manages orchestrator task lifecycle and message delivery. One server process per active session, registered by session_id. Uses `{:noreply, state}` + `GenServer.reply/2` pattern for long-running operations.

## Functions

### init/1

Initialize server state for a session.

```elixir
@spec init(integer()) :: {:ok, map()}
```

**Process**:
1. Initialize state map with session_id, task: nil, from: nil, scope: nil
2. Return {:ok, state}

**Test Assertions**:
- initializes minimal state with session_id
- no task running initially

### handle_call({:execute_step, scope, opts}, from, state)

Execute step via Orchestrator in Task (blocking to caller).

```elixir
{:execute_step, Scope.t(), keyword()}
```

**Process**:
1. Check if task already running, return error if so
2. Spawn Task.async running Orchestrator.execute_step(scope, session_id, opts)
3. Monitor the task process
4. Store task info, from, and scope in state
5. Return `{:noreply, new_state}` (don't reply immediately)
6. When task completes, handle_info will broadcast and reply

**Test Assertions**:
- spawns orchestrator in Task
- returns {:noreply, state} without replying
- stores task and from in state
- prevents concurrent execution

### handle_cast({:deliver_result, interaction_id, result}, _from, state)

Deliver external command result to waiting orchestrator task.

```elixir
{:deliver_result, integer(), map()}
```

**Process**:
1. Check if task is running
2. Extract task pid from state
3. Send `{:interaction_result, interaction_id, result}` message to task pid
4. Reply :ok immediately

**Test Assertions**:
- forwards message to waiting task
- returns error if no task running
- allows orchestrator to unblock and continue

### handle_cast({:run, scope, opts}, state)

Trigger auto-execution loop (non-blocking).

```elixir
{:run, Scope.t(), keyword()}
```

**Process**:
1. Check if task already running, defer if so (send self same message after delay)
2. Spawn Task running Orchestrator.execute_step(scope, session_id, opts)
3. Monitor the task process
4. Store task info and scope in state (no from needed, cast doesn't reply)
5. Return `{:noreply, new_state}`
6. When task completes, handle_info will broadcast and check auto-continuation

**Test Assertions**:
- spawns orchestrator in Task
- returns immediately without blocking
- defers if execution in progress

### handle_info({ref, result}, state)

Handle successful task completion.

```elixir
{reference(), term()}
```

**Process**:
1. Verify ref matches our monitored task's ref
2. Demonitor the task process with [:flush] to remove pending DOWN message
3. Extract result (already provided in message)
4. If result is {:ok, session}:
   - Fetch session with interactions from DB using SessionsRepository
   - Get latest interaction from session.interactions
   - Broadcast step_completed via SessionsBroadcaster with session and interaction_id
5. If state.from exists (synchronous call):
   - Reply to caller with GenServer.reply(state.from, result)
6. If no from (async cast):
   - Check if should auto-continue based on result
   - If auto mode + active + no pending: send self :auto_continue message
7. Clear task, from, and scope from state
8. Return `{:noreply, new_state}`

**Test Assertions**:
- replies to synchronous callers via GenServer.reply
- checks auto-continuation for async execution
- cleans up task state

### handle_info({:DOWN, ref, :process, pid, reason}, state)

Handle task failure.

```elixir
{:DOWN, reference(), :process, pid(), term()}
```

**Process**:
1. Verify ref matches our monitored task's ref
2. Build error result: {:error, {:task_failed, reason}}
3. If state.from exists (synchronous call):
   - Reply to caller with GenServer.reply(state.from, error_result)
4. Clear task and from from state
5. Return `{:noreply, new_state}`

**Test Assertions**:
- replies with error to synchronous callers
- cleans up task state
- handles task errors gracefully

## Dependencies

- orchestrator.spec.md
- session.spec.md
