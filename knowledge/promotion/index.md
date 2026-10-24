# Promotion and working copies

How verified work reaches the remote development branch and then a device
checkout, and the records it moves through — the design behind
`lib/code_my_spec/promotion*`, `working_copies*`, `workspaces*`, and the
lessons that shaped it. Code comments point here by section name.

| Module | Role |
|---|---|
| `Promotion` | The action: gate, ff-only merge, stamp landed stories, dispatch the deployment, report. |
| `Promotion.RunningCopy` | Leaf read model: the `story_promoted` verdict, read by the requirement graph. |
| `Promotion.Runner` | Where disk operations run: locally, or as named ops down a copy's harness channel. |
| `Promotion.Steps` | The git/disk operations themselves (precheck, merge, submodule sync, tags, batch build). |
| `PromotionQueue.Worker` | One project's queue: build a batch in the gate copy, gate, land or eject. |
| `BootVersion` | Which commit a running process booted from; drift; which paths need a restart. |
| `WorkingCopies` / `WorkingCopy` | The server-issued identity of one checkout, its main designation, preview and app state. |
| `Workspaces`, `PreviewAddress`, `PreviewTunnel`, `Runner.Local` | A project's cloud/bare-metal instance and its preview address and tunnel. |
| `Projects` / `Project` | Project records, local-config resolution, deploy keys. |
| `Migration` | Copies a project's authored records from a local harness to the cloud. |
| `DevState` | Reconciles what the database believes against the runtime. |

## Current remote-promotion contract (story 1147)

The project queue certifies a candidate on its source device and publishes that
exact commit to `origin/<development_branch>` (default `main`). Remote Git is
integration authority. A desktop checkout, its availability, and its preview
health do not determine whether publication succeeded. Normal development
publication is not a UAT or production release.

- `PromotionQueue.Worker` fetches the configured target through the source
  harness and builds in an isolated `promotion-gate:<source-copy-id>` checkout
  on that device. It preserves the submitting tree and queued candidate.
- Dirty submissions, stale product QA, analyzer findings, and conflicts retain
  their existing refusal rules. Main-device work uses the same queue and gates.
- Before publication the queue persists the certified base, head, branch, gate,
  promotion identity, and ordering sequence. Publication atomically advances the
  branch and creates `refs/codemyspec/promotions/<id>`. The expected-base lease
  and ancestry check prevent overwriting another publication.
- A changed remote base requires rebuilding and certifying again. A lost reply
  retries the persisted identity and reconciles its receipt and remote ancestry;
  an unrelated commit already on the remote is not proof of this publication.
- `Promotion.land_remote/6` records reviewed story/issue completion after
  publication. Persistence failure reports published-but-completion-held;
  retrying the same candidate resumes completion using its original receipt.
- `Promotion.RunningCopy` reads the publication stamp, even on main and even
  without a destination. Preview failure cannot clear a published story.
- `Promotion.DeviceSync` stores the desired destination revision independently.
  An offline destination remains pending. Its own harness fetches and safely
  fast-forwards the configured branch, synchronizes submodules, and applies the
  app lifecycle. Dirty/diverged checkouts are preserved and reported failed.
- Applied means the app's served commit was verified. An older replay cannot
  replace newer desired work. A verified successful application is not repeated.
  Use `list_working_copies` for publication-independent app/sync state and
  `sync_working_copy` to retry a pending or failed main-device application.
- Remote publication stamps identify the published commit. Historical local
  version-tag behavior below belongs to the retained bootstrap path.

## Legacy local implementation reference

The following sections describe the previous local-only path, retained for
bootstrapping this upgrade and explicit compatibility fixtures. Where they
refer to local main as authority, no-op main promotions, shared destination
paths, version tags, or optimistic serving claims, they do not describe the
remote queue above. Do not use them to bypass remote certification or to claim
an offline preview is serving.

## Promotion

