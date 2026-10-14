# Platform contexts

The contexts underneath the product surfaces: how files on a working copy
become rows and components, accounts and machines, billing, content
publishing, the embeddings backends, the conversation recorder, and the repo's
own `cms.*` mix tasks for test databases, onboarding and provisioning leaks.
Code comments point here by section name.

| Module | Role |
|---|---|
| `Files.Scanner` | Device half of file sync: walk, classify, stat, fingerprint, validate. No database. |
| `Files.FileSync` | Database half: resolve owners, upsert, delete what is gone, announce to the graph. |
| `Files` | File rows: queries, the changed-only upsert, per-copy scoping. |
| `Files.ComponentSync` | Reconciles component records against the code main's copy declares. |
| `Devices` | The machines working copies sit on. |
| `AppTokens` | Short-lived tokens a deployed app exchanges its refresh secret for. |
| `Billing` | Stripe subscriptions; the webhook writes `account.plan`. |
| `Content` / `ContentPublishing` | Published content; local snapshot → S3 blob + manifest → client pull. |
| `Embeddings.HexDocReconciler` | Embeds each pinned hex package@version's docs once. |
| `Embeddings.HetznerFlameBackend` | FLAME backend bursting embed runners onto the environment's burst box. |
| `AgentHarness.ConversationRecorder` | Proxies a sprite's model turns upstream and records them. |
| `Users`, `Invitations`, `UserPreferences` | Accounts' people, invites, and the saved active account/project. |
| `Mix.Tasks.Cms.*` | Test-database checks, onboarding a checkout, the spex leak sweep. |

## Files and working copies

- **Rows are per working copy.** `files` is unique on
  `(project_id, working_copy_id, path)`. A writer with no working copy writes
  against the project's nil-object copy (`WorkingCopies.ensure_default/1`),
  because ON CONFLICT never matches a null.
- **Readers with no checkout read main.** `WorkingCopies.reading_copy_id/1`
  picks the project's main copy; only a project with no main copy blends every
  copy. A blend reads one worktree's stray file as present everywhere — an
  orphan reported to every checkout, none of which can fix it.
- **Project-scoped artifacts read every copy** (`list_project_files/1`,
  personas), and nothing else does.
- **Copies whose path is missing are excluded** from presence questions
  (`path_missing_since`): a deleted checkout cannot send a final manifest.
