# CodeMySpec Manual QA Plan

Living doc. Walk sections in order; skip anything already proven. Add findings inline as you discover them. Last-audited: 2026-04-20 (confidence pass).

---

## How to use

- One session = one section. Don't try to do it all in one sitting.
- Each item has a **pass criterion** (the concrete thing that has to be true) and a **where** pointer to file/line if there's a known risk.
- Record failures under the section's `## Findings` subheading with date + short note. Convert real bugs into issues under `.code_my_spec/issues/`.
- Status: `[ ]` pending → `[~]` in progress → `[x]` passing → `[!]` failing (see findings).

---

## Section 0 — Pre-flight cleanup (30 min, do first)

Get the repo into a state that won't embarrass on a first clone.

- [ ] Delete `erl_crash.dump` from repo root (already gitignored but currently on disk). 2026-04-20 re-check: still present (4MB, Apr 20).
- [ ] Delete `diagnostics.jsonl` from repo root if not needed by tooling. 2026-04-20 re-check: still present (0 bytes).
- [x] Confirm `vpn.conf` is either needed + safe to publish, or remove + gitignore. 2026-04-20: gitignored ✓.
- [ ] Confirm `braindump.md` should ship — if not, gitignore. 2026-04-20: 0-byte file, NOT gitignored. Decide.
- [x] Run `git status --short` — nothing surprising should be dirty. 2026-04-20: clean aside from `.code_my_spec` submodule marker.
- [ ] Resolve skill file casing (see Section 5 finding): pick one of `SKILL.md` / `skill.md` and make all seven skills match. 2026-04-20: unchanged — `init/SKILL.md` + `sync/SKILL.md` (uppercase), `design|develop|implement|product|qa/skill.md` (lowercase).

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

- [!] Run `cms --help` on a clean box. Pass: useful help text shown. **Fail as of 2026-04-20** — dumps Burrito debug, no help printed on second run. **Confirmed 2026-04-20 (confidence pass)**: warm-cache run produces no stdout, pegs CPU at 92%, had to SIGTERM.
- [ ] Run `cms` with no args. Pass: either prints help or starts the server with a clear banner. Currently: hangs with no output.
- [ ] Confirm whether `cms` is meant to be invoked by the user directly or only by the extension's hooks. Document the answer in the README.
- [ ] If there's a server-start path: confirm shutdown signal (ctrl-C) works cleanly and doesn't leave Phoenix ports bound.

### Findings

