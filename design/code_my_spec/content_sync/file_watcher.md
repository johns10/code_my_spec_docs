# FileWatcher

## Purpose

GenServer that monitors local content directories for file changes during development. Watches configured filesystem paths using the FileSystem library and triggers content sync operations when files are modified. Started conditionally based on environment configuration (development only).

## Public API

```elixir
# GenServer Lifecycle
@spec start_link(opts :: keyword()) :: GenServer.on_start()

# Internal State
defstruct [:scope, :watched_directory, :debounce_timer]
```

## Execution Flow

### GenServer Initialization

1. **Environment Check**: Verify `:watch_content` config is enabled, return `:ignore` if false
2. **Directory Loading**: Read watched directory from `:content_watch_directory` config
3. **Scope Loading**: Read scope from `:content_watch_scope` config (account_id, project_id)
4. **Directory Validation**: Verify directory exists and is readable
5. **FileSystem Subscription**: Subscribe to FileSystem backend for directory events
6. **State Initialization**: Store scope, directory, and nil debounce_timer in GenServer state

### File Change Handling

1. **Event Reception**: Receive `{:file_event, _watcher_pid, {path, events}}` message
2. **Event Filtering**: Filter for relevant events (`:modified`, `:created`, `:removed`)
3. **Timer Cancellation**: If `debounce_timer` is not nil, cancel via `Process.cancel_timer/1`
4. **Timer Start**: Start new timer via `Process.send_after(self(), :trigger_sync, 1000)`
5. **State Update**: Store timer reference in `debounce_timer` field
6. **Return**: `{:noreply, %{state | debounce_timer: timer_ref}}`

### Debounced Sync Trigger

1. **Message Reception**: Receive `:trigger_sync` message from timer
2. **Timer Clear**: Set `debounce_timer` to nil
3. **Sync Call**: Call `ContentSync.Sync.sync_directory(scope, watched_directory)`
4. **Result Logging**: Log sync result (success or error) for developer visibility
5. **Return**: `{:noreply, %{state | debounce_timer: nil}}`

### Graceful Shutdown

1. **Stop Signal**: Receive shutdown signal from supervisor
2. **FileSystem Unsubscribe**: Clean up FileSystem subscriptions
3. **GenServer Termination**: Normal process exit

## Implementation Notes

### Configuration

FileWatcher reads configuration from application environment:

```elixir
# config/dev.exs
config :code_my_spec,
  watch_content: true,
  content_watch_directory: "/Users/developer/my_project/content",
  content_watch_scope: %{
    account_id: "dev_account",
    project_id: "dev_project"
  }

# config/prod.exs
config :code_my_spec,
  watch_content: false
```

**Required Config:**
- `:watch_content` - Boolean flag to enable/disable watching
- `:content_watch_directory` - Absolute path to content directory
- `:content_watch_scope` - Map with `account_id` and `project_id` keys

### Conditional Startup

FileWatcher should only start in development:

```elixir
# In application.ex supervision tree
children =
  if Application.get_env(:code_my_spec, :watch_content, false) do
    [ContentSync.FileWatcher | children]
  else
    children
  end
```

Or use a conditional child spec that returns `:ignore` when disabled.

### FileSystem Library Integration

Uses the `file_system` library for cross-platform file watching:

- Subscribes to a FileSystem backend with directory paths
- Receives messages in GenServer handle_info callback
- Handles backend-specific event formats
- Automatically handles platform differences (inotify, FSEvents, etc.)

### Scope Management

**Scope Source:**
- Read from application config (`:content_watch_scope`) at initialization
- Contains `account_id` and `project_id` for syncing
- Static per environment - does not change during runtime
- Convert config map to `%Scope{}` struct with `active_account_id` and `active_project_id`

### Debouncing Strategy

File changes come in rapid bursts (editor saves, git operations). Timer-based debouncing:

- Store timer reference in `debounce_timer` state field
- On file event: cancel existing timer (if present) and start new one
- Timer sends `:trigger_sync` message after 1000ms
- Only most recent change triggers sync, earlier changes ignored
- Simple and effective - no need for tracking timestamps

### Error Handling

**Sync Failures:**
- Log error with details
- Do NOT crash the GenServer
- Continue watching for next change

**Invalid Scope:**
- Log warning that no active project is set
- Skip sync operation
- Continue watching

**Directory Deleted:**
- Log error
- GenServer may crash (acceptable - supervisor restarts)
- Consider detecting and handling gracefully in future

### Development Experience

FileWatcher provides immediate feedback during development:

- Edit content file in editor
- FileWatcher detects change within ~100ms
- Sync runs automatically
- Developer sees updated content in browser (via LiveView + PubSub)

No manual sync button clicking required during development.

### Integration with ContentSync

FileWatcher calls the Sync component directly:

```elixir
def handle_info({:file_event, _watcher_pid, {_path, _events}}, state) do
  # Cancel existing timer if present
  if state.debounce_timer, do: Process.cancel_timer(state.debounce_timer)

  # Start new debounce timer
  timer_ref = Process.send_after(self(), :trigger_sync, 1000)

  {:noreply, %{state | debounce_timer: timer_ref}}
end

def handle_info(:trigger_sync, state) do
  case ContentSync.Sync.sync_directory(state.scope, state.watched_directory) do
    {:ok, result} ->
      Logger.info("FileWatcher: Content synced successfully", result: result)

    {:error, reason} ->
      Logger.error("FileWatcher: Sync failed", reason: reason)
  end

  {:noreply, %{state | debounce_timer: nil}}
end
```

### Single Directory Watching

FileWatcher watches a single configured directory (not multiple directories):

- Simple configuration
- Matches flat directory structure expected by Sync
- Developer points watcher at their content directory
- All content files expected in that single directory

### Production Behavior

In production, FileWatcher should not start:

- `:watch_content` set to `false`
- FileWatcher returns `:ignore` from start_link
- No filesystem watching overhead
- Content syncs triggered by user actions via GitSync