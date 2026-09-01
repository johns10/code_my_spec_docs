# CodeMySpec QA Plan

QA infrastructure for the running CodeMySpec backend. CodeMySpec is unusual in that it
ships *two* Phoenix apps in one OTP release — both are user-facing surfaces and both
need QA coverage. The plan below covers both, plus the MCP servers each app exposes.

## App Overview

CodeMySpec runs **two Phoenix endpoints** from one BEAM node, each with its own
router, auth model, and audience. QA touches three logical surfaces:

| Surface | Endpoint | Port | Pipeline | Audience |
|---|---|---|---|---|
| **Hosted UI / API** | `CodeMySpecWeb.Endpoint` | `4000` (HTTP), `4001` (HTTPS) | `:browser` (session) + `:api`/`:mcp_protected` (OAuth bearer) | Authenticated humans + Claude MCP connector |
| **Local UI / hooks (in-repo dev)** | `CodeMySpecLocalWeb.Endpoint` | `4004` (dev / dev_cli via `mix phx.server`) | `:browser` (no auth) + `:api`/`:mcp` (working-dir scoped) | The local CLI binary, hooks, and human owner |
| **Local UI / hooks (published binary)** | `CodeMySpecLocalWeb.Endpoint` | `4003` (the published `cms` binary) | Same pipelines as 4004 | End users running the `cms` CLI |
| **MCP servers** | Both endpoints expose `/mcp/*` forwards into `Anubis.Server.Transport.StreamableHTTP.Plug` | `4000/mcp/*`, `4004/mcp` (dev) or `4003/mcp` (published) | Streamable HTTP (SSE) | Agents — both Claude.ai (hosted) and Claude Code (local) |

> **Heads up — local app port:** The in-repo dev server (`mix phx.server` with `MIX_ENV=dev` or `MIX_ENV=dev_cli`) runs the local endpoint on **port 4004** so it can coexist with the published `cms` binary on **4003** (see `config/dev.exs:79` and `config/dev_cli.exs:38`). For QA against a dev checkout, hit `127.0.0.1:4004`. Most QA evidence in this session was captured against the dev port.

**Stack:** Phoenix 1.8 + LiveView, Ecto + PostgreSQL (`code_my_spec_dev`), SQLite for
the CLI's local DB (`~/.codemyspec/cli_dev.db` under `MIX_ENV=dev_cli`), Anubis MCP server library, Wallaby for
journey tests. Tailwind + esbuild watchers run via the dev endpoint config.

> **Heads up — local app DB:** The local CLI uses SQLite at `~/.codemyspec/cli_dev.db`, NOT a Postgres `cli_dev` database. Plain `mix run` defaults to `MIX_ENV=dev` (Postgres). Always prefix CLI seed scripts with `MIX_ENV=dev_cli`.

**Hosted auth (port 4000):**
- Browser: `Plug.Session` cookie + CSRF + `CodeMySpecWeb.UserAuth.fetch_current_scope_for_user`
- API/MCP: `Authorization: Bearer <access_token>` checked by `UserAuth.require_oauth_token` (ExOauth2Provider). Tokens are issued via `/oauth/token` after the OAuth dance at `/oauth/authorize`.
- LiveView mounts gate on `:require_authenticated`, `:require_active_account`, `:require_active_project` in `live_session` blocks.

**Local auth (port 4004 dev / 4003 published):**
- `Plugs.LocalOnly` rejects non-loopback IPs with `403 {"error": "Localhost only"}`.
- No user auth — the binary trusts whoever is on the box. Project scope comes from the **harness id**, sent as an `X-Harness-Id` header or a `?harness=<id>` query parameter, via `Plugs.HarnessScope`. The harness record says which project it serves and where its working copy is.
- Hook endpoints (`/api/hooks/*`) and skill endpoints (`/api/agent-tasks/*`, `/api/skills/*`) all use the `:hook` pipeline (`LocalOnly + HarnessScope`).
- **No directory travels on the wire.** `X-Working-Dir` and `?dir=` are gone, along with `Plugs.WorkingDir` and `WorkingDirScope`: resolving a checkout from an announced path succeeded against the wrong disk rather than failing when it was wrong. A request naming no harness is refused with a 400 that says where the id lives. The one exception is `/api/skills/init`, which runs before anything is onboarded and so has no id to send.

