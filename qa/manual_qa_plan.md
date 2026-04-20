# CodeMySpec Manual QA Plan

Living doc. Walk sections in order; skip anything already proven. Add findings inline as you discover them. Last-audited: 2026-04-20.

---

## How to use

- One session = one section. Don't try to do it all in one sitting.
- Each item has a **pass criterion** (the concrete thing that has to be true) and a **where** pointer to file/line if there's a known risk.
- Record failures under the section's `## Findings` subheading with date + short note. Convert real bugs into issues under `.code_my_spec/issues/`.
- Status: `[ ]` pending → `[~]` in progress → `[x]` passing → `[!]` failing (see findings).

---

## Section 0 — Pre-flight cleanup (30 min, do first)

Get the repo into a state that won't embarrass on a first clone.

- [ ] Delete `erl_crash.dump` from repo root (already gitignored but currently on disk).
- [ ] Delete `diagnostics.jsonl` from repo root if not needed by tooling.
- [ ] Confirm `vpn.conf` is either needed + safe to publish, or remove + gitignore.
- [ ] Confirm `braindump.md` should ship — if not, gitignore.
- [ ] Run `git status --short` — nothing surprising should be dirty.
- [ ] Resolve skill file casing (see Section 5 finding): pick one of `SKILL.md` / `skill.md` and make all seven skills match.

## Section 1 — Fresh-install happy path (60 min, clean machine or VM)

This is the one test that matters most. If this passes, you can ship.

- [ ] Clone `code_my_spec_claude_code_extension` on a clean box (not your dev box).
- [ ] Run `./install.sh`. Pass: binary downloads to `bin/cms`, chmod +x succeeds, no errors.
- [ ] `claude extension add /path/to/extension`. Pass: extension loads without plugin-schema errors.
- [ ] Start a new Claude Code session in an empty directory. Pass: extension initializes, MCP server connects to `http://localhost:4003/mcp`.
- [ ] Verify every skill is invocable (`/init`, `/design`, `/develop`, `/implement`, `/product`, `/qa`, `/sync`). Pass: each one resolves, `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill` script exits 0, response JSON parses.
- [ ] Run `/init auth`. Pass: auth URL opens in browser, you can complete sign-in, status check returns authenticated.
- [ ] Run `list_projects` MCP tool. Pass: returns at least your test account's projects (or empty list, not error).
- [ ] Run `init_project` with a test slug. Pass: project created, working directory registered.
- [ ] Run `sync_project`. Pass: returns counts, no silent success with zero files synced when files exist.
- [ ] Run `get_next_requirement`. Pass: returns a requirement or an init-checklist message, not a crash.

### Findings

_(append here as you go)_

## Section 2 — Binary cold-start UX (30 min)

Confirmed issue during audit: `cms --help` with a cold Burrito cache dumps 200MB+ of debug unpack logs to stdout, and on second invocation produces no visible help output while the binary hangs consuming CPU.

- [ ] Run `cms --help` on a clean box. Pass: useful help text shown. **Fail as of 2026-04-20** — dumps Burrito debug, no help printed on second run.
- [ ] Run `cms` with no args. Pass: either prints help or starts the server with a clear banner. Currently: hangs with no output.
- [ ] Confirm whether `cms` is meant to be invoked by the user directly or only by the extension's hooks. Document the answer in the README.
- [ ] If there's a server-start path: confirm shutdown signal (ctrl-C) works cleanly and doesn't leave Phoenix ports bound.

### Findings

- 2026-04-20: Two `cms` processes left running at ~90% CPU after killing terminal. Investigate Burrito launcher behavior when stdout isn't a tty; likely related to `PatchLauncherStep`.

## Section 3 — MCP tools verification matrix

Audit (2026-04-20) identified 31 tools on the local server. Test each at least once. Priority reflects first-user impact.

Exercise approach: the HTTP transport goes async for many tools (202 Accepted, response on separate SSE stream). Hardest to script. Shortcut — call tool modules directly via `mix run` with a constructed `Frame` + `Scope`. Bypasses transport but exercises tool + domain logic. See `/tmp/mcp_smoke.exs` for the harness used 2026-04-20.

### P0 — First-user flow (must work)

- [x] `list_projects` — 2026-04-20 OK. Auth-required, returns clean "Failed to list projects: not_authenticated" when no token.
- [ ] `init_project` — with valid project_id, with missing X-Working-Dir header, with duplicate. Only tested "bad uuid" path, which hits auth first.
- [x] `sync_project` — **FIXED 2026-04-20**: was crashing with `invalid input value for enum file_role: "task_artifact"`. Missing migration added (`20260420200000_add_task_artifact_to_file_role.exs`).
- [x] `get_next_requirement` — **FIXED 2026-04-20**: same enum issue; fixed by same migration. Returns correct init-checklist when no project linked.
- [ ] `start_task` / `evaluate_task` / `assign_task` — full lifecycle end-to-end. `start_task` with bogus params returns a clear error ("Must provide requirement_name + entity_type + entity_id, or requirement_name + module_name").

