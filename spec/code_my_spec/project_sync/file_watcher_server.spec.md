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
