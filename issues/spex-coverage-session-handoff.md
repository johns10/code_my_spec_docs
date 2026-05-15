# Spex Coverage Tightening — Session Handoff

Hot start prompt for the next conversation. This is a continuation of
the ongoing "tighten spex coverage to improve overall reliability"
initiative.

## What just shipped

### Story 127 (filesystem-to-DB projection) — 16 spex, all passing

This was the focus of the previous session. The complete inventory:

| Criterion | What it asserts |
|---|---|
| 5919 | Deleted file is reaped from the DB on next sync |
| 5920 | Full sync rescans every tracked file in the project |
| 5921 | Incremental sync processes only mtime-newer files (via stop hook) |
| 5922 | Single-path sync touches exactly one file |
| 5923 | sync_path leaves mtime stale + follow-up full sync catches up (2 scenarios) |
| 5924 | Saving a spec flows through classify → validate → upsert → component derivation |
| 5925 | Spec file validity comes from document parsing |
| 5926 | Malformed spec marked invalid with parser error |
| 5927 | mix.exs validity comes from concern-keyed checks |
| 5930 | Files outside the project source tree are not picked up |
| 5931 | Content edit produces new fingerprint + triggers downstream consumers |
| 5933 | Offline-deleted file reaped on next sync |
| 5934 | Single-path sync on missing path deletes the File row |
| 5937 | Misaligned test file marked invalid with alignment errors |
| 5944 | sync_path updates fingerprint eagerly while leaving mtime stale |
| 5945 | mtime flip without content change leaves fingerprint unchanged |
| 6085 | Linked project's file changes appear in /files without engineer intervention |

Retired: 5928 (boot starts watcher — supervisor mechanics, unit test territory),
5929 / 5938 / 5939 (same rule, same justification).

### Architectural change: `CodeMySpec.ProjectSync.Sync`

The file watcher was split into:
- **`FileWatcherServer`** — OS event source (FileSystem subscription, mix.lock polling)
- **`CodeMySpec.ProjectSync.Sync`** (new) — orchestrator: FileSync.sync_path + FileComponentSync + PubSub broadcast

Production: OS event → FileWatcherServer.handle_info → `Sync.sync_path`.
Specs: `Fixtures.notify_file_changed/2` → `Sync.sync_path`.

`FilesLive` subscribes to `"project:<id>:watcher"` and renders
`[data-test='watcher-last-event']` + `[data-test='watcher-activity']`
on incoming events.

### Boundary tightening — Fixtures is now the only door

- `CodeMySpecSpex.Fixtures` promoted to a top-level boundary with
  `deps: [CodeMySpec, CodeMySpec.Environments, CodeMySpecTest]`.
- `CodeMySpecSpex` (the spex boundary itself) no longer depends on
  `CodeMySpec` or `CodeMySpec.Repo`. Current doors:
  `[Environments, McpServers, Fixtures, Web, LocalWeb]`.
- `Fixtures.notify_file_changed/2` added as the "a file changed" surface.

The `:spex` compiler config in `mix.exs` is intentionally NOT enabled
because the suite has ~100 pre-existing boundary violations. **The
cleanup is its own issue** — see `.code_my_spec/issues/spex-boundary-tightening.md`.

### Documentation updated

- `.code_my_spec/knowledge/bdd/spex/surfaces.md` — file-change surface
  routed through Fixtures
- `.code_my_spec/knowledge/bdd/spex/cassettes.md` — `clean.json`
  inventory corrected (was mis-described as no-op)
- Memory: `feedback_sync_path_is_a_surface.md` — direct
  `ProjectSync.Sync` calls are forbidden; bridge through Fixtures
- Memory: `feedback_defer_spex_config_enable.md` — don't re-enable
  spex compiler config until the cleanup lands

## Next session — pick one

### Option 1: Boundary cleanup (~half-day, judgment-heavy)

Open `.code_my_spec/issues/spex-boundary-tightening.md`. That issue is
a self-contained prompt:
- Reads all relevant rules + memory entries up front
- Lists the ~100 violations by module
- Provides remediation guidance per module (Fixtures delegate vs.
  surface drive)