### P1 — Bootstrap installers

- [x] `install_agents_md` / `install_claude_md` / `install_rules` / `install_credo_checks` — 2026-04-20 all OK on a dir with mix.exs. **Still untested**: read-only dir, missing mix.exs (audit said falls back to nil app name silently).

### P2 — Stories / Architecture / Issues / Knowledge

- [x] `list_stories` / `list_story_titles` / `analyze_story_linkage` / `analyze_stories` — OK.
- [x] `validate_dependency_graph` — OK. Found real cycles in metric_flow (DashboardVisualization ↔ Dashboard).
- [x] `get_issue` / `accept_issue` — **FIXED 2026-04-20**: were raising Ecto error on non-UUID input. `IssuesRepository.get_issue/2` now returns nil for malformed UUIDs → tools return "Issue not found." cleanly. Same fix protects `dismiss_issue` and `resolve_issue` since they share the lookup.
- [x] `list_issues` — OK.
- [x] `read_knowledge` — **FIXED 2026-04-20**: bad library name ("bogus") silently fell back to `:knowledge` and returned "not found". Now returns clear "Invalid library 'bogus'. Use 'knowledge' or 'project_knowledge'."
- [x] `list_knowledge` — OK.
- [ ] `create_issue`, `dismiss_issue`, `resolve_issue` — not yet end-to-end tested (create → transition).
- [ ] `embed_hexdocs` / `search_hexdocs` / `embed_docs` / `semantic_search` — not tested (requires Ollama running).

### Cross-cutting

- [x] **structured_content removed from mappers 2026-04-20**. Per `feedback_no_structured_content` memory note — Claude ignores text when structured_content is set. Stripped from bootstrap_mapper, requirements_mapper, stories_mapper, issues_mapper, architecture_mapper, and list_projects tool. Cascade-fixed 6 test files.
- [ ] Orphan tools (`CreateStories`, `CreateComponents`, `ClearStoryComponent`, `TriageIssues`) — confirm delete vs register.

### Findings

- 2026-04-20: **Missing migration** — `task_artifact` in Elixir `File` schema enum but not in Postgres `file_role` enum. Crashed `sync_project` & `get_next_requirement` on any project with task artifacts. Fix: added migration `20260420200000_add_task_artifact_to_file_role.exs`.
- 2026-04-20: **Issue tools crashed on non-UUID input** — Ecto raised `invalid_text_representation`. Fix: `IssuesRepository.get_issue/2` now casts via `Ecto.UUID.cast/1` and returns nil on `:error`.
- 2026-04-20: **`read_knowledge` silent fallback** — unknown library name fell through to `:knowledge` default. Fixed with explicit validation.
- 2026-04-20: **`list_knowledge` + `embed_hexdocs` string-key bug** — tools matched `%{"library" => _}` / `%{"package" => _}` but schema delivers atom keys. Every call silently fell to defaults: library was always `:knowledge`, path was always root, package filter always ignored. Fixed.
- 2026-04-20: **Embed/search tools crashed in dev runtime** — `embed_docs`, `embed_hexdocs`, `semantic_search`, `search_hexdocs` all raised (missing Ortex module / missing `doc_embeddings` table) when Phoenix dev server handled the call. The pipeline only ships with the CLI binary (Ortex + sqlite_vec are `only: [:dev_cli, :prod_cli]`). Added `CodeMySpec.Embeddings.available?/0` gate; all 4 tools now return a clean "embeddings unavailable in this runtime" message.
- 2026-04-20: **`embed_docs` docstring was wrong** — said "Ollama + mxbai-embed-large", actual impl is Ortex + all-MiniLM-L6-v2. Fixed.
- 2026-04-20: **`list_tasks` crashed on valid session_id** — tool read `frame.assigns[:scope]` (nil — correct key is `:current_scope`), so `Sessions.get_by_external_id/2` got nil and raised FunctionClauseError. Fix: thread the scope from the already-validated `validate_local_scope`.
- 2026-04-20: **Issue lifecycle** — create → get → accept → resolve walks end-to-end green. Dismiss path too. Re-dismissing a dismissed issue returns a clean "cannot transition from dismissed to dismissed" validation error.
- 2026-04-20: **`start_task` / `evaluate_task` / `assign_task` without session** — all return "No session_id available. The PreToolUse hook should inject it automatically." Good UX, no crashes.
- 2026-04-20: **`create_issue` validation** — missing title, bad severity, bad scope all return clean `## Validation Error` with field-level detail.

