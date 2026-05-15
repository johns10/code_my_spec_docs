# Four Surfaces — Quick Reference

Spex drive exactly one of these. Pick the one that matches the real user action.

| I'm testing... | Surface | Entry point | Cassette? |
|---|---|---|---|
| Agent calls an MCP tool | MCP tool | `Tool.execute(params, %Frame{assigns: %{current_scope: context.scope}})` | No |
| Stop hook / hook endpoint | HTTP | `post(~p"/api/hooks/stop", body)` with `x-working-dir` header | Yes — ExCliVcr if shell-out |
| OAuth / outbound HTTP | HTTP | `OAuthHelpers.do_google_callback/3` or `do_github_callback/3` | Yes — ReqCassette (via OAuthHelpers) |
| Engineer uses local app (port 4003) | LiveView | `live(context.conn, ~p"/projects/...")` | No |
| Engineer uses cloud SaaS (/app) | LiveView | `live(context.conn, "/app/...")` + `@endpoint CodeMySpecWeb.Endpoint` | No |
| Agent writes a file to the project | Filesystem | `Environments.write_file(context.environment, "lib/foo.ex", content)` | No |

---

## MCP tool — 30-second skeleton

```elixir
alias Anubis.Server.Frame
alias CodeMySpec.McpServers.<Server>.Tools.<Tool>
import CodeMySpecSpex.TaskResponseHelpers, only: [response_text: 1]

frame = %Frame{assigns: %{current_scope: context.scope}}
{:reply, response, _frame} = Tool.execute(params, frame)

refute response.isError
assert response_text(response) =~ "expected text"
```

Deeper: [surfaces.md — MCP tools](surfaces.md#1-mcp-tools)

---

## Stop hook — 30-second skeleton

```elixir
use ExCliVcr  # add at top of module if shell-out scenario

response =
  use_cmd_cassette "my_cassette_name", record: :none do
    Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("x-working-dir", context.scope.cwd)
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> post(~p"/api/hooks/stop", %{
      "session_id" => context.session_id,          # from :bdd_task_started shared given
      "test_output_files" => %{
        "compile" => Path.expand("test/fixtures/validation/my_scenario/compile.jsonl")
      }
    })
    |> Phoenix.ConnTest.json_response(200)
  end
```

No shell-out scenario (config, block decision, etc.): omit `use ExCliVcr`
and `use_cmd_cassette`; pass only `test_output_files` if needed.

Deeper: [surfaces.md — HTTP / hook endpoints](surfaces.md#2-http--hook-endpoints), [cassettes.md](cassettes.md)

---

## LiveView — 30-second skeleton

```elixir
# Local app (default)
{:ok, view, html} = live(context.conn, ~p"/projects/#{context.project.name}/configuration")
view |> form("[data-test='configuration-form']", configuration: %{key: value}) |> render_submit()

# Cloud SaaS — add at module level:
@endpoint CodeMySpecWeb.Endpoint
{:ok, view, html} = live(context.conn, "/app/projects")   # plain string, not ~p
```

Deeper: [surfaces.md — LiveView](surfaces.md#4-liveview-ui)

---

## Filesystem — 30-second skeleton

```elixir
alias CodeMySpec.Environments

:ok = Environments.write_file(context.environment, "lib/foo.ex", "defmodule Foo do\nend\n")
{:ok, content} = Environments.read_file(context.environment, "lib/foo.ex")
```

`context.environment` is ready after `setup :setup_active_project`. Paths
are relative to `env.cwd` — no prefix needed.

Deeper: [surfaces.md — in-memory filesystem](surfaces.md#3-in-memory-filesystem)

---

## Gotchas at a glance

- **`~p` only works for local-endpoint routes.** Cloud routes (`/app/...`) need plain strings.
- **`response_text/1` is required for MCP assertions.** Don't touch response fields directly.
- **Hook endpoint needs `x-working-dir`** set to `context.scope.cwd`.
- **`test_output_files` paths must be `Path.expand/1`-ed.** Relative paths won't survive working-dir resolution.
- **Empty `compile.jsonl` = no diagnostics.** Do not write `[]` or `{}`.
- **ExCliVcr cassettes live in `test/fixtures/cassettes/`.** ReqCassette cassettes live in `test/cassettes/oauth/`.
