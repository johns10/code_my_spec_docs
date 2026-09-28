# QA Result — Story 1063/1021: A cached graph is never served after its inputs have moved

Re-test pass, scoped to the criteria the prior attempt (which recorded `partial`)
could not verify: cache-hit vs recompute on the requirements graph provenance
strip, project/checkout isolation of the cached graph, and the no-watcher case.
Out of scope (already passed previously, not retested): story release behavior,
QA-attempt scoping, second-identical-failure chaining, file classification.

**Status: pass** (all three targeted scenarios verified against the live :4000
surface via a real authenticated browser session; no defects found)

**IMPORTANT — submission gap:** `mcp__plugin_codemyspec_local__submit_qa_result`
and `mcp__plugin_codemyspec_local__create_issue` were not present in this
session's tool list (confirmed by direct invocation — both returned
`No such tool available`; `ToolSearch` was also disabled). This result was
therefore never filed as the canonical DB attempt. See the parent-agent report
for what to do about it.

## Tool

`web` — real browser session, established via the `vibium` CLI binary
(`/opt/homebrew/bin/vibium`) invoked through Bash rather than the
`mcp__vibium__*` MCP wrapper, which was also absent from this session's tool
list. Same underlying browser automation, same evidentiary value.

## Auth

Logged in as `qa@codemyspec.local` via the real magic-link flow at
`http://127.0.0.1:4000/users/log-in` → `http://127.0.0.1:4000/dev/mailbox` →
followed the emailed link (rewritten from `dev.codemyspec.com` to
`127.0.0.1:4000`). Session persisted in a named vibium daemon (`--session qa1063`)
for the rest of the run.

Note (qa scope): `vibium fill` / `vibium type` both failed with
`element not found` / `waiting for element` against the login page's real
`user[email]` input (confirmed actionable via `vibium is actionable` — visible,
stable, enabled, editable, all true) in both headless and headed mode. Worked
around by focusing the field with `vibium click` and typing one character at a
time with `vibium keys`. Filed as a QA-scope observation below (would be
`create_issue` scope:qa if the tool were reachable).

## Seeds / fixtures

No new seed scripts run. Used existing fixture projects already visible to
`qa@codemyspec.local`:

- **QA Fixture Project** (`11111111-1111-4111-8111-111111111111`) — no
  continuous agent, no `GraphWatcher`. Invalidated deliberately by editing
  `.code_my_spec/spec/qa_calculator.spec.md` in its sandbox working copy
  (`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`,
  harness id `1fc425f5-7b88-4e32-86a3-c16c3317408c`) — the sandbox's file
  watcher auto-synced each edit within a few seconds (confirmed via
  `~/.codemyspec/web.log` `[FileSync]`/`[HarnessProject]` lines). Reverted to
  original content at the end of the session; fingerprint back to
  `4c377df0...`, matching pre-QA state.
- **QA 963 Fresh** (`688de1a4-72eb-4a2a-b312-3a0e8ee63a71`) — idle, no watcher,
  used untouched as the isolation control.
- **Broken Oaths** (`49760b8b-6472-41e2-b05d-c5c97acaee99`) — has 6 continuous
  agents and a live `GraphWatcher` (confirmed via `GET /dev/state?project_id=...`
  showing `"graph_watcher":{"watching":true,...}`), used read-only to observe
  the watcher-present case.

## Scenarios

### 1. Cache hit vs recompute — PASS

Steps (QA Fixture Project graph, `/app/projects/11111111.../requirements/graph`):

1. First load after editing the sandbox spec file → `data-served-from="computed"`,
   text "computed just now", `graph-computed-at` = `2026-09-11T22:38:07.414360Z`,
   252 requirements. Screenshot: `qa1111_graph_1_computed.png`.
2. Immediate reload, no changes → `data-served-from="cache"`, text "from cache",
   `graph-computed-at` = `2026-09-11T22:38:07.229125Z` (same instant as #1 —
   see note below), still 252 requirements. Screenshot: `qa1111_graph_2_cache.png`.
3. Edited the sandbox spec file again (new comment) → waited for the harness
   file-watcher + `[FileSync]`/`[HarnessProject]` reconcile in `web.log` →
   reload → `data-served-from="computed"`, `graph-computed-at` advanced to
   `2026-09-11T22:41:27.638829Z`, still 252 requirements (content-only change).
   Screenshot: `qa1111_graph_3_recomputed.png`.