## Section 4 — Security regression (45 min)

From security audit 2026-04-20. One critical, rest defense-in-depth.

- [ ] **CRITICAL**: OAuth access + refresh tokens stored plaintext in `oauth_access_tokens` (migration `priv/repo/migrations/20250718022705_create_oauth_tables.exs:32-46`). Plan: migrate column to `CodeMySpec.Encrypted.Binary` before public launch.
- [ ] HTML injection in `lib/code_my_spec_local_web/controllers/bootstrap_controller.ex:156,177`: `#{error}` interpolated raw into HTML. Localhost-only, but fix anyway with `Phoenix.HTML.html_escape/1`.
- [ ] Rate limit on `/oauth/token`, `/oauth/register`, `/api/*` — none today (`lib/code_my_spec_web/router.ex:82-88,122-153`). Decide launch posture: add `plug_require_ratelimit` or explicitly accept the risk for first 100 users.
- [ ] CSP header missing on local web router (`lib/code_my_spec_local_web/router.ex:11`). Low impact, quick win.
- [ ] `String.to_atom` on untrusted input (`lib/code_my_spec/sessions/session_type.ex:61,73`). Replace with `String.to_existing_atom` or allowlist.
- [ ] Confirm `envs/.env` is gitignored (confirmed 2026-04-20) and no duplicate `.env*` slipped into other dirs.
- [ ] Run `mix sobelow --skip --compact` and triage remaining findings.

### Findings

_(append here as you go)_

## Section 5 — Extension surface (30 min)

The `CodeMySpec/` directory is what Claude Code loads. First-user breakage lives here.

- [ ] **Skill file casing**: `init/SKILL.md` and `sync/SKILL.md` vs `design/skill.md`, `develop/skill.md`, `implement/skill.md`, `product/skill.md`, `qa/skill.md`. Verify Claude Code's plugin loader accepts both — if not, the init/sync skills won't load. Normalize to one casing.
- [ ] `plugin.json` MCP endpoints: `stories` points to `https://dev.codemyspec.com/mcp/stories`. Is this intentional for a public extension, or should it be prod?
- [ ] Hook binary `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/hook` — verify exists, chmod +x, runs on SessionStart/PreToolUse/PostToolUse/Stop/SubagentStop without errors on a fresh install.
- [ ] Each agent markdown (`agents/*.md`) — confirm all referenced MCP tools (`mcp__plugin_codemyspec_local__*`) actually exist after tool-surface cleanup.
- [ ] Each skill's bin call (`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill <name> ...`) — verify the `skill` script handles each of `init|design|develop|implement|product|qa|sync` and returns valid JSON.
- [ ] `auto-update` bin — does it pull new binary versions silently? If so, document it. If not, delete if unused.
- [ ] README install instructions match install.sh behavior.

### Findings

- 2026-04-20: Skill casing inconsistency found. Risk unknown until tested on a fresh Claude Code install.

## Section 6 — Tests (owned by parallel agent)

Tests: 3025 total, 49 failures (1.6%). Failures look like surface drift (return-tuple mismatches, slug-format mismatches). Not a ship-blocker.

- [ ] Get to green. Parallel agent handling.
- [ ] Run `mix credo --strict` and note any new regressions.
- [ ] Run `mix boundary` — no violations.
- [ ] Run `mix format --check-formatted`.

### Findings

- 2026-04-20: Three known categories — `TechnicalStrategyTest` feedback text expectations, `QaAppTest` slug format (`login-form-broken` vs `login_form_broken`), agent-task evaluator return shape drift.

## Section 7 — Post-ship monitoring (set up before launch)

- [ ] Error reporting wired (Sentry/Honeybadger/Logflare?). Confirm prod config.
- [ ] Oban job failure alerts.
- [ ] Basic uptime check on `https://dev.codemyspec.com` (or wherever prod is).
- [ ] Analytics on MCP tool calls — which tools get used, which never do.

### Findings

_(append here as you go)_

---

## Issue log template

When you find something, copy this block into the relevant section's Findings:

```
- YYYY-MM-DD (severity P0/P1/P2): <one-line summary>. <where: file:line>. <planned fix or filed as issue-xxx>
```

## Session template

Start each QA session by picking one section. Write here what you're attempting:

```
## Session YYYY-MM-DD
- Section: <N>
- Goal: <what you're verifying>
- Result: <pass / findings filed>
```
