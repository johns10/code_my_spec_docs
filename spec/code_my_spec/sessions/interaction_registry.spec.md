# CodeMySpec.Sessions.InteractionRegistry

**Type**: genserver

Maintains ephemeral runtime state for interactions executing asynchronously. Provides real-time visibility into interaction status through non-durable status updates from agent hook callbacks. Status is cleared when users interact with it in the TUI.

## Functions

### start_link/1

Start the InteractionRegistry GenServer.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Call GenServer.start_link with init callback
2. Register process under __MODULE__ name for global access
3. Return {:ok, pid} on success

**Test Assertions**:
- starts the GenServer process
- registers under module name

### register_status/1

Store or update ephemeral runtime status for an interaction.

```elixir
@spec register_status(RuntimeInteraction.t()) :: :ok
```

**Process**:
1. Send synchronous call to GenServer with {:register, runtime} message
2. Server stores runtime in state map keyed by interaction_id
3. Log debug message with interaction_id and agent_state
4. Return :ok

**Test Assertions**:
- stores new status for interaction
- updates agent_state for existing interaction
- handles notification events
- handles agent_done events

### update_status/2

Update runtime status for an interaction with new attributes. Fetches existing runtime, merges attrs, and registers the update. Creates new runtime if none exists.

```elixir
@spec update_status(binary(), map()) :: :ok
```

**Process**:
1. Send synchronous call to GenServer with {:update, interaction_id, attrs} message
2. Server fetches existing runtime from state map
3. If no existing runtime, create new RuntimeInteraction with attrs
4. If existing, update via RuntimeInteraction.update/2 (changeset handles partial updates)
5. Store updated runtime in state map
6. Log debug message with interaction_id and agent_state
7. Return :ok

**Test Assertions**:
- merges status updates, preserving unmodified fields
- explicitly clears fields with nil values
- creates new runtime if none exists

### get_status/1

Retrieve current ephemeral status for an interaction.

```elixir
@spec get_status(binary()) :: {:ok, RuntimeInteraction.t()} | {:error, :not_found}
```

**Process**:
1. Send synchronous call to GenServer with {:get, interaction_id} message
2. Server fetches runtime from state map using Map.fetch
3. Return {:ok, runtime} if found
4. Return {:error, :not_found} if not present

**Test Assertions**:
- returns status for registered interaction
- returns error for unknown interaction
- returns most recent status after multiple updates

### clear_status/1

Remove ephemeral status for an interaction. Called when user interacts with the notification in the TUI.

```elixir
@spec clear_status(binary()) :: :ok
```

**Process**:
1. Send synchronous call to GenServer with {:clear, interaction_id} message
2. Server removes interaction_id entry from state map via Map.delete
3. Log debug message with interaction_id
4. Return :ok

**Test Assertions**:
- removes status from registry
- succeeds for non-existent interaction
- allows status to be re-registered after clearing

### clear_all/0

Remove all ephemeral status entries from registry.

```elixir
@spec clear_all() :: :ok
```

**Process**:
1. Send synchronous call to GenServer with :clear_all message
2. Server replaces state with empty map
3. Log debug message
4. Return :ok

**Test Assertions**:
- removes all registered statuses
- works when registry is empty

### list_active/0

List all interaction IDs with active runtime status.

```elixir
@spec list_active() :: [binary()]
```

**Process**:
1. Send synchronous call to GenServer with :list_active message
2. Server extracts keys from state map via Map.keys
3. Return list of interaction_id strings

**Test Assertions**:
- returns empty list when no statuses registered
- returns all registered interaction_ids
- excludes cleared interactions

## Dependencies

- CodeMySpec.Sessions.RuntimeInteraction
