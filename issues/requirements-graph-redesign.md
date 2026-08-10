# Requirements graph — redesign notes

The graph is **derived on demand from whatever the caller can reach**, rather than
maintained as a domain read model. Everything below follows from that, and most
of what has been filed against the analysis pipeline is really filed against
this.

## What it costs today

Measured on a 3200-component project: **34ms of preload against 4.4 seconds of
compute** (16a24105). `get_next_requirement` and the stop hook both recompute in
full, on every call. The stop hook fires on every agent turn, so that is
per-agent-per-turn CPU on a shared server, and it scales with fleet size rather
than with the amount that changed — which is usually one file.

---

# Part 1 — What is actually there now

Worth writing down because two things are already persisted, and the redesign is
smaller than "build a read model from scratch" implies.

## Yes — a requirement is a node

Confirmed, and it settles the modelling question before anything else:

```elixir
@spec compute_graph(Scope.t()) :: {[Requirement.t()], [edge()]}
```

`RequirementGraph.compute_graph/1` returns requirement structs as the nodes.
The key is

```elixir
defp node_key(n), do: {n.entity_type, n.entity_id, n.name}
```

so a node is **(entity_type, entity_id, definition_name)** — one per entity ×
definition. Edges are `%{from: node_key, to: node_key}`: prerequisites within a
graph, plus cross-entity edges (a child's `spec_file` to its parent's, a story's
requirements to its component's).

That means `requirements` **is already the node table, at the right grain**. It
has `component_id`, `story_id`, `project_id`, `name`. What it lacks is the other
half of a graph — the edges are in a `depends_on text` column holding `'[]'` —
and it is written as a *stamped answer* rather than read as a projection.

So this is not "build a read model". It is "the node table exists; give it edges
and stop treating it as a scratch pad".

## Two tables exist, and the projection is a blob

**`requirements`** — 5191 rows, the nodes, as above. `satisfied` is a stamped
boolean, `checked_at` a timestamp, `details` a jsonb reason. Nothing records
**which rows the answer was computed from**.

**`requirement_graphs`** — `fingerprint`, `payload bytea`, `node_count`,
`edge_count`.

This is the projection, and your objection to it is the right one: **it is a
blob, not domain structure.** The whole graph is serialised into one `bytea`
addressed by one hash. Nothing in it can be queried, joined, or partially
invalidated. You cannot ask "which requirements does this file affect" or "what
changed since the last one" — you can only compare the hash and, if it differs,
throw the entire payload away and recompute 4.4 seconds of graph.

A domain-structured projection is the same information as **rows and edges**:
`requirements` for the nodes it already holds, plus a `requirement_edges` table
for the `{from, to}` pairs currently trapped in the payload. Then the LiveViews
read the same rows the agents do, and there is one projection instead of a blob
for readers and a recompute for writers.

## The definitions

70 definitions across 10 graphs in `requirement_definition_data.ex`
(`context_graph`, `live_context_graph`, `schema_graph`, `behaviour_graph`,
`json_graph`, `controller_graph`, `liveview_graph`, `default_graph`,
`story_graph`, `project_graph`). Each is a `RequirementDefinition` with
`check_type`, `config`, `node_scope` (`:parent | :child | :self`) and
`prerequisites` (ids within its graph).

`RequirementCalculator.check/5` dispatches on `check_type`. That dispatch **is**
the relationship inventory, so here it is in full.

## The relationship inventory

| check_type | count | what it keys to | cardinality |
|---|---|---|---|
| `file_exists` | 28 | `(entity, config.role)` → `files` | one-or-more; existence of any |
| `file_valid` | 16 | `(entity, config.role)` → `files` | one-or-more; any with `valid: true` |
| `tests_passing` | 6 | `(component, "exunit")` → `problems` + analysis freshness | count == 0 |
| `path_exists` | 6 | a literal path or prefix, **read from disk** | not a row at all |
| `delegate` | 11 | arbitrary function | unconstrained |
| `field_present` | 1 | a column on the entity | no file |
| `field_true` | 1 | a column on the entity | no file |
| `no_problems` | — | `(component, source)` → `problems` | count == 0 |

The entity is a **component** in eight graphs and a **story** in
`story_graph`. `node_scope` selects which component: `:parent`, `:child` or
`:self`.

### Stories genuinely have no files for some requirements

`story_graph` is the clearest case of the shape you flagged:

- `component_linked` — `field_present` on `story.component_id`. No file.
- `three_amigos_complete` — delegate, reads rules and scenarios rows. No file.
- `bdd_specs_exist` — `file_exists` on role `:bdd_spec`, **many files, one per
  criterion**.
- `bdd_specs_passing` — `field_true` on `story.specs_ready`. A latch, no file.
- `qa_complete` — delegate into `CodeMySpec.Qa`. Rows, not files.
- `deploy` — delegate into `CodeMySpec.Deploys`. Now a table as of `dc36a954`.

So the answer to "one file or multiple" is **both, and sometimes neither**, and
the model has to say which without a special case per requirement.

### `files` already carries the keys

`files` has `component_id`, `story_id`, `role`, `path`, `fingerprint`, `valid`,
`harness_id`. The association work is half done — what is missing is not columns
on `files`, it is that **nothing records which file satisfied which
requirement**.

## The exceptions are not scattered — they are all in one graph

This is the strongest result of the investigation, and it supports taking
project setup off the graph.

| graph | total | `path_exists` | `delegate` | row-shaped |
|---|---|---|---|---|
| `context_graph` | 14 | 0 | 0 | **14** |
| `live_context_graph` | 10 | 0 | 0 | **10** |
| `default_graph` | 6 | 0 | 0 | **6** |
| `schema_graph` | 3 | 0 | 0 | **3** |
| `behaviour_graph` | 3 | 0 | 0 | **3** |
| `json_graph` | 2 | 0 | 0 | **2** |
| `controller_graph` | 5 | 0 | 0 | **5** |
| `liveview_graph` | 6 | 0 | 0 | **6** |
| `story_graph` | 6 | 0 | 3 | 3 |
| **`project_graph`** | **14** | **6** | **8** | **0** |

The eight component graphs are **49 requirements, 100% row-shaped** — every one
is `file_exists`, `file_valid`, `field_*` or `tests_passing`. Not one delegate,
not one `path_exists`.

`story_graph`'s three delegates all read tables (`BddRulesChecker`, `Qa`,
`Deploys`) and are convertible to queries.

