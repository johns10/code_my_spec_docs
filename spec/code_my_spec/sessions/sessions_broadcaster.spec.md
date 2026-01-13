# SessionsBroadcaster

Centralized broadcasting module for session-related events. Handles PubSub broadcasting for session lifecycle events, updates, and notifications to both account-level and user-level channels.

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Functions

### broadcast_created/2

Broadcasts a session creation event to both account and user channels.

```elixir
@spec broadcast_created(Scope.t(), Session.t()) :: :ok
```

**Process**:
1. Populate the session's display name using SessionsRepository.populate_display_name/1
2. Broadcast `{:created, session}` message to both account and user channels

**Test Assertions**:
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- includes populated display_name in the broadcasted session
- returns :ok on successful broadcast

### broadcast_updated/2

Broadcasts a session update event with fully preloaded associations.

```elixir
@spec broadcast_updated(Scope.t(), Session.t()) :: :ok
```

**Process**:
1. Preload session associations using SessionsRepository.preload_session/2
2. Populate the session's display name using SessionsRepository.populate_display_name/1
3. Broadcast `{:updated, session}` message to both account and user channels

**Test Assertions**:
- preloads session associations before broadcasting
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- includes populated display_name in the broadcasted session
- returns :ok on successful broadcast

### broadcast_deleted/2

Broadcasts a session deletion event.

```elixir
@spec broadcast_deleted(Scope.t(), Session.t()) :: :ok
```

**Process**:
1. Broadcast `{:deleted, session}` message to both account and user channels

**Test Assertions**:
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- includes the session struct in the message payload
- returns :ok on successful broadcast

### broadcast_activity/2

Broadcasts session activity for event-based updates.

```elixir
@spec broadcast_activity(Scope.t(), integer()) :: :ok
```

**Process**:
1. Construct message as `{:session_activity, %{session_id: session_id}}`
2. Broadcast to both account and user channels

**Test Assertions**:
- broadcasts {:session_activity, %{session_id: id}} message format
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- returns :ok on successful broadcast

### broadcast_mode_change/3

Broadcasts execution mode change notification.

```elixir
@spec broadcast_mode_change(Scope.t(), integer(), :manual | :auto | :agentic) :: :ok
```

**Process**:
1. Construct message as `{:session_mode_updated, %{session_id: session_id, execution_mode: execution_mode}}`
2. Broadcast to both account and user channels

**Test Assertions**:
- broadcasts {:session_mode_updated, %{session_id: id, execution_mode: mode}} message format
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- accepts :manual, :auto, and :agentic execution modes
- returns :ok on successful broadcast

### broadcast_step_started/3

Broadcasts when a new interaction/step is started.

```elixir
@spec broadcast_step_started(Scope.t(), Session.t(), integer()) :: :ok
```

**Process**:
1. Find the interaction in session.interactions by matching interaction_id
2. Extract the command_module from the interaction if found, otherwise nil
3. Construct message as `{:step_started, %{session: session, interaction_id: interaction_id, command_module: command_module}}`
4. Broadcast to both account and user channels

**Test Assertions**:
- includes session, interaction_id, and command_module in the message payload
- extracts command_module from the matching interaction
- sets command_module to nil when interaction is not found
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- returns :ok on successful broadcast

### broadcast_step_completed/3

Broadcasts when an interaction/step completes (success or error).

```elixir
@spec broadcast_step_completed(Scope.t(), Session.t(), integer()) :: :ok
```

**Process**:
1. Construct message as `{:step_completed, %{session: session, interaction_id: interaction_id}}`
2. Broadcast to both account and user channels

**Test Assertions**:
- broadcasts {:step_completed, %{session: session, interaction_id: id}} message format
- broadcasts to account channel with topic "account:{account_id}:sessions"
- broadcasts to user channel with topic "user:{user_id}:sessions"
- returns :ok on successful broadcast