- 2026-04-20: Two `cms` processes left running at ~90% CPU after killing terminal. Investigate Burrito launcher behavior when stdout isn't a tty; likely related to `PatchLauncherStep`.
- 2026-04-20 (confidence pass): Reproduced — `cms --help` from `/tmp/qa_cms_test` hung silently at 92% CPU until SIGTERM. Also observed two `beam.smp` processes from Apr 12 CLI runs still in state TN (stopped) — burrito launcher leaves orphan beam processes when prematurely killed. Fix upstream in Burrito fork.

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
- [x] `get_next_requirement` — **FIXED 2026-04-20**: same enum issue; fixed by same migration. Returns correct init-checklist when no project linked. Confidence pass: happy path returns MetricFlow.Agencies context prompt; no-auth path returns correct 4/6 init checklist.
- [ ] `start_task` / `evaluate_task` / `assign_task` — full lifecycle end-to-end. `start_task` with bogus params returns a clear error ("Must provide requirement_name + entity_type + entity_id, or requirement_name + module_name"). Confidence pass: `start_task`/`assign_task` without session return clean message; `evaluate_task` not tested with real session.

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
- 2026-04-20: **`create_issue` validation** — missing title, bad severity, bad scope all return clean `## Validation Error` with field-level detail. Valid scope values: `:app`, `:qa`, `:docs` (default `:app`). Heads-up: the old harness was calling with `scope: "project"` which is not a valid value — expected Validation Error is the correct behavior.
- 2026-04-20 (confidence pass): **`get_component` with bad UUID raises** — same class of bug already fixed for Issues. `Components.get_component!/2` lets Ecto raise `value "not-a-uuid" cannot be dumped to type :binary_id`, and a valid-format but missing UUID raises `expected at least one result but got none`. Fix: cast via `Ecto.UUID.cast/1` in `ComponentRepository.get_component/2` (or whatever the non-bang version is), return nil on `:error`, and have the tool map nil → "Component not found." Do the same sweep on any other tool calling a `!` repo function with user-supplied IDs. **FIXED 2026-04-21**: `ComponentRepository.get_component/2` now casts via `Ecto.UUID.cast/1` and returns nil on `:error`; `Components.Tools.GetComponent` switched to the non-bang version and maps nil → "Component not found". Verified: both bad-uuid and zero-uuid inputs now return clean errors; real ID still returns the component.
- 2026-04-20 (confidence pass): **`get_story` with bad id raises** — Story uses integer id; calling `Stories.get_story(scope, "not-a-number")` lets Ecto raise `cannot be cast to type :id`. Fix: guard with `Integer.parse/1` in the tool or in `StoriesRepository.get_story/2` and return nil on non-integer input. Affects any other tool that threads user strings into story id lookups. **FIXED 2026-04-21**: `StoriesRepository.get_story/2` now runs input through a private `cast_story_id/1` helper (accepts int, or `Integer.parse` round-trip), returns nil on non-integer input. Verified: bad/empty/999999 all return "Story not found", 557 still returns the story.
- 2026-04-20 (confidence pass): **`architecture_health_summary` crashes on JSON encoding** — raises `protocol JSON.Encoder not implemented for CodeMySpec.Components.Component (a struct), the protocol must be explicitly implemented`. The tool serializes component structs directly. Fix: `@derive {JSON.Encoder, only: [...]}` on `Components.Component` (and any other structs the tool embeds), or map to a plain map before encoding. Tool is fully broken until fixed. **FIXED 2026-04-21**: (a) `DependencyRepository.format_cycles/1` now reshapes each cycle to plain maps via new `component_summary/1` — no more raw `%Component{}` struct leak into cycles; (b) `ArchitectureHealthSummary.analyze_dependency_issues/2` no longer stores the raw `{:error, cycles}` tuple in the response (it was a JSON-encode failure mode of its own). Tool now returns a clean JSON blob including cycle paths.
- 2026-04-20 (confidence pass): **Harness RAISEs that are NOT bugs** (schema validation catches in the real Anubis flow): `show_requirement` and `evaluate_task` fail `no function clause` when executed with empty params directly from Elixir — normal HTTP path rejects missing required fields at schema layer. `list_projects` also fails with `could not find persistent term for endpoint CodeMySpecLocalWeb.Endpoint` when run via `mix run --no-compile` because the endpoint isn't started in that BEAM node. All three are harness artifacts only.
- 2026-04-20 (confidence pass): **Happy-path verified end-to-end**: `list_projects` (via HTTP), `list_stories`, `list_story_titles`, `list_issues`, `list_components`, `list_knowledge`, `list_requirements`, `validate_dependency_graph`, `analyze_stories`, `show_architecture_overview`, `list_project_tags`, `context_statistics`, `orphaned_contexts`, `get_next_requirement`, `analyze_story_linkage`, `get_component` (real id), `get_story` (real id), `read_knowledge` (valid path), plus full issue lifecycle create→get→accept→resolve→resolve_again (clean transition error).
- 2026-04-20 (confidence pass): **Embeddings tools** (`embed_docs`, `embed_hexdocs`, `semantic_search`) all return graceful "Embeddings are unavailable in this runtime" under `mix phx.server`. Fix from prior pass holding.
- 2026-04-20 (confidence pass): **Pagination edge cases** clean — `limit: -5`, `limit: 0`, `offset: 99999`, `limit: 500` all return without crashing. `offset: 99999` still displays "No more stories. Showing 100000-99999 of 53 total." — ugly but not a bug.
- 2026-04-20 (confidence pass): **Path traversal protection** holds — `read_knowledge` with `../../../../etc/passwd` returns "Invalid path"; with `/etc/passwd` returns "Knowledge entry not found". Both correct.
- 2026-04-20 (confidence pass): **`install_agents_md` in empty dir** (no mix.exs) now returns a clear error ("mix.exs not found in /tmp/qa_empty_XXXXX. This doesn't look like an Elixir project — CodeMySpec currently only supports Phoenix/Elixir."). `install_claude_md` and `install_rules` succeed in empty dirs (no mix.exs dependency) — intended since CLAUDE.md has no app-specific content.

## Section 4 — Security regression (45 min)

