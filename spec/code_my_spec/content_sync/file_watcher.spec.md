# CodeMySpec.ContentSync.FileWatcher

Public API for file watching during development.

Monitors local content directories for file changes and triggers ContentAdmin sync operations. This provides immediate validation feedback during content development without manual sync button clicking.

FileWatcher syncs to ContentAdmin (NOT Content) - the multi-tenant validation layer in the SaaS platform. Publishing flow: FileWatcher -> ContentAdmin -> (Publish) -> Content.

This module follows Dave Thomas's pattern of separating execution strategy from business logic:
- `FileWatcher` (this module): Public API
- `FileWatcher.Server`: GenServer implementation with side effects
- `FileWatcher.Impl`: Pure business logic (100% unit testable)

## Delegates

- validate_directory/1: CodeMySpec.ContentSync.FileWatcher.Impl.validate_directory/1
- relevant_event?/1: CodeMySpec.ContentSync.FileWatcher.Impl.relevant_event?/1

## Functions

### child_spec/1

Returns a child specification for use in a supervision tree.

```elixir
@spec child_spec(keyword()) :: Supervisor.child_spec()
```

**Process**:
1. Build child spec map with id set to `__MODULE__`
2. Set start tuple to `{__MODULE__, :start_link, [opts]}`
3. Configure as worker type with permanent restart strategy
4. Set shutdown timeout to 500ms

**Test Assertions**:
- returns valid child_spec map
- sets id to __MODULE__
- configures start_link with provided opts
- sets type to :worker
- sets restart to :permanent
- sets shutdown to 500

### start_link/1

Starts the FileWatcher GenServer.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Check if enabled via `:enabled` option or application config `:watch_content` (default: false)
2. If enabled is false, return `:ignore` (conditional startup)
3. If enabled is true, start GenServer via `GenServer.start_link(Server, opts)`
4. Return `{:ok, pid}` on success or `{:error, reason}` on failure

**Options**:
- `:enabled` - Override enabled check (useful for testing conditional startup)
- `:directory` - Override watched directory
- `:scope` - Provide Scope struct directly
- `:debounce_ms` - Override debounce delay (useful for fast tests)
- `:sync_fn` - Override sync function (useful for mocking)

**Test Assertions**:
- returns :ignore when watch_content config is false
- returns :ignore when enabled option is false
- starts GenServer when watch_content config is true
- starts GenServer when enabled option is true
- returns {:ok, pid} on successful start
- returns {:error, reason} on invalid configuration
- passes opts to Server.init/1

### validate_directory/1

Validates that a directory exists and is actually a directory.

```elixir
@spec validate_directory(String.t()) :: :ok | {:error, :invalid_directory}
```

**Process**:
1. Check if path exists using `File.exists?/1`
2. Check if path is a directory using `File.dir?/1`
3. Return `:ok` if both checks pass
4. Return `{:error, :invalid_directory}` otherwise

**Test Assertions**:
- returns :ok for valid existing directory
- returns {:error, :invalid_directory} for non-existent path
- returns {:error, :invalid_directory} for file path (not directory)
- returns {:error, :invalid_directory} for empty string

### relevant_event?/1

Checks if an event list contains relevant file events.

```elixir
@spec relevant_event?(list()) :: boolean()
```

**Process**:
1. Check if events list contains any of: `:modified`, `:created`, `:removed`
2. Return `true` if any relevant event found
3. Return `false` for empty list or non-list input
4. Return `false` for event lists containing only other event types

**Test Assertions**:
- returns true for [:modified]
- returns true for [:created]
- returns true for [:removed]
- returns true for [:created, :modified]
- returns true for list containing relevant event among others
- returns false for empty list
- returns false for list with only irrelevant events like [:renamed, :attrib]
- returns false for non-list input

## Dependencies

- CodeMySpec.ContentSync.FileWatcher.Server
- CodeMySpec.ContentSync.FileWatcher.Impl
- CodeMySpec.ContentSync
- CodeMySpec.Users.Scope