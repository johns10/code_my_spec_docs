# CodeMySpec QA Plan

QA infrastructure for the running CodeMySpec backend. CodeMySpec is unusual in that it
ships *two* Phoenix apps in one OTP release — both are user-facing surfaces and both
need QA coverage. The plan below covers both, plus the MCP servers each app exposes.

## App Overview

CodeMySpec runs **two Phoenix endpoints** from one BEAM node, each with its own
router, auth model, and audience. QA touches three logical surfaces:

| Surface | Endpoint | Port (dev) | Pipeline | Audience |
|---|---|---|---|---|
| **Hosted UI / API** | `CodeMySpecWeb.Endpoint` | `4000` (HTTP), `4001` (HTTPS) | `:browser` (session) + `:api`/`:mcp_protected` (OAuth bearer) | Authenticated humans + Claude MCP connector |
| **Local UI / hooks** | `CodeMySpecLocalWeb.Endpoint` | `4003` | `:browser` (no auth) + `:api`/`:mcp` (working-dir scoped) | The local CLI binary, hooks, and human owner |
| **MCP servers** | Both endpoints expose `/mcp/*` forwards into `Anubis.Server.Transport.StreamableHTTP.Plug` | `4000/mcp/*`, `4003/mcp` | Streamable HTTP (SSE) | Agents — both Claude.ai (hosted) and Claude Code (local) |

**Stack:** Phoenix 1.8 + LiveView, Ecto + PostgreSQL (`code_my_spec_dev`), SQLite for
the CLI's local DB (`priv/repo/cli_dev.db`), Anubis MCP server library, Wallaby for
journey tests. Tailwind + esbuild watchers run via the dev endpoint config.

**Hosted auth (port 4000):**
- Browser: `Plug.Session` cookie + CSRF + `CodeMySpecWeb.UserAuth.fetch_current_scope_for_user`
- API/MCP: `Authorization: Bearer <access_token>` checked by `UserAuth.require_oauth_token` (ExOauth2Provider). Tokens are issued via `/oauth/token` after the OAuth dance at `/oauth/authorize`.
- LiveView mounts gate on `:require_authenticated`, `:require_active_account`, `:require_active_project` in `live_session` blocks.

**Local auth (port 4003):**
- `Plugs.LocalOnly` rejects non-loopback IPs with `403 {"error": "Localhost only"}`.
- No user auth — the binary trusts whoever is on the box. Project scope comes from the **`X-Working-Dir` header** via `Plugs.WorkingDir` → `Plugs.WorkingDirScope`, which looks up `Project.local_path` and builds a scope.
- Hook endpoints (`/api/hooks/*`) and skill endpoints (`/api/agent-tasks/*`, `/api/skills/*`) all use the `:hook` pipeline (`LocalOnly + WorkingDir + WorkingDirScope`).

**Key route map:**
- `4000/` — marketing pages, `/users/log-in`, `/users/register`
- `4000/app/*` — hosted SaaS LiveViews (overview, accounts, projects, stories, components, issues, architecture)
- `4000/api/*` — JSON API (stories, personas, issues, projects, uploads, push notifications) — OAuth bearer
- `4000/mcp/{stories,components,personas,analytics-admin}` — hosted MCP servers — OAuth bearer + `ProjectScopeOverride`
- `4000/.well-known/oauth-*` — MCP discovery
- `4003/projects/:project_name` — project hub (cards for next-task, sync, requirements, components, architecture, stories, issues, sessions, knowledge)
- `4003/projects/:project_name/{requirements,components,stories,issues,architecture,sessions,knowledge,...}` — local LiveView UI
- `4003/api/bootstrap/*` — login + project listing for the init flow (`auth/status` returns `{email, authenticated}` without needing a session)
- `4003/api/hooks/*` — Claude Code lifecycle hooks (session-start, pre/post tool use, stop, subagent-stop, notification)
- `4003/api/agent-tasks/start`, `4003/api/skills/start` — skill entry points
- `4003/mcp` — single forward into `LocalServer` (all local MCP tools — `get_next_requirement`, `start_task`, `evaluate_task`, etc.)
- `4003/health` — unauthenticated readiness probe (`{"status":"ok"}`)
- `4003/` — projects index (same as `/projects`)

## Tools Registry

Three layers, three tools. Pick by pipeline, not by guess.

### Vibium MCP (`mcp__vibium__browser_*`)

Use for any route in a `:browser` pipeline on either endpoint — anything that renders HTML, runs LiveView, or expects a session cookie.

```
mcp__vibium__browser_launch
mcp__vibium__browser_navigate { url: "http://127.0.0.1:4003/projects/code-my-spec" }
mcp__vibium__browser_map
mcp__vibium__browser_click { selector: "@e3" }
mcp__vibium__browser_screenshot { filename: "4003_requirements.png" }
```