**`project_graph` holds every single `path_exists` and eight of the eleven
delegates, and has zero row-shaped checks.** It is not a graph of artefacts; it
is a checklist about the state of a working copy and a provider.

### CORRECTION — "lift project_graph out" was too coarse

The table above is right about where the off-shape checks live. The conclusion I
drew from it was wrong, and I am fixing it before acting on it.

`project_graph`'s 14 nodes are **not** 14 pieces of project setup. Exactly one
is:

| requirement | check | what it really is |
|---|---|---|
| `project_setup` | delegate → `AgentTasks.ProjectSetup.check` | **the brownfield onboarding DAG — this is the one** |
| `personas_complete` | delegate → `PersonasChecker` | mainline, reads `personas` |
| `stories_exist` | delegate → `StoriesChecker` | mainline, reads `stories` |
| `architecture_designed` | delegate → `ArchitectureChecker` | mainline, reads `components` |
| `spex_boundary_ready` | delegate → `SpexBoundaryChecker` | mainline, reads `files` |
| `issues_triaged` | delegate → `IssuesChecker` | mainline, reads `issues` |
| `issues_resolved` | delegate → `IssuesChecker` | mainline, reads `issues` |
| `technical_strategy` | path_exists | `.code_my_spec/architecture/decisions.md` |
| `code_generation` | path_exists | `.code_my_spec/tasks/code_generation.sh` |
| `qa_setup` | path_exists | `.code_my_spec/qa/plan.md` |
| `qa_journey_plan` | path_exists | `.code_my_spec/qa/journey_plan.md` |
| `qa_journey_execute` | path_exists | `.code_my_spec/qa/journey_result.md` |
| `qa_journey_wallaby` | path_exists | a qa artefact |
| `qa_integration_plan` | delegate → `QaIntegrationPlan.evaluate` | globs `.code_my_spec/integrations/*.md` |

Ripping the graph would have deleted `architecture_designed`, `stories_exist`
and `personas_complete` — real mainline steps that gate the whole component
pipeline. That would have been a bad afternoon.

So the work is three different jobs wearing one graph:

1. **Rip** — `project_setup`, one node, plus `AgentTasks.ProjectSetup` and its
   twelve step modules. Brownfield-only, explicit, in memory. This is the part
   you authorised and it is genuinely small.