- **Two independent halves.** The read model (`RunningCopy`) answers from each
  story's `promoted_version` stamp; the action (`promote/3`, `land/6`) writes
  that stamp. The graph sits below `Promotion` and calls only the leaf.
- **One target.** The merge target is the project's designated main copy, never
  something the agent names. The running checkout and the agent's copy share an
  object store (worktrees), so nothing is pushed.
- **Order of `promote/3`:** handoff gate → the copy contains main → clean tree
  → every analyzer has a clean run at its HEAD (`gate/3`; missing runs are
  started and the answer is `{:pending, _}`) → the story's own spex pass on the
  certifying run → HEAD unmoved since → QA reviewed this candidate →
  `git merge --ff-only` of exactly that commit → submodule sync → stamp →
  dispatch the deployment.
- **No post-merge check.** `--ff-only` either makes main's tree byte-identical
  to the certified commit or touches nothing, so there is nothing new to check.
- **Synchronous by design.** Everything before the dispatched deployment is
  reads, a `git status` and a fast-forward; refusals come back in the call,
  never through a side channel. An async wrapper once answered "started" for
  promotions already refused.
- **Lock.** `Promotion.Lock.with_lock/2` holds the project for gate and merge.
  A second caller is refused naming when the first started — never queued,
  since a queued promotion whose branch moved would merge something nobody
  asked for.
- **Promoting from the running copy** has nothing to merge: no gate, the
  story's spex must pass on a spex run at main's HEAD, it is stamped with main's
  current version, and the app is always restarted. It must never refuse with
  "nothing to merge" — that left an agent with a dead app no way out.
- **Every refusal names what to act on** and the copy the findings belong to
  (`:working_copy`), which may not be the caller's.
- **Landing a story** (`record_landed_stories/4`) is one transaction:
  complete its reviewed QA issues, stamp it promoted, then emit
  `[:promotion, :team_free]`. Only the landed stories are stamped — a
  project-wide sweep would stamp code sitting unmerged elsewhere. A write
  failure after the merge answers `landed: true, assignment_held: true`.

## The gate

- **Keyed on the commit, never on fingerprints.** A run answers for a commit
  only if the harness saw it start on a clean tree at that commit and finish
  there (`Analysis.answer_at_commit/3`). Fingerprint freshness had several
  definitions and stalled the fleet.
- **Every source, whatever the project config.** Config decides what the stop
  hook sweeps, never what promote demands.
- **Blocking.** Only problems from sources whose latest run is at `head`.
  Credo and compiler block at `:error`/`:warning` regardless of stop-hook mode;
  exunit and spex go through `Blocking.enforceable/2` (a spex finding with no
  location is advisory); `:info` is advisory. `Blocking.blockable/2` is shared
  with task evaluation.
- **The compiler run is `--force`d.** An incremental compile reports only what
  it recompiled, and another analyzer holding the build lock can have compiled
  a violation already.
- **One run per missing source.** If one is already running at `head`, the
  promoting agent is added as a waiter instead of starting a second.
- **No copy, no gate.** A scope with no working copy is refused rather than
  falling back to the project's default copy's problems.
- **Logged on entry and on answer**, so "asked and never answered" is told
  apart from "never asked".

## Deployment

- **Reload by default** (`deployment_plan/2`): a restart of :4000 kills every
  in-flight agent turn on the box. Restart when the merge touches
  `BootVersion.restart_paths/0`, when changed paths are unreadable, when the
  harness cannot reload, or when asked. A failed reload restarts within the
  same deployment.
- **Dispatched, never awaited.** The restart may kill the very BEAM running the
  promotion, so it runs in a detached task and the answer is "merged,
  deployment unconfirmed" — the normal success, worded as such.
- **`preview_status` is claimed `serving` at dispatch.** Without the claim the
  next gate read sees a stale `down` and tells the agent to promote again,
  forever. Over-claiming costs one QA attempt that meets the real failure.
