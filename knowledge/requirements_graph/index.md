# The requirement graph

How the graph that tells every agent what to work on is written, read and kept
current — the design behind `lib/code_my_spec/requirements*`, and the lessons
that shaped it. Code comments point here by section name. The checkers,
definitions, preloading and the contexts the graph reads are in
[checkers.md](checkers.md).

| Module | Role |
|---|---|
| `Requirements.IncrementalGraph` | One process per project; the only writer. Drains marks, settles verdicts, redraws edges. |
| `Requirements.GraphStore` | Writes and reads the rows: `requirements`, `requirement_edges`. |
| `Requirements.RequirementGraph` | Pure: computes nodes and edges, ranks actionable work. Writes nothing. |
| `Requirements.Handlers` | Settles requirements an event moved, from loaded profiles, without recomputing. |
| `Requirements.GraphWatcher` | The front callers use to start and settle the writer. |
| `Requirements` | The context's public surface. |

## Writers and readers

- **One writer.** An `IncrementalGraph` process per project (Registry key
  `{project_id, :graph}`, under `WatcherSupervisor`, `restart: :transient`)
  writes `requirements` / `requirement_edges` through `GraphStore`. Writers
  start with an agent, at boot for continuous projects, and on the first read of
  a project that has no rows.
- **Reads never recompute.** A reader settles the writer at its vantage
  (`IncrementalGraph.settle/2`: drain what is pending, consider the asked-about
  checkouts) and then reads the rows (`Projection.load/2`). It waits for
  observations already announced; it never re-derives what nobody announced.
  A read costs a preload (tens of ms); a compute costs seconds on a large
  project. `settle: false` exists so a test can see an unannounced write still
  missing.
- **A read starts the writer only for a project with no rows.** "Never
  projected" means no project-level rows — every seed writes them, so their
  absence holds at any vantage. The bound stops a read from resurrecting a
  projector a test's teardown stopped. Zero rows must never read as "All
  requirements satisfied".
- **Announcing.** A drain that consumed marks broadcasts
  `{:graph_updated, project_id}` on `GraphInputs.topic/1` (readers refresh) and
  emits `[:code_my_spec, :requirements, :graph_changed]`, which `Agents.GraphWake`
  answers by starting agent wakes off the projector's process. A drain that
  consumed nothing announces nothing.
- **Row writes.** `GraphStore.write/3` replaces what one computation covered;
  `put_verdict/2` / `put_verdicts/5` move verdicts a handler already knows;
  `sweep/2` settles one requirement across every owner of a type;
  `write_edges/3` writes an edge set as a difference. Inserts are chunked by the
  65,535-parameter limit divided by the row's measured width.
- **Audit.** `served_vs_recomputed/1` recomputes the whole project once on
  demand and compares it with the served rows, edges and per-role actionable
  sets. It writes nothing. `compute_graph_with_actionable_metrics/1` recomputes
  on purpose, to time a compute.
- **Small readers.** `open_reason/3` reads one row and computes nothing (its
  caller is the stop hook; a stop is not a change). `satisfied_now?/2` re-checks
  a story requirement against the story before `start_task` takes it, because
  the graph can lag an unannounced write.

## Vantages

- **A verdict is a statement about a checkout.** The graph is projected per
  vantage — a working copy id, or `nil` — and a row's `working_copy_id` is its
  vantage. `vantage_report/1` lays the checkouts side by side; routing bugs are
  often invisible from any single one.
- **The `nil` vantage** is the row-space for readers with no checkout, computed
  from the project's default checkout's files (`Preloader.files_vantage/1`), or
  every checkout's when there is none. It is shared by all projects, so every
  query over it needs a project predicate, and filters use `is_nil` /
  `IS NOT DISTINCT FROM`, never `= NULL`.
- **`normalize_vantage/1`** resolves the vantage once, before `Preloader.load/1`
  sees the scope. Without it a caller naming no checkout computes from every
  checkout's files blended while storing under the default checkout's identity.
- **A `nil` mark** is a change that is not about a checkout (a story renamed, an
  issue accepted). It is the only case that fans out to every vantage; looping
  every vantage on every drain would be the whole-project recompute this design
  avoids. A file sync moves the `nil` vantage only when it happens in the
  default checkout.