**Screenshot caveat:** `browser_screenshot` writes to `~/Pictures/Vibium/<filename>`. The `filename` parameter is treated as a basename — relative paths like `.code_my_spec/qa/{story}/foo.png` are silently ignored. Either name files with port + scenario prefix (`4003_requirements.png`, `4000_login.png`) and copy them into the QA artifact dir at the end of the run, or shell-out a `cp` step.

**Hosted login (port 4000):** the `/users/log-in` page renders **two stacked forms** — a magic-link form on top and a password form on the bottom — and **both** use the same input names `user[email]` and `user[password]` (no `id="login_email"`). Disambiguate by scoping to the form, e.g. `form[action="/users/log-in"] input[name='user[email]']` for the password form. Two viable paths:

1. **Password login** — fill both fields in the password form, submit, persist with `browser_storage_state`.
2. **Magic-link login** — fill `user[email]` in the magic-link form, click "Log in with email", then read the swoosh mailbox at `http://127.0.0.1:4000/dev/mailbox` (banner on the login page links to it) to grab the token and visit `/users/log-in/:token`. Useful when you don't want to bake passwords into the seed script.

Quick smoke test of auth gating: GET `/app` while unauthenticated → 302 to `/users/log-in`.

**Local login (port 4003):** none — `LocalOnly` accepts the loopback IP directly. Just navigate.

**LiveView click reliability:** card-link clicks on `/projects/:project_name` occasionally do not navigate (URL doesn't change). Direct `browser_navigate` to the destination URL is more reliable; reserve clicks for in-page interactions where you're already mounted.

See `.code_my_spec/framework/qa-tooling/vibium_reference.md` for the full tool table.

### curl — single-line, never multi-line

Use for `:api` and `:mcp` pipelines (JSON, SSE). Everything in `.code_my_spec/framework/qa-tooling/curl.md` applies.

**Local hooks / skills / API (no auth, working-dir header):**
```
curl -sSf -X POST http://127.0.0.1:4003/api/hooks/session-start -H "Content-Type: application/json" -H "X-Working-Dir: $PWD" -d '{"session_id":"qa-probe","cwd":"'$PWD'"}'
```

**MCP servers — DO NOT curl tool calls.** The local MCP server (Anubis Streamable HTTP) returns `202 Accepted` with empty body for `tools/call` and `tools/list`; the actual JSON-RPC response comes back over the **`initialize` request's open SSE channel**, which a one-shot curl tears down before it can read. Confirmed empirically — `init` returns 200 + inline SSE with the server info, but every subsequent request returns `202` with no body. A correct curl wrapper would have to run the init stream as a background process and tail it; not worth the complexity.

For QA, use:
- **The agent's own MCP client tools** (`mcp__plugin_codemyspec_local__*`) — they handle the SSE channel correctly and are available to every QA agent.
- **`mix test test/code_my_spec/mcp_servers/*_test.exs`** for the server logic itself.
- **Plain curl** only for endpoints that genuinely return synchronous JSON: `/health`, `/api/bootstrap/*`, `/api/hooks/*`, `/api/skills/*`, `/api/agent-tasks/*`, and `/api/projects/:project_name/*`.

**Hosted API (OAuth bearer):** No curl wrapper exists. The dev box's OAuth discovery
points at the production hostname (`dev.codemyspec.com`), so minting a fresh local
bearer would require the Cloudflare tunnel up. For QA on the hosted API surface,
either reuse an access token already in the DB (read it via `iex -S mix`) or skip
to the LiveView surface where browser-session auth Just Works via Vibium.

### mix run — seeds and one-offs

Use for setup that needs the app's contexts (creating users, accounts, projects through the supervised pipeline).

```
mix run priv/repo/qa_seeds.exs                       # server (Postgres) QA fixture
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs   # local CLI (SQLite) QA fixture
mix run priv/repo/seeds.exs                          # OAuth MCP connector app
mix run priv/repo/seeds/math_test_project.exs        # demo project content
```

Don't wrap `mix run` in bash loops — each invocation boots the BEAM cold.

### iex — diagnostic only

For "is this assertion ever true in the running system" questions:
```
iex -S mix
iex> CodeMySpec.Repo.aggregate(CodeMySpec.Stories.Story, :count)
```
Use sparingly during QA; prefer the surfaces above so the test actually exercises a pipeline.

## Seed Strategy

The two endpoints have different schemas, so QA fixtures come in two flavors.

### Server (Postgres, `:dev`) — `priv/repo/qa_seeds.exs`

Idempotent. Creates user + personal account + member + project. Run with:

```
mix run priv/repo/qa_seeds.exs
```

Outputs:
- Email `qa@codemyspec.local`, password `qa-password-123!`
- Account slug `qa-account` (UUID printed at end)
- Project `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`),
  `local_path` always rewritten to the script's working dir so QA from any
  checkout resolves correctly

The script uses `Users.register_user/1` + `update_user_password/2`,
`Accounts.create_account/2`, and `Project.bootstrap_changeset/2` so password
hashing and changeset validation come from the real code path. It also stamps
`Member{role: :owner}` directly so the user can administer the account.

