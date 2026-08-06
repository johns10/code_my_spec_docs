# The light harness

Splitting the local application into a server that owns the domain and a local
process that owns the disk.

## Why now

The local application boots sixteen supervised children per install — Vault,
Repo, Migrator, Analysis supervisor, embedding serving, the MCP server, an
endpoint, Presence, WorkSource, the file watcher, a socket supervisor, a
presence client. It serves MCP itself, which is why the relay exists: booting
that per project was slow, and two projects meant two copies of the same server
against one SQLite file. Rather than write a second, multi-project server, the
relay gave Claude Code a single instantly-bootable thing to talk to.

Postgres removes both pressures. Nothing needs the relay, and nothing needs a
full harness per project. What still has to be local is the disk: watching it,
syncing it, and running a toolchain against it.

## Shape

Three applications, two of them shipped to users.

- **CodeMySpecWeb** — Postgres, the MCP tools, and the hook *decision* logic.
  Gains the tools; gains the shared hook code that both harnesses call.
- **CodeMySpecLocal** — today's full harness. Unchanged by this work. It keeps
  SQLite and standalone operation for anyone not on the cloud, and it becomes a
  consumer of the hook code rather than its owner.
- **The light harness** — file watching, file sync, analyzer execution,
  embedding inference. Talks to the server for everything else.

The rule that decides where something goes: **does it need the working copy?**
Not "is it about a project" — nearly everything is about a project. Does it need
the bytes on this disk, or a toolchain to run against them.

## What the code says

Measured, not estimated.

**MCP tools: 7 of 139 tool files touch the filesystem.**

    bootstrap/tools/init_project.ex          install_credo_checks.ex
    bootstrap/tools/install_agents_md.ex      install_rules.ex
    bootstrap/tools/install_claude_md.ex      requirements/tools/sync_project.ex
                                              requirements/tools/get_next_requirement.ex

Everything else is pure DB and moves as-is. Of the seven, `install_agents_md`
and `install_claude_md` stop existing (see Decisions), the remaining installers
are one-shot setup rather than workflow, and `get_next_requirement` is only
local because it syncs first — once sync is the harness's job, it is pure DB
too. The steady-state local tool surface is `sync_project`.

**Mounting the tools on the server is one `forward`.** `CodeMySpecWeb.Router`
already forwards four MCP servers through
`Anubis.Server.Transport.StreamableHTTP.Plug`; LocalServer is a fifth line.

**Hooks split along execution, not along subject.** The stop hook's analyzers
shell out through `Environments.cmd(env, "mix", …)` in `Compile`, `Tests`, and
the spex/credo runners — those need a working copy and a toolchain and cannot
move. The decision they feed (blocking problems, config modes, session and task
state, the R5b handoff) is DB logic, and it is already reused verbatim by the
Antigravity controller, which is evidence the seam is real. `post-tool-use` is
FileEdits tracking and `session-start` is a DB upsert; both are already
serverless in everything but where they are mounted.

**Embeddings are further along than expected.** `PgVectorBackend` exists and
`dev_sprite` already uses it, so storage on Postgres is solved. The gap is
inference: `Ortex` and `Tokenizers` are `only: [:dev_cli, :prod_cli, :cli_demo,
:dev_sprite]` and `Embeddings.Serving` starts only in the local application, so
nothing on the server can currently turn text into a vector.

## Decisions

**Project identity is a project-local config value, overridable by
environment.** Today every tool resolves scope by `x-working-dir` →
`Projects.resolve_local_project/1` → `Scope.for_local_project/2`. That is a
*server-side database lookup keyed by a filesystem path*, which is precisely
what a server with no disk cannot do.

Resolution order: `CMS_PROJECT_ID` → `project_id` in
`.code_my_spec/config.yml` → refuse. No guessing.