2. **Classify** — the six `path_exists` all point at files under
   `.code_my_spec/`. They are not exotic: give them roles and they become
   ordinary `file_exists` rows. The `integrations/*.md` glob is **done**
   (0e2d6170, b0cf13e9): classify claims both the directory and the index,
   `files_digest` covers them, `DelegateFiles` is deleted.
3. **Query** — the six table-reading delegates become predicates. No behaviour
   change, they already read rows.

The "49 row-shaped requirements in eight graphs" number is unaffected. What
changes is that lifting setup out removes **one** node, not fourteen — and the
other thirteen are converted rather than deleted.

### So: make project setup its own thing

Your instinct is right and the numbers are unambiguous. `project_graph` is a
different kind of object wearing the same struct:

- its checks are about **a working copy and external services**, not about rows
- its nodes have no `component_id` or `story_id` — they key to a project
- it is what forced `DelegateFiles` to exist and what makes `GraphFingerprint`
  incomplete, and therefore what makes `cached_graph/1` unusable by agents
  (the `DelegateFiles` half is now closed — see the correction in Part 2)
- it is also the part that changes least often and matters at the *start* of a
  project rather than continuously

Take those 14 nodes out and **the remaining 55 are queryable rows with foreign
keys**, which is the entire redesign, achieved by subtraction.

Computed on demand, as you suggested, is the right shape for what is left: a
setup checklist answered when someone asks "is this project set up", not
recomputed on every agent turn as part of a graph about specs and tests. It can
stay a DAG — it has real prerequisites — it just should not be *this* DAG.

### DECIDED — and it goes further than "off the graph"

Your answer removes the caveat I had written here. I had said
`get_next_requirement` must still reach project setup or a fresh project has
nothing to work on. **That is wrong, because a fresh project no longer has
project setup to do.**

- `cms new` covers it entirely now. **The mainline exits `cms new` with project
  setup complete — that is the promise.**
- So project setup only ever runs against a **brownfield Elixir project** being
  onboarded.
- It is **called explicitly**. It does not sit behind `get_next_requirement`.
- **In memory, on demand.** No table.

That is a cleaner cut than "lift it into a separate DAG": it is not a phase of
the mainline at all, it is an onboarding tool for a project that did not come
from our generator. Greenfield never sees it.

Two things follow that are worth being deliberate about:

1. **`get_next_requirement` stops returning setup steps.** Anything that assumed
   a project begins by working through them — prompts, docs, the onboarding
   flow — needs to stop assuming it.
2. **The brownfield entry point has to exist and be findable.** Today the only
   way in is the graph. If the graph stops offering it and nothing replaces the
   door, brownfield onboarding has no entry point rather than an explicit one.

## The 11 delegates, by what they read

Five read tables and could be queries today:

    StoriesChecker.exist?          stories
    PersonasChecker.complete?      personas
    BddRulesChecker.complete?      rules / scenarios
    IssuesChecker.triaged?         issues
    IssuesChecker.resolved?        issues
    ArchitectureChecker.complete?  components
    SpexBoundaryChecker.complete?  files
    Qa.complete_check              qa attempts
    Deploys.uat_check              deploys (new table)

