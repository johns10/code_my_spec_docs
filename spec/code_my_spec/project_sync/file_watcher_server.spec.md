# CodeMySpec.ProjectSync.FileWatcherServer

Singleton GenServer that manages the FileSystem watcher process and debounces file change events.

This module uses `use GenServer` and integrates with the `FileSystem` library to watch for file changes. There is only ONE instance of this server per application.

## Behaviour

```elixir
use GenServer
```

## State

```elixir
@type state :: %{
  watcher_pid: pid() | nil,
  debounce_timer: reference() | nil,
  pending_changes: MapSet.t(String.t()),
  running: boolean()
}
```

**Fields**:
- `watcher_pid` - PID of the underlying FileSystem watcher process
- `debounce_timer` - Timer reference for debouncing, nil if no timer active
- `pending_changes` - Set of file paths that have changed and are waiting to be processed
- `running` - Boolean indicating whether the file watcher has completed initial sync and is actively monitoring

## Functions

### start_link/1

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

Starts the singleton file watcher server.

**Process**:
1. Starts GenServer with name `__MODULE__` (registered singleton)
2. Accepts empty opts or `[]` for consistency with supervision tree
3. Returns `{:ok, pid}` or `{:error, {:already_started, pid}}`

**Test Assertions**:

- start_link/1 starts the GenServer with registered name __MODULE__
- start_link/1 returns error if already started
- start_link/1 can be called with empty list []

### running?/0

```elixir
@spec running?() :: boolean()
```

Returns whether the file watcher is currently running.

**Process**:
1. Makes synchronous call to the server with `:running?`
2. Returns the `running` boolean from state
3. Returns `false` before initial sync completes, `true` after

**Test Assertions**:

- running?/0 returns false before initial sync completes
- running?/0 returns true after initial sync completes
- running?/0 returns false if file watcher stops

### init/1

```elixir
@spec init(keyword()) :: {:ok, state(), {:continue, :initial_sync}} | {:stop, reason :: term()}
```

Initializes the server and starts the FileSystem watcher.

**Process**:
1. Determines project root directory (CWD via `File.cwd!/0`)
2. Starts FileSystem watcher with paths:
   - `[project_root]/docs/spec`
   - `[project_root]/lib`
3. Subscribes to file system events via `FileSystem.subscribe(watcher_pid)`
4. Initializes state with watcher_pid, nil timer, empty pending_changes, and `running: false`
5. Returns `{:ok, state, {:continue, :initial_sync}}` to trigger initial sync without blocking startup

**Test Assertions**:

- init/1 starts FileSystem watcher with correct paths
- init/1 subscribes to file system events
- init/1 initializes state correctly with running: false
- init/1 stops with error if FileSystem fails to start
- init/1 uses project root from File.cwd!/0
- init/1 returns continue tuple to trigger initial sync

### handle_continue/2 - Initial Sync

```elixir
@spec handle_continue(:initial_sync, state()) :: {:noreply, state()}
```

Performs initial sync_all for all active projects without blocking GenServer startup.

**Process**:
1. Logs that initial sync is starting
2. Gets all active scopes via `get_all_scopes/0`
3. For each scope, calls `Sync.sync_all/1`
4. Logs success or error for each project sync
5. Broadcasts running status change with `broadcast_status_change(true)`
6. Sets `running: true` in state
7. Returns `{:noreply, state}`

**Test Assertions**:

- handle_continue/2 gets all active scopes
- handle_continue/2 calls Sync.sync_all/1 for each scope
- handle_continue/2 logs success for each completed sync
- handle_continue/2 logs errors but continues with other scopes
- handle_continue/2 broadcasts running status change
- handle_continue/2 sets running to true in state

### handle_info/2 - File System Event

```elixir
@spec handle_info({:file_event, pid(), {path :: String.t(), events :: [atom()]}}, state()) ::
  {:noreply, state()}
```

Handles file system change events from FileSystem watcher.

**Process**:
1. Receives file system event with path and events list
2. Adds path to `pending_changes` MapSet (automatically deduplicates)
3. If debounce timer exists, cancels it with `Process.cancel_timer/1`
4. Starts new debounce timer (100ms) with `Process.send_after(self(), :process_changes, 100)`
5. Returns `{:noreply, updated_state}` with new pending_changes and timer ref

**Test Assertions**:

- handle_info/2 adds changed file to pending_changes
- handle_info/2 cancels existing debounce timer if present
- handle_info/2 starts new debounce timer
- handle_info/2 accumulates multiple file changes before timer fires
- handle_info/2 deduplicates duplicate file paths