From security audit 2026-04-20. One critical, rest defense-in-depth.

- [ ] **CRITICAL**: OAuth access + refresh tokens stored plaintext in `oauth_access_tokens` (migration `priv/repo/migrations/20250718022705_create_oauth_tables.exs:32-46`). Plan: migrate column to `CodeMySpec.Encrypted.Binary` before public launch. 2026-04-20 re-check: still plaintext.
- [x] HTML injection in `lib/code_my_spec_local_web/controllers/bootstrap_controller.ex:156,177`: `#{error}` interpolated raw into HTML. Localhost-only, but fix anyway with `Phoenix.HTML.html_escape/1`. 2026-04-20 re-check: line 150 still `<p>#{error}</p>`; sobelow still flags it as `XSS.SendResp`. **FIXED 2026-04-21**: `send_error_html/2` now escapes via `Phoenix.HTML.html_escape/1 |> Phoenix.HTML.safe_to_string/1` before interpolating.
- [ ] Rate limit on `/oauth/token`, `/oauth/register`, `/api/*` — none today (`lib/code_my_spec_web/router.ex:82-88,122-153`). Decide launch posture: add `plug_require_ratelimit` or explicitly accept the risk for first 100 users. 2026-04-20 re-check: confirmed no Hammer/PlugAttack/exrated in deps, no RateLimit plug anywhere in `lib/`.
- [ ] CSP header missing on local web router (`lib/code_my_spec_local_web/router.ex:11`). Low impact, quick win. 2026-04-20 re-check: browser pipeline calls `put_secure_browser_headers` which ships a default CSP — present but lenient.
- [x] `String.to_atom` on untrusted input (`lib/code_my_spec/sessions/session_type.ex:61,73`). Replace with `String.to_existing_atom` or allowlist. 2026-04-20 re-check: **already fixed** — both `cast_full_atom/1` (:69) and `load/1` (:77) now use `String.to_existing_atom` with `@valid_types` allowlist.
- [x] Confirm `envs/.env` is gitignored (confirmed 2026-04-20) and no duplicate `.env*` slipped into other dirs. 2026-04-20 re-check: repo-wide find finds only `envs/.env`.
- [x] Run `mix sobelow --skip --compact` and triage remaining findings.

### Findings

- 2026-04-20 (confidence pass): sobelow output triaged:
  - **HIGH**: `Misc.BinToTerm` — `:erlang.binary_to_term(docs_bin)` at `lib/code_my_spec/embeddings/doc_extractor.ex:73`. Input is the `~c"Docs"` chunk of a BEAM file loaded via `:beam_lib.chunks/2`. Risk is bounded (BEAM comes from compiled deps we ship / user installs), but if we ever extract docs from user-supplied binaries this becomes remote code. Flag for follow-up: either restrict to `:safe` or document the trust boundary.
  - **MEDIUM (new)**: `XSS.SendResp` at `lib/code_my_spec_local_web/plugs/project_scope.ex:30,36`. Interpolates `name` (route param) and `inspect(reason)` into HTML bodies. LocalOnly-gated but should `html_escape`. **FIXED 2026-04-21**: plug now routes all error halts through `text_halt/3` which sets `text/plain` content-type, removing the XSS vector regardless of body contents.
  - **MEDIUM**: `DOS.StringToAtom` at `lib/code_my_spec/static_analysis/analyzers/spec_alignment.ex:210` — `String.to_atom(func_name)` from parsed spec content. Spec content is user-authored; this is an atom-exhaustion vector. Replace with `String.to_existing_atom` or cap. **FIXED 2026-04-21**: `parse_function_signature/1` now returns the function name as a string; `build_impl_function_map/1` converts impl atoms to strings via `Atom.to_string/1` so the comparison still works both ways. No atom creation from untrusted input.
  - **LOW**: Directory-traversal findings in `agent_tasks/write_bdd_specs.ex`, `bdd_specs.ex`, `embeddings/*`, `mcp_servers/bootstrap/tools/install_*`, `environments/*`, etc. Most are intended — tools write files relative to the user's local project root. Revisit only if a tool takes an untrusted path from the MCP caller without a validator.

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
- 2026-04-20 (confidence pass): Re-confirmed casing split — `init/SKILL.md`, `sync/SKILL.md` (uppercase, Apr 15 mtime), vs `design|develop|implement|product|qa/skill.md` (lowercase, Apr 14 mtime). 7 skill dirs total.
- 2026-04-20 (confidence pass): `plugin.json` `stories` endpoint is `https://dev.codemyspec.com/mcp/stories` — **decide before public launch**: point at prod or keep dev while private.
- 2026-04-20 (confidence pass): All eight plugin bin scripts exist and are +x: `agent-task`, `approve`, `auto-update`, `bootstrap-auth-start`, `bootstrap-auth-status`, `bootstrap-projects`, `hook`, `skill`. `skill` with no args returns a clean JSON usage error and exits 0.
- 2026-04-20 (confidence pass): Agent files (`qa.md`, `researcher.md`, `bdd-spec-writer.md`, `code-writer.md`, `spec-writer.md`, `test-writer.md`) reference only two MCP tools — `mcp__plugin_codemyspec_local__start_task` and `mcp__plugin_codemyspec_local__evaluate_task`. Both exist. No dangling refs.

