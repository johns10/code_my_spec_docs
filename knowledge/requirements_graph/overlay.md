# The copy overlay

Status: design, for review (2026-10-30). Step 4 of the topology/overlay plan.

A copy's graph is three things: the project's **topology** (nodes and edges,
records only, `requirement_topologies`), the project's **record verdicts**
(`project_requirements`), and the copy's **overlay**: what only that copy's
machine can know, reported by its harness. Readiness is computed on read from
the three. Nothing else is kept per copy.

## What the overlay carries

| fact | today | overlay |
|---|---|---|
| file verdicts: `implementation_file` (per component), `bdd_specs_exist` (per story), `technical_strategy`, `code_generation`, `qa_journey_execute`, `spex_boundary_ready`, `architecture_designed`, `qa_integration_plan` | server computes per copy from synced File rows, stores a row per node per copy | harness computes from its own scan, reports `{entity, name, satisfied, details}` |
| HEAD | only the main copy's, as `project.head_commit` | every copy's `head` |
| behind main | not kept; the promote gate runs git live | `behind`: commits between HEAD and the remote main as last fetched, the "pull first" signal |
| dirty | not kept | `dirty`: uncommitted changes, so "pull first" can say why it cannot |
| which read model the verdicts answer | none | `read_model`: the fingerprint of the records the harness was handed |

The file **inventory** stays as it is: the manifest the harness already sends
on every scan becomes File rows (`FileSync`), which other features read (Files
UI, `DeployBoilerplate`, architecture, setup). The overlay is the verdicts drawn
from that inventory, not a second copy of it.

Not in the overlay, because they are records, not files: the three
placement-filtered gates (`issues_triaged`, `issues_resolved`,
`work_dispatched`). They differ per copy only because a copy leaves out issues
on stories placed elsewhere (`IssuesRepository.exclude_other_copies_stories/2`).
The server computes them per copy and stores them beside the overlay
(`copy_gates`), written by the projector on issue and story events: three
values per copy, not a projection.

## When the harness sends it

After each scan, with the manifest it already delivers (`CmsHarness.Sync.run/2`),
as one `"overlay"` message: `%{version, read_model, head, behind, dirty,
verdicts: [[type, id, name, satisfied, details]]}`. Details only for
unsatisfied verdicts. About 1,650 verdicts on the largest project.

Also when the read model moves without a scan: the server bumps the read-model
fingerprint when records a file verdict reads change (criteria, components,
stories, the proposal's referents), and the harness, which already refreshes
the read model on a timer and on request, recomputes from its last scan and
reports. No rescan.

The verdicts run the same checker code on both sides. Each file check takes
`(entity, files, records slice)` and no database: the harness builds the slice
from its scan and an extended `Files.Scanner.ReadModel` (criteria by story,
component types and module names, story numbers, context names, whether a
component is authored, the app name). Today three checks still reach the
database and are made pure first: `bdd_specs_covered` (criteria),
`SpexBoundaryChecker` (paths), `QaIntegrationPlanChecker` (files).

## How the server stores it

One row per copy, `copy_overlays`: `working_copy_id` (primary key, references
working_copies, delete_all), `project_id`, `read_model`, `head`, `behind`,
`dirty`, `verdicts` (compressed term, like the topology), `gates` (the three
server-computed gates), `reported_at`. Replaced whole on each report. No
per-node rows.

The `nil` vantage (readers with no copy) reads the default copy's overlay, as
it reads that copy's files today. A project with no default copy has no file
overlay at `nil`: its file verdicts read as unsatisfied, "no checkout has
reported files" (today `nil` blends every copy's files; John to confirm).

## Readiness on read

For copy C: nodes = the topology's nodes for the entities C sees (ready stories
placed with C or nowhere, their issues, every component, the project); each
verdict from the record verdicts, C's overlay, or C's gates; a node C's overlay
does not name (a component created since its last report) reads unsatisfied,
"awaiting this copy's report". Edges = the topology's among those nodes.
`actionable_from` over the result: measured 7-33 ms on the largest project.

A copy whose harness is offline keeps its last overlay: stale, never half. The
overlay is replaced in one write, and the topology and record verdicts each in
one, so a reader never sees a partial copy.

## Shadow (before cut-over)

The harness sends the overlay; the server stores it and, once the drain that
consumed that copy's manifest has settled, compares each verdict with its own
per-copy row (`Verification` normalization). It logs the mismatch count and
samples per report, and keeps the last count on the row. Nothing reads the
overlay. Cut-over when every live copy of the dev project has reported with 0
mismatches for N days, plus the equivalence script: readiness from the new read
path against today's rows on the real dev project, every copy, 0 diffs.

## What cut-over deletes

- `requirements` per-copy rows (table dropped after one release) and every path
  that only served them: `GraphStore` per-copy `write`, `put_verdict(s)`/`sweep`
  for file names, `projected?`, `definitions_covered?`, `incomplete_entities`,
  `reap_unseen`, `clear`, `rows_at`; `Projection.load`'s union and `vantages/1`.
- The per-vantage projector: `IncrementalGraph`'s vantage loop
  (`vantages/2`, `settle_vantages/5`, `settle_vantage/5`, `about?/3`, settled
  kinds), seeding per vantage (`run(:everything)` per copy, `established/3`),
  `baseline/2`, `reproject_topology/2` per vantage, `last_topology`, per-vantage
  shape.
- Dormancy (4-lite): `live_vantages/3`'s awake rule, `leave_behind/2`, wake
  marks. A copy's overlay is whatever its harness last reported.
- The file half of `Handlers`/`Profiles`: the `:files` profile and the
  `settle/3` clauses for the eight file names; `files_synced` stops being a
  graph event (it still syncs File rows).
- Per-copy readers rewritten onto the read path: `Bands`,
  `NodeRepository.requirement_details/3`, `StoryGraph.read_progress/2`,
  `GraphReport`, `served_vs_recomputed`, `VantageReport`, `IncrementalReport`.

What stays on the server: the topology, record verdicts, the three gates per
copy, File rows, and readiness.