**Key route map:**
- `4000/` — marketing pages, `/users/log-in`, `/users/register`
- `4000/app/*` — hosted SaaS LiveViews (overview, accounts, projects, stories, components, issues, architecture)
- `4000/api/*` — JSON API (stories, personas, issues, projects, uploads, push notifications) — OAuth bearer
- `4000/mcp/{stories,components,personas,analytics-admin}` — hosted MCP servers — OAuth bearer + `ProjectScopeOverride`
- `4000/.well-known/oauth-*` — MCP discovery
- `4004/projects/:project_name` — project hub (cards for next-task, sync, requirements, components, architecture, stories, issues, sessions, knowledge)
- `4004/projects/:project_name/{requirements,components,stories,issues,architecture,sessions,knowledge,...}` — local LiveView UI
- `4004/api/bootstrap/*` — login + project listing for the init flow (`auth/status` returns `{email, authenticated}` without needing a session)
- `4004/api/hooks/*` — Claude Code lifecycle hooks (session-start, pre/post tool use, stop, subagent-stop, notification)
- `4004/api/agent-tasks/start`, `4004/api/skills/start` — skill entry points
- `4004/mcp` — single forward into `LocalServer` (all local MCP tools — `get_next_requirement`, `start_task`, `evaluate_task`, etc.)
- `4004/health` — unauthenticated readiness probe (`{"status":"ok"}`)
- `4004/` — projects index (same as `/projects`)

## Tools Registry

### Picking the tool — start from the surface, not the test framework

QA exercises the **agent's actual surface** from outside the BEAM. The spex
suite (`mix spex`) is the BDD layer — it drives the same surface in-process
to assert behavior at the contract level. **It is not a QA tool.** A clean
`mix spex` run tells you the contract is implemented; it does not tell you
the running app honors it under real network conditions, real payloads, or
real failure modes. QA's job is the latter.

**There is no such thing as a "spex-only" story.** Every story has at least
one of the surfaces below as its agent-facing entry point. Pick the tool
that matches the surface, then probe it from outside:

| Surface | Tool | Example |
|---|---|---|
| LiveView page (`:browser` pipeline) | **Vibium MCP** | `/projects/:project_name`, `/app/*` |
| Controller endpoint returning JSON / 2xx no-body (`:api`, `:hook`, `:mcp_protected`) | **curl** | `POST /api/hooks/stop`, `GET /health`, `POST /api/agent-tasks/start` |
| MCP tool registered on a server | **`mcp__plugin_codemyspec_local__*`** (or `mcp__plugin_codemyspec__*` for hosted) | `start_task`, `evaluate_task`, `get_next_requirement` |
| File projection (Files context, hex doc projection, etc.) | Write/read with the fs, then query through one of the above | Touch `mix.lock`, then `curl` the sync hook, then call `semantic_search` MCP tool |
| GenServer state / process internals | There is no QA surface here. If a story claims this is its surface, the story is wrong — push back. | — |

**If a criterion looks "spex-only":** re-read its `## Surface` (or `##
Observation surface`) section in the spex moduledoc. Every well-written
spex states the controller route, MCP tool, or other agent surface it
drives. That's the QA tool. If the spex truly has no external surface, the
criterion is probably testing an implementation detail and the story
should be revised.

Three layers, three tools. Pick by pipeline, not by guess.

### Vibium MCP (`mcp__vibium__browser_*`)

Use for any route in a `:browser` pipeline on either endpoint — anything that renders HTML, runs LiveView, or expects a session cookie.

```
mcp__vibium__browser_launch
mcp__vibium__browser_navigate { url: "http://127.0.0.1:4004/projects/code-my-spec" }
mcp__vibium__browser_map
mcp__vibium__browser_click { selector: "@e3" }
mcp__vibium__browser_screenshot { filename: "4003_requirements.png" }
```

**Screenshot caveat:** `browser_screenshot` writes to `~/Pictures/Vibium/<filename>`. The `filename` parameter is treated as a basename — relative paths like `.code_my_spec/qa/{story}/foo.png` are silently ignored. Either name files with port + scenario prefix (`4003_requirements.png`, `4000_login.png`) and copy them into the QA artifact dir at the end of the run, or shell-out a `cp` step.

**Hosted login (port 4000):** the `/users/log-in` page renders **one form**, containing `_csrf_token` and `user[email]`. There is no password field — magic link is the only path. This section used to describe two stacked forms and a password login; that cost every QA session the same detour, because the documented selector times out with "element not found" and the agent then re-maps the DOM to discover the real flow.

