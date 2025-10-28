# FileWatcher

## Purpose

GenServer that monitors local content directories for file changes during development. Watches configured filesystem paths using the FileSystem library and triggers ContentAdmin sync operations when files are modified. This provides immediate feedback during content development without manual sync button clicking. Started conditionally based on environment configuration (development only).

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
3. **Sync Call**: Call `ContentSync.Sync.sync_to_content_admin(scope, watched_directory)`
4. **ContentAdmin Processing**:
   - Parse markdown files in directory
   - Validate frontmatter schema
   - Store parse results in `content_admin` table
   - Broadcast changes via PubSub
5. **Result Logging**: Log sync result (success or error) for developer visibility
6. **Return**: `{:noreply, %{state | debounce_timer: nil}}`

### Graceful Shutdown

1. **Stop Signal**: Receive shutdown signal from supervisor
2. **FileSystem Unsubscribe**: Clean up FileSystem subscriptions
3. **GenServer Termination**: Normal process exit

## Architecture Context

### ContentAdmin vs Content

FileWatcher syncs to **ContentAdmin** (NOT Content):

**ContentAdmin** (SaaS Validation Layer):
- Multi-tenant (account_id, project_id scoping)
- Stores in `content_admin` table
- Includes `parse_status` and `parse_errors` fields
- Used for validation and preview only
- Accessed by developers in CodeMySpec SaaS platform
- FileWatcher syncs here during development

**Content** (Client Production Layer):
- Single-tenant (no account/project scoping)
- Stores in `contents` table
- No parse_status fields (only valid content deployed)
- Used for serving published content to end users
- Accessed by visitors to deployed client sites
- Receives content via HTTP POST from SaaS when developer clicks "Publish"

**Publishing Flow:**
```
[Dev edits locally] -> [FileWatcher] -> [ContentAdmin validation]
                                             ↓ (when ready)
                                      [Dev clicks "Publish"]
                                             ↓
                              [SaaS pulls from Git again]
                                             ↓
                              [HTTP POST to client /api/content/sync]
                                             ↓
                                       [Content.sync_content/1]
                                             ↓
                                    [contents table (production)]
```

ContentAdmin is NEVER copied to Content. Publishing always pulls fresh from Git.

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
- Contains `account_id` and `project_id` for multi-tenant ContentAdmin isolation
- Static per environment - does not change during runtime
- Must load full `%Scope{}` struct with Account and Project records from database
- Use `Users.build_scope_from_ids/2` or similar to construct proper Scope struct

**Scope Construction:**
```elixir
# In init/1
%{account_id: account_id, project_id: project_id} =
  Application.get_env(:code_my_spec, :content_watch_scope)

# Load account and project from database
case Users.build_scope_from_ids(account_id, project_id) do
  {:ok, scope} ->
    # Continue with initialization
  {:error, reason} ->
    Logger.error("FileWatcher: Failed to build scope", reason: reason)
    :ignore
end
```

**Why Full Scope Required:**
- ContentAdmin functions expect `%Scope{}` with loaded Account/Project structs
- Scope used for multi-tenant filtering (account_id, project_id)
- PubSub broadcasts use scope to construct topic names

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

FileWatcher provides immediate feedback during content development:

- Developer edits markdown file in local content directory
- FileWatcher detects change within ~100ms
- After 1 second debounce, sync runs automatically to ContentAdmin
- ContentAdmin parses files and validates frontmatter/markdown
- Parse status (success/error) stored in ContentAdmin records
- LiveView UI updates via PubSub broadcast showing parse results
- Developer sees validation errors immediately without clicking "Sync"

**Flow Example:**
```
[Editor Save] -> [FileWatcher Detect] -> [1s Debounce] ->
[Sync to ContentAdmin] -> [Parse & Validate] ->
[PubSub Broadcast] -> [LiveView Update] -> [Dev sees results]
```

No manual sync button clicking required during development.

### Integration with ContentAdmin

FileWatcher syncs directly to ContentAdmin for validation-only workflow:

```elixir
def handle_info({:file_event, _watcher_pid, {_path, _events}}, state) do
  # Cancel existing timer if present
  if state.debounce_timer, do: Process.cancel_timer(state.debounce_timer)

  # Start new debounce timer (1 second)
  timer_ref = Process.send_after(self(), :trigger_sync, 1000)

  {:noreply, %{state | debounce_timer: timer_ref}}
end

def handle_info(:trigger_sync, state) do
  # Call Sync module to process directory and write to ContentAdmin
  case ContentSync.Sync.sync_to_content_admin(state.scope, state.watched_directory) do
    {:ok, result} ->
      Logger.info("FileWatcher: ContentAdmin synced successfully",
        total: result.total_files,
        success: result.successful,
        errors: result.errors
      )

    {:error, reason} ->
      Logger.error("FileWatcher: ContentAdmin sync failed", reason: reason)
  end

  {:noreply, %{state | debounce_timer: nil}}
end
```

**Sync Target:**
- Writes to `content_admin` table (NOT `contents` table)
- ContentAdmin schema includes `parse_status` and `parse_errors` fields
- Multi-tenant scoped by account_id and project_id
- PubSub broadcast notifies LiveView of changes

### Single Directory Watching

FileWatcher watches a single configured directory (not multiple directories):

- Simple configuration
- Matches flat directory structure expected by Sync
- Developer points watcher at their content directory
- All content files expected in that single directory

### Production Behavior

**In SaaS Server (Production):**
- FileWatcher should NOT start (`:watch_content` set to `false`)
- FileWatcher returns `:ignore` from start_link
- No filesystem watching overhead
- ContentAdmin syncs triggered manually by developer clicking "Sync from Git"
- Uses `ContentSync.sync_to_content_admin/1` which clones Git repo

**In Client Appliances (Deployed):**
- FileWatcher does NOT exist (not part of client deployment)
- Client appliances don't have ContentAdmin schema at all
- Content syncs triggered by SaaS server via HTTP POST to `/api/content/sync`
- Uses `Content.sync_content/1` which writes directly to `contents` table

**Development Only:**
FileWatcher is strictly a development convenience for rapid iteration:
- Watches local filesystem directory
- Syncs to ContentAdmin for validation feedback
- Avoids manual clicking during content authoring
- NOT used in any production scenario (SaaS or client)