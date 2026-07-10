# ComponentCode no longer orders by component dependency (dependent surfaced before its deps)

## Status
new

## Severity
medium

## Description

`get_next_requirement` returned the `implementation_file` (ComponentCode)
requirement for a **dependent** context before the `implementation_file`
requirements of the **dependency** contexts it composes. The graph used to
order ComponentCode bottom-up (leaf dependencies first); in this session it
surfaced the top of the chain first.

This forced a manual override — the operator had to say "bottom up" and pick
the dependency contexts by hand instead of letting the graph drive.

## Repro (from get_ai_traffic, story 811)

Three context components were created during ArchitectureDesign:

- `GetAiTraffic.McpServers.FixServer` — `## Dependencies`: `GetAiTraffic.ContentGuard`, `GetAiTraffic.ChangeLedger`, `GetAiTraffic.Platforms`
- `GetAiTraffic.ContentGuard` — no dependencies (leaf)
- `GetAiTraffic.ChangeLedger` — no dependencies (leaf)

Steps:

1. `create_component` for all three (FixServer renamed from an earlier name via `update_component`).
2. Added the `## Dependencies` bullets to `fix_server.spec.md`.
3. `validate_dependency_graph` → "No circular dependencies detected".
4. `sync_project` → "Files: 1215 (0 changed). Components: 145".
5. `get_next_requirement` → `implementation_file` for **FixServer** (`a3cca164-…`).

Expected: ContentGuard and ChangeLedger (leaf deps) should be the actionable
ComponentCode requirements first, since `implementation_file` carries the
`dependencies_satisfied` prerequisite and FixServer depends on both.

## Hypotheses (unverified)

1. **Dependency edges not registered by sync.** `sync_project` reported
   `0 changed` even though `## Dependencies` was just edited into
   `fix_server.spec.md`. If the new edges weren't derived, FixServer's
   `dependencies_satisfied` is vacuously true → it becomes actionable before
   its deps. (Related to `task-graph-representation-gaps.md` Gap #1, but that
   issue is about graph *visualization*; this is about *NextActionable*
   ordering.)

2. **Interaction with disabled spec/test requirements.** This project runs
   with component specs and unit tests turned off (see
   `requirement-settings-fast-mode.md`). With ComponentSpec/test requirements
   removed, `implementation_file` may be evaluated without the prerequisite
   chain that previously enforced dependency order, so the dependency ordering
   that used to come "for free" is gone.

## Suspected location

- `ProjectCoordinator.NextActionable` — cross-component dependency traversal for `implementation_file`.
- `DependencyChecker` / `dependencies_satisfied` evaluation for `context` types.
- `Components.Sync` dependency-edge derivation from `## Dependencies` (the `0 changed` result is suspicious).

## Impact

Bottom-up implementation order has to be driven manually. For a context that
composes focused sub-contexts (the recommended decomposition), the agent is
pointed at the orchestrator before the pieces it orchestrates exist.
