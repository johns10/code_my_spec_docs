# Checkers, inputs and edges

What a requirement's verdict is computed from and how the pieces around the
writer work: the definitions and check types, the preloaded context, the
fingerprints, the edge derivation, how writers announce changes, what a drain
costs, and how one copy's work is read back for an agent. The writer itself
(`IncrementalGraph`, `GraphStore`, vantages, marks, seeding) is in
[the core doc](index.md); this doc does not repeat it. Code comments point here
by section name.

| Module | Role |
|---|---|
| `Requirements.RequirementDefinitionData` | The templates: every requirement, its check, role and prerequisites, by graph. |
| `Requirements.RequirementCalculator` | Dispatches a definition's `check_type` against an entity. |
| `Requirements.BddRulesChecker` | Three Amigos delegates: the bar, the seal, open questions. |
| `Requirements.Preloader` | Loads the context a computation reads: whole, per story, per component family, per project, or just the shape. |
| `Requirements.Profiles` | One set-based read per slice, shared by every handler that settles from it. |
| `Requirements.Freshness` | Fingerprints: per entity (`inputs_fingerprint`) and of the edge shape (`topology/2`). |
| `Requirements.Edges` | The edge set, derived one entity at a time. |
| `Requirements.Topology` | Pure graph facts: reachability, reduction, depth, partitions. |
| `Requirements.Projection` | Reads rows back into nodes and edges; resolves the reading vantage. |
| `Requirements.GraphInputs` | The one event every graph input announces through. |
| `Requirements.DrainCost` | What a drain cost, counted from Ecto telemetry. |
| `Requirements.StoryExecution` | What one copy's selected story offers a role. |
| `Requirements.GraphProjector` | Lays the graph out for sigma.js from topology facts only. |
| `Stories`, `Issues`, `Components`, `BddSpecs`, `Architecture` | Contexts the graph reads; each announces its writes. |

## Definitions

- **Templates are data.** Each graph (per component type, story, story issue,
  project) is a list of definitions with integer ids; `prerequisites` name ids
  within the same template. A container's `dependencies_met` junction (always
  satisfied) turns D dependencies × N children into D + N edges.
- **Template ids must be unique within a template.** Prerequisites resolve by
  id through a map that keeps the last writer, so a reused id silently rewires
  them; `deploy` once reused `three_amigos_complete`'s id and, with devops on,
  closed a cycle through the whole story chain. Invisible with devops off,
  because the filter drops `deploy` before the map is built.
- **Validation type.** A session holding a `:manual` task may stop before
  validation runs, so an open manual task switches spex, credo and exunit off
  for that session. `three_amigos_complete` and `qa_complete` are automatic for
  that reason: sealing requires the bar, and completing QA requires a real
  attempt. QA was manual because a parent's stop completed the QA sub-agent's
  live task before any attempt existed; the evaluator's `:skip` (leave a
  sub-agent's task active) is what made automatic safe.
- **Gates must be satisfiable by whoever holds them.** `qa_setup` opens all
  story-level work, so it waits on `issues_triaged` (triage always has an
  answer: accept, dismiss, route), not `issues_resolved`, which no single agent
  on a shared project can always reach. Resolution gates `qa_journey_plan`, the
  fan-in that tests the build to ship.
- **Stamps, not analysis.** `ready_for_qa` reads `qa_ready_commit`, written by
  `Promotion.certify/3`; `story_promoted` reads `promoted_version`, written only
  by a promotion naming the story. The graph does not read problems. Name a
  requirement for what it reads: a gate named like a git fact gets checked
  against ancestry.
- **Role lives on the definition.** Rows have no role column, so "is there work
  of my kind" narrows by name (`requirement_names_for_role/1`) across every
  graph.

## Check types

- `RequirementCalculator` dispatches on `check_type`, never on names.
  Checkers exporting an arity-3 function get the preloaded context; the rest
  take `(scope, entity)` and query for themselves.
- **A raising checker is not caught.** Every delegate is ours; a raise turned
  into `false` was indistinguishable from an unsatisfied requirement in every
  count. A condition a checker cannot evaluate is a `{false, %{reason: …}}`.