**Magic-link login** — fill `user[email]`, click "Log in with email", then read the swoosh mailbox at `http://127.0.0.1:4000/dev/mailbox` (banner on the login page links to it) to grab the token and visit `/users/log-in/:token`. Persist with `browser_storage_state`.

The seed user is **pre-confirmed**, which matters: an account with a password set and no confirmation is refused a magic link on purpose — allowing it is a session-fixation vulnerability — and with no password form on the page that account has no way in at all. `qa_seeds.exs` now confirms the user it creates, and confirms an existing one that predates that. If you meet "Confirm your email address before signing in with a link", the user is in that state; re-run the seed.

Quick smoke test of auth gating: GET `/app` while unauthenticated → 302 to `/users/log-in`.

**Local login (port 4004 dev / 4003 published):** none — `LocalOnly` accepts the loopback IP directly. Just navigate.

**LiveView click reliability:** card-link clicks on `/projects/:project_name` occasionally do not navigate (URL doesn't change). Direct `browser_navigate` to the destination URL is more reliable; reserve clicks for in-page interactions where you're already mounted.

See `.code_my_spec/framework/qa-tooling/vibium_reference.md` for the full tool table.

### curl — single-line, never multi-line

Use for `:api` and `:mcp` pipelines (JSON, SSE). Everything in `.code_my_spec/framework/qa-tooling/curl.md` applies.

**Local hooks / skills / API (no auth, working-dir header):**
```
curl -sSf -X POST http://127.0.0.1:4004/api/hooks/session-start -H "Content-Type: application/json" -H "X-Harness-Id: $(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' .cms_harness.json | head -1 | cut -d'"' -f4)" -d '{"session_id":"qa-probe"}'
```

**MCP servers — curl works, and it is a first-class result.** This section used to say
the opposite, on the strength of an empirical test that was missing one header.

Send `Accept: application/json, text/event-stream` and the JSON-RPC response arrives
inline on the POST:

```bash
ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' .cms_harness.json | head -1 | cut -d'"' -f4)
curl -s -X POST http://localhost:4004/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "X-Harness-Id: $ID" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'

id: 0
event: message
data: {"id":1,"jsonrpc":"2.0","result":{"tools":[…
```

Omit that header and the server answers **406 with a body that says exactly why** —
`"Not Acceptable: Client must accept application/json"`. It is not a silent `202`, and
there is no background process to run or init stream to tail.

The cost of the old claim was real: story 817's QA reported all seven criteria as
unexercisable and fell back to source inspection, citing this paragraph as one of three
blockers (`83291e9f`).

For QA, use:
- **`curl`** — for any MCP surface, including servers whose typed tools are not in the
  QA agent's frontmatter. Drive the handshake in order: `initialize`, then
  `notifications/initialized`, then `tools/call`, echoing the `Mcp-Session-Id` the
  server returns. See `plugins/claude/agents/qa.md`, which documents this.
- **The agent's own MCP client tools** (`mcp__plugin_codemyspec_local__*`) — more
  ergonomic where they exist, with schema validation. Only the servers in the agent's
  frontmatter are reachable this way; allowlists are static and there is no runtime
  discovery.
- **`mix test test/code_my_spec/mcp_servers/*_test.exs`** for the server logic itself.

**Hosted API (OAuth bearer):** No curl wrapper exists. The dev box's OAuth discovery
points at the production hostname (`dev.codemyspec.com`), so minting a fresh local
bearer would require the Cloudflare tunnel up. For QA on the hosted API surface,
either reuse an access token already in the DB (read it via `iex -S mix`) or skip
to the LiveView surface where browser-session auth Just Works via Vibium.

### mix run — seeds and one-offs

Use for setup that needs the app's contexts (creating users, accounts, projects through the supervised pipeline).

```
mix cms.seed priv/repo/qa_seeds.exs                  # server (Postgres) QA fixture
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

> **Only with the dev server stopped.** The server on 4000 holds the compile
> lock, so a `mix run` under `MIX_ENV=dev` mid-session 500s the app you are
> testing. To check seed state while it is up, read Postgres directly:
> `psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"`

Outputs:
- Email `qa@codemyspec.local` — **passwordless; there is no password login.** The
  seed still calls `update_user_password/2`, but `/users/log-in` offers only
  GitHub, Google, and a magic link. Log in like this:

  1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]`
     with `qa@codemyspec.local` → click "Email me a login link".
  2. `http://127.0.0.1:4000/dev/mailbox` — the local mail adapter catches it.
  3. The link is minted with the configured host
     (`https://dev.codemyspec.com/users/log-in/<token>`). **Rewrite the origin
     to `http://127.0.0.1:4000` before navigating** — following it as-is leaves
     the local app. This is the step people miss.
  4. It lands on `/app` with the fixture project active. Single-use token; a
     re-run needs a fresh link.
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
# Local app NOT running:
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs

# Local app already on port 4004:
NO_SERVER=true MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

The local schema has no accounts/members table — `HarnessScope` resolves the
harness id on each request, and the harness record carries both the project and
the working copy's root.

### Sandbox project for MCP-surface SC tests — `code_my_spec_test_repos/qa_sandbox/`

QA scenarios that mutate state through the agent surface (`create_story`,
`create_persona`, `accept_issue`, `dismiss_issue`, `tag_stories`,
`start_three_amigos_session`, `add_rule`, `add_scenario`, etc.) **MUST**
target the sandbox project, not the working CodeMySpec checkout. Mutating
the working project leaves test cruft (orphan stories, test personas,
placeholder issues) that clamps real graph nodes and forces manual
cleanup later.

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) has its
`local_path` set to:

```
/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
```

To direct MCP calls there, send **the sandbox's own harness id** — the working
copy is named by id now, not by the directory a request announces, so `cd`-ing
somewhere no longer changes which project answers.

1. **Onboard the sandbox against the fixture project**, naming it explicitly:

   ```bash
   SANDBOX=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
   mix cms.harness.onboard "$SANDBOX" --project 11111111-1111-4111-8111-111111111111
   ```

   `--project` is not optional and its absence is why this was wrong for weeks.
   Onboarding mints the id **from the server**, and the server reads the project
   off the credential presenting it — so a bare `mix cms.harness.onboard` mints
   the sandbox onto whichever project the calling checkout's key belongs to,
   which is the real CodeMySpec. Setting the fixture project's `local_path` does
   not help: the path is a property of the project record, not an input to
   onboarding. The section below says the same thing about `cd`, and it defeats
   this step too.

   **Re-running it on an already-onboarded sandbox changes nothing**, including
   the project. `.cms_harness.json` already names an id, so no mint happens and
   `--project` never reaches the server. To re-point it, delete that file first:

   ```bash
   rm "$SANDBOX/.cms_harness.json"
   mix cms.harness.onboard "$SANDBOX" --project 11111111-1111-4111-8111-111111111111
   ```

2. **Prove the isolation before mutating anything.** Not optional, and not by
   reading titles — the fixture project holds copies of real stories, so a
   familiar-looking list proves nothing. Count them:

   ```bash
   # 25-ish means the fixture project. ~120 means you are about to write into
   # the real backlog.
   ```

   Call `list_story_titles` through the sandbox's id (step 3 shows how) and check
   the count against `.code_my_spec/config.yml`'s project. If it comes back with
   the real project's stories, stop — the guarantee this section makes is void
   until the onboard above is redone.

3. **Send that id** when curling a local endpoint:

   ```bash
   SANDBOX=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
   ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SANDBOX/.cms_harness.json" | head -1 | cut -d'"' -f4)
   curl -s -X POST http://localhost:4004/mcp \
     -H "Content-Type: application/json" \
     -H "Accept: application/json, text/event-stream" \
     -H "X-Harness-Id: $ID" \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
   ```

   This is the part that changed: pointing at the sandbox used to be a matter of
   where you stood, and is now a matter of which id you send. That is the whole
   point — two checkouts of one project are two harnesses whatever their paths
   say, and a path could not tell them apart.

App-surface QA (Vibium against ports 4000 / 4003, exercising live LiveViews
and controllers) still hits the dev databases — only the agent-surface
mutation tests need the sandbox swap.

The sandbox project has only the minimal Phoenix shape (`mix.exs`, `lib/`,
`test/`, `config/`, `.code_my_spec/`) needed to be a working copy a harness
can be onboarded into. It is intentionally empty so SC tests can create their own
stories/personas/issues without colliding with real data.

To reset the sandbox between major QA passes, re-run the cli_qa_seeds
script with `QA_LOCAL_PATH` pointing at the sandbox dir.

### Demo content

`priv/repo/seeds/math_test_project.exs` and `metricflow_and_fuellytics.exs`
populate stories/components/issues so the requirements/components/issues
LiveViews render something. Run them after the QA fixture seed.

