# CodeMySpec.ProjectSync

Public API for orchestrating synchronization of the entire project from filesystem to database and maintaining real-time sync via file watching.

This is the public interface module following the Dave Thomas pattern:

- **CodeMySpec.ProjectSync** (this module) - Public API
- **CodeMySpec.ProjectSync.Sync** - Synchronization implementation (all sync logic)
- **CodeMySpec.ProjectSync.ChangeHandler** - Routes file changes to sync operations
- **CodeMySpec.ProjectSync.FileWatcherServer** - GenServer managing FileSystem watcher (singleton)

## Types

```elixir
@type sync_result :: %{
  contexts: Contexts.Sync.sync_result(),
  requirements_updated: integer(),
  errors: [term()]
}
```

## Functions

### sync_all/1

```elixir
@spec sync_all(Scope.t()) :: {:ok, sync_result()} | {:error, term()}
```

Performs a complete project synchronization at startup.

Delegates to `Sync.sync_all/1`.

**Test Assertions**:

- sync_all/1 delegates to Sync.sync_all/1
- sync_all/1 returns sync result from Sync module

### start_watching/0

```elixir
@spec start_watching() :: {:ok, pid()} | {:error, term()}
```

Starts the singleton file watcher server process.

Delegates to `FileWatcherServer.start_link/1`.

Note: This is typically called by the application supervisor at startup, not manually.

**Test Assertions**:

- start_watching/0 starts FileWatcherServer
- start_watching/0 returns server pid
- start_watching/0 returns error if already started

### stop_watching/0

```elixir
@spec stop_watching() :: :ok
```

Stops the singleton file watcher server process.

Delegates to `GenServer.stop(FileWatcherServer)`.

**Test Assertions**:

- stop_watching/0 stops the server process
- stop_watching/0 returns :ok