- **A lost acknowledgement is verified, not trusted or failed.** The app is
  asked what it serves (`AppTransport`) until it reports the merged commit or
  the bound runs out. Only an app answering on the wrong commit is a failure; a
  silent one stays unconfirmed. Read what the app *serves*, not what it
  launched from — a reload moves only the first.
- **The agent is told the outcome** (`notify:`), confirmation included: it was
  already told QA can start, so a failure is a correction. `nil` means nobody
  to tell. The recipient comes from the tool call, never guessed.
- **`restart_acknowledgement_lost?/1`** reads the reason text ("draining",
  "not_connected", "not awaited", "promotion_restart"); `Runner`'s error
  wording is load-bearing.
- **Project-specific follow-up** (this repo refreshing its harness) is the far
  side's optional `after-promote` recipe, not a branch in promotion code.

## Versions

- A promotion **tags** the certified commit `vX.Y.Z` (annotated, local only);
  it commits nothing, so a branch level with main stays level.
- Patch bump from the nearest `vX.Y.Z` tag, or from `mix.exs`'s literal when
  untagged. A merge that moved nothing mints nothing.
- `version` ("did this merge mint one") and `stamp_version` ("which version
  carried this story onto main") are different questions. A no-op merge mints
  no version but still stamps its story with main's current one; otherwise a
  story whose code is already on main can never be stamped.
- A tag that should have been made and was not is `version_error`, logged as
  an error and stated in the outcome — never silent.

## Runner and steps

- The gate needs the database, git needs the disk: the gate stays on the
  server and each step travels. A harness environment sends the step as a named
  op (`Analysis.harness_fs_request/4`), addressed by working copy id — never by
  root, since two checkouts of one project are two copies.
- Named ops, not a general `cmd`: `analysis/run` owns command execution on the
  harness.
- JSON replies are atomized recursively in one place.
- **Precheck** uses `--untracked-files=no --ignore-submodules=all`, matching
  the `story_promoted` gate. Untracked files are reported, not refused.
- **Submodule pointer.** A copy moving `.code_my_spec`'s gitlink is refused
  unless the new pointer is on the docs `origin` and descends from main's. On
  landing, the pinned commit is fetched from the promoting copy and checked out
  in main's submodule; a dirty submodule refuses first; any failure rolls the
  merge back (`reset --keep`, tag deleted) — but only if HEAD is still this
  promote's commit.
- **Gitlink detection** reads `ls-tree` mode 160000; `rev-parse <c>:<path>`
  also answers for a plain tracked directory.

## Promotion queue

- One candidate per batch. Build in the project's gate copy: reset to main's
  HEAD (with `submodule.recurse=false`), `git clean`, merge the candidate, drop
  the gate's test databases (`ecto.migrate` only goes forward), build assets.
- **Candidates main already contains** land at once without a gate.
- **A lone candidate level with main** reuses a certification its own copy
  already holds at that commit; it never starts runs in the requester's copy.
- **Gate copy hygiene.** The tree and databases are not swapped under a run
  still going there; the wait is bounded so an orphaned run row cannot hold the
  queue forever.
- **Nothing is retried.** A candidate is taken only once main and the gate
  copy can both be read; until then it stays queued, and a copy joining wakes
  the queue. Once taken, any failure ejects it with the reason (red findings,
  a failed run at the batch commit, a gate that could not run, a build or
  landing error). Only main moving under a batch rebuilds it.
- **Assets** are built after the analyzers are green: no analyzer runs the
  asset pipeline.
- **Landing** goes through `Promotion.land/6` under the same lock. If main
  moved while gating, the batch is rebuilt on the new main. A candidate whose
  QA is not current is ejected, not requeued (it would head the queue forever).
- Waits on `analysis:<project>` PubSub with a slow recheck timer behind it, so
  a lost message never stalls the queue.

## Running-copy verdict

- `story_promoted` answers from the story's `promoted_version` stamp alone.
  Never from the checkout it was promoted from (the checkout moves on to other
  stories), and never from whether main is serving (every restart would
  unsatisfy every promoted story).
- A story fix submitted after the last promotion unsatisfies it again.
- On the running copy itself only `preview_status` is asked; never-checked and
  `erroring` pass.

## Working copies

- **The server issues the id**; the client writes it to `.cms_harness.json`
  and presents it on every join. Paths collide across containers, hostnames
  are generated, session ids churn — nothing client-derived identifies a
  checkout.
- **Recognition before minting:** `{project, device, root}`; never root alone.
  The oldest match wins. A mint with no device is refused (a seen row must name
  a device, `seen_copies_are_on_a_machine`).
- `.code_my_spec/` as a root is refused server-side.
- **Main** is designated, never inferred — except a project's *only* checkout.
  Designation clears the old main first (partial unique index), never the
  target, and announces a graph change itself.
- **Labels:** a join refreshes only an auto-generated label; a chosen one is
  never overwritten.
- **Graph announcements** fire only when `main`, `preview_status` or
  `preview_url` actually changed.
- **`observe_paths/2`** is scoped to the reporting device; silence about a copy
  is not absence. Nothing is deleted on `last_seen_at`.
- **App state** is per copy (`app_url`, `app_commit`, `app_serving_commit`,
  `app_status`), so QA can test a branch before it is promoted.

## Previews

- `PreviewAddress` writes one DNS record per project on our zone with our
  credential, the first time a preview is asked for; it outlives containers.
- `PreviewTunnel`: one Cloudflare tunnel per machine (every connector must
  reach every route), routes edited remotely under `TunnelIngressLock`, the
  secret generated here and stored encrypted. "Record name taken" means look
  and repoint, not success.
- Previews must be same-site with the framing page (session cookie) and inside
  the CSP frame-src derived from the base domain.
- `Workspaces` records a cloud copy's root itself (the server chose it) and
  reuses the existing cloud copy and device on reboot.

## Migration

- Exports through the contexts (the harness runs the same code over SQLite);
  imports in one transaction behind a paid-plan check.
- Insert order follows references: components → dependencies → epics →
  stories → personas and links → rules → criteria → issues → questions → QA
  attempts. Each step returns `local_id => record`; later steps read only
  those maps.
- Re-runs are safe: stories by `migrated_from_id`, then title only for rows
  with no source id; epics by name; personas by slug or name; criteria by a
  per-story snapshot consumed as matched; attempts by `submitted_at` instant.
  A reused row still takes the payload's authored fields.
- Component links use `Component.deterministic_id/2` (UUIDv5 of project and
  module), computed rather than carried — the project id changes.

## Lessons

- **A cached mirror of git state is a staler copy of something you can ask
  for.** Ahead/behind/dirty columns went stale, churned every story's
  fingerprint, and decided nothing; promote runs git live.
- **A check is not a change.** Announce graph inputs only when a read field
  moved; a health poll re-confirming `serving` was most of all graph events.
- **One verdict, many readers.** The deployment outcome is classified once and
  read by both the log and the agent message; two readings once logged
  `restart FAILED` for a restart that worked.
- **An error's meaning depends on the operation.** "Server went away" is
  failure everywhere except a restart, where it is success.
- **Never tell an agent its promotion failed when the merge landed.** It
  promotes again and restarts the shared dev server for every copy.
- **A remedy must change something.** A dirty-tree ff-only refusal reported as
  "behind main" sent agents to a merge that was a no-op.
- **Refusals agents cannot act on stop the pipeline like bugs.** Name the copy,
  the file, the command.
- **Fork git only on failure paths.** Spex cassettes patch `System.cmd/3`
  process-globally, so a per-stop `git` call kills spex.
- **Name the outside cause.** A submodule `core.worktree` rewritten from
  another worktree reads as local corruption and invites a reclone.
- **Stubs tidier than the API test a service that does not exist** (Cloudflare
  sends `"errors": []` on success).
- **Nothing user-visible may silently fail into a log nobody reads** — a
  workspace `run.log`, an info line saying "version none".
