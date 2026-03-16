# CodeMySpec.Components.Sync

Synchronizes components from filesystem to database. Parent-child relationships
are derived from module name hierarchy.

Provides four public functions:
1. `sync_changed/2` - Identifies and syncs only changed components
2. `update_parent_relationships/4` - Updates parent relationships for affected components only
3. `sync_all/2` - Backward-compatible full sync (delegates to the above)
4. `sync_one/3` - Syncs a single component by module name

Each phase pre-filters before expensive operations, reducing file I/O and database writes.

## Type

module

## Functions

### sync_changed/2

Synchronizes only changed components from spec files and implementation files.
Pre-filters files by mtime BEFORE parsing — unchanged files are never read.

```elixir
@type parse_error :: {path :: String.t(), reason :: term()}
@spec sync_changed(Scope.t(), keyword()) :: {:ok, [Component.t()], [binary()]} | {:error, term()}
```

**Options**:
- `:base_dir` - Base directory to scan (defaults to current working directory)
- `:force` - When true, ignores mtime and syncs all files (defaults to false)
- `:ignored_components` - List of fully qualified module names to exclude (e.g., `["MyApp.Repo"]`)

**Process**:
1. Load existing components from database, build `module_name -> files_changed_at` lookup
2. Collect file infos with mtimes for spec files (`Paths.spec_glob()`) and impl files (`lib/**/*.ex`)
3. Split each set into changed/unchanged by comparing file mtime against component's `files_changed_at`
4. Parse ONLY changed files — spec files extract module name (H1), type (`## Type`), description (intro text), and dependencies (`## Dependencies`); impl files extract declared `defmodule` name
5. For unchanged files, derive module names from paths without file I/O
6. Merge changed spec and impl data by module name — impl module name takes priority, then spec H1, then path-derived
7. Filter out ignored components by module name
8. Upsert changed components with `synced_at = utc_now()` and `files_changed_at = max(spec_mtime, impl_mtime)`
9. Sync dependencies for changed components — adds new, removes stale
10. Cleanup components no longer present in filesystem
11. Return `{:ok, all_components, changed_component_ids}`

**Test Assertions**:
- uses implementation module name when present
- falls back to spec module name when no implementation
- falls back to path-derived name when neither declares module
- finds all spec files recursively
- finds all impl files recursively in lib/
- merges spec and impl data when both exist for same module
- creates components that don't exist
- updates components that do exist (idempotent)
- removes components no longer in filesystem
- respects scope boundaries
- skips files that have not been modified since last sync
- syncs files when mtime is newer than component files_changed_at
- force option bypasses mtime check
- sets files_changed_at to max mtime of component's spec and impl files
- syncs dependencies from spec ## Dependencies section
- adds new dependencies declared in spec
- removes dependencies no longer declared in spec
- filters out ignored components by module name
- extracts type from ## Type section
- extracts description from intro text between H1 and first H2
- validates spec H1 matches file path

### update_parent_relationships/4

Updates parent-child relationships for components affected by changes.
Only updates components that were just synced or whose parent was just synced.

```elixir
@spec update_parent_relationships(Scope.t(), [Component.t()], [binary()], keyword()) ::
        {:ok, [binary()]} | {:error, term()}
```

**Options**:
- `:force` - When true, updates all parent relationships (defaults to false)

**Process**:
1. In force mode: derive parent relationships for ALL components, return all IDs
2. In incremental mode:
   a. Build component lookup map and changed ID set
   b. Find affected components — those that were changed OR whose parent module name is in the changed set
   c. For each affected component, find nearest ancestor by walking up the module namespace tree
   d. Update parent_component_id only if it changed (set, cleared, or moved)
   e. Return expanded set of changed IDs (original + newly updated)

**Test Assertions**:
- derives parent relationships from module hierarchy (A.B is child of A)
- finds nearest ancestor when immediate parent doesn't exist (A.B.C.D -> A.B if A.B.C missing)
- clears parent when parent component is removed
- does not set self as parent
- only updates affected components in incremental mode
- updates all components in force mode
- returns expanded list including children whose parent changed

### sync_all/2

Backward-compatible full sync that delegates to `sync_changed/2` then `update_parent_relationships/4`.

```elixir
@spec sync_all(Scope.t(), keyword()) :: {:ok, [Component.t()], [parse_error()]} | {:error, term()}
```

**Options**:
- `:base_dir` - Base directory to scan (defaults to current working directory)
- `:force` - When true, ignores mtime and syncs all files (defaults to false)

**Process**:
1. Call `sync_changed(scope, opts)` to sync changed components
2. Call `update_parent_relationships(scope, all_components, changed_ids, opts)` to derive hierarchy
3. Return `{:ok, all_components, []}`

**Test Assertions**:
- syncs components and derives parent relationships in one call
- returns all components including unchanged
- returns empty parse errors list

### sync_one/3

Syncs a single component by module name. Derives spec and impl file paths from
the module name, parses any that exist, upserts the component, syncs its
dependencies, and updates its parent relationship.

```elixir
@spec sync_one(Scope.t(), String.t(), keyword()) :: {:ok, Component.t()} | {:error, term()}
```

**Options**:
- `:base_dir` - Base directory (defaults to current working directory)

**Process**:
1. Derive spec path (`.code_my_spec/spec/<module_path>.spec.md`) and impl path (`lib/<module_path>.ex`) from module name
2. Parse whichever files exist — return `{:error, :no_files_found}` if neither exists
3. Merge spec and impl data if both exist (same merge logic as `sync_changed`)
4. Upsert component with `synced_at = utc_now()` and `files_changed_at = file mtime`
5. Load all project components, sync dependencies for this component
6. Update parent relationship using nearest ancestor lookup

**Test Assertions**:
- syncs component from spec file only
- syncs component from impl file only
- merges spec and impl when both exist
- returns error when neither spec nor impl file exists
- syncs dependencies from spec
- sets parent relationship from module hierarchy
- sets files_changed_at to file mtime

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.Sync.FileInfo
- CodeMySpec.Documents
- CodeMySpec.Paths
- CodeMySpec.Users.Scope
- CodeMySpec.Utils.Paths