## Section 6 — Tests (owned by parallel agent)

Tests: 3025 total, 49 failures (1.6%). Failures look like surface drift (return-tuple mismatches, slug-format mismatches). Not a ship-blocker.

- [x] Get to green. Parallel agent handling. **2026-04-20 confidence pass: 1 doctest + 3011 tests, 0 failures, 18 excluded, 62s runtime.**
- [x] Run `mix credo --strict` and note any new regressions. 2026-04-20: 53 warnings, 147 refactoring, 235 readability, 102 software design — 537 suggestions total. Not a gate.
- [!] Run `mix boundary` — no violations. 2026-04-20: `mix boundary` task doesn't exist; `mix boundary.spec` **crashes** with a `FunctionClauseError` deep inside `boundary 0.10.4 Boundary.Mix.View.build/0`. Library incompat with current deps. Needs investigation — either upgrade boundary or pin back. Not a ship-blocker but hides boundary regressions. 2026-04-21 dig: the real crash is `ArgumentError: 1st argument: the table identifier does not refer to an existing ETS table` at `Boundary.Mix.CompilerState.ets_keys/1`. Boundary's compiler hook populates an ETS table during compilation that gets torn down before `boundary.spec` runs — an upstream lifecycle bug, not something we can fix in-project. Options: wait for a newer boundary release compatible with Elixir 1.19/OTP 28, or fork and guard the `:ets.first/1` call.
- [!] Run `mix format --check-formatted`. 2026-04-20: at least one test file unformatted — a `write_file(...)` call needs to wrap onto multiple lines. Easy fix with `mix format`.

### Findings

- 2026-04-20: Three known categories — `TechnicalStrategyTest` feedback text expectations, `QaAppTest` slug format (`login-form-broken` vs `login_form_broken`), agent-task evaluator return shape drift.
- 2026-04-20 (confidence pass): All three categories landed green. 3011/3011 tests pass. `--warnings-as-errors` still aborts the run because several compile-time warnings remain in lib/test code; triage warnings before wiring `--warnings-as-errors` into CI.
- 2026-04-21: After the six fixes below, re-ran full suite — **3011/3011 still green**. One regression was caught during the re-run: `SpecAlignmentTest` "detects extra test assertions" failed because `find_extra_test_assertions/4` had a `is_atom(name)` guard that no longer matched after switching function names to strings. Guard changed to `is_binary(name)` and tests pass.

## Section 7 — Post-ship monitoring (set up before launch)

- [ ] Error reporting wired (Sentry/Honeybadger/Logflare?). Confirm prod config. 2026-04-20: **nothing wired** — no Sentry/Honeybadger/Logflare/AppSignal/Rollbar references anywhere in `config/*.exs` or `mix.exs`.
- [ ] Oban job failure alerts. 2026-04-20: no `Oban` config in `config/*.exs` — either Oban is unused or it's configured dynamically. Confirm and wire alerts either way.
- [ ] Basic uptime check on `https://dev.codemyspec.com` (or wherever prod is).
- [ ] Analytics on MCP tool calls — which tools get used, which never do. 2026-04-20: no telemetry/analytics keys in config.

### Findings

- 2026-04-20 (confidence pass): Section 7 is entirely unstarted. Before public launch, pick at least one error sink (Sentry is lowest-friction in Phoenix) and wire a basic health probe on the prod endpoint. Without it, the first production crash will be invisible.

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