- **The upsert is the diff.** `on_conflict_changed_only/0` updates a row only
  when a replaceable column differs, and `RETURNING` hands back exactly the
  rows written, so one statement is both the write and "what moved". A
  hand-written Elixir diff read the whole table per manifest and was wrong
  twice. `component_id` coalesces (a manifest that cannot resolve a component
  keeps the server's); `story_id` does not (a dropped story is a real clear).
  `@replaceable_fields` and the `on_conflict` columns are separate lists — keep
  them in step.
- **Dangling component ids are dropped before insert.** Another harness's
  `ComponentSync` can prune a component between our read and our insert; the FK
  violation used to roll back the manifest, close the channel, and loop on
  reconnect. Dropping costs one link the next sync restores. The race is
  narrowed, not closed; closing it means serialising reconcile per project.
- **Deletes are scoped to the harness** that sent the manifest; unscoped, two
  copies of one project erased each other on every scan.

## File sync

- **Split by what each half needs.** `Scanner` runs where the files are and
  ships only verdicts, never content. `FileSync.reconcile/2` needs only the
  database, so a harness with none sends its observations to the server.
- **Whole observation sets, never deltas** — only a full set can tell a
  deletion from an omission.
- **A refusal is never an empty scan.** `Scanner.observe/2` and
  `stream_files/1` return `{:error, reason}` when the environment cannot walk;
  `FileSync` carries `{:error, {:cannot_scan, reason}}` out. Folding the
  refusal into `[]` once deleted every row and problem for a working copy, and
  the next read deleted them again after the harness re-sent them.
- **`:not_supported_on_harness` logs at `:info`** — it is a property of the
  environment and fires on every stop hook for a harness-backed copy; any other
  refusal is `:error` (`scan_refusal_level/1`).
- **The server resolves ownership.** A harness's read model is fetched once at
  channel join and goes stale (a sprite joins before stories exist, so spex
  never linked and `bdd_specs_exist` could never pass). `reconcile/2`
  re-resolves against the live domain on every manifest.
- **`reconcile_and_project/2`** commits the file reconcile and the incremental
  component projection in one transaction, with an explicit 60s timeout (Ecto's
  15s default sits inside the measured tail). A timeout kills the task and its
  pooled connection, which the harness sees only as a closed channel and a
  rejoin that rescans everything — so every reconcile logs its duration, warns
  at two thirds of the limit, and a failure is logged by name before reraising.
- **The automatic path projects incrementally**: only the components changed
  files name, plus an orphan check for removed files' module names. The full
  resync is for explicit `sync_project` / `/codemyspec:sync`.
- **Announcing.** A sync that changed anything records a `files_synced` event
  and marks sharing one observation id with its log line. A removal names no
  entities (`:unknown`, full recompute) because the rows that would name the
  owners are gone. `sync_path/3` (the watcher) announces too, only on a moved
  fingerprint or a removed file.
- **Specs-ready is cleared on a fingerprint change**, not an mtime change. The
  watcher updates fingerprints eagerly, so it must clear specs-ready itself:
  the later stop-hook pass sees the fingerprint already matching and never
  fires.
- **Lockfile and project-knowledge reconciles** run after the transaction
  commits and off the caller (the caller may be the channel, and reading back
  over it would self-call). Both re-derive "did it change" from stored state,
  so `LockfileSweep` is a correct backstop.
- **mtime is the pre-filter, fingerprint is the truth.** `sync_changed` opens
  only files with a newer mtime; out-of-band consumers gate on the fingerprint.

## File classification

- `@sync_roots` bounds the walk; `@ignored_dirs` keeps build output and vendored
  source out. The deploy roots are walked so `DeployBoilerplate.missing/2` can
  answer from rows (one `:deploy_artifact` role, existence only).
- **An artifact a requirement reads must be classified**, or it never syncs and
  the requirement reports it missing while it sits on disk — which looks like a
  dead file watcher. `unclassified/1` lists what nothing claims, and
  `ClassifiableArtifactsTest` enumerates the gated artifacts.
- **Verdicts are decided where the file is.** Spex, setup files, personas, QA
  plans, integration specs and encrypted env key names are validated at scan
  time into `validation_errors`, so checkers read rows and never a disk the
  server may not have. Integration specs record facts (`pending` is not
  invalid).
- QA verify scripts are claimed so creating one moves the graph fingerprint.
  Files no graph node reads (`qa/summary.md`, `design/design_system.html`) are
  deliberately unclaimed.
- **Ownership, in order:** a spex file's recorded criterion; the path against
  components projected forward into conventional paths (exact); the
  `defmodule` the file declares; a module derived from the path (a guess —
  `Git.Cli` never matches `Git.CLI`). Story directories resolve through
  `story_ids_by_number` because numbers are durable and ids are
  per-deployment.

## Component sync

- Components are records; a sync reconciles existence only. A module main's
  code declares with no component is created `:discovered`; a `:discovered`
  component main's code no longer names is pruned unless an authored
  dependency or a story points at it. Authored and unmarked components are
  never pruned here.
- "Main's code" is `Files.LiveCopies.speaking_ids/1`: a feature copy's new
  module is discovered once promoted; a stale copy's deletion is not believed.
- **It announces its own change.** Callers run `FileSync.sync/2` and then this,
  so `FileSync`'s announcement lands before the components exist; a recompute
  in that window answered from a half-applied sync. Only changed component ids
  are announced, project-wide (component rows are read by every checkout).
- File ownership is backfilled by the same path patterns `Files.read_model/1`
  uses, plus the scanned `defmodule` for Phoenix files outside their
  conventional directory; an owned file is never re-claimed.

## Devices

- The machine mints its device id once (`~/.codemyspec/device.json`) and
  presents it forever. Server-issued ids raced: several daemons on one box
  share one file, and each announce was handed back the other's answer.
- A self-picked id is not trusted as globally unique: one colliding with
  another account's device gets a fresh server-minted id. A collision with this
  account's row is two daemons racing; the loser recognises the winner's row.
- Recognition also checks the user's other accounts (a machine carries copies
  from every account), and never moves the row.
- A nil account matches only accountless devices (`is_nil/1`, since `= NULL`
  matches nothing).
- `announce/3` (identity, once at boot) and `mark_alive/1` (liveness) are
  separate; conflating them made `last_seen_at` mean "last reboot".
- `destroy/2` cascades to the device's working copies; records of work done on
  them are `SET NULL`.

## Billing

- `account.plan` has one writer, the Stripe webhook — except `start_subscription/3`
  with no Stripe key configured, which grants directly because no webhook will
  come.
- **One subscription per account.** An existing billing subscription is moved
  to the new price (the subscription *item*, not a new line). A duplicate bills
  the sum while our data looks correct; the only record of it is in Stripe.
- **When the existing subscription cannot be read, refuse.** A refused checkout
  is visible and retried; a duplicate is invisible and bills monthly. A DNS
  blip under the old "create anyway" fallback produced exactly that duplicate.
- The account is reloaded before branching: `stripe_subscription_id` is written
  by a webhook after the page mounted, and the scope's copy is stale.
- Trials grant on `customer.subscription.created` with status `trialing`
  (there is no invoice at trial start) and confirm a `pending_setup_intent`;
  a downgrade's proration is a credit with no secret, which means done.
- Webhook metadata lives at the top of a subscription event and under
  `parent.subscription_details` on an invoice; both are read, or the event is
  deduped and grants nothing.

## Content publishing

- `ContentPublishing.sync/2` parses markdown from a directory on disk (no git)
  into `content_snapshots`; a bad file is an error row, schema-validated at sync
  so it never rolls back the client's persist.
