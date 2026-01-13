# CodeMySpecCli.Components.JobStatus

A status indicator component that displays running background jobs. Subscribes to PubSub events and only shows when jobs are active.

This module uses `use GenServer` and acts as a stateful component that tracks background job statuses.

## Behaviour

```elixir
use GenServer
```

## State

```elixir
@type state :: %{
  file_watcher_running: boolean(),
  subscribers: [pid()]
}
```

**Fields**:
- `file_watcher_running` - Boolean indicating if the file watcher is currently running
- `subscribers` - List of PIDs that are subscribed to status changes

## Functions

### start_link/1

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

Starts the JobStatus component server.

**Process**:
1. Starts GenServer with name `__MODULE__` (registered singleton)
2. Accepts empty opts or `[]` for consistency with supervision tree
3. Returns `{:ok, pid}` or `{:error, {:already_started, pid}}`

**Test Assertions**:

- start_link/1 starts the GenServer with registered name __MODULE__
- start_link/1 returns error if already started
- start_link/1 can be called with empty list []

### subscribe/0

```elixir
@spec subscribe() :: :ok
```

Subscribes the calling process to job status updates.

**Process**:
1. Makes synchronous call to server with `:subscribe`
2. Server monitors the subscriber process
3. Subscriber will receive `{:job_status_changed, %{file_watcher_running: boolean()}}` when status changes
4. Returns `:ok`

**Test Assertions**:

- subscribe/0 adds calling process to subscribers list
- subscribe/0 monitors the subscriber process
- subscribe/0 returns :ok
- subscribe/0 deduplicates if same process subscribes multiple times

### get_status/0

```elixir
@spec get_status() :: %{file_watcher_running: boolean()}
```

Gets the current job status.

**Process**:
1. Makes synchronous call to server with `:get_status`
2. Server returns current status map
3. Map contains `file_watcher_running` boolean

**Test Assertions**:

- get_status/0 returns map with file_watcher_running key
- get_status/0 reflects current state

### render/0

```elixir
@spec render() :: iodata()
```

Renders the job status indicator.

**Process**:
1. Gets current status via `get_status/0`
2. If `file_watcher_running` is true:
   - Returns iodata list with green indicator (`[*]`) and text " Files syncing..."
   - Uses `Owl.Data.tag/2` for colored output
3. If nothing is running, returns empty string ""

**Test Assertions**:

- render/0 returns empty string when nothing is running
- render/0 returns status line when file watcher is running
- render/0 includes green indicator and descriptive text
- render/0 uses Owl.Data.tag for styling

### init/1

```elixir
@spec init(keyword()) :: {:ok, state()}
```

Initializes the component and subscribes to status events.

**Process**:
1. Subscribes to PubSub topic `"file_watcher:status"` via `Phoenix.PubSub.subscribe/2`
2. Gets initial file watcher status by calling `CodeMySpec.ProjectSync.FileWatcherServer.running?/0`
3. Handles error if FileWatcherServer is not available (defaults to `false`)
4. Logs initialization with current status
5. Initializes state with `file_watcher_running` and empty `subscribers` list
6. Returns `{:ok, state}`

**Test Assertions**:

- init/1 subscribes to "file_watcher:status" PubSub topic
- init/1 gets initial status from FileWatcherServer
- init/1 handles error if FileWatcherServer not available
- init/1 initializes state correctly
- init/1 logs initialization message

### handle_call/3 - Subscribe

```elixir
@spec handle_call(:subscribe, {pid(), term()}, state()) :: {:reply, :ok, state()}
```

Handles subscription requests from processes.

**Process**:
1. Extracts subscriber PID from call
2. Monitors the subscriber process with `Process.monitor/1`
3. Adds PID to subscribers list (deduplicates with `Enum.uniq/1`)
4. Returns `{:reply, :ok, updated_state}`

**Test Assertions**:

- handle_call/3 extracts PID from caller
- handle_call/3 monitors subscriber process
- handle_call/3 adds subscriber to list
- handle_call/3 deduplicates existing subscribers
- handle_call/3 returns :ok

### handle_call/3 - Get Status

```elixir
@spec handle_call(:get_status, term(), state()) :: {:reply, map(), state()}
```

Handles status query requests.

**Process**:
1. Constructs status map from current state
2. Returns `{:reply, %{file_watcher_running: boolean()}, state}`

**Test Assertions**:

- handle_call/3 returns map with file_watcher_running
- handle_call/3 reflects current state
- handle_call/3 does not modify state

### handle_info/2 - File Watcher Status Changed

```elixir
@spec handle_info({:file_watcher_status_changed, %{running: boolean()}}, state()) ::
  {:noreply, state()}
```

Handles file watcher status change events from PubSub.

**Process**:
1. Receives `{:file_watcher_status_changed, %{running: boolean()}}` message
2. Logs debug message with new status
3. Notifies all subscribers by sending `{:job_status_changed, %{file_watcher_running: boolean()}}`
4. Updates state with new `file_watcher_running` value
5. Returns `{:noreply, updated_state}`

**Test Assertions**:

- handle_info/2 processes file_watcher_status_changed messages
- handle_info/2 logs debug message
- handle_info/2 notifies all subscribers
- handle_info/2 updates state with new status
- handle_info/2 sends correct message format to subscribers

### handle_info/2 - Process Down

```elixir
@spec handle_info({:DOWN, reference(), :process, pid(), term()}, state()) :: {:noreply, state()}
```

Handles subscriber process termination.

**Process**:
1. Receives `:DOWN` message when a monitored subscriber process dies
2. Removes dead subscriber PID from subscribers list
3. Returns `{:noreply, updated_state}`

**Test Assertions**:

- handle_info/2 processes :DOWN messages
- handle_info/2 removes dead subscriber from list
- handle_info/2 leaves other subscribers intact
