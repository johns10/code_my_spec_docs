# Observability Audit — Internal Agent Operation, Main Agent, Requirements Graph

150 acceptance criteria across 16 stories. A criterion only becomes a spex if
some **real surface** reveals it, because a spex drives surfaces and nothing
else. This audit answers, once and up front, three questions per criterion
group: *what surface observes it*, *does that surface exist*, and *does it
exist under test*.

It exists because the alternative was discovering the answer one criterion at
a time while writing specs — four surprises in the first hour, each costing
about twenty minutes, with 150 criteria to go.

## The surfaces available

| Surface | Where | In test? |
|---|---|---|
| Local LiveViews — requirements, requirements/graph, components, issues, sessions, architecture, knowledge, stories, epics | `CodeMySpecLocalWeb` | yes |
| Cloud LiveViews — `/notifications`, `/questions/:id`, `/accounts/:id/agents`, `/projects/:id/working-copies`, `/projects/:id/agent-conversation` | `CodeMySpecWeb` | yes |
| REST — `/api/projects/:project_name/requirements` and friends | `CodeMySpecLocalWeb` | yes |
| Hook endpoints — `/api/hooks/*` via `post_hook/3` | `CodeMySpecLocalWeb` | yes |
| MCP tools — `get_next_requirement`, `start_task`, `evaluate_task`, … | `LocalServer` | yes |
| Channels — `harness_project:*`, `harness:session:*`, `session:*`, `issues:*` | both | yes |
| **`/dev/*` — including `/dev/state`** | `CodeMySpecWeb` | **NO** |

**`dev_routes: true` is set in `config/dev.exs` only.** Every `/dev` route —
including `/dev/state`, the one surface carrying `GraphWatcher.status` — is
absent under test. A spex written against it gets a 404. This was the first
wall hit and it invalidates the obvious approach to several criteria.

## The load-bearing finding: a wake is visible

Roughly 28 criteria across stories 1047, 1048 and 1050 assert that some agent
was or was not woken. All of them are observable, because
`StopDecision.do_wake/2` finds or creates the agent's conversation and sends
`"Work of your kind is available."` plus the menu.

So **the agent-conversation LiveView is the surface for every wake claim**:
a woken agent has that message, an un-woken one does not. The negative case —
"QA work does not wake the coding agent" — is the absence of that message in
that agent's conversation, which is exactly how the role-scoping stories get
tested.

`wake/2` also declines to wake an agent that is `awaiting_answer?`, which is
directly relevant to the cadence and question stories.

## Criteria by group

| Group | Stories | Count | Surface | Status |
|---|---|---|---|---|
| Agent woken / not woken | 1047, 1048, 1050 | ~28 | agent-conversation LiveView | **observable** |
| Stop-hook menu content | 1047 | ~6 | `post_hook/3` response body | **observable** |
| Questions and answers | 1052, 1053 | ~20 | `/notifications`, `/questions/:id` | **observable** |
| Agent state visibility | 1012 | 14 | `/accounts/:id/agents`, working-copies LiveViews | **mostly** — see gaps |
| Conversation reading | 1013 | 11 | agent-conversation LiveView | **partly** — no query surface |
| Graph state and freshness | 1020, 1021 | ~19 | `/api/.../requirements/graph` (**built for this**) | **observable now** |
| Harness restart | 1051 | 9 | `restart_harness/1` + agent surfaces | **observable** |
| Machinery health | 1015 | 10 | none | **gap** |
| Main agent actions | 1014, 1016, 1018 | ~27 | none yet | **blocked on the feature** |
| Cadence | 1017 | 9 | none yet | **blocked on the feature** |

## Gaps, and what to do about each

**1. Graph freshness had no surface — now it does.** `RequirementsController.index`
calls `compute_all/1`, recomputing on every request, so it can never show cache
behaviour. `RequirementsLive` discards `computed_at`. `/dev/state` is dev-only.
Added `GET /api/projects/:project_name/requirements/graph` returning the
**cached** graph plus `computed_at` and watcher status (`watching`, `pending`,
`last_recompute`). It deliberately does not settle first: a caller checking
whether a write moved the graph must see the state as it stands.

**2. Machinery health has no surface at all.** Story 1015's ten criteria need
harness liveness, tool-surface health, analyzer health and machine load. None
is exposed anywhere a test can reach. This needs building, and it is a product
gap as much as a testing one — it is exactly the information that was missing
during the 2026-09-11 outage, when a toolless agent was indistinguishable from
an idle one for four hours.

**3. Conversation querying has no surface.** Story 1013 wants the last N turns,
a time range, and a token-limited result. The agent-conversation LiveView shows
a conversation; it does not answer questions about one. This is the query
surface that story specifies, so it is the story's own build work rather than a
prerequisite.

**4. Main agent surfaces do not exist because the main agent does not.** Stories
1014, 1016, 1017 and 1018 — about 36 criteria — describe behaviour of a feature
not yet built. Their spex are written against surfaces that arrive with the
feature. Expected, and not a blocker to sequencing: they come last for this
reason.

## Criteria rewritten because they were unobservable in principle

Story 1021 had four criteria asserting internal mechanics. Three were rewritten
as their observable consequences and one was deleted:

- *"the graph is not recomputed on every heartbeat"* → **a heartbeat changes
  nothing anyone can see**: same answer on the graph surface, nobody woken.
- *"only the requirements that story's attempt bears on are recomputed"* →
  **one story's attempt moves that story and leaves the others**.
- *"no domain event is published"* → **a heartbeat wakes nobody**.
- *"a writer that does not publish leaves the graph wrong, and nothing reveals
  it"* → **deleted**. It described a known cost, not something an
  implementation can satisfy; the positive guard is criterion 3235.

The general rule this establishes: **a criterion asserting an internal property
should be rewritten as the consequence that makes the property worth having.**
"Not recomputed" only matters because of what it prevents, and what it prevents
is observable.

## Incidental findings

Things noticed while auditing, none of them QA work:

- **`find_entity_node/4` recomputes the whole graph to find one node**
  (`requirements_live.ex:821`), on a page that reads the cache everywhere else.
- **Several MCP tools call `compute_all/1` per invocation** — `start_task`,
  `show_requirement`, `show_component_requirements`, `skill_router` — paying a
  full graph computation on every call rather than reading the cache.
- **`StopDecision.wake/2` rescues and logs at warning**, the same
  paper-over shape as `GraphWatcher.recompute/1`. Both are at odds with the
  project's stated position that failures are raised loudly so they become
  issues that get fixed.
- **`mix spex <path>` runs the entire suite** (1,192 tests, ~142s). `--pattern`
  is the filter, and it does not match on criterion filename.
