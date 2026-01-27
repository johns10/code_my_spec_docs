# CodeMySpec.Sessions.InteractionsRegistry

**Type**: GenServer

Maintains ephemeral runtime state for interactions executing asynchronously. Provides real-time visibility into interaction status through non-durable status updates from agent hook callbacks.

## Functions

### start_link/1

Start the InteractionRegistry GenServer.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Initialize GenServer with empty ETS table or map
2. Register process name

**Test Assertions**:
- start_link/1 starts the registry process
- start_link/1 allows process to be found by name

### register_status/2

Store or update ephemeral runtime status for an interaction.

```elixir
@spec register_status(binary(), map()) :: :ok
```

**Process**:
1. Validate interaction_id is a binary
2. Store status map in registry keyed by interaction_id
3. Return :ok

**Test Assertions**:
- register_status/2 stores new status for interaction
- register_status/2 overwrites existing status for interaction
- register_status/2 handles notification events
- register_status/2 handles agent_done events

### get_status/1

Retrieve current ephemeral status for an interaction.

```elixir
@spec get_status(binary()) :: {:ok, map()} | {:error, :not_found}
```

**Process**:
1. Lookup interaction_id in registry
2. Return {:ok, status_map} if found
3. Return {:error, :not_found} if not found

**Test Assertions**:
- get_status/1 returns status for registered interaction
- get_status/1 returns error for unknown interaction
- get_status/1 returns most recent status after multiple updates

### clear_status/1

Remove ephemeral status for an interaction (called when user interacts in TUI).

```elixir
@spec clear_status(binary()) :: :ok
```

**Process**:
1. Delete interaction_id entry from registry
2. Return :ok regardless of whether entry existed

**Test Assertions**:
- clear_status/1 removes status from registry
- clear_status/1 succeeds for non-existent interaction
- clear_status/1 allows status to be re-registered after clearing

### clear_all/0

Remove all ephemeral status entries from registry.

```elixir
@spec clear_all() :: :ok
```

**Process**:
1. Clear all entries from registry storage
2. Return :ok

**Test Assertions**:
- clear_all/0 removes all registered statuses
- clear_all/0 works when registry is empty

### list_active/0

List all interaction IDs with active runtime status.

```elixir
@spec list_active() :: [binary()]
```

**Process**:
1. Retrieve all keys from registry storage
2. Return list of interaction_ids

**Test Assertions**:
- list_active/0 returns empty list when no statuses registered
- list_active/0 returns all registered interaction_ids
- list_active/0 excludes cleared interactions

## Dependencies

- interaction.spec.md
- event_handler.spec.md
