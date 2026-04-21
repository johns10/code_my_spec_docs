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

### How to exercise MCP tools

Two approaches. **Use the direct-Elixir harness for bug hunting** — it's the one that caught everything in the 2026-04-20 pass. HTTP is worth doing once at the end to confirm the transport wraps correctly.

#### Prerequisites

- `mix phx.server` running on `:4003` (the local dev server must be up for hot reload, but you drive tests in a separate shell).
- A real project row with `local_path` set — test against `metric_flow` or any other linked project. Create one via `init_project` if needed.
- An auth token seeded into `client_users`. Quickest path:
  ```elixir
  # mix run --no-compile -e '<paste below>'
  {:ok, token_line} = System.cmd("mix", ["run", "--no-compile", "-e", "Mix.Tasks.GetJohns10Token.run([])"])
  # Grab the bearer token from stdout, then:
  expires_at = DateTime.utc_now() |> DateTime.add(7200, :second) |> DateTime.truncate(:second)
  attrs = %{id: 1, email: "johns10@gmail.com", oauth_token: "<paste_token>",
            oauth_refresh_token: "unused", oauth_expires_at: expires_at}
  %CodeMySpec.ClientUsers.ClientUser{}
  |> CodeMySpec.ClientUsers.ClientUser.changeset(attrs)
  |> CodeMySpec.Repo.insert(on_conflict: {:replace_all_except, [:id]}, conflict_target: [:email])
  ```
  Without this, every auth-required tool returns `not_authenticated` and you can't exercise their happy paths.

#### Approach A — Direct Elixir (recommended for bug hunting)

Fastest iteration, best failure modes (real stacktraces, no HTTP async silliness). Bypasses transport but exercises every tool + domain boundary.

Template harness (`/tmp/smoke.exs`):

```elixir
alias Anubis.Server.Frame
alias CodeMySpec.{Users, Accounts, Projects, Repo}
import Ecto.Query

user = Repo.one(from u in Users.User, limit: 1)
account = Repo.one(from a in Accounts.Account, limit: 1)
project = Repo.one(from p in Projects.Project,
                   where: not is_nil(p.local_path),
                   limit: 1)

scope = %Users.Scope{
  user: user,
  active_account: account,
  active_account_id: account.id,
  active_project: project,
  active_project_id: project.id,
  cwd: project.local_path,
  environment: CodeMySpec.Environments.Environment.new(:local, project.local_path)
}

frame = %Frame{assigns: %{current_scope: scope, working_dir: project.local_path}}

run = fn label, mod, params ->
  IO.puts("\n===== #{label} =====")
  try do
    case mod.execute(params, frame) do
      {:reply, resp, _} ->
        is_err = Map.get(resp, :isError, false)
        text = resp.content |> Enum.map_join("\n", fn c -> Map.get(c, "text", "") end)
        IO.puts("[#{if is_err, do: "ERR", else: "OK"}] #{String.slice(text, 0, 400)}")
        text
    end
  rescue
    e -> IO.puts("[RAISE] #{Exception.message(e) |> String.slice(0, 400)}"); nil
  end
end

# Happy path
run.("list_stories", CodeMySpec.McpServers.Stories.Tools.ListStories, %{})

# Intentionally broken inputs — these surfaced real bugs in 2026-04-20
run.("get_issue (bad uuid)", CodeMySpec.McpServers.Issues.Tools.GetIssue,
  %{issue_id: "not-a-uuid"})
run.("list_issues (bad status)", CodeMySpec.McpServers.Issues.Tools.ListIssues,
  %{status: "bogus"})
run.("list_stories (negative limit)", CodeMySpec.McpServers.Stories.Tools.ListStories,
  %{limit: -5})
run.("list_tasks (fake session)", CodeMySpec.McpServers.Tasks.Tools.ListTasks,
  %{session_id: "ghost-session"})
run.("read_knowledge (traversal)", CodeMySpec.McpServers.Knowledge.Tools.ReadKnowledge,
  %{path: "../../../../etc/passwd"})
run.("read_knowledge (bad library)", CodeMySpec.McpServers.Knowledge.Tools.ReadKnowledge,
  %{library: "bogus", path: "foo.md"})
```

Run it:

```bash
mix run --no-compile /tmp/smoke.exs 2>&1 | grep -E "^===|^\[(OK|ERR|RAISE)"
```

Always use `--no-compile` — a running `mix phx.server` holds the `_build/` lock and a plain `mix run` will trip over `CodeMySpec.Environments.registry_child_spec/0 is undefined`. The `--no-compile` flag bypasses the re-compile that would otherwise conflict.

