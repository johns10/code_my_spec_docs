# ProjectSync.ChangeHandler

Routes file change events to appropriate synchronization operations.

This is a pure functional module that determines what needs to sync based on which file changed, then delegates to `ProjectSync.Sync` for the actual synchronization.

## Functions

### handle_file_change/3

```elixir
@spec handle_file_change(Scope.t(), file_path :: String.t(), events :: [atom()]) ::
  :ok | {:error, term()}
```

Routes a file system change event to the appropriate sync operation.

**Process**:
1. Ignores `:removed` events (handled by stale component removal in sync)
2. Determines file type using `determine_file_type/1`
3. For spec or implementation files:
   - Delegates to `Sync.sync_context/2` with the file path
   - Sync module handles finding the context (whether from spec path or implementation module)
4. For unrecognized file types, returns `:ok` (no-op)
5. Returns `:ok` on success or `{:error, reason}` on failure

**Event Types**:
- `:created` - new file created
- `:modified` - existing file changed
- `:removed` - file deleted (ignored)
- `:renamed` - file renamed (treated as `:created`)

**Test Assertions**:

- handle_file_change/3 ignores :removed events
- handle_file_change/3 delegates to Sync.sync_context/2 for spec files
- handle_file_change/3 delegates to Sync.sync_context/2 for .ex files
- handle_file_change/3 returns :ok for unrecognized file types
- handle_file_change/3 returns :ok for :removed events
- handle_file_change/3 propagates errors from Sync module
- handle_file_change/3 handles malformed file paths gracefully

### determine_file_type/1

```elixir
@spec determine_file_type(String.t()) :: :spec | :implementation | :other
```

Determines the type of file based on path and extension.

**Process**:
1. Checks if path ends with `.spec.md` and is under `docs/spec/` → `:spec`
2. Checks if path ends with `.ex` and is under `lib/` → `:implementation`
3. Otherwise → `:other`

**Test Assertions**:

- determine_file_type/1 returns :spec for .spec.md files in docs/spec
- determine_file_type/1 returns :implementation for .ex files in lib
- determine_file_type/1 returns :other for files outside conventional paths
- determine_file_type/1 returns :other for test files
- determine_file_type/1 returns :other for non-code files

## Implementation Notes

**Routing Logic**:
- This module is concerned only with routing, not synchronization
- All actual sync logic is delegated to `ProjectSync.Sync`
- This keeps routing logic separate from business logic

**Error Handling**:
- Malformed paths return `:ok` (no-op, not an error)
- Unrecognized file types return `:ok` (no-op)
- Only propagate errors from actual sync operations

**File Type Detection**:
- Must check both extension AND path location
- A `.spec.md` file outside `docs/spec/` is not a spec file
- A `.ex` file outside `lib/` might be a test or script