Two do not:

    AgentTasks.ProjectSetup.check          reads the working copy
    AgentTasks.QaIntegrationPlan.evaluate  globs .code_my_spec/integrations/*.md

Those two, plus the six `path_exists` checks, are the entire reason the cached
graph cannot serve agents.

---

# Part 2 — Why it cannot be cached today

A published projection already exists (`requirement_graphs`) and already serves
the LiveViews. The agent paths cannot use it.

`GraphFingerprint` can cover checks that read tables. It cannot cover a check
that globs a directory or shells at a provider, because no fingerprint over a
preloaded database context can see them. A cached graph can therefore tell an
agent that work is finished which a deploy has just reopened — story 859's spex
caught exactly that when it was last wired as a read-through cache
(`criterion_7321_a_fresh_uat_deploy_reopens_the_release`).

**The cache is correct to refuse.** The fix is not a better cache.

`QaIntegrationPlan` was the sharpest instance: it globs
`.code_my_spec/integrations/*.md`, which `Scanner.classify/1` did not claim, so
they were not `File` rows at all — part of the "N file(s) match no role and are
NOT synced" the harness reports every scan. `Requirements.DelegateFiles` existed
solely to hash those paths and close the gap (41406ceb) — a second, hand-rolled
files table for the files the real one dropped.

> **Corrected 2026-08-09.** Classify claims that directory now
> (`{&Paths.integrations_dir/0, :integration}`), so those files sync like any
> other document and `files_digest` — which carries each row's content hash —
> covers them. `DelegateFiles` is deleted (0e2d6170). Two fingerprint tests had
> been holding it up by writing specs to disk without ever syncing, so they were
> asserting the side channel rather than the behaviour; they go through
> `FileSync.sync/2` now.
>
> Removing it surfaced a live one directly underneath: `Paths.integrations_index()`
> is `.code_my_spec/integrations.md`, a **sibling** of `integrations/`, and
> `match_doc_dir/2` requires the trailing slash — so the index was claimed by
> nothing, and `DelegateFiles` had not covered it either (it globbed
> `integrations/*.md` only). `check_index/1` is the first gate of the state
> machine and writing the index is half the task's done signal, so an agent could
> do exactly what it was told and the fingerprint would not move. Fixed in
> b0cf13e9, with both integration paths added to `ClassifiableArtifactsTest` —
> whose moduledoc already named five prior instances of this same bug. This was
> the sixth, and the list is only protective for paths that are in it.
>
> Still uncovered, and left deliberately: verify-script paths. Each integration
> spec names one in a `## Verify Script` section and `check_verify_scripts/2`
> stats it, but the path is arbitrary and read out of file *content*, which the
> `files` table does not store. Nothing watches those, and nothing did before.
> This is the case the coverage model below has to answer rather than paper over.

---

# Part 3 — The shape

**Every input a requirement depends on is a row, and the row has a foreign key
to what it is about.** Then a file change updates the `files` row, and a query
against the read model returns current state, because current state *is* the
rows.

## 3.1 Composable predicates, not a compute pass

This matches what you had in mind, and the definition data already has the shape
for it: `check_type` + `config` is a predicate name plus its arguments. Today
`RequirementCalculator` interprets that pair in Elixir against preloaded lists.
It could instead **emit a query fragment**, and each check_type becomes one
composable function:

```elixir
defmodule Requirements.Predicates do
  import Ecto.Query

  # (entity, role) -> files. Existence.
  def satisfied(:file_exists, q, %{role: role}) do
    where(q, [n], exists(
      from f in File,
        where: f.component_id == parent_as(:node).component_id,
        where: f.role == ^role,
        select: 1
    ))
  end

  # Same join, one more predicate. This is the argument for the shape:
  # file_valid is file_exists + `valid`, and today they are two branches
  # of a case that each rebuild the lookup.
  def satisfied(:file_valid, q, %{role: role}), do: ...

  def satisfied(:no_problems, q, %{source: source}), do: ...
  def satisfied(:field_true, q, %{field: f}), do: ...
end
```

Composed over the node set, "which requirements are satisfied for this project"
becomes a handful of queries rather than 4.4s of `Enum`. And `depends_on` stops
being a text blob: the composition *is* the dependency.

**The open question I cannot answer alone** is whether satisfaction should be
computed at query time (a view / on-demand SELECT) or **materialised** into
`requirements.satisfied` by the same query on write. Query-time is always
correct and never stale; materialised is cheap to read and needs invalidation.
My instinct is query-time first, because the entire problem here is a
materialised answer that could not be invalidated correctly — but that is a
judgement about read volume I would rather make with you.

## 3.2 Close the classification holes

A check reading a file the scanner drops is invisible. Integration specs need a
role and a `validate_entry/4` rule; then they are `File` rows, `files_digest/1`
covers them, and `DelegateFiles` deletes itself.

The general form: **anything a requirement reads must be something the scanner
claims.** A file the walker descends into but does not classify is worse than a
file it never sees, because it looks covered.

This also removes the six `path_exists` checks as a category — a path that
matters is a row with a role.

## 3.3 State that is not a document goes into a table

An integration plan's verified/pending status is project state wearing a
markdown costume. So were the deploy records, until `dc36a954` gave deploys a
table — that commit is the pattern, and its moduledoc argues the case better
than I can: `health_verified_at` is separate from `inserted_at` precisely so the
column that decides the requirement is one that can only be set by a check
passing.

External state — a deploy that happened outside this application — cannot be a
row we own. It needs a **recorded observation with a timestamp**, and the graph
reads the observation rather than re-deriving it.

## 3.4 Explicit associations, not derived ones

A criterion's spex file used to be located by rebuilding
`<story_id>_<slug>/criterion_<id>_<slug>_spex.exs` and parsing the ids back out.
Four things that all move, two directions that must agree. When they stopped
agreeing the symptom was silent: **97 of 841 files unmatched**, and every one
had been invisible to the graph for as long as the ids had been stale. A
criterion with no matching file reads as work not done.

`spec_path` is recorded on sight now. The rule: **a derived association is a
silent failure waiting for one of its inputs to move.** The graph still has
others.

---

# Part 4 — The analysis coupling

This is the part I would most like to get right before writing code, and I think
it forces a change to how files are modelled rather than merely how they are
read.

## Today's fingerprint is whole-corpus

`Analysis.Fingerprint.current(scope, source)` hashes the sorted
`{path, fingerprint}` pairs of **every** file whose role feeds that source:

    compiler  [:implementation, :test, :test_support, :mix_exs]
    credo     [:implementation, :test, :test_support, :mix_exs, :credo_exs]
    exunit    [:implementation, :test, :test_support, :mix_exs]
    spex      [:implementation, :test, :test_support, :bdd_spec, :mix_exs]

One hash per source. `fresh?/2` is `run.input_fingerprint == current`.

Two consequences, and both are filed:

- **`7a7eed33`** — any single edit changes the whole hash, so a source slower
  than the edit cadence is *permanently* stale. exunit takes ~2m10s here and an
  agent edits every few seconds. Its result is never at the current fingerprint,
  so it is never fresh, so its findings are always labelled stale.
- The system cannot say **which** files changed, only that something did. So
  there is no basis for running a subset.

## What the analysis notes already propose

`analysis-redesign-notes.md` argues for content-addressed results: store by
`(project, harness, source, fingerprint)` and ask "do I hold a result for this
source at the tree's current fingerprint". That deletes the whole
run-rejection class, and I still think it is right.

But it inherits the whole-corpus fingerprint. Content-addressing a hash that
changes on every keystroke gives you a cache that never hits.

## So the file model has to carry the dependency

The missing thing is the same one the requirements graph is missing: **an edge
from a consumer to the specific inputs it consumed.**

Concretely, a result should record the file rows it covered — not a hash of all
of them. Then:

- **freshness becomes a set difference**, not a hash comparison: which of the
  files this result covered have a different `fingerprint` now? None → fresh.
- **staleness becomes attributable**: "exunit is stale because these 3 files
  changed" is sayable, and is exactly what the stop hook cannot say today.
- **partial runs become possible**: re-run only what the changed files reach.
  That is the difference between a 2m10s suite invalidated by every keystroke
  and one that is usually already answered.

`files.fingerprint` is already SHA-256 of content, so the per-file material
exists. What does not exist is the join table.

### The shared substrate

Both halves want the same thing:

    files  (already: path, role, fingerprint, component_id, story_id, harness_id)
      ^                        ^
      |                        |
    requirement satisfied   analysis result covered
    by these files          these files at these fingerprints

One `files` table, two sets of edges into it. That is why these should be
designed together and why I would not start the requirements work without
deciding the analysis edge at the same time — the alternative is two dependency
mechanisms over one table, which is the situation that produced `DelegateFiles`.

### DECIDED — always analyse the whole set. And that is the right call.

Every run analyses the whole source. No subset execution.

**This is correct and I would not change it.** Subset execution requires knowing
which tests a source file affects. Getting that wrong means silently not running
a test that would have failed — the optimistic direction, which is the one
failure mode this whole system is organised against. Two minutes of CPU is not
worth buying with that.

### But the question had a second half, and that is where I was wrong

You asked me to correct you if the whole-set answer was wrong. It is not. What
is wrong is something I wrote in this document an hour before you asked, so the
correction is mine to make.

I proposed stamping a **second fingerprint at completion** and judging freshness
on it. That does not work, and the reason is arithmetic:

> exunit takes ~2m20s. If the agent edits every one to two minutes, then
> `enqueue_fingerprint != completion_fingerprint` on *every single run*. Every
> result is permanently "moved under it". Same dead end, better label.

For an analyzer slower than the edit rate there is **no fingerprinting scheme
that makes its answer describe the current tree**. That is physics, not
modelling. Any design whose freshness test is "did the corpus change" is
structurally broken for slow sources, and that includes the one I proposed.

### The thing that already solves it

`problems` carries `file_fingerprint`, and **2403 of 2420 rows have one**.
`ProblemRepository.reject_superseded/1` is applied to every read:

```elixir
where: f.fingerprint != parent_as(:problem).file_fingerprint
...
|> where([p], is_nil(p.file_fingerprint) or not exists(files))
```

A problem whose file has changed since the problem was recorded is **already
excluded**. So a problem that comes back from `list_project_problems/2` is, by
construction, a finding about bytes that are still on disk right now.

Per-problem staleness is already correct, already per-file, and already running.

### So the source-level stale marker is the bug

Look again at the reported symptom with that in hand:

    exunit (1) — stale, last ran 0s ago

That **one** problem survived `reject_superseded`. Its file has not changed. It
is a live finding about current content — and the footer told the agent to
ignore it and wait for a rerun that would find the same thing. `7a7eed33` says
so directly: the run reconciled one real problem, a genuine
environment-dependent failure, and it *arrived wearing a "stale, ignore me"
label*.

The source-level freshness gate is answering "has anything in this corpus
changed since the run", which for a slow source is always yes and which the
per-problem check has already answered better, per file.

### What I would actually do

**Split the two uses of freshness, and stop using the corpus one to judge
findings.**

1. **Scheduling — keep it.** "Have the inputs changed since the last completed
   run" is exactly right for deciding whether to enqueue. Whole-corpus is fine
   here; a false rerun costs CPU, which is the cheap direction.

2. **Findings — drop it.** A problem that survived `reject_superseded` is
   current. Do not label it stale, do not tell the agent to wait. If it survived
   the file-fingerprint check, the file it describes is the file on disk.

3. **Clean vs never-ran — needs run state, not fingerprints.** The one thing the
   source-level marker is genuinely needed for is telling "zero problems because
   it ran and found nothing" from "zero problems because it never ran". That is
   what the analysis notes already argue for: publish liveness separately, and
   let running / failed / never-ran be three distinct answers rather than
   inferred from a hash.

That closes `7a7eed33` without a second fingerprint, without per-file dependency
tracking, and without subset execution — consistent with your decision, and
smaller than what I had written.

### The proper model: coverage, not corpus hashes

Everything above says what to stop doing. This is what the domain actually
wants, and it is worth building rather than working around, because the current
shape has a hole in it that no amount of fingerprinting closes.

#### The asymmetry that is the real defect

Two facts an analyzer produces, and only one is modelled:

| fact | modelled? | how |
|---|---|---|
| "this file had this problem at this content" | **yes** | `problems.file_fingerprint` + `reject_superseded/1` |
| "this file was clean at this content" | **no** | nothing — an absent row |

A file with no problems is indistinguishable from a file nobody analysed. That
is not a labelling bug, it is a **missing fact**, and it is the invariant at the
bottom of this document sitting in the schema rather than in a message:

> Absent information must not render as good news.

`tests_passing` and `no_problems` are literally `count == 0`. They read "clean"
from an absence. The corpus fingerprint is the workaround — it stands in for
"has anything been looked at recently" because nothing records what was looked
at.

#### The missing table

One fact per `(file, source)`: **the content it was last analysed at, and
when.**

```
file_analyses
  file_id      uuid    -> files
  source       string  -- compiler | credo | exunit | spex
  fingerprint  string  -- the content the analyzer actually read
  analyzed_at  utc_datetime
  run_id       -> analysis_runs   (provenance, not identity)
  unique (file_id, source)
```

Upserted, not appended. Only the *current* coverage matters; history lives in
`analysis_runs`.

#### Whole-set execution makes this cheap, not expensive

This is the part I had backwards earlier, and it is why your "analyse the whole
set" answer and this model are complementary rather than alternatives.

Measured on this working copy:

    implementation  872      compiler / exunit inputs   1,232
    test            352      credo inputs               1,233
    test_support      7      spex inputs                2,096
    mix_exs           1
    credo_exs         1      steady state total        ~5,800 rows
    bdd_spec        864

**~5,800 rows per working copy, at rest.** The file sync already upserts 4,544
rows per manifest without anyone noticing. A whole-set run upserts one row per
file it covered — the same order of magnitude, on a path that already does it.

Because execution is always whole-set, coverage is not a scheduling input. It is
a *record*. That removes the hard part: nobody has to decide which files a run
should cover, only write down which it did.

#### What it answers that nothing answers today

- **"Is this source fresh?"** → a query: does any file with a feeding role have
  `files.fingerprint != file_analyses.fingerprint`? No rows → fresh. Composable
  with the requirement predicates, same shape.
- **"Why is it stale?"** → the same query, selecting the rows. *"exunit is stale
  because these three files changed"* becomes sayable. Today the stop hook can
  only say that something did.
- **"Is this file clean, or unlooked-at?"** → clean is a row with a matching
  fingerprint. Unlooked-at is no row. **This is the one that matters** — it
  closes the invariant in the schema instead of relying on every reader to
  remember it.
- **"Has this ever been analysed?"** → answerable per file, which the requirement
  graph needs for `tests_passing` to mean anything.

And subset execution stops being a redesign: if it ever becomes worth doing, you
upsert fewer rows. Nothing else changes. The door your decision wanted to leave
open is left open by this rather than by keeping the model vague.

#### When the snapshot is taken decides whether it is true

"Lift out all the fingerprints when a run starts, record what we ran against" is
the model. The one detail that decides whether the record is a fact: **snapshot
at the start, never at the end.**

The failure directions are not symmetric.

Analyzer starts at T0 and takes 2m20s. A file changes at T0+90s, after the tool
had already read it at T0+60s.

- **Snapshot at start** — records the content as of T0. The tool read that. If
  the file later changes, current ≠ recorded → stale → rerun. Wrong only in the
  direction of doing extra work.
- **Snapshot at end** — records the content as of T1, which the tool never read.
  Current == recorded → **fresh**. A false fact, written down, permanent. Exactly
  the optimistic error, and worse than a stale message because nothing later
  contradicts it.

So: start. It fails safe, and "fails safe" is the whole design constraint here.

##### Exact, if you want it

Start-snapshot is *safe* but not *exact*: a file that changed mid-run is recorded
at content the tool may not have read. It resolves to a rerun, so nothing is
claimed falsely — but it is a guess dressed as a record.

The harness can do better for free, because it is already watching the files. A
file that changed between run start and run finish is one the harness *knows*
changed. Excluding those from the covered set turns

> "we recorded this at the content it had when we started"

into

> "we know the tool read this content, because it did not move while it ran"

Same data, no second scan, and the difference is that the covered set contains
only files the record is actually true about. Files that moved mid-run simply
are not covered by that run, which reads as stale, which is correct — they were
analysed at content that no longer exists.

#### Upsert on `(file, source)`, not a row per run

Both work for the query. The cost is not close.

A row per file per run keeps history: 1,232 rows for an exunit run, and at a run
every couple of minutes that is ~430,000 rows a day for one working copy, most
of them identical to the row before. `RunsRepository.prune/2` already exists
because `analysis_runs` had the same problem at 1/1000th the volume.

Upserting on `(file, source)` holds **only current coverage** — ~5,800 rows per
working copy, flat, forever. History of *runs* stays in `analysis_runs`, where
it belongs and where it is already pruned.

Provenance is not lost: `run_id` on the coverage row says which run last touched
it. What is lost is the ability to ask "what did the run three hours ago cover",
which nothing asks and which the run's own record can answer if it ever matters.

#### The shortcut to refuse

The tempting implementation is for the **server** to stamp `fingerprint` from
`files` at reconcile time. Do not. The analyzer ran minutes ago; `files` has
moved since. That records "analysed at the current content" for a file whose old
bytes were what the tool actually read — the optimistic error, and a
*permanent* one, because it writes a false fact rather than showing a stale
message.

**The fingerprint recorded must be the one the analyzer saw.** The harness has
it: it scans the working copy anyway, and `Scanner` already computes SHA-256 per
file. The run should carry the covered set and its fingerprints back with the
result, the way `analysis_result` already carries diagnostics.

That is more wire and more work than stamping server-side, and it is the
difference between a fact and a guess. Given how many of this project's bugs
have been a proxy standing in for something nobody recorded, I would pay it.

#### What retires

- `Fingerprint.current/2` as a **freshness** test — replaced by the coverage
  query. It can survive as a cheap scheduling hint ("probably worth a rerun"),
  where being wrong costs only CPU.
- `analysis_runs.input_fingerprint` as the thing `fresh?/2` compares. Keep it as
  provenance if useful; stop deciding with it.
- The whole "is the corpus unchanged" framing, which is what made a source
  slower than the edit rate permanently stale.

### Which means the files table barely changes

Worth saying plainly, since it is the opposite of what this document implied
before your answers:

- `files` already has `path`, `role`, `fingerprint`, `valid`, `component_id`,
  `story_id`, `harness_id`. Requirements key off `(entity, role)`; that works
  today.
- No join table is needed. The consumer→input edge I argued for in the earlier
  draft was in service of subset analysis and per-file freshness, and you have
  ruled out the first and `reject_superseded` already provides the second.
- The classification hole (integration specs, `DelegateFiles`) belonged to
  `QaIntegrationPlan`, which is a `project_graph` delegate — **it leaves with
  project setup.** `DelegateFiles` can go with it rather than being fixed.

The one files-adjacent thing I would fix is cost, not shape:
`Fingerprint.current/2` calls `Files.list_files(scope)` — a full project file
load — and `check_blocking_problems/3` calls `Analysis.fresh?/2` once per source
with problems, each doing its own load, plus `last_ran/2` doing another via
`Analysis.status/1`. That is five or six full loads of a 4,544-row table per
stop hook, on every agent turn. `Fingerprint.current/1` already computes all
four sources from **one** load; the hot path just does not use it.

---

# Part 5 — Ordering

Reordered after the per-graph count: **lifting project setup out comes first**,
because it is subtraction and it makes everything after it simpler. The
classification and document-state work I had listed first turns out to be
mostly *inside* project setup, so it may not need doing at all in its old form.

1. **Lift `project_graph` out** into a separately computed setup DAG. Removes
   all 6 `path_exists` and 8 of 11 delegates from the graph in one move, and
   with them the reason `cached_graph/1` cannot serve agents. Keep
   `get_next_requirement` able to reach it.
2. **Convert `story_graph`'s three delegates to queries** — `BddRulesChecker`,
   `Qa`, `Deploys`. All three read tables already; `dc36a954` did the hard part
   for deploys. After this the whole remaining graph is rows.
3. **Edges out of the blob** — `requirement_edges` alongside `requirements`, so
   the projection is domain structure rather than a `bytea`. LiveViews and
   agents read the same rows.
4. **The dependency edge to `files`** — designed once for both requirements and
   analysis results (Part 4).
5. **Composable predicates** — `check_type` emits query fragments;
   `RequirementCalculator`'s dispatch becomes `Requirements.Predicates`.
6. **Incremental update** (`d10f65e8`) — falls out of (3)–(5).
7. **Where it runs** (`8b94f6df`) — decide last. If the graph is rows and
   foreign keys the question becomes cheap either way; if it is not, moving the
   computation moves the problem.

# Part 6 — Decisions

All five are answered. Recorded here so the next person does not reopen them.

1. **Project setup** — comes out of the mainline entirely, not just off the
   graph. `cms new` covers it; the mainline exits `cms new` with setup complete.
   It survives only as **brownfield onboarding for an existing Phoenix project**,
   **called explicitly**, **in memory on demand**, **not behind
   `get_next_requirement`**. No table.
2. **Satisfaction** — **query time**. Materialise later if read volume demands
   it; the current pain is a materialised answer that could not be invalidated.
3. **Analysis** — **always analyse the whole set**. No subset execution, no
   per-file dependency tracking. Door left open, not walked through.
4. **`requirements`** — **rebuild**. Delete the 5191 rows and redesign the table
   as needed. It is a projection; it can be recomputed from source.
5. **`requirement_graphs`** — **delete it.** If the projection is rows, the blob
   has no job.

## What (4) and (5) together mean

They are more freeing than they look. With the data disposable and the blob
gone, there is no migration to write and no compatibility to keep — the table
can take the shape the queries want rather than the shape history left. The only
constraint is that whatever reads `requirement_graphs` today (the LiveViews)
reads rows instead, which is a change worth doing in the same commit so nothing
is ever reading a projection that has stopped being written.

# The invariant

> Absent information must not render as good news.

A requirement whose input cannot be seen reads as *not done* — the safe
direction, and why this has been survivable. A cached graph inverts it: an input
that cannot be seen reads as *unchanged*, and unchanged reads as done. That is
the trap 859's spex caught, and it is the one to design against.
