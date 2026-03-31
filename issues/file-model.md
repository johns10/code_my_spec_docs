# File Model: First-Class Files as Domain Entities

## Problem

Files are the connective tissue of the entire system — components have spec/impl/test files, stories have bdd specs and qa artifacts, projects have architecture docs, requirements produce prompt/problem files. But files aren't in the domain model. They're computed on the fly from conventions every time we need them.

This forces every subsystem to reinvent file tracking:

- **ComponentSync** globs the filesystem, parses spec files to extract module names, compares mtimes against a single `files_changed_at` timestamp. Rebuilds the file→component mapping from scratch every sync.
- **DirtyTracker** exists only because we have no file-level tracking. Compares `files_changed_at` vs `last_analyzed_at` — a workaround for not modeling files.
- **FileExistenceChecker** recomputes `Utils.component_files` every call, then hits the filesystem. Should be a DB query.
- **ProblemAssigner** rebuilds a reverse index (path → component_id) via `DirtyTracker.build_path_index` every time. This is literally reconstructing a relationship that should be a FK.
- **Utils.Paths** has `resolve_context_path`, `spec_path`, `implementation_path` — all the relationship logic, computed every time instead of persisted.
- **Problems** have `file_path` (string) but no FK to a File entity. The path→owner resolution happens in memory at assignment time.

The result: sync is complex, validation rebuilds indexes, and every new feature that touches files has to navigate the same computed-path maze.

## Design

### File Schema

```
files
  - id (uuid)
  - path (string, unique per project, relative to project root)
  - role (:spec | :implementation | :test | :rule | :json | :review | :bdd_spec | :qa_brief | :qa_result | :config)
  - mtime (utc_datetime, from filesystem stat)
  - size (integer, bytes, from filesystem stat)
  - content_hash (string, optional, for change detection beyond mtime)
  - component_id (uuid, nullable FK)
  - story_id (integer, nullable FK)
  - project_id (uuid, FK — always set, scoping)
```

The nullable FK pattern matches how Requirements already work (component_id | story_id | project_id).

Path is the natural join key. When `mix compile` reports `lib/my_app/accounts.ex:42: warning: ...`, we look up the File by path, follow the FK to the owner. No runtime index construction.

### What Collapses

| Current | With File model |
|---------|----------------|
| `Utils.component_files(component, project)` | `component.files` (preloaded association) |
| `DirtyTracker.build_path_index` | `File \|> where(path in ^paths) \|> select([:path, :component_id])` |
| `DirtyTracker.dirty_for_analysis?` | `File \|> where(mtime > last_analyzed_at)` |
| `FileExistenceChecker.check` | `Enum.any?(component.files, &(&1.role == :spec))` |
| `ProblemAssigner.assign` | Problem `belongs_to :file` via path FK |
| `ComponentSync.sync_changed` mtime comparison | File records already have mtime — just compare |
| `Utils.Paths.resolve_context_path` | Not needed at query time — relationship is a FK |

### File Classification

`stat_and_classify` pattern matches on path conventions to determine role. All conventions already exist scattered across `Paths` and `Utils` — this consolidates them:

```
lib/**/*.ex                          → :implementation
test/**/*_test.exs                   → :test
.code_my_spec/spec/**/*.spec.md      → :spec
.code_my_spec/rules/**/*.md          → :rule
test/spex/**/*_spex.exs              → :bdd_spec
.code_my_spec/qa/**/*_brief.md       → :qa_brief
.code_my_spec/qa/**/*_result.md      → :qa_result
.code_my_spec/config.yml             → :config
CLAUDE.md                            → :config
```

Owner resolution follows from the path. The module segment in `lib/my_app/accounts/user.ex` maps to a component via `module_to_path` (already in `Utils.Paths`). BDD specs at `test/spex/my_app/accounts_spex.exs` map to the same component's story. QA files at `.code_my_spec/qa/story_3_brief.md` map to story 3. Architecture files are project-owned.

Files that don't match any pattern are ignored (deps/, _build/, .git/, node_modules/, etc.).

### Sync Becomes Simple

Using DirWalker (already a dep) to stream the filesystem:

```elixir
def sync_files(scope, base_dir) do
  DirWalker.stream(base_dir)
  |> Stream.reject(&ignored_path?/1)
  |> Stream.map(&stat_and_classify/1)   # {relative_path, role, mtime, size}
  |> Stream.filter(&trackable_role?/1)   # only roles we care about
  |> Enum.to_list()
  |> upsert_files(scope)                 # bulk upsert, return changed file IDs
end
```

`stat_and_classify` uses the path conventions (same logic as `Utils.Paths`) to determine role and potential owner. Owner resolution happens once at upsert time, not on every query.

Changed files = files where mtime in DB differs from filesystem mtime. That's the complete set. No globs, no manifest comparisons, no DirtyTracker.

### Problems Join Through Files

```
Problem belongs_to File (via file_path → File.path)
File belongs_to Component | Story | Project
```

When an analyzer reports a problem at a path, we look up (or create) the File, attach the Problem. The File already knows its owner. ProblemAssigner disappears.

### Relationship to Validation Pipeline Redesign

The File model is the foundation that makes the validation pipeline redesign clean:

1. Stop hook fires → sync files (DirWalker, fast)
2. Changed files are known → follow FKs to affected owners
3. Validation layer runs analyzers scoped to changed files
4. Analyzers produce Problems → attach to Files → follow FKs to owners
5. Task evaluate reads Problems through File→owner chain

Without the File model, step 2 requires rebuilding path indexes. With it, it's a preload.

## Implementation Sequence

1. **Migration**: Create `files` table with schema above
2. **File context**: CRUD operations, bulk upsert, query by owner/role/path
3. **File sync**: DirWalker-based scanner that upserts File records with mtimes
4. **Wire into ComponentSync**: After file sync, derive component changes from File mtime changes instead of globbing + parsing
5. **Wire into requirements**: FileExistenceChecker queries Files instead of filesystem
6. **Wire into problems**: Problems reference Files, ProblemAssigner simplified
7. **Remove DirtyTracker**: No longer needed — File mtime is the source of truth
8. **Remove Utils.component_files runtime computation**: Replaced by `component.files` association

## Open Questions

- Should `content_hash` be populated eagerly (every sync) or lazily (only when mtime changes)? Eager is simpler but slower for large files.
- Should File records for non-existent files be kept (with a `:missing` status) or deleted? Keeping them preserves history; deleting keeps the table clean.
- Path uniqueness: scoped to project_id? Or globally unique? (Scoped — same path can exist in different projects.)
- Should we index `(project_id, path)` as unique, or just `path` within project scope via a unique index with project_id?
