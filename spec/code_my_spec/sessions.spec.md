# CodeMySpec.Sessions

**Type**: context

Phoenix context for managing sessions. Provides the public API for session lifecycle, execution, and result handling. Delegates execution flow to SessionServer for concurrency control.

## Functions

### subscribe_sessions/1

Subscribe to scoped notifications about session changes for an account.

```elixir
@spec subscribe_sessions(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract account_id from scope
2. Subscribe to PubSub topic "account:{account_id}:sessions"

**Test Assertions**:
- subscribes to account-scoped session events
- receives {:created, session}, {:updated, session}, {:deleted, session} messages

### subscribe_user_sessions/1

Subscribe to user-level notifications about session changes.

```elixir
@spec subscribe_user_sessions(Scope.t() | integer()) :: :ok | {:error, term()}
```

**Process**:
1. Extract user_id from scope or use provided integer
2. Subscribe to PubSub topic "user:{user_id}:sessions"

**Test Assertions**:
- subscribes to user-scoped session events
- accepts Scope struct or user_id integer
- receives session change notifications

### list_sessions/2

List sessions filtered by scope and options.

```elixir
@spec list_sessions(Scope.t(), keyword()) :: [Session.t()]
```

**Process**:
1. Extract status filter from opts (default: [:active])
2. Query sessions by project_id, user_id, and status
3. Preload associations (project, component, interactions)
4. Populate display names via SessionsRepository
5. Return list of sessions

**Test Assertions**:
- returns sessions for active project and user
- filters by status (default :active)
- accepts multiple statuses
- preloads associations
- populates display names

### get_session/2

Get a session by id within scope.

```elixir
@spec get_session(Scope.t(), integer()) :: Session.t() | nil
```

Delegates to SessionsRepository.get_session/2

### get_session!/2

Get a session by id within scope, raises if not found.

```elixir
@spec get_session!(Scope.t(), integer()) :: Session.t()
```

Delegates to SessionsRepository.get_session!/2

### create_session/2

Create a new session.

```elixir
@spec create_session(Scope.t(), map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build changeset with attrs and scope
2. Insert into database
3. Broadcast :created event
4. Return session

**Test Assertions**:
- creates session with valid attrs
- validates required fields
- sets account_id, project_id, user_id from scope
- broadcasts created event
- returns changeset error for invalid attrs

### update_session/3

Update an existing session.

```elixir
@spec update_session(Scope.t(), Session.t(), map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify session belongs to scope (account_id, user_id)
2. Build changeset with attrs
3. Update in database
4. Broadcast :updated event
5. Return updated session

**Test Assertions**:
- updates session with valid attrs
- verifies ownership
- broadcasts updated event
- returns changeset error for invalid attrs

### delete_session/2

Delete a session.

```elixir
@spec delete_session(Scope.t(), Session.t()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify session belongs to scope
2. Delete from database
3. Broadcast :deleted event
4. Return deleted session

**Test Assertions**:
- deletes session
- verifies ownership
- broadcasts deleted event

### run/3

Execute a session according to its execution_mode.

```elixir
@spec run(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | :ok | {:error, term()}
```

**Process**:
1. Delegate to SessionServer.run/2
2. Manual mode: blocks and returns result
3. Auto mode: returns immediately, executes in background

**Test Assertions**:
- manual mode executes one step synchronously
- auto mode starts background execution
- starts SessionServer if not running
- returns error for invalid session

### continue/5

Process interaction result and continue execution if auto mode.

```elixir
@spec continue(Scope.t(), integer(), integer(), map(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Delegate to SessionServer.continue/4
2. Process result via ResultHandler
3. Auto mode: continues execution automatically
4. Manual mode: returns without continuing

**Test Assertions**:
- processes result successfully
- auto mode continues execution
- manual mode stops after processing result
- broadcasts updated event

### handle_result/5

Handle interaction result (legacy - prefer continue/5).

```elixir
@spec handle_result(Scope.t(), integer(), integer(), map(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Call ResultHandler.handle_result
2. Broadcast updated event
3. Return updated session

**Test Assertions**:
- processes result via ResultHandler
- broadcasts updated event
- returns updated session

### next_command/3

Get next command for a session.

```elixir
@spec next_command(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Delegate to CommandResolver.next_command
2. Broadcast updated event
3. Return session with new interaction

**Test Assertions**:
- creates next interaction
- broadcasts updated event
- returns error if session complete

### execute/3

Execute next step in a session (legacy - prefer run/3).

```elixir
@spec execute(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Delegate to Executor.execute
2. Broadcast updated event
3. Return result

**Test Assertions**:
- executes next step
- broadcasts updated event

### update_execution_mode/3

Update session execution mode and regenerate pending command.

```elixir
@spec update_execution_mode(Scope.t(), integer(), String.t()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Load session
2. Update execution_mode field
3. If pending interaction exists: regenerate command with new mode
4. Broadcast updated event and mode change event
5. Return updated session

**Test Assertions**:
- updates execution mode
- regenerates pending command with new mode settings
- broadcasts updated and mode_change events
- handles sessions without pending interactions

### create_result/2

Create a Result struct from attributes (virtual).

```elixir
@spec create_result(Scope.t(), map()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:
- creates result struct with valid attrs
- validates result structure

### update_result/3

Update a Result struct with new attributes (virtual).

```elixir
@spec update_result(Scope.t(), Result.t(), map()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:
- updates result struct with valid attrs
- validates result structure

## Delegates

- get_session/2: SessionsRepository.get_session/2
- get_session!/2: SessionsRepository.get_session!/2
- update_external_conversation_id/3: SessionsRepository.update_external_conversation_id/3

## Dependencies

- session.spec.md
- sessions_repository.spec.md
- sessions_broadcaster.spec.md
- session_server.spec.md
- executor.spec.md
- result_handler.spec.md
- command_resolver.spec.md
