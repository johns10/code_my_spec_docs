# CodeMySpec.AgentTasks.QaJourney

## Type

skill

## Intent

Drive end-to-end QA of the application as a three-phase pipeline: plan
a small set of cross-story user journeys, execute them against the
running app with browser tools, then codify the passing journeys as
Wallaby regression tests. The same module satisfies three requirement
nodes; the agent walks the next un-skipped phase per session and the
prompt marks completed phases as SKIP.

Journeys are distinct from per-story QA (`qa_story`): journeys trace
complete user paths across multiple stories — signup → first action →
verification — and are codified as permanent feature tests, not
re-walked manually each cycle.

## Done signal

Three independent `:path_exists` checks in `RequirementCalculator`:

- `qa_journey_plan` — `.code_my_spec/qa/journey_plan.md` exists.
- `qa_journey_execute` — `.code_my_spec/qa/journey_result.md` exists.
- `qa_journey_wallaby` — any file under `test/journeys/` exists
  (graph node uses `path_prefix: "test/e2e/"`; the module writes to
  `Paths.qa_journey_wallaby_dir() = "test/journeys"`).

No custom `evaluate/2` — the path-existence check is the contract.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the project graph
as three serial nodes (`qa_journey_plan` 10 → `qa_journey_execute` 11
→ `qa_journey_wallaby` 12), each gated by the previous phase's
artifact, all pointing at the same module. The combined prompt is
deliberately phase-aware: it always shows all three sections so the
agent sees the full pipeline, but pre-existing artifacts collapse a
phase to a one-line SKIP marker.

## Out of scope

- Per-story QA testing. That's `qa_story`; this task tests journeys
  that cut across stories.
- Writing or modifying `.code_my_spec/qa/plan.md` (the project-wide
  QA infrastructure spec). That's owned by `qa_setup`.
- Fixing application bugs. Failed journey steps surface as journey
  failures; bugs go through `triage_issues` / `fix_issues`.
- Designing journeys for failure paths the stories don't reference.
  Journeys cover real user paths, not exhaustive negative cases.

## Failure modes the agent should avoid

- Treating journeys as one-per-story — they're cross-story paths.
- Using curl with session cookies on browser-authenticated routes.
- Marking a journey "pass" when steps deviated from the plan.
- Writing Wallaby tests for journeys that didn't pass in Phase 2.
- Skipping screenshots in Phase 2 (they're the evidence trail).
- Re-running phases whose artifacts already exist instead of
  honoring the SKIP markers.

## Resources

Required input (per phase):
- Phase 1: stories list (loaded via `Stories.list_stories/1`),
  `qa_journey_plan` document spec (projected via
  `DocumentSpecProjector`).
- Phase 2: the journey plan from Phase 1, `qa_journey_result`
  document spec.
- Phase 3: both Phase 1 and 2 artifacts.

Optional input (read when present):
- `.code_my_spec/qa/plan.md` — QA infrastructure from `qa_setup`.
- `.code_my_spec/architecture/overview.md` — system component graph.
- Existing `test/journeys/*_test.exs` — update rather than duplicate.

Required reading:
- `priv/knowledge/qa_journey/workflow.md` — full three-phase
  procedure, server-prereq checklist, tool-by-pipeline rules,
  Wallaby conventions, anti-patterns.

Produced:
- `.code_my_spec/qa/stories_summary.md` — pre-written by `command/2`
  before the agent runs (full story descriptions + criteria, not
  inlined in the prompt).
- `.code_my_spec/qa/journey_plan.md` (Phase 1).
- `.code_my_spec/qa/journey_result.md` (Phase 2).
- `.code_my_spec/qa/journeys/screenshots/*` — Phase 2 evidence.
- `test/journeys/*_test.exs` — Phase 3.

## Tools

- **MCP browser tools** (Vibium) — required for Phase 2 execution
  against `:browser`-pipeline routes.
- `curl` via Bash — only for `:api`-pipeline routes; use the
  `authenticated_curl.sh` helper from the QA plan when present.

Built-ins (Read, Write, Bash, Glob) handle the rest. No
task-specific MCP tools.

## Dependencies

- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Paths
- CodeMySpec.Stories