- **`:field_true` names its latch's setter.** A latch is the one check where
  doing the work is not enough: `specs_ready` is set only by evaluating its
  task, and three green sweeps followed by "specs_ready is not set" read as a
  broken gate until `evaluate_task` flipped it at once.
- **`:path_exists` reads rows, never disk.** Every gated path classifies to a
  role, so the row exists whenever the file does; a disk fallback gave the
  harness (with a checkout) and the server (without) two answers for one
  instant. The row's validator verdict counts (`valid: nil` means no validator
  applies, a pass) and its errors go in the reason, since "File invalid" alone
  does not say which section is missing. With no checkout on the scope a path
  may match one row per checkout; one valid copy is enough.
- **`:component_exists`, not `:field_present`.** A component id is derived from
  project and module name, so a story can name a component before it syncs;
  "not set" (map the story) and "not there yet" (wait) are different work.
- **`:bdd_specs_covered` is per criterion**, matched by the number a spex file's
  `criterion:` names, over every file on the copy. A story with no criteria is
  unsatisfied. The task evaluator and the handler call the same
  `bdd_specs_covered/3`, so they cannot disagree with the recompute.

## Three Amigos

- **The bar and the seal are different questions.** `complete?/2,3` is the bar
  (persona, ≥1 rule, < 15 rules, every rule has a scenario, no open question);
  `ThreeAmigos.evaluate/2` seals on it. `three_amigos_complete` reads the seal:
  recomputing the bar let a red card added to a shipped story silently un-ship
  it.
- **Every red card answered**, not "more scenarios than questions": that rule
  let stories carry open questions nothing ever asked again.
- **`questions_answered`** makes post-seal questions somebody's work (product,
  via `ResolveQuestions`), gated on the seal.
- `sealed?/2` re-reads the story before answering "not sealed", because
  evaluation seals mid-request and re-checks from a struct loaded before it.

## Preloading

- **Files are one checkout's.** Every checkout files its own row per path.
  Blended, files that exist only in another worktree satisfied hundreds of
  `(component, role)` pairs — an agent was told specs existed and skipped them.
  Over-satisfaction is the expensive direction: work skipped is never noticed;
  work repeated is obvious.
- **The unscoped reader** gets the reading copy's files
  (`WorkingCopies.reading_copy_id/1`: the project's default copy, else its main
  one) and every ready story; a person looking at the project is asking about
  all of it. A checkout gets its own stories plus unassigned ones, never another
  copy's. `files_copy/1` is the rule for narrow loaders; `files_vantage/1`
  ignores the scope's checkout.
- **Only `ready_for_dev` stories project** — a filter, not a node, because an
  agent would simply satisfy a node. Parked stories stay reachable through the
  backlog tools.
- **Absent is not empty.** Narrow loaders fill only the keys they load.
  Checkers read `ctx[:key]` and query when it is absent; an empty map is an
  answer. Filling every key with an empty collection once made `qa_complete`
  false for every story on a live project.
- **Shared half once per drain.** Components, rules, questions, issue stamps
  and deploys are identical across checkouts; `shared/1` loads them once and
  emits `DrainCost.project_preload/0`. Before, queries grew linearly with the
  checkout count on an unchanged project.
- **Narrow loads skip fingerprints** (`skip_fingerprints`): a hash from a
  narrow context is plausible but not the one a whole load produces.
- `topology_context/1` is the shape only — enough for `Freshness.topology/2`,
  `Edges.plan/3` and rehydrating rows — so a narrow drain redraws without a
  full load.

## Fingerprints