The base `priv/repo/seeds.exs` creates the `claude-mcp-connector` OAuth app
on the server; QA seeds do **not** duplicate that.

## System Issues

### Onboarding the sandbox says `:no_credential` while the credential is in the repo

`mix cms.harness.onboard` — step 1 of the sandbox section above — fails with
`{:error, :no_credential}` unless `CMS_TOKEN` or `CMS_DEPLOY_KEY` is in the
**shell** environment. Two QA cycles have stopped here and concluded no
credential exists.

One is in the repo. `envs/dev.env` and `envs/test.env` both carry `DEPLOY_KEY`
(dev also has the Stripe set: `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`,
`STRIPE_WEBHOOK_SECRET`, and both price ids). Whether `DEPLOY_KEY` is the one
`onboard` wants or a git deploy key sharing the name is **not yet confirmed** —
check before relying on it.

The reason it reads as absent: `envs/*.env` are Dotenvy files loaded by the app
at boot and **never exported to the shell**. So `System.get_env` is empty in
anything you shell out to, and both statements are true at once — the value is
right there, and the tool correctly reports it has none. Nothing in the error
says where to look.

Export it for the command rather than assuming it is missing:

```
CMS_DEPLOY_KEY=$(grep '^DEPLOY_KEY=' envs/dev.env | cut -d= -f2-) mix cms.harness.onboard <sandbox-path>
```

Confirm the result with `mix cms.harness.onboard --check <sandbox-path>`, which
as of `c3cae092` asserts the keys onboarding writes (`CMS_HARNESS_ID`,
`MIX_TEST_PARTITION`, an `ANTHROPIC_BASE_URL` **with an id on it**) and names
which are missing. Before that commit it answered `onboarded:` from the file's
existence alone, so a half-onboarded copy reported success — do not trust a bare
`onboarded:` from an older build.

### An agent's own typed MCP tools cannot be pointed at the sandbox

The section above says mutating scenarios **MUST** target the sandbox. Worth
stating how, because the obvious route does not work: a QA agent's typed
`mcp__plugin_codemyspec_local__*` tools are bound to whichever harness its Claude
Code session serves. Inside a worktree of the real repo that is the real dev
harness, and there is no parameter to redirect a call. Only curl against the
sandbox's MCP endpoint, carrying its `X-Harness-Id`, actually isolates.

This bit two cycles of story 896 before anyone noticed, because the failure is
invisible: the call succeeds, and the row simply lands in the real project
owner's data. `ask_user` was the first tool where that was both visible and
irreversible — story 896 gives questions no dismiss and no expiry, so two probe
questions are permanently in the owner's `/app` inbox and only he can clear them.

Issue `08d4d7bd` tracks it. It will recur for **any** writing MCP tool, not just
`ask_user` — check before exercising one from your own tool list. Read-only calls
(`list_problems`, `list_requirements`, `list_user_questions`, `check_answer`) are
safe against the real harness.

### ~~Local MCP can't be QA'd via plain curl~~ — withdrawn, it can

This said the Anubis Streamable HTTP transport returns `202 Accepted` with an empty
body and delivers the response over the `initialize` request's SSE channel, so a
one-shot curl could never read it.

That is wrong. With `Accept: application/json, text/event-stream` the response comes
back inline on the POST; without it the server returns 406 and says so. Verified
against `localhost:4004/mcp` on 2026-08-14. See the curl section above.

Left in place rather than deleted because it was cited as a blocker — story 817's QA
recorded all seven criteria as unexercisable and fell back to source inspection, and a
reader who finds that report needs to know this entry was the reason and was mistaken.

### ~~CLI dev DB has pending unrelated migrations~~ — resolved 2026-08-15

~~`MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs` currently fails because
auto-migrate hits a pre-existing migration (`stories_account_id_index` from
`fix_stories_account_id_type`) that errors out — unrelated to QA. Until that
chain is resolved, the local CLI seed only runs cleanly against `:prod_cli`
(the bundled CLI binary). The script itself is correct; its first invocation
in a clean `:dev_cli` env is gated on the migration fix.~~

**No longer true. `:dev_cli` boots.** Verified three ways on 2026-08-15:

- `fix_stories_account_id_type` (version `20260424170000`) **is** applied in
  `~/.codemyspec/cli_dev.db`.