Filter `grep -v "^\[debug\]\|^SELECT\|^↳\|^\[90m"` when output is too noisy.

**What to look for:**

- `[RAISE]` = bug. Any Ecto `invalid_text_representation`, `UndefinedFunctionError`, `FunctionClauseError`, or `ArgumentError` from `String.to_existing_atom` means the tool doesn't guard its inputs.
- `[ERR]` with `inspect(atom)` or `inspect({:tuple, …})` in the user-facing message = sloppy error formatting. Compare to clean cases like "Invalid severity: ...". Allowed values should be shown.
- `[OK]` with empty content or content containing `nil`, `your_app`, or `[]` placeholders = silent-success bug. `install_agents_md` without `mix.exs` looked like this.

#### Approach B — HTTP (transport smoke)

Use this once per pass to confirm the Anubis transport wraps the tool responses cleanly. Do not use for input-validation hunting — the async 202 model is a pain to script.

Helper scripts live at `/tmp/mcp_call.sh` (init + send) and `/tmp/mcp_tool.sh` (tools/call). Rough recipe:

```bash
# Init (captures mcp-session-id)
rm -f /tmp/mcp_session.txt /tmp/mcp_counter.txt
/tmp/mcp_call.sh initialize \
  '{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"qa","version":"0.1"}}'

# notifications/initialized (required)
curl -sS -X POST http://localhost:4003/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "X-Working-Dir: $PWD" \
  -H "mcp-session-id: $(cat /tmp/mcp_session.txt)" \
  --data-binary '{"jsonrpc":"2.0","method":"notifications/initialized"}'

# Call a tool
/tmp/mcp_tool.sh list_projects
```

Streamable HTTP returns 200 + inline SSE for synchronous tool responses, **or** 202 with empty body + response on a separate long-lived GET stream. Open a persistent GET before POST'ing the tool call to catch async responses:

```bash
curl -sS -N -X GET http://localhost:4003/mcp \
  -H "Accept: text/event-stream" \
  -H "mcp-session-id: $(cat /tmp/mcp_session.txt)" > /tmp/mcp_stream.log &
```

Then `tail -f /tmp/mcp_stream.log` while you POST calls. Each response arrives as a `data: {...}` line.

#### Edge-case library that keeps paying dividends

Feed every tool that takes an ID at least one of these. Multiple real bugs came out of it.

| Input | What to try | Why |
|---|---|---|
| **ID params** | `"not-a-uuid"`, `"00000000-0000-0000-0000-000000000000"`, `999999999` | Catches unguarded `Ecto.UUID.cast`, missing `get_by` → nil handling. |
| **Enum-ish strings** | `"bogus"`, `"EXTRA-critical"`, `""`, `nil` | Catches `String.to_existing_atom/1` raises (see SessionType fix). |
| **Pagination** | `limit: -5`, `limit: 0`, `limit: 500`, `offset: 99999` | Catches Postgres `invalid_row_count_in_limit_clause` and unbounded queries. |
| **Required string fields** | `""`, `" "`, 10KB string | Catches missing length validation. |
| **Path params** | `"../../../etc/passwd"`, `"/etc/passwd"`, `"does/not/exist.md"` | Catches traversal + silent-not-found bugs. |
| **Precondition mismatch** | Tool needing `mix.exs` run from `/tmp/empty_dir`; tool needing session run without session_id | Catches silent-success fallbacks. |
| **State transitions** | `dismiss_issue` on an already-dismissed issue; `start_task` twice for same requirement | Catches missing state-machine guards. |

#### Common gotchas

- **Running server holds `_build/` lock.** `mix run` rebuilds and sometimes fails startup with odd "module not available" errors. Always use `mix run --no-compile`.
- **`Map.get(params, "key")` is always wrong on tool input.** Anubis delivers atom-keyed params. String-key patterns silently fall through to defaults (see `list_knowledge` + `embed_hexdocs` bugs).
- **`%Scope{}` in frame must be under `:current_scope`**, not `:scope`. Several tools had this typo and crashed on a valid session_id.
- **`scope.active_project` may not be loaded** even when `active_project_id` is set. Tools that access `scope.active_project.name` crash if a partial scope slips through. Always resolve via `Validators.validate_local_scope/1`.
- **Embeddings are CLI-binary-only.** Running `embed_*` / `semantic_search` under `mix phx.server` should return "embeddings unavailable in this runtime", not raise. Regression test: kill the running server, `mix run --no-compile` a call — should still be graceful.
- **Pagination with no matches** returns an odd "Showing 100000-99999 of 51 total" style message. Not a crash, but a display regression to watch for.

---

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