- `publish/1` refuses while any row has errors, writes `content.json` and a
  hashed `manifest.json` to the project's bucket, then triggers the deployed
  client, which runs `Content.Pull` → `Content.sync_content/1` (replace-all in
  one transaction). A trigger failure still returns the written objects.
- **Sync is trigger-only.** Nothing reconciles later, so an unconfigured trigger
  is an error, not a quiet success.
- `aws_*` fields are any S3-compatible provider's. With `s3_endpoint` set,
  signing uses that host (scheme stripped) and object URLs are path-style
  against it — Hetzner, which provisioning uses, needs both; a bare
  `https://<bucket>/` URL resolved nowhere and the pull aborted after the
  trigger had been accepted.

## Conversation recorder

- A pass-through that observes: the upstream response is returned unchanged,
  and every write is wrapped so recording can never fail the run.
- **Client housekeeping is dropped** by literal prefix (`@client_wrappers`):
  transcript classifiers, suggestion and status prompts. Measured, they were
  most of the recorded bytes, rendered as the agent's own words, and duplicated
  every tool result. Matching on the model or system prompt would be structural
  but neither reaches the recorder; a length or shape heuristic would drop real
  turns.
- Tool results get one row each with their `tool_use_id`; tool calls keep the
  provider's id, so the view pairs them.
- Free text identical to the last `:user` message is skipped (repeated system
  reminders were a fifth of all rows). The comparison is per role — against
  the last message outright it always meets the previous response.
- Only `<system-reminder>` blocks are stripped from requests; guessing at
  other preambles would eventually eat a real question. A turn that is only
  injected context, only thinking, or only tool calls still leaves a trace.

## Hex doc reconciler

- Embeds per `(package, version, model)`, never per project; the
  `doc_packages` marker commits with the chunks.
- Terminal failures (404, checksum, unparseable, non-5xx status) are one
  `failed`/`no_docs` row; everything else defers with `attempts` up to
  `@max_attempts`, then fails.
- Killed tasks surface as `{:exit, _}` in the `Task.async_stream` results and
  are deferred; an early sweep went silent for 40+ minutes because nothing read
  them. Every sweep logs one summary line.

## Test databases

- Each worktree has its own test database, plus analyzer partitions with `a`
  (exunit) and `s` (spex) suffixes. A bare `MIX_ENV=test mix ecto.migrate`
  migrates only the one the session resolves, so every message names the
  partition it is about.
- `cms.check_test_migrations` raises when behind and creates a missing database
  in-VM (`storage_up/1` + `Ecto.Migrator` on `Repo.config()`), never by
  shelling out to `mix`. `cms.migrate_test_partitions` migrates the three that
  exist and creates none.
- The partition base comes from onboarding's recording, not
  `MIX_TEST_PARTITION` (often inherited from another checkout) and not the
  resolved database (a suffix cannot be stripped reliably).
- A database can be current by version and wrong by schema (two migrations once
  shared a version). The repair is dropping the partition, not migrating again.

## Onboarding

- `cms.harness.onboard` mints the working copy's id from the server and writes
  `.cms_harness.json` and `.claude/settings.local.json` through
  `ClientUtils.Harness.Onboarding`, the single implementation (`--check` too).
- The minting server is `--server-url`, else the copy's recorded server, else
  the project's committed one, else the build's default; a foreign root warns.
- The partition is written once (`put_new`) and never re-derived: renaming it
  would orphan a migrated database.
- Every write is merged over what is there; re-onboarding reads both
  `working_copy_id` and `harness_id`, so a copy keeps its identity.

## Provisioning leak sweep

- `cms.provisioning_leaks` lists what the spex account still holds, split into
  spex-marked and real, so the expensive mistake — deleting a real resource —
  stays obvious. `--delete` goes through `Teardown`, skips servers younger than
  an hour (age, not a lock, because a stale lock fails toward deletion), and
  `--force` drops that window.
- Markers: Hetzner names are prefixed `spex-`; DNS records carry `spex-` as a
  label prefix or `c` + four digits starting a label, anchored left on a label
  boundary. Narrower patterns each hid live leaks. The long-lived drill
  environment (`spex-drill`) is excluded by marker.
- A collector that fails says so; "nothing leaked" and "nothing was checked"
  must never look the same.

## Lessons

- **A refusal must never look like an empty answer.** "Could not look" read as
  "nothing is there" deleted whole projections — twice.
- **Two lists that must agree need one source.** Hand-kept pairs (a diff and its
  `SET`, path patterns in two modules) drifted every time.
- **Ownership is decided by whoever holds the live domain**, not by a cached
  read model shipped elsewhere.
- **A writer announces its own change**, at the moment it lands; another
  writer's announcement is not cover.
- **Log the ordinary case**, not only the near miss: trends and silence are
  only visible against a baseline.
- **Name the database, the working copy, the server** in every message — two of
  each answering is the common failure.
- **Under uncertainty, fail toward the visible error** — refuse a sale, refuse a
  delete — rather than toward a silent cost.