This is not a new mechanism. That file already carries `account_id`,
`client_api_url`, `code_repo` and `description`, and `Scope.from_local_config/1`
already reads it from the project root — per-project identity in a project-local
file is the established pattern, `project_id` simply is not one of the fields
yet. `cms.new` writes it at generation and `init_project` writes it for existing
projects, so it is the developer's to own without being theirs to remember.
Sprites are unaffected: the env var already wins, which is what they do today.

The important consequence is that resolution happens entirely on the harness.
The server only ever receives an id and never learns anything about paths.

Gitignore it. A fork that inherited the id would silently write into the
upstream project; `init_project` giving the fork its own is the safe default.

**Inference stays local; the harness ships vectors.** The alternative — Ortex in
the web build — puts an ONNX runtime and a model in the server image to serve
work the harness is already doing. The harness computes and sends embeddings;
the server stores them in pgvector.

**Dependencies get persisted, and hexdocs embed from that.** Today the watcher
polls `mix.lock`'s mtime, then waits out a ten-second settle window for `mix
deps.get` to finish unpacking before globbing `deps/<pkg>/lib/**/*.ex`. That is
a race with a timer for a referee, and it is the kind of thing that survives
until the machine is slower than the timer. Persisting the dependency set — name
and version — makes hexdoc embedding a function of recorded state rather than of
catching a filesystem event at the right moment. Re-embedding becomes something
that can be asked for, retried, and verified.

**AGENTS.md and CLAUDE.md move into the `cms.new` templates.** They are pure
functions of the app name, which is what the generator is for. Keeping them as
scripts is fine; keeping them as MCP tools an agent has to remember to call is
not.

**One harness process, one supervision subtree per project.** Not one process
per project, though that was the more attractive answer on its face and it is
pointing at something real.

Two things decide it. The hooks are POSTed by Claude Code to a fixed URL in the
plugin's configuration; a process per project means a port per project, so every
hook needs to discover which port belongs to the project it is in — a new moving
part on the critical path of every agent turn, whose failure mode is a hook that
silently posts nowhere. And with inference staying local, each process loads its
own copy of `priv/models/all-MiniLM-L6-v2.onnx`: 86 MB, times the number of
projects, plus a BEAM baseline each. Five projects is most of half a gigabyte of
duplicated model, and the obvious fix — a shared inference service — is a
multi-project component, so that road arrives back here having paid for the
trip.

The isolation argument is right, though, and it names an existing bug:
`FileWatcherServer` is a **singleton** managing every project at once, so one
project's crash stops watching for all of them. A `DynamicSupervisor` with a
child per project — that project's watcher, its analysis supervisor, its
channel — fixes exactly that, and OTP is built for it. A wedged analyzer
restarts one subtree.

One endpoint, one model, one lifecycle; per-project isolation underneath.

What this gives up against separate processes is protection from a BEAM-level
crash or OOM taking every project down at once. Rare, and the service supervisor
restarts it.

What it buys, and the reason it is the right answer rather than merely the
cheaper one: **the sprite and the laptop run the same shape.** A sprite is just
N=1 — one child in the tree, same code, same lifecycle. Today they diverge, and
that divergence is where several of the 2026-07-30 defects lived. A drill on a
sprite should validate the laptop path, and this is what makes that true.

**The harness holds no database.** It talks to the server for everything —
Files, leases, analysis runs, embeddings. This is the decision that keeps it
light: no Repo, no migrations, no credentials to distribute, no second schema to
keep in step, and no question about which store is authoritative. The cost is
that the API becomes load-bearing rather than incidental, so designing it is a
phase rather than a detail.

REST for the small and transactional (lease claim, hook decision, analysis run
results). A channel for the bulk — file sync and embeddings both move enough
data that request-per-item would be the wrong shape. Start with REST
everywhere and move a path to a channel when the volume argues for it, rather
than guessing up front.

**Phoenix, not a bare Bandit plug app.** Not for the LiveViews — for the
supervision tree and PubSub that already carry the file watcher, the lease
session, the analysis supervisor, and the Slipstream socket. A bare plug app
means rebuilding that scaffolding to avoid mounting an endpoint the hooks need
anyway. The sixty-odd LiveView routes simply do not get mounted.

## The API

The harness has no database, so this contract is the product. Designed for
thousands of files, a connection that must be present, and no offline mode.

### The channel is the lease

One Phoenix channel per project the harness serves, and **the channel's lifetime
is the project lease**. The server takes the Postgres advisory lock when the
channel joins and releases it when the channel closes — so the property built
into `Leases.Session` survives the move intact: a harness that panics, is
`docker rm -f`'d or loses its network frees the project as its socket closes. No
TTL, no heartbeat, no clock agreement.

This is the reason the primary transport is a channel rather than REST. Not
throughput — liveness. REST has no "this client is still here" signal, so a
lease over REST would need the expiry-and-heartbeat design that was deleted
today for being a timer compensating for a deadline.

A second harness joining the same project gets its join refused, with the label
of the holder. Same behaviour as now, one layer out.

### The harness sends conclusions, not raw material

This is what makes thousands of files affordable. Classification, validation and
fingerprinting are pure functions over content, and the harness already has all
three. It reads the disk and sends the *outcome* — path, role, fingerprint,
valid, and the component or story it belongs to. Roughly 150 bytes a file, so a
full 4,300-file project is about 650 KB. File content never crosses the wire.

Sync is a manifest diff, not a dump:

1. harness pushes `sync_manifest` — `{path, fingerprint}` for every file
2. server diffs against what it holds and replies with the paths whose details
   it actually needs
3. harness pushes `sync_files` for just those

A steady-state sync sends a manifest and receives an empty diff. A first sync
sends everything once. The full-manifest step is what makes the result
*verifiable*: the server can tell deletions from omissions, which a stream of
per-file updates cannot.

### Failing loudly

Not an offline application, so disconnection is an error and never a quiet
degradation.

- **Hooks refuse rather than allow.** The stop hook's job is to decide whether
  the agent may stop. With no server it cannot decide, so it blocks and says the
  harness is not connected. Allowing the stop would be the silent green light
  this whole design is trying to avoid.
- **The file watcher stops watching.** Events it cannot deliver are events it
  will not remember; continuing to watch would build a backlog whose loss is
  invisible.
- **The banner and the log say so,** in those words, naming the harness rather
  than the server — the failure that cost an hour today read as "MCP server is
  down" when the server was healthy.

The distinction that has to survive: *"I asked and there is nothing to do"* and
*"I could not ask"* are different answers and must never render the same.

### Analysis and embeddings

Analysis runs are small and transactional — the harness executes the analyzer
locally, pushes `analysis_result` with the problems, and the server reconciles
them exactly as it does now. Hook decisions are a channel call with a reply, on
the critical path of every agent turn, so they stay small.

Embeddings are the one genuinely bulky payload: a vector is a few kilobytes and
a project has thousands. They ride the same channel in batches, content-addressed
by fingerprint so an unchanged document is never re-sent — the dedup
`EmbeddingService.file_hash_matches?/4` already performs, moved to the boundary.

### What stays REST

The hook endpoints Claude Code POSTs to are local HTTP on the harness and do not
change. Everything the harness initiates goes over the channel.

## Order of work

Each phase should leave the tree green and shippable; none of them is a
big-bang.

1. **Project identity.** Accept `CMS_PROJECT_ID` and `config.yml`'s
   `project_id` as scope sources alongside working-directory resolution, with
   the existing path lookup still winning while both exist. Teach `cms.new` and
   `init_project` to write it. Nothing moves yet; this is the precondition that
   makes the rest mechanical.
2. **Tools on the server.** Mount LocalServer in `CodeMySpecWeb.Router` behind
   the existing `:mcp_protected` pipeline. The 132 pure-DB tools work from the
   env-var scope. The seven filesystem tools stay pointed at the local harness.
3. **The hook seam.** Lift the decision half of the hook controllers into
   `CodeMySpecWeb`, leaving the analyzer execution behind an interface the local
   side implements. `CodeMySpecLocal` calls the lifted code and keeps behaving
   identically — that is the regression test for the extraction.
4. **The harness API.** Define what the harness sends and receives, because it
   has no database of its own: sync results, analysis results, lease claim and
   release, embeddings, hook decisions. This is the phase most likely to be
   underestimated — it is the entire contract between the two halves.
5. **The harness.** A new Phoenix application, supervision tree built up from
   nothing: PubSub, one endpoint for the hooks, embedding serving, and a
   `DynamicSupervisor` whose children are per-project subtrees (watcher,
   analysis supervisor, channel). Add a child only when something fails without
   it. Explicitly no Repo.
6. **Embeddings and deps.** Persist the dependency set; re-point hexdoc
   embedding at it; have the harness ship vectors to pgvector.
7. **A drill.** A full unattended sprite run on the new shape. Today's run
   validated a harness that is being replaced; this is the one that counts.

## Status

Phases 1–6 are built; **phase 7, the drill, has never run.** The tree is green
(3,018 server tests, 46 harness, 12 cms_scan) and the whole path works end to end
against a real server and from inside a container — but two things stand between
here and a drill anyone should believe.

| # | Phase | State |
|---|---|---|
| 1 | Project identity | Done. `:project_id` app-env → `config.yml` → path lookup. A config naming an unknown project is `{:error, :not_found}`, deliberately not a fall-through, so a wrong id is loud. `init_project` *prepends* the key, because `description` is a multi-line quoted scalar and round-tripping the file mangles it. |
| 2 | Tools on the server | Done. `LocalServer` forwarded at `/mcp/harness`. Exercised for the first time only in this session — 83 tools, `list_stories` answering for the right project. |
| 3 | The hook seam | Done. `CodeMySpec.Hooks.*`, its own top-level Boundary, because the stop decision reaches into `McpServers` and `CodeMySpec` deliberately does not. |
| 4 | The harness API | Done. `HarnessProjectChannel`: join takes the lease, `read_model`, `observations`, `hook_decision`. |
| 5 | The harness | Done. `../cms_harness`, `../cms_scan`. Supervision tree is three children, built up rather than trimmed. Analyzer execution verified blocking a broken project and allowing a fixed one. |
| 6 | Dependencies & embeddings | Half. Dependencies are recorded and the `mix.lock` settle-timer is gone. The harness ships no vectors — blocked on a packaging decision, not on code. |
| 7 | A drill | **Never run.** Blocked. |

### Blocked, and on whom

- **A headless Claude Code credential — John.** Claude Code in the container
  reports "Not logged in". On macOS credentials are Keychain-backed, not in
  `~/.claude`, so copying that directory carries config but no auth. The sprite
  scripts contain no credential mechanism at all, so whatever made earlier drills
  work was supplied by hand and never written down. `claude setup-token` →
  `CLAUDE_CODE_OAUTH_TOKEN` is probably the answer, and it then belongs in
  `sprite.sh`: a drill that needs a human to log it in is not an unattended drill.
- **`cms_scan` stays a pinned copy — attempted adoption, backed out.** Tried and
  measured rather than reasoned about, and the answer reversed twice.

  The overlap with `cms_core` looked encouraging: 6 shared files, and exactly the
  DB-free filesystem layer, suggesting `cms_scan` is the bottom layer of the
  three-way split rather than a competitor to it. That still holds.

  What kills adoption is **Boundary**, which this project runs as a compiler.
  `cms_scan` deliberately uses the `CodeMySpec.*` namespace so adoption would be
  "a mix.exs line and a delete, zero call-site churn". But a module can only
  belong to one boundary, and `CodeMySpec.Paths` — owned by app `:cms_scan`, as
  `:application.get_application/1` confirms — sits inside the namespace boundary
  `CodeMySpec` claims. Adoption produced 188 violations, and declaring the
  modules as deps produced a violation *on the declaration line itself*: boundary
  `CodeMySpec` may not depend on something the namespace says is already inside
  it.

  So adoption requires renaming to `CmsScan.*`, which touches **392 files** in
  code_my_spec — precisely the churn the shared namespace existed to avoid. The
  namespace choice bought a cheap adoption that Boundary then made impossible.

  Recommendation: **do not adopt.** Keep the copy and the drift tripwire, which
  is verified to fail on divergence. Duplication that is guarded beats a 392-file
  rename that fights a tool the project uses on purpose. Revisit only if the
  three-way split makes the rename worth doing for its own reasons.

  Kept from the attempt, because both are right regardless: `read_model/1` moved
  off `Scanner` to `Files` (Scanner's own moduledoc said it did not belong), and
  the requirement-definition lookups moved off `Components.Registry` to
  `Requirements.Registry`.

- **How the harness gets the embedding model — John.** Phase 6's second half and
  the last build item. Inference stays local so file content never crosses the
  wire; what is undecided is how the harness gets the 86 MB ONNX model. Vendor it
  (86 MB in a repo), download on first run (needs network, and a harness that
  cannot reach it is a new failure mode), or point at the copy already in the
  image via a configurable path (lowest regret, unblocks the sprite, leaves the
  laptop open). Not required for a drill.
- **Nothing else of mine.** Analyzer execution is done and verified.

### The analyzer gap — closed, and verified both ways

**The defect.** A file that cannot compile was written into a project the harness
was serving; the stop hook answered `{}` — you may stop — with zero problems
recorded. Nothing in `cms_harness` shelled out. `Stop.decide/2` consults persisted
Problems, so with nothing writing them it correctly reported that nothing blocks,
from facts nobody had gathered.

That corrected an earlier entry here: "answered a stop hook with `{}` — allowed,
over the wire" had been recorded as a success. The *transport* worked; the
decision was vacuous. Reading it as a passing turn is exactly the mistake this
project is about.

**The fix.** The harness runs the tools and sends what they printed as raw data;
the server converts it with the same `ProblemConverter` a local run uses, so both
paths produce Problems by one code path rather than two that must agree. Ecto
never enters the harness. `Compile`, `Tests` and `Spex` are vendored into
`cms_scan` and pinned by its drift test — they alias only `Environments`, which is
what made them movable. Dispatch is server-driven: the server owns the run ledger
so it knows what is stale and pushes `run_analysis`; the harness owns the disk so
it runs it.

It also closed a clause that was an unconditional allow. `validate_stop` for a
scope with no `cwd` returned `{:ok, …}` — no analysis, no blocking check. Right
while the only way to reach it was a caller with no working copy anywhere; wrong
the moment a harness held the disk on the other end of a channel, because then the
stop hook arrived there on every agent turn and got an answer computed from
nothing.

**Verified end to end against a real server, both directions:**

| | Result |
|---|---|
| Project that cannot compile | `decision: block`, quoting the actual compiler errors |
| After removing the broken file | Allowed; compiler problems back to zero |

Both directions matter. A hook that always blocks would pass the first test alone.

**Two things that made this hard to test, worth remembering.** The first attempt
reported the broken project as *allowed*, and neither cause was the code. Runs in
the table were from an earlier session and were being memoized as fresh — clearing
them made dispatch fire immediately. And the fixture was a bare `mix` project with
no `:diagnostics` compiler, so `Compile` had no diagnostics file to read and
reported clean. **A fixture that is not a real CodeMySpec project cannot exercise
the compiler path at all.**

That second one leaves a narrow pre-existing hole, byte-identical between server
and `cms_scan` so it predates this work: a non-zero exit with no diagnostics file
is recorded `completed`, i.e. clean. It only bites projects missing the
`:diagnostics` compiler, which `ProjectSetup` requires — but it is the green-light
family and it is still there.

### The defect log, grouped by what could see them

Ten defects, and the grouping is the transferable part: **nothing found by a
later category was visible to an earlier one.**

**Only a real socket could see these** — `Phoenix.ChannelTest` builds sockets by
hand and compares replies as terms:

1. **A UI preference stood in for authorization.** `authorize/2` compared the topic
   against `scope.active_project_id`, which `Scope.for_user/1` fills from the
   user's saved *UI preference*. A laptop could serve exactly one project — the
   one last clicked in the web app. Sprites were refused outright: the deploy-key
   connect assigns `:deploy_key_project_id` and the channel never read it.
2. **`read_model` could not be encoded.** It carried whole `%Component{}` rows,
   which have no `@derive Jason.Encoder`, so the serializer raised and the harness
   never received a read model — it could never scan. The test asserted on the
   reply *term*, in-process, which never touches the serializer.
3. **Refusals could not name the checkout** — the one property the lease design
   claims. `label_for/1` read assigns nothing ever sets. The test passed because it
   injected the assign by hand.
4. **`hook_decision` did not exist.** The harness pushed it for the whole of phase
   5; the catch-all returned `{:noreply, socket}`, so it got no reply and sat out
   its full timeout on every hook. Both suites green throughout — the server did
   not know the event existed, the harness tested against a fake that implemented
   it.

**Only the built release could see these:**

5. **The stop hook blocked every clean turn.** Slipstream collapses an empty reply
   to the bare atom `:ok`, and an empty decision map is the *most common* answer a
   hook gets. The harness called it unreadable and refused. Worse than it first
   looked: `post_tool_use`, `notification` and `ask_user_question` all answer
   `{200, %{}}`, so on post-tool-use this fired on **every tool call**.
6. **A missing credential was reported as a dead channel** — the refusal told the
   reader to check the network when the fix was an environment variable. Every
   reason's *wording* was tested; which reason gets picked was not.

**Only running it in a container could see this:**

7. **The sprite patched the wrong plugin manifest.** `find -path '*codemyspec*'`
   matches two files, because the *marketplace* directory is also named
   `codemyspec`. The symptom would have been "the agent has no MCP tools", with
   nothing tying it to a glob.

**Found by reading, then proven:**

8. **A sprite could sync but not act.** The socket accepts a deploy key;
   `/mcp/harness` requires OAuth. Verified with a 401. Fixed by *exchange* rather
   than by widening the key — `DeployKeyOrOAuth` argues against that in its own
   moduledoc, and a `client_credentials` grant carries no resource owner, which
   `require_oauth_token` needs.
9. **The launcher queried the database** it was the launcher for, to resolve a
   module name. Now carried on the token exchange the sprite already makes.
10. **No analyzers at all**, above.

Two more that were mine, caught before shipping: a token that expired in an hour
against runs that take longer, with a comment claiming something refreshed it
(nothing does); and an underscore conversion written in shell that got
`ABCWidget` wrong, now done server-side by `Macro.underscore`.

### Rules earned, not assumed

- **An in-process test cannot see a wire.** Four of the above, for two reasons: a
  hand-built socket carries assigns production never sets, and a reply asserted as
  a term is never serialized.
- **A test that builds its own socket is not testing the socket.** Three of the
  four passed *because* of the test helper.
- **Verify against the release, not just `mix run`.** Two more.
- **Prove the test fails without the fix.** Caught two tests that passed for the
  wrong reason.
- **Do not paper over a race with a sleep and a comment.** The sync flake was
  rationalised in a comment as an OS-level settle; it was a `cast` where a `call`
  was needed, and separately a test asserting on arrival order rather than content.

### Ratified deviations from this document

- **No PubSub in the harness.** Nothing subscribes; the registry covers process
  discovery. "Add only when something fails without it", applied honestly.
- **The stop hook blocks once, then allows loudly.** This document said refuse,
  full stop. Claude Code re-fires Stop after a block, so unconditional refusal
  livelocks and an unattended sprite burns its budget. A stop carrying
  `stop_hook_active: true` is allowed with a `systemMessage` saying nothing was
  checked. Allowed-and-labelled stays distinguishable from verified-and-clean;
  allowed-and-silent would not. Better than what was written here.
- **Sync is one shot, not a manifest diff.** The doc specifies three steps. What
  is built sends full detail once. The verifiability that motivated the full
  manifest is intact — the server still sees the whole set and can tell a deletion
  from an omission. What is given up is steady-state bandwidth, ~650 KB against
  ~260 KB, which does not yet justify a three-step protocol.

### Two rejections that were not in the plan

Both the "green light" failure mode, caught while building:

- **An empty manifest is refused.** `reconcile/2` deletes every row whose path is
  absent, so an empty list wipes the project — and over a wire "found nothing" and
  "did not run" arrive identically. A genuinely empty project has no rows to lose.
- **An unknown role or unparseable mtime rejects the whole manifest.** Both are
  load-bearing: role decides how a file enters the graph, mtime is compared
  directly in `stale_paths/2` so a nil crashes rather than degrades.

### Known, and not yet resolved

- **`cms_scan` is a pinned copy, not an extraction.** Guarded, but duplicated.
  Blocked on the decision above. The dependency was also bigger than this document
  said: `observe/2` transitively needs `Paths`, the whole `Documents` tree (3,177
  lines plus parsers), `Components.Registry`, and `SpecAlignment` — and that last
  uses `%Problems.Problem{}` and `%Users.Scope{}` as struct literals, so it cannot
  be copied, only split. That is what turned "vendor or extract" into a project.
- **`cms_scan` carries broken copied code.** `Components.Registry` came without
  `Requirements.RequirementDefinitionData`, so two of its functions call an absent
  module. Not reachable from `Scanner`, but it makes `--warnings-as-errors`
  unusable there.
- **Nothing tests the harness against the real server automatically.** The contract
  test is a hand-maintained list of event names. It would have caught #4 and will
  catch the next missing handler, but it does not verify payload shapes.
- **The harness ships no embeddings.** Phase 6's second half.
- **One unexplained harness test failure**, seen once, not reproduced in fourteen
  subsequent runs, no log kept. Recorded rather than called fixed.

## Risks

**A sync that silently does not happen looks exactly like a project with nothing
to do.** This is the same shape as the three worst defects found in the
2026-07-30 session — tests reading results from the wrong machine and returning
`{}`, a compile reading diagnostics from the wrong machine and reporting clean, a
spex suite that was not running at all reporting zero failures. In each case the
harness's most dangerous output was a green light. When the local side is
*only* watch-and-sync, that failure mode concentrates there. "I looked and found
nothing" and "I did not look" must be distinguishable in the data, designed in
before the first drill rather than discovered during one.

**The sixteen-children temptation.** The obvious way to build the harness is to
copy the local application's supervision tree and delete. What survives a
deletion pass is whatever nobody was sure about, which is how it ends up heavy
again. Build up from nothing and add what fails without it.

**Scope resolution touches everything.** Even with the env var, the change lands
in `Validators` and the transport assigns, which all 84 tools funnel through. A
mistake there is uniform and quiet.

## Open questions

- **Hook latency over the wire.** A hook decision is a channel round trip on the
  critical path of every agent turn. Local it is sub-millisecond; over the
  internet it is tens to low hundreds. Almost certainly fine against turns that
  take seconds, but it should be measured rather than assumed, because it is
  paid on every single turn.

Settled since first draft: the API shape (channel-primary, manifest-diff sync,
conclusions not content), loud failure on disconnection, no offline mode, one
process with per-project supervision subtrees, project identity (config.yml + env override), no
database in the harness, the supervision tree built up from nothing, and the
relay — which is not a concern here, because this is a separate application and
part of the paid server product.
