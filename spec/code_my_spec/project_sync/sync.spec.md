# ProjectSync.Sync

Implementation module that performs the actual synchronization logic.

This is a pure functional module with no state - all functions perform synchronization operations (DB operations, file system operations).

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

Performs a complete project synchronization.

**Process**:
1. Calls `Contexts.Sync.sync_all_contexts/1` to sync all contexts and their components
2. Gets current file list from filesystem
3. Gets latest test results (or empty test run if none exist)
4. Calls `ProjectCoordinator.sync_project_requirements/4` to analyze and update all component requirements
5. Returns consolidated sync statistics

**Test Assertions**:

- sync_all/1 calls Contexts.Sync.sync_all_contexts/1
- sync_all/1 calls ProjectCoordinator.sync_project_requirements/4 after context sync
- sync_all/1 handles errors from context sync gracefully
- sync_all/1 respects scope boundaries
- sync_all/1 returns consolidated statistics with contexts and requirements_updated counts
- sync_all/1 creates empty test run if no tests exist yet

### sync_context/2

```elixir
@spec sync_context(Scope.t(), file_path :: String.t()) ::
  :ok | {:error, term()}
```

Synchronizes a context when any of its files change (spec or implementation).

**Process**:
1. Determines how to find the context based on file type:
   - If spec file (`.spec.md`): Use the spec path directly
   - If implementation file (`.ex`):
     - Read file and extract module name using `extract_module_name/1`
     - Find owning context using `find_context_for_module/2`
     - Use that context's spec path
2. Calls `Contexts.Sync.sync_context/2` with the spec path
   - This syncs the context record (from spec)
   - And syncs all components (from implementation files)
3. After successful context sync, recalculates ALL project requirements:
   - Gets current file list
   - Gets latest test results
   - Calls `ProjectCoordinator.sync_project_requirements/4`
   - Must recalculate ALL requirements (not just for this context) because contexts have dependencies on each other
4. Returns `:ok` on success or `{:error, reason}` on failure

**Test Assertions**:

- sync_context/2 uses spec path directly for .spec.md files
- sync_context/2 extracts module name and finds context for .ex files
- sync_context/2 calls Contexts.Sync.sync_context/2
- sync_context/2 recalculates ALL project requirements after context sync
- sync_context/2 returns :ok if no context matches implementation file (orphaned file)
- sync_context/2 returns error if spec file doesn't exist
- sync_context/2 returns error if context sync fails
- sync_context/2 respects scope boundaries

### extract_module_name/1

```elixir
@spec extract_module_name(String.t()) :: {:ok, String.t()} | {:error, :no_module}
```

Extracts the module name from Elixir source code content.

**Process**:
1. Uses regex `defmodule\s+([A-Z][a-zA-Z0-9_.]*)\s+do` to find module definition
2. Returns the captured module name
3. If no module found, returns `{:error, :no_module}`
4. If multiple modules, returns the first one

**Examples**:
- Input: `"defmodule CodeMySpec.Contexts.Sync do\n  # code\nend"`
- Output: `{:ok, "CodeMySpec.Contexts.Sync"}`

**Test Assertions**:

- extract_module_name/1 extracts module name from valid code
- extract_module_name/1 returns error for code without module
- extract_module_name/1 returns first module if multiple exist
- extract_module_name/1 handles nested modules correctly
- extract_module_name/1 handles module names with underscores

### find_context_for_module/2

```elixir
@spec find_context_for_module(Scope.t(), module_name :: String.t()) ::
  {:ok, Context.t()} | {:error, :no_match}
```

Finds which context owns a module by matching module name prefixes.

**Process**:
1. Queries all contexts for the scope from `ContextsRepository`
2. Filters contexts where context.module_name is a prefix of the given module_name
3. If multiple matches, selects the longest prefix (most specific)
4. Returns the matching context or `{:error, :no_match}`

**Examples**:
- Module: `"CodeMySpec.Contexts.Sync"`
- Contexts in DB:
  - `CodeMySpec.Contexts` (module_name)
  - `CodeMySpec.Users` (module_name)
- Output: `{:ok, %Context{module_name: "CodeMySpec.Contexts", ...}}`

**Test Assertions**:

- find_context_for_module/2 matches by module name prefix
- find_context_for_module/2 selects longest prefix when multiple match
- find_context_for_module/2 returns error when no context matches
- find_context_for_module/2 respects scope boundaries
- find_context_for_module/2 handles exact module name match

### recalculate_requirements/1

```elixir
@spec recalculate_requirements(Scope.t()) :: :ok | {:error, term()}
```

Recalculates all component requirements after a sync operation.

**Process**:
1. Gets current file list from filesystem (recursively list all files in project)
2. Gets latest test results using `TestRuns.get_latest_test_run/1`
3. If no test run exists, creates an empty one with `%TestRun{failures: []}`
4. Calls `ProjectCoordinator.sync_project_requirements/4` with scope, files, test_run, and empty opts
5. Returns `:ok` on success or `{:error, reason}` on failure

**Test Assertions**:

- recalculate_requirements/1 gets file list from filesystem
- recalculate_requirements/1 gets latest test results
- recalculate_requirements/1 creates empty test run if none exists
- recalculate_requirements/1 calls ProjectCoordinator.sync_project_requirements/4
- recalculate_requirements/1 respects scope boundaries