- **Requested vantages** (from `settle` callers, plus the starter's own) are
  considered in the next drain even when no mark names them, then forgotten.
  Considered is not recomputed: an established vantage with nothing pending
  costs nothing.
- **Per-vantage state.** The edge baseline (`last_topology`) and handler
  hit/miss counts are kept per vantage: one slot would answer one checkout's
  question with another's, and summing hides a miss in one worktree behind a
  hit in another.

## Marks and drains

- **Marks** (`Invalidations`) name what a writer moved. The projector has no
  timer: a mark that arrives is drained. Marks arriving in groups is a consumer
  catching up.
- **Drain order.** Events with handlers are applied first — one row per
  verdict, no recompute. The rest go to `plan/2`, which decides what to load
  before loading: `:everything` when a writer could not say what it moved or
  the projector has not seeded; otherwise `{:narrow, entities}` (adding the
  project when project requirements moved). Narrow loads are `load_story`,
  `load_component_family`, `load_project`; `Preloader.load/1` is never reached
  on the narrow path.
- **The unit of work is `compute_entity/4`.** `reduce_to/2` narrows only the
  lists and keeps the by-id maps whole, so an entity computed alone answers
  exactly as it would in a larger set. A component's unit is its family: a
  child narrowed alone reads as top-level and runs a different template, and
  about half of all components are nested. Project nodes always take the whole
  context, because their checkers count across the project.
- **Consume after writing.** Marks are deleted only once the writes they
  describe are durable. A drain that raises leaves them queued for the next one;
  a projector that cannot keep up shows as a growing pending count.
- **Costs.** The common case — seeded, nothing pending — is one query.
  `DrainCost` reports each drain's queries, rows written and `handled` vs
  `recomputed`, so a drain that fell back is visible as one. The dev fault
  `graph_recompute_fails` makes a drain raise.

## Seeding

- **On start a projector establishes every vantage.** A vantage with rows is
  trusted: rows and the mark queue are durable, and files, which have no row,
  are rescanned by the harness on reconnect and arrive as `files_synced`. A
  vantage with no rows is seeded whole. The seed runs from a message to itself,
  not in `init/1`, which blocks the supervisor.
- **Trusted means covered.** A vantage counts as established only if this
  process has seen it, or its rows cover every current definition
  (`GraphStore.definitions_covered?/2` against `RequirementGraph.defined_names/2`).
  Handlers settle rows and never create them, so a release that adds or removes
  a requirement needs a reseed. `clear/1` and `reproject/2` force one.
- **An unseeded projector computes even with no marks.** It has to establish
  what is true before deltas mean anything.
- **A seed computes once and writes once** (`compute_nodes`), drawing edges once
  for every vantage of the project. Per-entity compute-and-write made a no-op
  seed tens of thousands of queries.

## Edges

- **Four kinds:** same-entity prerequisites; `project.qa_setup →
  story.component_linked`; story ↔ component tree (kickoff `bdd_specs_exist →`
  first work item, exit `→ ready_for_qa`); `story.qa_complete →
  project.qa_journey_plan` (the fan-in `GraphProjector` lays out on).
- **Edges are global.** They end in `Topology.transitive_reduction/1`, so they
  cannot be computed per entity. They are a function of the node set, never of
  a verdict: a drain that only swept cannot move them.
- **When to redraw.** A vantage met with rows already there is redrawn once per
  process — a release that moves a prerequisite moves edges and no row. After
  that, only when the shape moved (`Freshness.topology/2`) *or* a write inserted
  or reaped a row; a story can appear in the shape one drain before its rows
  exist.
- **Stored by row id**, upserted then reaped, never deleted and reinserted: a
  reinserted row gets a new id and orphans every edge on it. Edge identity is
  `{from_requirement_id, to_requirement_id}`; an endpoint with no row is dropped.
- **Written as a difference.** The wanted set is whole (a reduction is global);
  the write deletes stale ids and inserts new ones. A full rewrite was most of
  all write volume.
- **Closure rules.** Kickoff spans the story's surface and its transitive
  dependency closure; a context brings only its direct children. A
  `:discovered` component with no file on this checkout is a phantom from
  another checkout: kept while referenced, excluded from kickoff and children.
  `:authored` components are never filtered. A filtered-out prerequisite is
  walked past to its nearest surviving ancestor.

## Verdicts and handlers

- **Satisfaction is local.** A node's `satisfied` is its own check, never
  changed by graph context. Gating happens in `actionable_from/3`; per role, a
  block travels only within the same entity or the same role, so another role's
  prerequisite orders work without hiding it.
- **Handlers settle from profiles.** An event loads the profiles its kind
  dirties once, and each handler settles its requirement across every entity at
  once — one default write for the population, then the exceptions. Population
  size does not change the query count. The exceptions side is whichever side
  carries per-entity detail (an `expected_path`, `validation_errors`).
- **`{:ok, []}` is not `:no_handler`.** An event that moved nothing the graph
  reads is an answer; `:no_handler` means "unknown, re-derive". Handling a kind
  drops its fallback marks; `@partial` kinds keep them.
- **Delegate requirements** (`architecture_designed`, `personas_complete`,
  `spex_boundary_ready`, `qa_integration_plan`, `stories_exist`,
  `work_dispatched`) carry verdicts no event does, so they are settled by
  calling the requirement's own checker once — a recompute narrowed to one
  requirement.
- **A handler-settled row reads exactly like a recompute-settled one**
  (`Requirement.normalize_details/1`). Unchanged rows are never rewritten
  (`IS DISTINCT FROM`), so `computed_at` holds still when nothing changed.
- **Sweeps are one transaction per event**, so a reader never sees a new
  default beside stale exceptions. A handler change that matched no row is
  logged: the event named an entity this vantage never projected.
- **Ranking.** Tier 0 project requirements, tier 1 story/component work by story
  rank (priority, then age), tier 2 the QA journey; within a story, deeper in
  the chain sorts first. `deploy` exists only when devops is on.

## Tests and the sandbox

- **Allowance.** A per-project process takes its sandbox allowance in `init/1`
  from its starter's whole caller chain (`Repo.SandboxAllowance.owners/0`), and
  each reader re-grants. A Task reaches the sandbox only through `$callers`, so
  granting from the Task alone fails silently.
- **A projector whose test ended stops normally** (`owner_gone`), never crashes:
  a crash is restarted into the same dead sandbox, and enough crashes trip
  `WatcherSupervisor`'s restart intensity and take every project's projector
  down. `sandbox_gone?/1` matches every checkout exit shape a finished test
  leaves; outside the sandbox those are real faults.
- **`settle` over a dead projector** raises under the sandbox (kill, crash,
  timeout) with the cause; a normal stop or an already-gone projector — a test
  that ended, read by a task it left running — is only logged.
- **`trap_exit`** lets a supervisor's shutdown wait for the drain in flight;
  dying mid-transaction takes a shared sandbox connection down.
- **Teardown is per project.** `Fixtures.stop_watching/1` stops one project's
  writer. `stop_graph_watchers/0` stops every project's and is only for sync
  tests.

## Lessons

- **Never answer success for a call that did not complete.** `settle` answering
  `:ok` over a dead projector made a killed projector read as an empty graph,
  and a test-isolation bug hid behind "the graph is flaky".
- **Anything that touches every project's process breaks concurrent tests** —
  stopping all children of a shared supervisor, node-wide telemetry or PubSub
  handlers. Scope teardown and handlers to the test's own project.
- **A read must never repair the graph.** When reads re-derived, a writer that
  announced nothing looked identical to one that worked, and specs passed
  against silent writers.
- **An event kind is handled only when everything it can move is settled.**
  Handling drops the fallback marks, so an unsettled requirement keeps a stale
  verdict forever — seen when sealing a story moved `three_amigos_complete` with
  no handler, and when `questions_answered` had a profile but no settle clause.
- **A requirement whose meaning can change takes its verdict from the
  recompute's own function**, not a lookup table: `bdd_specs_exist` stayed
  "has any spec file" after it became per-criterion.
- **A profile lists every source that moves its requirement**: persona
  artifacts are files, so `personas_complete` needs the files profile.
- **A sweep's default needs a project predicate**: the `nil` vantage is shared,
  and one project's drain once wrote another's verdicts.
- **Batch per owner kind, never per entity** inside a drain: per-entity
  statements multiply by vantages and entities.
- **Trust durable rows on restart.** Reseeding everything recomputed what was
  already right, about ten seconds per promotion on a large project.
- **Consume work markers only after the work is durable.**
- **A nudge carries the checker's reason**, not just the node's name, or the
  agent cannot act on it.
- **Measure before optimizing.** The edge phase's cost was kickoff generation,
  not node computation or the reduction; two guesses were wrong.