4. Reload again, no further changes → `data-served-from="cache"`,
   `graph-computed-at` = `2026-09-11T22:41:27.589486Z` (same instant as #3),
   stayed there on repeat. Screenshot: `qa1111_graph_4_cache_stable.png`.

Confirmed directly in Postgres (`requirement_graphs` table) that the row for
`project_id=11111111... AND working_copy_id IS NULL` (the UI's blended-vantage
row) moved from `computed_at=2026-09-11 21:...` (stale, pre-session) to
`22:38:07.229125` (step 1) to `22:41:27.589486` (step 3) — matching exactly
what the DOM's cache-hit reads reported.

**Observation (INFO, not a defect):** the timestamp shown on the very first
"computed just now" response (`.414360Z`) is not byte-identical to what the
*same* computation shows on the next "from cache" read (`.229125Z`) — a
185ms/49ms gap in the two runs observed. This is because
`RequirementGraph.cached_graph_with_actionable_metrics/1` stamps the
DB-persisted `computed_at` at publish time (inside `compute_and_publish`),
then stamps a *second*, later `DateTime.utc_now()` for the metrics shown on
that same fresh-compute response (after `actionable_from/3` and
`verify_round_trip/4` finish). Both read as "just now" to a human; this is
not visible as a functional problem and doesn't affect the pass/fail behavior
the story cares about, so not filed as an issue — noting it here in case
exact timestamp equality ever becomes a requirement.

### 2. Isolation between projects/checkouts — PASS

- QA Fixture Project (252 requirements) and QA 963 Fresh (14 requirements)
  show completely distinct node counts and independent provenance — no
  cross-project bleed in the DOM.
- Loaded QA 963 Fresh once (`data-served-from="computed"`,
  `graph-computed-at=2026-09-11T22:40:05.993118Z`), reloaded
  (`"cache"`, `.981294Z`). Screenshot: `qa963fresh_1_computed.png`.
- Deliberately invalidated **QA Fixture Project** (scenario 1, step 3) in
  between, then reloaded **QA 963 Fresh** again: still `data-served-from="cache"`,
  `graph-computed-at` unchanged at `.981294Z` (identical to the pre-invalidation
  read), 14 requirements unchanged. Screenshot: `qa963fresh_isolation_check.png`.
  Invalidating one project's cache had zero observable effect on the other's.
- Confirmed at the data layer too: `requirement_graphs` carries one row per
  `(project_id, working_copy_id)`. The sandbox harness's own per-checkout row
  (`working_copy_id=1fc425f5-...`, last published `2026-09-11 21:32:43`) was
  untouched throughout — only the UI's separate `working_copy_id IS NULL` row
  moved as I reloaded the web page. Two independent rows for the same project,
  confirming the checkout-vs-checkout isolation the story's other criteria
  (heartbeat/cross-copy) describe, from the data side rather than a live
  channel join (which remains out of reach for curl/QA per the prior attempt's
  code-review finding — not retested here, unchanged conclusion).

### 3. No-watcher case — PASS

- QA Fixture Project and QA 963 Fresh (neither has a continuous agent) both
  render: `<span data-test="graph-watcher" class="text-warning">no watcher —
  this graph only moves when somebody reads it</span>` — no
  `graph-watcher-error` span present. Confirmed via `vibium html` on the raw
  DOM, not just the rendered screenshot text.
- Broken Oaths (6 continuous agents, live `GraphWatcher` confirmed via
  `/dev/state`) instead renders `<span data-test="graph-watcher">watcher
  idle</span>` — the positive case, correctly distinguished from the
  no-watcher case. Screenshot: `broken_oaths_watcher_idle.png`.
- `graph-watcher-error` was not observed in either direction — reaching it
  requires a live watcher whose last recompute raised, which nothing in this
  session's fixtures forced and manufacturing one was judged disproportionate
  for this pass (would need to break a real project's inputs mid-recompute).
  Not filed as a gap since the code path (`recompute_failure/2` in
  `GraphWatcher`, tested by `graph_watcher_test.exs` per source reading) is
  unit-level covered; just noting it wasn't exercised live here.

## Evidence

Screenshots in
`.code_my_spec/qa/1021/screenshots/`:

- `qa1111_graph_1_computed.png`, `qa1111_graph_2_cache.png`,
  `qa1111_graph_3_recomputed.png`, `qa1111_graph_4_cache_stable.png` —
  QA Fixture Project cache-hit/recompute cycle.
- `qa963fresh_1_computed.png`, `qa963fresh_isolation_check.png` —
  isolation control project, before/after QA Fixture Project's invalidation.
- `broken_oaths_watcher_idle.png` — watcher-present case.

## Issues

None filed — no defects found in the surface tested. (Would have used
`create_issue` with `scope: qa` for the `vibium fill`/`type` tooling gap
noted under Auth above, had the tool been reachable in this session.)
