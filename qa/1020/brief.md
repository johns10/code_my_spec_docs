# Qa Story Brief

Story 1062 (internal id 1020): "The graph recomputes as observations arrive." Component: `CodeMySpec.Requirements` — specifically `GraphWatcher`, `GraphInputs`, and the diagnostic surfaces that expose their state.

## Tool

Vibium browser (LiveView provenance strip) — **revised after execution.** The plan originally targeted `GET /api/projects/:project_name/requirements/graph` on port 4004 (`CodeMySpecLocalWeb.RequirementsController.graph/2`) as a curl-able diagnostic surface. In this environment port 4004 is served by the lightweight `cms harness` process, not a full `mix phx.server` `CodeMySpecLocalWeb` — confirmed via `GET /health` on 4004 (returns the harness's own project-registry JSON, `build_drift` field, no `CodeMySpecLocalWeb` router at all) and a 404 on that path with the harness's own not-found body ("The CodeMySpec harness failed to handle this hook... This is the local harness process, not the CodeMySpec server."), not `ProjectScope`'s plain-text 404. So that endpoint is unreachable here — infra limitation, not a story defect. The LiveView provenance strip on port 4000 (confirmed real `mix phx.server`, per `web.log` boot lines) is this session's only usable external surface for this story.

This story's real mechanism is a per-project GenServer (`GraphWatcher`) with no direct route of its own. Everything about it besides the provenance strip (debounce timing, PubSub payload shape, which agent process reacts) is GenServer/process internals with no honest QA surface — per this project's own QA plan, those stay spex-covered rather than forced through a fake surface.

## Auth

**Local app (port 4004), the diagnostic endpoint — no auth beyond loopback:**
```
curl -s http://127.0.0.1:4004/api/projects/708492f9-454e-482f-a2eb-be64f0356b87/requirements/graph
```
`LocalOnly` accepts the loopback IP directly; `ProjectScope` resolves the project from the `:project_name` path param (this project's id: `708492f9-454e-482f-a2eb-be64f0356b87`).

**Hosted app (port 4000), for the LiveView provenance strip — magic-link login:**
1. Vibium: `browser_navigate` to `http://127.0.0.1:4000/users/log-in`, fill `user[email]` with `qa@codemyspec.local`, click "Email me a login link".
2. `browser_navigate` to `http://127.0.0.1:4000/dev/mailbox`, grab the token, visit `http://127.0.0.1:4000/users/log-in/:token` (rewrite origin from `dev.codemyspec.com` if the link uses it).
3. Then navigate to `http://127.0.0.1:4000/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/requirements/graph`.

**Filing findings / triggering graph inputs — via `create_issue` (run_script, since it's not in this session's direct MCP tool list):**
```lua
create_issue({ title = "...", description = "...", severity = "info", scope = "app", story_id = 1020 })
```
This is also the mechanism used to *exercise* several criteria: `Issues.create_issue` is one of only three writers that call `GraphInputs.changed/1` (the others are `Qa.QaAttempts.submit_qa_result` and `Files.FileSync`), so filing an issue is the cheapest real, honest way to produce a graph-input event on this live project.

## Seeds

None needed — this brief tests against the real, already-seeded Code My Spec project (id `708492f9-454e-482f-a2eb-be64f0356b87`), not the QA fixture/sandbox project. This story's mechanism (GraphWatcher, GraphInputs) is project-wide infrastructure, not a per-story fixture; running it against the sandbox would prove nothing about the project the watcher actually watches, and per the QA plan the sandbox swap is only required for MCP-mutation isolation tests, not for read-only/diagnostic probing of live infra.

Confirm which build `:4000` is serving before and after this run:
```
grep '\[Boot\] serving' ~/.codemyspec/web.log | tail -1
```

## What To Test

Values below (`node_count`, exact wait times) are illustrative; read the actual response.

- **Criterion 3242 — work becomes available while nobody is looking.** GET the diagnostic endpoint, note `computed_at`. File one `create_issue` (scope app, story_id 1020, severity info, describing a real/trivial observation). Wait ~3s (past the 2s debounce). GET again — `computed_at` must have advanced with nobody having read in between.
- **Criterion 3244 — many writes at once cost one update.** File 4-5 issues back to back with no waits. Wait ~3s. GET the endpoint twice in a row — both reads must report the identical `computed_at` (one recompute for the whole burst, not one per issue).
- **Criterion 3246 — a reader never sees an answer older than the observations in hand.** File one issue, then GET the endpoint *immediately* (no wait). `computed_at` must already reflect the write — a reader forces its own settle rather than reading a stale cached value while the debounce timer is still ticking.
- **Criterion 3247 — the collection window does not delay anybody who asks.** Same as 3246: measure wall-clock time of the immediate GET. It must return promptly (not block for the ~2s debounce window) — this is the same reader-forces-settle path, so treat this and 3246 as one live check with two properties to note (correctness of the answer, and that it didn't block).
- **Criterion 3351 — a steady stream still gets a pass.** File an issue, wait ~3s, GET (expect new `computed_at`); file another issue, wait ~3s, GET again (expect a second, further-advanced `computed_at`). Confirms the debounce is coalescing, not a one-shot latch that stops recomputing after the first pass.
- **Criterion 3353 — a read with nothing pending does not force a recompute.** With no writes in flight, GET the endpoint 3 times a few seconds apart. `computed_at` must stay identical across all three (an idle read is a cache hit, `served_from: "cache"`, not a forced recompute).
- **Criterion 3354 — two reads inside one window cost one recompute.** File one issue, wait ~3s (past debounce), then GET twice in immediate succession. Both must report the same `computed_at` (the second read hits the now-published cache, not a second recompute).
- **Criterion 3303 — a recompute that succeeds passes without noise.** Around the same event used for 3242, grep `~/.codemyspec/web.log` for `[GraphWatcher]` in that time window. A clean recompute should log nothing at `:error`/`:warning` — only a genuine fault logs (per `graph_watcher.ex`'s `recompute_failure/2`).
- **Criteria 3243 / 3249 / 3250 — an idle agent is woken, and only the right one.** These need a live in-loop agent on this project (the watcher is only started via `Agents.wake_project_roles/2`'s call sites, not on LiveView mount — check `GraphWatcher.status/1`'s `watching: true`/`false` on the diagnostic endpoint first to confirm a watcher is actually running before relying on wake behavior). If a watcher is running and an idle agent exists: file an issue, wait past debounce, then check that agent's own per-agent conversation page (not the conversation index/list, which shows rows without message text) for "Work of your kind is available." If no watcher is running for this project right now, or no idle in-loop agent is available to observe, record these as **not exercised this session** rather than guessing — do not treat "watcher not running" itself as a defect (ensure_watching is intentionally on-demand).
- **Criteria 3245 / 3355 — the announcement (PubSub `{:graph_updated, project_id}`, "no extra fields").** No external surface exists today — nothing in the codebase subscribes to this topic outside internal processes (confirmed: the requirements LiveView does not). Record both as **spex-covered, no external surface** — do not force a fake check.
- **Criterion 3352 — one project's burst does not collapse into another's.** No safe live surface: it would require writing to a second real project concurrently, which either pollutes real data or requires infra this brief doesn't have time to stand up. Record as **spex-covered, no external surface for this session**.
- **LiveView provenance strip (secondary, cross-checks the diagnostic endpoint):** on `/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/requirements/graph`, check `[data-test="graph-provenance"]`'s `data-served-from`, and the child spans `[data-test="graph-served-from"]`, `[data-test="graph-computed-at"]` (title attr = ISO timestamp), `[data-test="graph-watcher"]` (idle/pending/no-watcher text), `[data-test="graph-watcher-error"]` (only present on a real fault). Screenshot before and after triggering a recompute. Note: an existing filed issue (`3f169de1`, still status "incoming") claims this page always full-recomputes and has no provenance — current source (`graph_projector.ex` calling `Requirements.project_graph_with_actionable_metrics/1` → the cached path) looks like this was already fixed; confirm live and say so either way rather than re-filing blind.

## Result Path

`.code_my_spec/qa/1020/` — screenshots to `.code_my_spec/qa/1020/screenshots/` (copied from `~/Pictures/Vibium/` per the known Vibium screenshot-path caveat). No result.md — findings go through `create_issue`, and the run ends with one `submit_qa_result` call listing every issue id filed.

## Setup Notes

- Existing issues already filed against story 1020 — do not refile: `3f169de1` (graph LiveView bypassed cache, likely already fixed — confirm live), `735b5172` (known gap: stories/criteria/personas/deploys don't call `GraphInputs.changed`), `3ad5e45c` (criterion 3248 has no fault seam; that criterion's spex was removed and criterion 3248 no longer appears in this story's live acceptance-criteria list). Related, filed against a different story: `d8c5d193` (same input-wiring gap, framework scope).
- `:4000`/`:4004` share one BEAM release — a build promotion affects both. Confirmed build drift mid-QA-prep: `2b8993724` → `d32d27e85` at `2026-09-11T23:08:31Z`. Re-check the build line before recording final results; if it moves again during execution, say so in the submitted result rather than silently reporting against a build that's no longer live.
- Never target the QA sandbox project for this story — it would test a watcher for a project nobody is actually using, proving nothing about the real mechanism.
