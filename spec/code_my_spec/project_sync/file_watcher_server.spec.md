# CodeMySpec.ProjectSync.FileWatcherServer

Singleton GenServer that watches project directories for file changes and runs incremental component sync. Manages multiple project watchers keyed by project root directory. New directories are registered lazily via `ensure_watching/2` — typically called from agent task entry points where a scope with `cwd` is available.

On file change: debounces events (100ms), runs `Components.Sync.sync_changed/2` to detect changed components, recalculates requirements for changed components, cascades to story and project requirements, and rewrites status files.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.HierarchicalTree
- CodeMySpec.Components.Sync
- CodeMySpec.ProjectSync.StatusWriter
- CodeMySpec.Requirements.Sync
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
- FileSystem

## Functions

### start_link/1

Starts the file watcher GenServer.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Starts GenServer with name from opts (defaults to `__MODULE__`)
2. Initializes with empty watchers map, empty pending map, and nil debounce timer

**Test Assertions**:

- start_link/1 starts a GenServer that can be called by name
- start_link/1 initializes with no watched directories

### ensure_watching/2

Ensures the given scope's project directory is being watched. No-op if already watching that directory or if scope has no cwd.

```elixir
@spec ensure_watching(Scope.t(), GenServer.name()) :: :ok | :ignored
```

**Process**:
1. Returns `:ignored` if scope has no `cwd`
2. If directory already watched, returns `:ok` (no-op)
3. Finds existing subdirectories from `[".code_my_spec/spec", "lib", "test"]` under the project root
4. Starts a FileSystem watcher on those directories and subscribes to events
5. Stores the watcher PID and scope keyed by project root
6. Returns `:ok` (even if watcher fails to start — logs warning)

**Test Assertions**:

- ensure_watching/2 registers a new project directory
- ensure_watching/2 is a no-op for already watched directories
- ensure_watching/2 returns :ignored when scope has no cwd
- ensure_watching/2 watches multiple project directories

### watched_dirs/1

Returns the list of currently watched project root directories.

```elixir
@spec watched_dirs(GenServer.name()) :: [String.t()]
```

**Process**:
1. Returns the keys of the watchers map (project root paths)

**Test Assertions**:

- watched_dirs/1 returns empty list when no directories are watched
- watched_dirs/1 returns all registered project root paths

### init/1

GenServer callback. Initializes empty state.

```elixir
@spec init(keyword()) :: {:ok, map()}
```

**Process**:
1. Returns `{:ok, state}` with empty watchers, pending, and nil debounce_timer

**Test Assertions**:

- init/1 returns ok with empty state

### handle_call/3

GenServer callback handling `:ensure_watching` and `:watched_dirs` messages.

```elixir
@spec handle_call(term(), GenServer.from(), map()) :: {:reply, term(), map()}
```

**Process**:
1. `{:ensure_watching, project_root, scope}` — starts a FileSystem watcher for the project root's watchable subdirectories, stores entry in state
2. `:watched_dirs` — returns keys of the watchers map

**Test Assertions**:

- handle_call/3 starts FileSystem watcher for new project root
- handle_call/3 skips already-watched directories
- handle_call/3 returns watched directory list

### handle_info/2

GenServer callback handling file events, flush timer, and watcher stop.

```elixir
@spec handle_info(term(), map()) :: {:noreply, map()}
```

**Process**:
1. `{:file_event, watcher_pid, {path, events}}` — if relevant event (modified/created/removed/renamed), adds path to pending set for that watcher, resets debounce timer to 100ms
2. `:flush` — for each watcher with pending changes, runs incremental component sync, recalculates requirements for changed components, cascades to story/project requirements, rewrites status files
3. `{:file_event, watcher_pid, :stop}` — removes the watcher entry for the stopped watcher
4. Other messages — ignored

**Test Assertions**:

- handle_info/2 debounces and marks components dirty via sync
- handle_info/2 accumulates pending changes and flushes after debounce
- handle_info/2 ignores non-relevant events like :isdir
- handle_info/2 removes watcher entry on FileSystem stop event
- handle_info/2 deduplicates file paths in pending set

### terminate/2

GenServer callback for cleanup on shutdown.

```elixir
@spec terminate(term(), map()) :: :ok
```

**Process**:
1. Cancels debounce timer if active
2. Returns `:ok`

**Test Assertions**:

- terminate/2 cancels active debounce timer
- terminate/2 returns :ok