- Nothing in `priv/repo/cli_migrations/` is newer than that database's highest
  applied version (`20260813230000`), so there is no pending chain to fail on.
- `NO_SERVER=true MIX_ENV=dev_cli mix run -e 'IO.puts("BOOTED OK")'` boots the
  app — which runs `CodeMySpecLocalWeb.Migrator` in the supervision tree — and
  prints `BOOTED OK`.

Struck through rather than deleted, for the same reason as the curl entry above:
it was cited as a blocker (issue `8b94f6df` could not measure a serialized graph
context because of it), and a reader who finds that report needs to see what it
was relying on.

**Two things learned while checking, worth keeping:**

`MIX_ENV=dev_cli mix ecto.migrate` is **not** how the CLI migrates and will fail
confusingly. It runs the *Postgres* set in `priv/repo/migrations`, whose first
statement is `CREATE EXTENSION IF NOT EXISTS citext`, and SQLite answers
`(Exqlite.Error) near "EXTENSION": syntax error` — which reads as a broken
migration rather than as the wrong command. The CLI migrates itself at boot from
`priv/repo/cli_migrations` via `CodeMySpecLocalWeb.Migrator`; there is nothing to
run by hand. (Filed as `02ff6d6b`.)

Booting `:dev_cli` **starts a Cloudflare quick tunnel** for `127.0.0.1:4004` and
connects a Presence client to `wss://dev.codemyspec.com`. Both stop when the
process exits, but a boot is not the inert local action it looks like — worth
knowing before running one to test something.

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

### Stop-hook pipeline scenarios need a real file write, not a fixture

Criteria about what the validation pipeline *does* — a compile error blocking
evaluation, an invalid test file re-firing with diagnostics — are not reachable
by posting a stop hook with `test_output_files` and nothing else. `f12a5c2a`
recorded two of them (story 669, criteria 5565 and 5568) as unexercisable in
pure curl+MCP QA, and that conclusion still holds. The mechanism has moved
since it was filed, and the current one is worth knowing because it decides
what *is* reachable.

**Then:** `run_pipeline/5` short-circuited with `:ok` on empty `changed_files`,
so the compile step was never called at all and the fixture fed nothing.

**Now:** a quiet stop calls `Analysis.ensure_stale_runs/3` with
`only_failed: true`, always including `compiler` among the candidates, and the
caller's opts — including `compile_output_file` — reach the dispatched job. So
a fixture *can* feed a run from a quiet stop. What gates it is `only_failed`:
it enqueues a source whose last run failed, crashed or timed out, and one that
has never run ("a source that has never run is stale, not current"), and
nothing else.

The practical consequence for QA: on the live project, whose compiler has run
and succeeded, a quiet stop enqueues nothing and the fixture is inert. On a
project or source with no completed run it would fire. Neither is a reliable
lever, so the criteria stay spex-covered.

To exercise these live you need a real file write inside the task window —
PostToolUse attribution is what puts a path in `changed_files` — which means a
real agent edit or a `mix`-driven write, not a curl. The spex do exactly that:
`Environments.write_file` plus `use_cmd_cassette`, which is why they cover
these two and QA does not.

If this becomes worth reaching from QA, the two routes are a seed that
pre-populates `FileEdits` attribution rows, or a fixture endpoint that bypasses
the `changed_files` gate. Neither exists.

## Notes

- **Don't run `mix phx.server` if these ports are in use.** Both endpoints already auto-start under the dev release; check `lsof -i -P -n | grep LISTEN | grep -E ':4000|:4001|:4003'` first.
- **The hosted endpoint has HTTPS on `4001`** with a self-signed cert (`priv/cert/selfsigned.pem`). Stick to `http://127.0.0.1:4000` for QA — TLS adds nothing here and Vibium prompts for the cert.
- **`dev.codemyspec.com`** is the production hostname tunneled via Cloudflare from the dev box (see `:cloudflare_tunnel` in `config/dev.exs`). Don't QA against that — it's externally reachable. Always use `127.0.0.1`.
- **Existing manual QA plan** lives next to this file at `manual_qa_plan.md`. That doc covers a different scope (CLI install, Burrito binary, extension load) and remains the reference for those concerns; this plan is strictly the running backend.
- **Per-story QA uses this plan** — `QaStory.check_plan` reads `.code_my_spec/qa/plan.md` as Phase 1, before any story brief is written. Keep the Tools Registry section honest because it ends up in every story prompt.
