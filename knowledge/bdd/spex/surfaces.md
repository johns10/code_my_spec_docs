# Surfaces — the four real interaction points in this codebase

The framework docs cover the *why* and the DSL. This file covers the
*how* for the four surfaces that actually exist in this repo. For each:
pick the surface that matches what the user would touch, then copy the
skeleton.

---

## 1. MCP tools

**When to use:** the scenario tests something an agent does — creates a
story, applies a tag, starts a task, queries a graph. The agent calls
these tools directly; so does the spec.

**Module convention:** tools live under
`CodeMySpec.McpServers.<Server>.Tools.<ToolModule>`.

**Canonical skeleton:**

```elixir
alias Anubis.Server.Frame
alias CodeMySpec.McpServers.Stories.Tools.CreateStory
alias CodeMySpec.McpServers.Stories.Tools.ListStoryTitles

import CodeMySpecSpex.TaskResponseHelpers, only: [response_text: 1]

# in when_ / then_:
frame = %Frame{assigns: %{current_scope: context.scope}}
{:reply, response, _frame} = CreateStory.execute(params, frame)

refute response.isError, "expected success, got: #{inspect(response)}"

body = response_text(response)
assert body =~ "expected string"
```

**Assertions:**
- Success guard: `refute response.isError`
- Failure guard: `assert response.isError`
- Body text: always go through `response_text/1` — it extracts the text
  content from the Anubis response struct. Direct access to internal
  fields is a boundary violation.

**Gotchas:**
- `context.scope` must come from `setup_active_project`. It carries the
  in-memory environment; the tool reads it from the frame.
- Some tools only make sense with an active task (e.g. anything that
  gates on `session.active_task`). Use the `:bdd_task_started` shared
  given to set that up — see `shared_givens.md`.

**Real examples:**
- `test/spex/686_ai_assisted_story_management/criterion_5907_agent_creates_a_story_spex.exs` — simple create + list
- `test/spex/686_ai_assisted_story_management/criterion_5912_agent_creates_and_applies_a_tag_spex.exs` — multi-tool, explicit `StoryHelpers.create_story` in `given_`

---

## 2. HTTP / hook endpoints

**When to use:** the scenario tests the stop hook (`POST /api/hooks/stop`)
or any other HTTP endpoint the agent or harness hits. Not for LiveViews.

**The minimal hook POST** (no shell-out, clean pipeline path):

```elixir
response =
  Phoenix.ConnTest.build_conn()
  |> Plug.Conn.put_req_header("x-working-dir", context.scope.cwd)
  |> Plug.Conn.put_req_header("content-type", "application/json")
  |> post(~p"/api/hooks/stop", %{
    "test_output_files" => %{
      "compile" => fixture_path("compile.jsonl")
    }
  })
  |> Phoenix.ConnTest.json_response(200)
```

The `x-working-dir` header is how `WorkingDirScope` resolves the scope.
Always use `context.scope.cwd` (the stub dir from `setup_active_project`).

**Adding a session/task context:**

```elixir
post(~p"/api/hooks/stop", %{
  "session_id" => context.session_id,
  "test_output_files" => %{"compile" => fixture_path("compile.jsonl")}
})
```

`context.session_id` comes from the `:bdd_task_started` shared given.

**With ExCliVcr (shell-out scenarios):**

```elixir
use ExCliVcr

response =
  use_cmd_cassette "pipeline_compile_error", record: :none do
    Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("x-working-dir", context.scope.cwd)
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> post(~p"/api/hooks/stop", %{
      "session_id" => context.session_id,
      "test_output_files" => %{"compile" => fixture_path("compile.jsonl")}
    })
    |> Phoenix.ConnTest.json_response(200)
  end
```

**With ReqCassette (outbound HTTP — OAuth / external APIs):**

Used for OAuth provider flows. The pattern does not appear directly in
spex files; instead, call into `CodeMySpecSpex.OAuthHelpers`:

```elixir
@endpoint CodeMySpecWeb.Endpoint  # OAuth routes live on the cloud endpoint

alias CodeMySpecSpex.OAuthHelpers

given_ "a Google OAuth callback is prepared", context do
  OAuthHelpers.build_google_cassette!(cassette_name, user_claims)
  {:ok, Map.put(context, :cassette_name, cassette_name)}
end

when_ "the callback completes", context do
  conn = OAuthHelpers.do_google_callback(build_conn(), context.cassette_name, "state")
  {:ok, Map.put(context, :conn, conn)}
end
```