### handle_info/2 - Debounce Timer

```elixir
@spec handle_info(:process_changes, state()) :: {:noreply, state()}
```

Handles debounce timer expiration and processes accumulated file changes.

**Process**:
1. Gets all paths from `pending_changes` MapSet
2. For each path:
   - Determines which scope(s) own the file using `determine_scope_for_file/1`
   - For each affected scope, calls `ChangeHandler.handle_file_change/3` with scope, path, and `[:modified]` events
3. Logs any errors but continues processing other files
4. Clears `pending_changes` (set to empty MapSet)
5. Sets `debounce_timer` to nil
6. Returns `{:noreply, updated_state}`

**Test Assertions**:

- handle_info/2 processes all pending changes when timer fires
- handle_info/2 determines scope for each changed file
- handle_info/2 calls ChangeHandler.handle_file_change/3 for each scope/file combination
- handle_info/2 continues processing even if one file sync fails
- handle_info/2 clears pending_changes after processing
- handle_info/2 sets debounce_timer to nil after processing
- handle_info/2 logs errors from failed syncs
- handle_info/2 passes [:modified] as events to ChangeHandler

### handle_info/2 - FileSystem Stop Event

```elixir
@spec handle_info({:file_event, pid(), :stop}, state()) :: {:noreply, state()}
```

Handles FileSystem watcher shutdown.

**Process**:
1. Logs warning that watcher has stopped
2. If `running` is true, broadcasts status change with `broadcast_status_change(false)`
3. Sets `watcher_pid` to nil and `running` to false in state
4. Returns `{:noreply, updated_state}`

**Test Assertions**:

- handle_info/2 handles FileSystem stop event
- handle_info/2 broadcasts status change if was running
- handle_info/2 does not broadcast if was not running
- handle_info/2 sets watcher_pid to nil
- handle_info/2 sets running to false
- handle_info/2 logs warning message

### terminate/2

```elixir
@spec terminate(reason :: term(), state()) :: :ok
```

Cleanup when server is stopping.

**Process**:
1. If watcher_pid is not nil, stops the FileSystem watcher with `FileSystem.stop/1`
2. If debounce_timer is not nil, cancels the timer with `Process.cancel_timer/1`
3. Processes any remaining pending_changes before shutdown:
   - Calls `handle_info(:process_changes, state)` to process final batch
4. Returns `:ok`

**Test Assertions**:

- terminate/2 stops FileSystem watcher if running
- terminate/2 cancels debounce timer if active
- terminate/2 processes pending changes before shutdown
- terminate/2 returns :ok

## Private Functions

### broadcast_status_change/1

```elixir
@spec broadcast_status_change(boolean()) :: :ok | {:error, term()}
```

Broadcasts file watcher running status changes to all subscribers.

**Process**:
1. Uses `Phoenix.PubSub.broadcast/3` with topic `"file_watcher:status"`
2. Sends message `{:file_watcher_status_changed, %{running: boolean()}}`
3. Returns `:ok` on success or `{:error, reason}` on failure

**Test Assertions**:

- broadcast_status_change/1 broadcasts to "file_watcher:status" topic
- broadcast_status_change/1 includes running boolean in message
- broadcast_status_change/1 returns :ok on success

### get_all_scopes/0

```elixir
@spec get_all_scopes() :: [Scope.t()]
```

Gets all active user scopes (users with active projects).

**Process**:
1. Queries all users from database
2. Preloads user preferences
3. For each user, tries to get their preferences via `UserPreferences.get_user_preference/1`
4. Filters for users with `active_project_id` set
5. Builds and returns list of `Scope` structs with active account and project preloaded
6. Rejects nil values (users without preferences or active projects)

**Test Assertions**:

- get_all_scopes/0 queries all users from database
- get_all_scopes/0 preloads user preferences
- get_all_scopes/0 filters for users with active projects
- get_all_scopes/0 builds Scope structs with active account and project
- get_all_scopes/0 rejects users without preferences or active projects

### determine_scope_for_file/1

```elixir
@spec determine_scope_for_file(String.t()) :: [Scope.t()]
```

Determines which scope(s) should process a file change based on file path.

**Process**:
1. Gets project root from `File.cwd!/0`
2. Checks if file path starts with project root
3. If yes, returns all active scopes via `get_all_scopes/0`
4. If no, returns empty list (file outside project)

**Test Assertions**:

- determine_scope_for_file/1 returns all scopes for files within project
- determine_scope_for_file/1 returns empty list for files outside project
- determine_scope_for_file/1 uses File.cwd!/0 for project root
