# Components.Sync

**Type**: logic

Synchronizes context components and their child components from filesystem to database.

## Functions

### sync_contexts/1

```elixir
@spec sync_contexts(Scope.t()) :: {:ok, [Component.t()]} | {:error, term()}
```

Synchronizes all context components from both spec files and implementation files in the project.

**Process**:
1. Scans `docs/spec/` directory for all `.spec.md` files at the context level
2. Scans `lib/<project_name>/` directory for all top-level `.ex` files (contexts)
3. Merges the two lists, using code file path as the canonical identifier
4. For each context found:
   - If spec file exists:
     - Parses spec file to extract context metadata (name, type, description)
     - Extracts module name from corresponding implementation file if it exists
   - If only implementation file exists (no spec):
     - Extracts module name from implementation file
     - Sets type to nil (requires spec to have type)
   - Generates path-based GUID from spec or implementation file path
   - Upserts context component using `Components.upsert_component/2` with:
     - `guid`: path-based GUID for idempotency
     - `type`: `:context` or `:coordination_context` (from spec, `:context` if no spec)
     - `module_name`: extracted from spec or implementation
     - `parent_component_id`: nil (contexts are top-level)
5. Calls `sync_components/2` for each context to sync its child components
6. Queries all context components from DB
7. Removes any context components that no longer exist in either filesystem location
8. Returns list of synced contexts

**Test Assertions**:

- sync_contexts/1 finds all spec files in docs/spec/
- sync_contexts/1 finds all context implementation files in lib/<project_name>/
- sync_contexts/1 merges spec and implementation lists
- sync_contexts/1 parses spec files for context metadata when available
- sync_contexts/1 extracts module names from implementation files
- sync_contexts/1 creates contexts from specs only (planned)
- sync_contexts/1 creates contexts from implementation only (existing, no spec)
- sync_contexts/1 merges spec and implementation data when both exist
- sync_contexts/1 generates path-based GUIDs from file paths
- sync_contexts/1 creates contexts when they don't exist
- sync_contexts/1 updates contexts when they exist
- sync_contexts/1 calls sync_components/2 for each context
- sync_contexts/1 removes contexts that no longer exist in either location
- sync_contexts/1 respects scope boundaries

### sync_components/2

```elixir
@spec sync_components(Scope.t(), parent_component :: Component.t()) :: {:ok, [Component.t()]} | {:error, term()}
```

Synchronizes all child components belonging to a parent context component from both spec files and implementation files.

**Process**:
1. Receives parent component (must have `type: :context` or `type: :coordination_context`)
2. Scans `docs/spec/<context_path>/` directory for component spec files
3. Uses `Paths.implementation_path/1` to determine the context's implementation directory
4. Recursively scans the context's implementation subdirectory for `.ex` files (excluding the context file itself)
5. Merges the two lists, using implementation file path as the canonical identifier
6. For each component found:
   - If spec file exists:
     - Parses spec file to extract component metadata (name, type, description)
     - Extracts module name from corresponding implementation file if it exists
   - If only implementation file exists (no spec):
     - Extracts module name from implementation file
     - Sets type to nil (requires spec to have type)
   - Generates path-based GUID from implementation file path
   - Upserts component using `Components.upsert_component/2` with:
     - `guid`: path-based GUID for idempotency
     - `module_name`: extracted module name
     - `parent_component_id`: parent context's guid
     - `type`: from component spec file (nil if no spec)
     - Other metadata from spec (name, description, etc.)
7. Queries all child components from DB for this parent (using `parent_component_id`)
8. Removes any components from DB that no longer exist in either filesystem location
9. Returns list of synced components

**Test Assertions**:

- sync_components/2 finds all component spec files in docs/spec/<context_path>/
- sync_components/2 uses Paths.implementation_path/1 to find context directory
- sync_components/2 recursively finds all .ex files in context subdirectory
- sync_components/2 excludes the context file itself (only syncs children)
- sync_components/2 merges spec and implementation lists
- sync_components/2 extracts module names from implementation files
- sync_components/2 parses spec files for component metadata when available
- sync_components/2 creates components from specs only (planned)
- sync_components/2 creates components from implementation only (existing, no spec)
- sync_components/2 merges spec and implementation data when both exist
- sync_components/2 generates path-based GUIDs from file paths
- sync_components/2 creates components when they don't exist
- sync_components/2 updates components when they exist
- sync_components/2 sets parent_component_id to parent context guid
- sync_components/2 removes components that no longer exist in either location
- sync_components/2 respects scope boundaries
- sync_components/2 returns error if parent is not a context type
- sync_components/2 handles files without valid module definitions

## Dependencies

- utils/paths.spec.md