Cassette JSON is written to `test/cassettes/oauth/` (not to
`test/fixtures/cassettes/`). `OAuthHelpers.cassette_opts/0` sets
`mode: :replay` and `match_requests_on: [:method, :uri]`.

For a new outbound HTTP integration, `ReqCassette.with_cassette/3` is
the entry point; see the ReqCassette README for the `Req` plug injection
pattern. No spex currently calls `with_cassette` directly outside of
`OAuthHelpers`.

**Gotchas:**
- Cassettes are matched on `[:command, :args]` for ExCliVcr, `[:method, :uri]`
  for ReqCassette — env vars and working dirs are NOT part of the match key.
- `record: :none` will raise `CassetteNotFoundError` if an unexpected
  `System.cmd` fires. Use this to enforce pipeline short-circuit behavior
  (see `criterion_5099_spex.exs` — the cassette contains ONLY a compile
  entry; credo/test never appear).
- Do not mix `use ExCliVcr` with `use ReqCassette` in the same spec; the
  cassette stores are separate.

**Real examples:**
- `test/spex/555_*/criterion_5099_*.exs` — compile failure short-circuit, explicit fixture_path + cassette
- `test/spex/553_*/criterion_5108_*.exs` — no cassette needed (clean run uses only fixture compile.jsonl)
- `test/spex/602_*/criterion_5493_*.exs` — ReqCassette via OAuthHelpers, `@endpoint CodeMySpecWeb.Endpoint`

---

## 3. In-memory filesystem

**When to use:** the scenario requires files to exist in the project's
working directory before sync, stop hook, or validation runs. Always use
this for "the agent wrote a file" setup.

**Operations:**

```elixir
alias CodeMySpec.Environments

# Write — agent writing a file
:ok = Environments.write_file(context.environment, "lib/foo.ex", content)

# Read — then_ observing file content after a generator ran
{:ok, content} = Environments.read_file(context.environment, "lib/foo.ex")

# Check existence
true = Environments.file_exists?(context.environment, ".code_my_spec/spec/foo.spec.md")
```

Paths are **relative to `env.cwd`**. Do not prefix with the absolute
stub dir path — `"lib/foo.ex"` and `"/memfs/env-42/lib/foo.ex"` resolve
to the same key when `env.cwd` is `/memfs/env-42`.

**The environment is already wired up** by `setup_active_project`:

- `context.environment` — the `InMemoryEnvironment` agent
- `context.scope.environment` — same agent, also accessible from the scope
- LiveViews that rebuild scope via `Scope.for_local_project/1` resolve to
  the same agent (registered by `Fixtures.register_environment/2`)

You do not need to create or register the environment yourself.

**Typical pattern — write files, then sync via LiveView:**

```elixir
given_ "the agent has written a spec and impl into the project", context do
  :ok = Environments.write_file(context.environment, ".code_my_spec/spec/foo.spec.md", spec_content())
  :ok = Environments.write_file(context.environment, "lib/foo.ex", impl_content())
  {:ok, context}
end

when_ "the engineer triggers a sync", context do
  {:ok, files_live, _html} =
    live(context.conn, "/projects/#{context.project.name}/files")

  files_live |> element("[data-test='sync-button']") |> render_click()
  {:ok, Map.put(context, :files_live, files_live)}
end
```

**Gotchas:**
- FileSync wipes problems for files that don't exist in the memfs. If a
  scenario seeds a `Problem` via fixture, make sure the corresponding
  file is also written to the env, or sync will clear it.
- `ensure_dir/2` is a no-op. The memfs has no directory entries — only
  file keys.
- The stub dir at `context.scope.cwd` has only a `mix.exs` file on real
  disk. `File.read!` calls inside production code that bypass
  `Environments.read_file/2` will fail during specs — that is intentional.

**Real examples:**
- `test/spex/127_*/criterion_5924_*.exs` — write spec + impl, sync, observe file row in LiveView
- `test/spex/127_*/criterion_5944_*.exs` — two writes + two syncs, assert fingerprint changes

### Triggering a file-change event (`Fixtures.notify_file_changed/2`)

In production, the file watcher subscribes to OS events and invokes
`CodeMySpec.ProjectSync.Sync.sync_path/2` per file. The memfs has no
OS-event source, so specs synthesize the event through the Fixtures
bridge:

```elixir
alias CodeMySpecSpex.Fixtures

when_ "the agent edits a file and the watcher syncs it", context do
  :ok = Environments.write_file(context.environment, "lib/foo.ex", new_content())
  {:ok, _} = Fixtures.notify_file_changed(context.scope, "lib/foo.ex")
  {:ok, context}
end
```

`Fixtures.notify_file_changed/2` wraps the watcher's public contract —
same call path as production, just with the OS subscription replaced by
a direct invocation. This is the legitimate surface for "a file
changed" scenarios; treat it the same as a hook POST or LiveView click.
**Do not** reach for `CodeMySpec.ProjectSync.Sync` or the underlying
`FileSync` / `FileComponentSync` modules directly — the spex boundary
only allows app access through Fixtures.

When the event fires, LiveViews subscribed to the watcher PubSub topic
receive a `{:watcher_synced, info}` message, so anything rendering
watcher activity updates automatically.

**Real examples:**
- `test/spex/127_*/criterion_5922_*.exs` — single-path sync touches one file
- `test/spex/127_*/criterion_5934_*.exs` — single-path sync on missing path reaps the row

---

## 4. LiveView (UI)

**When to use:** the scenario tests something an engineer sees or does in
the browser.

**Two endpoints:**

| Endpoint | URL prefix | Use for |
|---|---|---|
| `CodeMySpecLocalWeb.Endpoint` | `/projects/...`, `/api/hooks/...` | Local CLI app on port 4003 (default) |
| `CodeMySpecWeb.Endpoint` | `/app/...`, `/auth/...` | Cloud SaaS / OAuth |

`CodeMySpecSpex.Case` sets `@endpoint CodeMySpecLocalWeb.Endpoint` by
default. Override at the **module level** for cloud routes:

```elixir
@endpoint CodeMySpecWeb.Endpoint
```

**For cloud routes, use plain string paths (not `~p`):**

`~p` is compiled against `CodeMySpecLocalWeb` verified routes. Using `~p`
in a module that has overridden `@endpoint` to the cloud endpoint will
either fail to compile or silently match the wrong route.

```elixir
# WRONG — ~p is bound to LocalWeb at compile time
live(context.conn, ~p"/app/projects")

# RIGHT
live(context.conn, "/app/projects")
```

**Local-endpoint skeleton:**

```elixir
use CodeMySpecSpex.Case  # @endpoint defaults to CodeMySpecLocalWeb.Endpoint

when_ "the engineer opens the requirements graph", context do
  {:ok, _live, html} =
    live(context.conn, ~p"/projects/#{context.project.name}/requirements/graph?preload=true")

  {:ok, Map.put(context, :html, html)}
end

then_ "the graph contains the expected node", context do
  assert context.html =~ "implementation_file"
  {:ok, context}
end
```

**Cloud-endpoint skeleton:**

```elixir
use CodeMySpecSpex.Case

@endpoint CodeMySpecWeb.Endpoint

when_ "the user visits /app/projects", context do
  {:ok, view, html} = live(context.conn, "/app/projects")
  {:ok, Map.merge(context, %{view: view, html: html})}
end
```

**Prefer `data-test` selectors** over class or id attributes:

```elixir
context.config_live
|> form("[data-test='configuration-form']", configuration: %{require_specs: false})
|> render_submit()

files_live |> element("[data-test='sync-button']") |> render_click()
```

**Gotchas:**
- `conn` from `setup` is unauthenticated. After auth setup steps run,
  `context.conn` carries a valid session token.
- After a redirect (e.g. form submit → redirect → `/app/projects`),
  recycle the conn: `recycle(context.conn)` before the next request.
- `has_element?/2` is non-asserting — wrap it in `assert` or `refute`.
- Always include an anchor assertion when a `then_` is mostly `refute`
  statements (see `priv/knowledge/bdd/spex/writing_a_spex.md` for the pattern).

**Real examples:**
- `test/spex/553_*/criterion_5081_*.exs` — local endpoint, `data-test` selector, anchor + refute pattern
- `test/spex/62_*/criterion_6079_*.exs` — cloud endpoint override, plain string path
- `test/spex/604_*/criterion_5505_*.exs` — cloud endpoint, recycle conn after redirect
- `test/spex/562_*/criterion_5654_*.exs` — local endpoint, plain string path (no `~p` because no `:verified_routes` for this path)
