# CodeMySpec.Components.Sync

Synchronizes components from filesystem to database. Parent-child relationships are derived from directory structure.

## Functions

### sync_all/2

Synchronizes all components from spec files and implementation files.
Module names can come from three sources.
Implementation name takes precedence (it's what Elixir actually compiles).
All three should match.
Warn if they don't.

Only parses and upserts files that have been modified since the component was last synced.

```elixir
@type parse_error :: {path :: String.t(), reason :: term()}
@spec sync_all(Scope.t(), keyword()) :: {:ok, [Component.t()], [parse_error()]} | {:error, term()}
```

**Options**:
- `:base_dir` - Base directory to scan (defaults to current working directory)
- `:force` - When true, ignores mtime and syncs all files (defaults to false)

**Process**:
1. Find all spec files: `docs/spec/**/*.spec.md` - collect as FileInfo structs with mtime
2. Find all impl files: `lib/**/*.ex` (excluding `_build/`, `deps/`) - collect as FileInfo structs with mtime
3. Load existing components from database to build module_name -> synced_at map
4. For each file, skip if file mtime <= component synced_at (unless :force is true)
5. For files that need syncing:
   - Derive module name from path
   - Parse declared module name from file content
   - Warn if they don't match
   - Use implementation's declared name if present, else spec's, else path-derived
6. Parse spec files for type and description (impl-only files default to type "other")
7. Merge spec and impl data by resolved module name
8. Upsert only changed components
9. Derive parent relationships from module name hierarchy
10. Cleanup components that no longer exist in filesystem
11. Return all components (both synced and unchanged)

**Test Assertions**:
- uses implementation module name when present
- falls back to spec module name when no implementation
- falls back to path-derived name when neither declares module
- warns when path-derived name differs from declared name
- warns when spec and impl module names differ
- finds all spec files recursively in docs/spec/
- finds all impl files recursively in lib/
- merges spec and impl data when both exist for same module
- creates components that don't exist
- updates components that do exist (idempotent)
- derives parent relationships from module hierarchy
- removes components no longer in filesystem
- respects scope boundaries
- skips files that have not been modified since last sync
- syncs files when mtime is newer than component synced_at
- force option bypasses mtime check

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.Sync.FileInfo
- CodeMySpec.Users.Scope
