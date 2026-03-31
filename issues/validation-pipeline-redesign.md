# Validation Pipeline Redesign: Task-Driven Analyzers

## Problem

The stop hook validation pipeline (`Validation.validate_stop`) is blunt. It runs every analyzer (compiler, credo, sobelow, `mix test --stale`, `mix spex --stale`) on every stop, regardless of what the agent was working on. A spec-writing task doesn't need test execution. A code task doesn't need spex. The pipeline doesn't know and doesn't care.

This creates two problems:
1. **Slow** — runs analyzers that aren't relevant to the work
2. **Noisy** — surfaces failures from unrelated code the agent may have touched

Meanwhile, the task evaluate functions (`ComponentCode.evaluate/2`, etc.) mostly just read DB state — requirements and persisted Problems. They don't run analyzers themselves. So if the right analyzers didn't run, evaluate reads stale data.

## Design

Two layers with clear responsibilities:

### Layer 1: Validation (runs analyzers, writes to DB)

The validation layer decides which analyzers to run based on:
- **The active task** — each task module declares which analyzers it needs
- **Generic safety** — compilation always runs (catches breakage from any edit)

It runs the analyzers, persists results to the Problems table, and recalculates requirements. It does NOT decide pass/fail.

### Layer 2: Task Evaluation (reads DB, decides pass/fail)

Each task's `evaluate/2` reads the freshly-persisted state:
- Are my requirements satisfied?
- Do I have blocking problems?

Returns `{:ok, :valid}` or `{:ok, :invalid, feedback}`. Pure read — no side effects.

This is mostly how evaluate already works. The change is ensuring the validation layer has run the right analyzers before evaluate reads the results.

### Stop Hook Flow

```
Stop hook arrives
  │
  ├─ 1. incremental_sync(scope, base_dir: cwd)
  │     Syncs file mtimes, recalculates requirements
  │
  ├─ 2. Validation.run_for_task(scope, active_task)
  │     ├─ Always: compile (generic safety)
  │     ├─ Task-declared: e.g. ComponentCode → [:exunit]
  │     ├─ Task-declared: e.g. WriteBddSpecs → [:spex]
  │     ├─ Task-declared: e.g. ComponentSpec → [] (nothing extra)
  │     └─ Persist Problems, recalculate affected requirements
  │
  ├─ 3. TaskEvaluator.evaluate_sessions(scope, session_id)
  │     └─ task.evaluate(scope, task) — reads DB only
  │
  └─ 4. Check next_actionable_project → block or allow
```

### `analyzers/0` Callback on Agent Tasks

New optional callback that each task module can implement:

```elixir
@callback analyzers() :: [analyzer_key]
@type analyzer_key :: :compiler | :credo | :sobelow | :exunit | :spex
```

Default returns `[]`. Task modules opt-in:

| Task Module | analyzers() |
|-------------|-------------|
| ProjectSetup | `[]` |
| ComponentSpec | `[]` |
| ComponentCode | `[:exunit]` |
| ComponentTest | `[:exunit]` |
| WriteBddSpecs | `[:spex]` |
| FixBddSpecs | `[:spex]` |
| ContextSpec | `[]` |
| ContextDesignReview | `[]` |
| DevelopComponent | `[:exunit]` |

Compilation always runs regardless — it's not in the callback, it's in the validation layer's base set. Credo/sobelow could be in the base set too, or opt-in per task.

### `--stale` for Tests and Spex

`mix test --stale` handles dependency tracking for us — we don't need to figure out which test files are affected by which source changes. Elixir's manifest tracks compile-time and runtime references transitively.

For spex: `mix spex` doesn't support `--stale` (confirmed in research_stale_tests.md). Options:
- Pass explicit file paths (current approach)
- Build our own mtime tracking
- Contribute `--stale` to sexy_spex

### Generic Edits (Agent Goes Off-Rails)

If the agent edits 5 files outside its task scope, compilation catches any breakage. That's the generic safety net. We don't need to run per-component analysis on every touched file — compilation is transitive and catches everything `--stale` would surface.

If we want credo/sobelow on generic edits, those go in the base set (always run) rather than task-declared.

## What Exists Today

- `Validation.Pipeline` — runs all analyzers generically, returns Problems
- `StaticAnalysis.AnalyzerBehaviour` — `run/2`, `available?/1`, `name/0` callbacks
- `StaticAnalysis.Runner` — executes analyzers by atom key (`:credo`, `:sobelow`)
- `Problems` context — persists/queries problems by component, source, file
- `DirtyTracker` — compares `files_changed_at` vs `last_analyzed_at` (can be removed; `sync_changed` handles mtime comparison)
- Agent task modules — implicit `command/2` + `evaluate/2` contract, no formal behaviour

## Implementation Sequence

1. **Add `analyzers/0` callback** to agent task modules (optional, default `[]`)
2. **Create `Validation.run_for_task/2`** — takes scope + active task, resolves analyzers, runs them, persists results
3. **Wire into StopController** — insert between `incremental_sync` and `TaskEvaluator`
4. **Remove DirtyTracker dependency** from the stop hook path
5. **Update evaluate functions** as needed (most already read DB state correctly)

## Open Questions

- Should credo/sobelow be in the base set (always run) or task-declared?
- Should we compile only on code-touching tasks, or always? (Probably always — it's cheap and catches unexpected breakage)
- How to handle spex without `--stale` support?
