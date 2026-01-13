# Simplify Components.Sync to Create Components Without Requiring Parent Contexts

## Problem

Currently `Components.Sync` requires parent contexts to exist before child components can be discovered. The sync logic:

1. `find_spec_contexts` - looks for `*.spec.md` directly in `docs/spec/{project}/` (top-level only)
2. For each context found, `sync_components` looks in that context's subdirectory for children

This means running:
```
mix cli start-agent-task -t component_spec -m CodeMySpecCli.Hooks.ValidateEdits
```
...fails with "Component not found" because `CodeMySpecCli.Hooks` context doesn't exist, so the sync never looks in `docs/spec/code_my_spec_cli/hooks/` for child specs.

This is unnecessary coupling. A spec file exists at the expected path, but it can't be discovered without its parent context also existing.

## Solution

Refactor sync to scan ALL spec files and ALL impl files, create components for each, then derive parent relationships from module names.

## Changes

### File: `lib/code_my_spec/components/sync.ex`

**Replace hierarchical discovery with flat discovery:**

1. **New function: `find_all_spec_files/2`**
   - Scan `docs/spec/{project_path}/**/*.spec.md` recursively
   - Return list of all spec files regardless of depth

2. **New function: `find_all_impl_files/2`**
   - Scan `lib/{project_path}/**/*.ex` recursively
   - Filter out non-module files (application.ex, repo.ex, etc.)
   - Return list of all impl files

3. **Refactor `sync_contexts/2` → `sync_all_components/2`**
   - Find all spec files
   - Find all impl files
   - Merge by module name
   - Upsert each as a component
   - **After all components exist:** derive parent relationships from module names
   - Cleanup removed components

4. **New function: `derive_parent_relationships/2`**
   - For each component, compute parent module name (e.g., `CodeMySpecCli.Hooks.ValidateEdits` → `CodeMySpecCli.Hooks`)
   - Look up parent by module name
   - If found, update `parent_component_id`
   - If not found, leave as `nil`

5. **Determine type from path depth:**
   - Top-level specs (directly in `docs/spec/{project}/`) → type: "context"
   - Nested specs → type from spec content or "component"

### File: `lib/code_my_spec/project_sync/sync.ex`

- Update call from `Components.Sync.sync_contexts` to `Components.Sync.sync_all_components`

## Verification

1. Create a spec file at `docs/spec/code_my_spec_cli/hooks/validate_edits.spec.md` (already exists)
2. Run sync without `CodeMySpecCli.Hooks` context existing
3. Verify component is created with `parent_component_id: nil`
4. Run `mix cli start-agent-task -t component_spec -m CodeMySpecCli.Hooks.ValidateEdits`
5. Verify it succeeds and generates a prompt

Optional: Create `CodeMySpecCli.Hooks` context, re-sync, verify parent relationship is established.