### Local CLI (SQLite, `:dev_cli` / `:prod_cli`) — `priv/repo/cli_qa_seeds.exs`

Idempotent. Creates an optional `client_user` (so `bootstrap/auth/status`
reports authenticated without an OAuth round-trip) plus the same project row
keyed on the same UUID. Run with:

```
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

The local schema has no accounts/members table — `WorkingDirScope` only needs
the `Project.local_path` to match `PWD` (or the `X-Working-Dir` header) on
each request to resolve a scope.

### Demo content

`priv/repo/seeds/math_test_project.exs` and `metricflow_and_fuellytics.exs`
populate stories/components/issues so the requirements/components/issues
LiveViews render something. Run them after the QA fixture seed.

The base `priv/repo/seeds.exs` creates the `claude-mcp-connector` OAuth app
on the server; QA seeds do **not** duplicate that.

## System Issues

### Local MCP can't be QA'd via plain curl

The Anubis Streamable HTTP transport returns `202 Accepted` with empty body for
`tools/call`/`tools/list` and writes the actual response to the SSE channel that the
`initialize` request opened. A one-shot curl can't see that response unless it keeps
the init stream alive in a background process. Plan: don't try. Use the agent's
`mcp__plugin_codemyspec_local__*` tools for ad-hoc probing and `mix test` against the
server modules for unit/integration coverage.

### CLI dev DB has pending unrelated migrations

`MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs` currently fails because
auto-migrate hits a pre-existing migration (`stories_account_id_index` from
`fix_stories_account_id_type`) that errors out — unrelated to QA. Until that
chain is resolved, the local CLI seed only runs cleanly against `:prod_cli`
(the bundled CLI binary). The script itself is correct; its first invocation
in a clean `:dev_cli` env is gated on the migration fix.

### OAuth discovery on dev points at production

`GET http://127.0.0.1:4000/.well-known/oauth-authorization-server` returns issuer
`https://dev.codemyspec.com` (and `authorization_endpoint`, `token_endpoint`, etc.
all on that same hostname) because the dev endpoint's `:url` config points at the
Cloudflare-tunneled hostname. Practical impact: minting a fresh OAuth bearer for
hosted-API QA on a dev box requires the named tunnel to be up. There is no purely
local OAuth flow against `127.0.0.1:4000`. For QA against the hosted surface, plan
to either (a) reuse an existing access token from the DB, or (b) skip the OAuth
flow and assert via `iex -S mix` that records exist as expected.

### Vibium screenshots ignore relative paths

`browser_screenshot { filename: "...path..." }` always writes to
`~/Pictures/Vibium/<basename>` — the leading directories in `filename` are dropped.
The plan cannot tell QA agents to write directly into
`.code_my_spec/qa/{story}/screenshots/`; the result-collection step has to copy
from `~/Pictures/Vibium/` into the story dir. See the `manual_qa_plan.md` for the
established workaround if there is one.

### LiveView card-link click misses

On `/projects/:project_name`, clicking the navigation cards (mapped as `@e2`–`@e13`
in a fresh map) does not always trigger navigation — the URL stays the same and the
DOM doesn't change. Sidebar links work; direct navigation always works. The cards
render as `<.link navigate=...>` (i.e. real `<a href>` with `data-phx-link="redirect"`)
and rely on LiveView's JS to intercept the click; the race is between Vibium clicking
and the JS handler attaching. Default to `browser_navigate` for cross-page moves;
reserve clicks for in-page interactions on a route where the LiveView has already
mounted.

### Two ports = two sets of screenshots

QA result artifacts may include screenshots from both `4000/*` and `4003/*` for the
same feature (e.g. story creation has a hosted form *and* a local viewer). Name
screenshots with the port prefix (`4000_story_form.png`, `4003_story_view.png`) so
result.md is unambiguous.

## Notes

- **Don't run `mix phx.server` if these ports are in use.** Both endpoints already auto-start under the dev release; check `lsof -i -P -n | grep LISTEN | grep -E ':4000|:4001|:4003'` first.
- **The hosted endpoint has HTTPS on `4001`** with a self-signed cert (`priv/cert/selfsigned.pem`). Stick to `http://127.0.0.1:4000` for QA — TLS adds nothing here and Vibium prompts for the cert.
- **`dev.codemyspec.com`** is the production hostname tunneled via Cloudflare from the dev box (see `:cloudflare_tunnel` in `config/dev.exs`). Don't QA against that — it's externally reachable. Always use `127.0.0.1`.
- **Existing manual QA plan** lives next to this file at `manual_qa_plan.md`. That doc covers a different scope (CLI install, Burrito binary, extension load) and remains the reference for those concerns; this plan is strictly the running backend.
- **Per-story QA uses this plan** — `QaStory.check_plan` reads `.code_my_spec/qa/plan.md` as Phase 1, before any story brief is written. Keep the Tools Registry section honest because it ends up in every story prompt.