- Defines verification (zero violations + `mix spex` green)

When done, the `:spex` compiler config gets re-enabled permanently as
the gate against regression. The framework `boundaries.md` doc gets
updated to match reality (the doc was always the gold standard; the
suite finally catches up).

### Option 2: Continue spex coverage tightening on another story

The list of stories with pending Gherkin or thin coverage worth
revisiting (from prior session audits):

- **553** (project configuration / local quality gate settings) — has
  6076/6077 written but the rest is pending. May be worth a sweep.
- **460** (BDD specification lifecycle) — spex exists but the harmony
  pass never finished.
- **697** / **698** (dashboard / activation funnel) — has some QA spex
  but probably more to do here as the funnel evolves.
- Anything the engineer prioritizes — open the new session with
  "tighten spex for story N" and the harness will start there.

If picking this option, **also be aware** that introducing new spex
files while the boundary cleanup is pending may add new violations.
Prefer the cleanup first if possible, or write new spex strictly
through the existing doors (`Environments`, `McpServers`, `Fixtures`,
LiveView) to avoid adding to the backlog.

### Option 3: Other open issues

Several other in-flight items spotted in this session, worth scoping
before picking up:

- The "Quick sync" + "Sync" twin buttons in `files_live.ex` both have
  `phx-click="sync"`. Test helpers (`shared_givens.ex`,
  `full_satisfaction_fixtures.ex`, several spex) use the selector
  `button[phx-click='sync']` which now matches both. ~8 call sites
  need to migrate to `[data-test='sync-button']`. **This is currently
  the cause of ~178 spex failures when the full suite runs.**
- Reviewer-flagged spex discipline drift across the suite — the BDD
  rules are in better shape than the spex files comply with. Could be
  a "rule audit" pass after the boundary cleanup.

## What to read on session start

These files set the floor:

1. `.code_my_spec/AGENTS.md` — workflow guide
2. `CLAUDE.md` (project root) — project conventions
3. `priv/knowledge/bdd/spex/{boundaries,writing_a_spex,environment}.md` — framework BDD rules
4. `.code_my_spec/knowledge/bdd/spex/{surfaces,cassettes,four_surfaces_quick_reference}.md` — project BDD rules
5. Memory directory at
   `/Users/johndavenport/.claude/projects/-Users-johndavenport-Documents-github-code-my-spec/memory/`
   — start with `MEMORY.md`, then read the feedback entries it links

## State of the working tree at handoff

Uncommitted changes (relevant):

- `lib/code_my_spec/project_sync/sync.ex` (new)
- `lib/code_my_spec/project_sync/file_watcher_server.ex` (refactored)
- `lib/code_my_spec_local_web/live/files_live.ex` (PubSub subscription + watcher data attrs + Quick sync button — the last one is upstream-introduced)
- `test/support/code_my_spec_spex.ex` (Fixtures in deps, CodeMySpec/Repo out)
- `test/support/code_my_spec_spex_case.ex` (lib/test/.code_my_spec subdirs in stub_dir)
- `test/support/fixtures/spex_fixtures.ex` (top-level boundary, notify_file_changed)
- 7 new + several edited spex in `test/spex/127_filesystem_to_db_projection/`
- `.code_my_spec/knowledge/bdd/spex/{surfaces,cassettes}.md`
- `mix.exs` (no functional change — `spex:` config tried and reverted)
- `.code_my_spec/issues/spex-boundary-tightening.md` (new)
- `.code_my_spec/issues/spex-coverage-session-handoff.md` (this file)

DB cleanup that happened during the session:

- Criterion 5928, 5929, 5938, 5939 deleted from local SQLite (`~/.codemyspec/cli.db`)
- Criterion 6085 added under the watcher-auto-attach rule
  (`2552bfbd-7276-4972-ab45-81ca4a071ef7`)

No commits made — the engineer hasn't asked yet. Coordinate with them
on whether to stage one big commit or split before continuing.