- **Per entity**, not per project (one project fingerprint made any
  observation rebuild every node and edge) and not per requirement (one
  entity's requirements share almost all inputs).
- **Rows a checker reads are keyed `{id, updated_at}`**, never by named
  fields. Naming fields was wrong twice in one afternoon: `add_scenario` sets a
  criterion's `kind` and `rule_id`, and the seal is `story.three_amigos_sealed`;
  both moved a verdict without moving a fingerprint. Timestamps are safe for
  rows written one at a time; files are keyed by content hash because a no-op
  sync rewrites every file row.
- **Rows no checker reads stay out**, and so do volatile columns: the
  `working_copies` gate inputs are only the main copy's `preview_status` /
  `preview_url` and whether the asking copy exists. Commit counts and
  `last_seen_at` moved every story's fingerprint on every keystroke anywhere.
- **Loading a collection is not covering it.** Deploys, unready stories,
  `persona_stories` links and QA invalidations were each missed in turn because
  something nearby looked like coverage. An invalidation writes its own row and
  leaves the attempt unchanged.
- **Config is stamped into every entity fingerprint** (`with_config/2`): it
  decides which definitions exist and is no input to any entity.
- **`topology/2` is edges only**: component type, parent, dependencies, story
  attachment, discovered-component file membership, issue placement, config,
  and the definition set (names and prerequisites). It gates edge redraws and
  edge-plan reuse; it never moves a verdict.
- **The definition set must be in the topology hash.** Without it a release
  that moved a prerequisite produced an identical shape and every vantage kept
  stale edges until unrelated activity happened. It must not reach entity
  fingerprints: every template edit would recompute every entity everywhere.
- Every part is sorted: encounter order flapping a hash is churn.

## Edge derivation

- **The reduction decomposes.** Three template facts bound paths: the project
  enters a story at `qa_setup → component_linked` and leaves at
  `qa_complete → qa_journey_plan`; a story enters components at
  `bdd_specs_exist` and re-enters at `ready_for_qa`; so no component-to-component
  path crosses a story or the project. Hence the component side reduces once,
  each story's edges reduce against reachability over it, and the project chain
  reduces against the stories' bridges.
- **Why.** A whole-set reduction made one component appearing cost a reduction
  over tens of thousands of edges at every vantage.
- **Plans are shared by shape and file membership.** Generating kickoff edges
  is most of a redraw; checkouts with the same discovered-file membership reuse
  one plan.
- **`over/4` must equal the whole-set result** (`RequirementGraph.edges_over/4`);
  `edges_derived_per_entity_match_the_pass_test` holds them together. A template
  edge breaking one of the three facts fails there first.
- **Reachability is bitsets** over a condensation: per-successor DFS scaled with
  distinct targets × edges, and real graphs spread targets widely. Cycles occur;
  the reduction never minimizes inside a cycle and keeps equivalent entrances,
  since removing alternates independently can remove every entrance.

## Announcing writes

- **Why one event.** Every computation used to be reader-triggered, so an agent
  that stopped with an empty queue sat for ninety minutes while issues it could
  triage were filed. Context topics are user-keyed, so a per-project topic
  carries "something the graph reads moved".
- **Marks are durable** (`Invalidations`) because an accumulated dirty set
  cannot be rebuilt after a restart. The PubSub message carries only an
  observation id, which ties a write's log line to the drain that consumed it.
- **Name what moved, or fan out.** Empty entities record a project-wide mark;
  `:project_wide` is the default vantage. `:this_checkout` only for changes
  about the writer's own tree (files, analyzer runs): a story renamed from a
  worktree is not about that worktree, and inheriting the scope's checkout
  would leave every other checkout with the old title.
- **The vocabulary is closed.** `event/6` refuses undeclared kinds; the
  declared-events test demands each kind has a handler or an explicit fallback.
- **Creation, deletion and readiness flips reach `compute_entity/4`.** Handlers
  settle rows and never create or reap them: a story created after the seed got
  no rows until creation became a kind nothing handles. A `ready_for_dev` flip
  is creation or deletion to the graph. Component kinds are handled (for
  `architecture_designed`) but `@partial`, so their marks still recompute the
  component.
- **Name exactly the entity.** A component's unit is its family; naming the
  parent too recomputed the grandparent's family — a child under one context
  once recomputed a hundred siblings at every vantage. Changes to non-structural
  component fields (`description`) announce nothing.
- **Guard on ids, not loaded structs.** A guard on `scope.active_account`
  skipped every announcement from scopes that carry ids only; invisible while
  reads recomputed.

## Drain cost

- **Queries and rows, not `checked_at`.** A handler sweep stamps every row in
  two writes, so "rows rewritten" made the cheaper implementation read as the
  dearer one. Counts mean the same thing for either.
- **Counted from Ecto telemetry**, filtered to the draining process; our own
  tally would be a second account that drifts.
- **Separate channels** for what queries cannot see: edge redraws (in-memory,
  zero rows when unchanged), project preloads, and write transactions (a count
  per entity reveals a per-entity loop; a seed once ran tens of thousands of
  queries that way).
- **Kept per kind** (`:event`, `:reseed`), so one kind cannot overwrite the
  other's reading. Assert on counts, never on duration.

## Story execution

- **Completion is local to the active story.** A story with nothing for the
  asking role falls back to project-level work only, never to other stories'
  work, and a finished story answers `:complete` so `Agents.Work` moves the
  team on.
- **The fallback exists** because a copy pointed at a story answered every role
  "blocked" while the project chain was unfinished: assigning the first story
  idled four roles for an hour.
- **Only for a role, and never for a bound agent.** A role-less ask is a person
  who must hear "your story is blocked on this". A bound agent fell through to
  project `issues_resolved` and sat on it while its story never started; bound
  agents get their story's work only and are not clamped by project-level
  prerequisites.
- **Asked for a story, answer about it or refuse.** A mismatched story once fell
  through to the whole project, byte-identical to no selection.
- **"Nothing to do" has three sentences**: finished, someone else's queue, no
  graph at all. An unprojected project once answered "All requirements
  satisfied"; that sentence decides whether an agent is started. Asked of the
  actionable set, so an agent with nothing actionable may stop.
- **Open questions block builders and testers, not product**, which owns
  questions and must be offered the work of clearing them.

## Issues

- **A gate whose passing state depends on work outside the gated unit is a
  wall.** Project gates count only `:app` issues (framework issues are the
  vendor's; `:qa`/`:docs` are about tooling): framework issues once held a
  coding agent for hours on work outside its repository. Issues on stories
  assigned to another copy are that copy's.
- **Triage counts every tenant scope** and any severity on a story: dismissing
  is always an answer, and an incoming issue holds its story's QA.
- **Framework issues stay where filed.** The vendor reads across in one guarded
  query; a cross-project write was reverted because no read surface followed it.
- **A story from another project is refused**, not linked or rehomed.
- **Prefixes resolve, ambiguity is reported.** Prose cites eight-character
  prefixes; "not found" for an existing prefix led to a correct citation being
  deleted.

## BDD specs

- **Story numbers, not ids.** Spex directories are `<number>_<slug>`; ids are
  per-deployment and renumber on migration. A number compared against ids
  silently matches another story.
- **A recorded `spec_path` wins** over a derived one; a derived path moves when
  wording or ids move, while the file stays.
- **Runner traps.** `mix spex <dir>` loads zero tests and reports clean, so
  directories are expanded. JSONL is read through the environment that wrote
  it. `merge_clean_env/1`, never appending the scrub, which would unset
  `MIX_ENV`. The raw output is returned, since a nonzero exit with an empty
  JSONL means the suite never ran. Failure paths are made relative, or problem
  cleanup deletes them as missing files and they reappear next sweep.

## Lessons

- **Over-satisfaction is the dangerous direction.** Scope every file read to
  one checkout; a blended read tells agents work is done.
- **Key read rows by `updated_at`, never by a list of fields.** A missed field
  is silent and costs an agent a session; an extra one costs a recompute.
- **Loading something is not covering it.** Ask what each checker reads.
- **A definition change must move the edge fingerprint**, and nothing else.
- **Absent means "ask"; empty means "none".** Never fill a context key you did
  not load.
- **A gate must be satisfiable by the role that holds it.**
- **Never catch a checker's raise into `false`.**
- **Name a requirement for what it reads.**
- **Handlers settle; only a recompute creates or reaps rows.** Entity creation,
  deletion and readiness flips must reach `compute_entity/4`.
- **Announce exactly the entity that moved**; over-naming multiplies by
  families and vantages, under-naming leaves silent staleness.
- **Measure the cost both implementations share** (queries, rows), not a proxy
  one of them games.
- **A proxy that says "nothing to do" must distinguish finished, elsewhere and
  absent.**
- **Match spex files by story number**, and resolve numbers to ids explicitly.
