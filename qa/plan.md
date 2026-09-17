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
>
> **Heads up — 4004 is sometimes the light harness, not this app:** on a box running the light harness (`CMS_HARNESS=1` / `cms harness`, e.g. a sprite, or a dev box someone set up with `CMS_HARNESS_PORT=4004`), port 4004 answers as `CmsHarness.Web.Endpoint` — a proxy for hooks/analysis/promotion with no LiveView, no data plane, and no `CodeMySpecLocalWeb` routes at all. A browser hit there gets a JSON `systemMessage` ("this is the local harness process, not the CodeMySpec server"), and `/health` returns the harness's own status JSON rather than this app's plain `{"status":"ok"}`. Check which one is actually listening before trusting anything below against it — `curl -s 127.0.0.1:4004/health` tells you immediately — and if it's the harness, QA the local LiveView surface against **port 4000** (`CodeMySpecWeb.Endpoint`) instead.

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

**Prefer `POST /dev/sign-in`.** It mints the same `"login"` token `deliver_login_instructions/2` puts in the email, redeemed at the same route by the same controller — so you exercise the product's real session auth and skip only the mailbox. It exists because working the magic-link flow by hand every run meant racing every other agent on the box for a `/dev/mailbox` they all share, where "the right message" is whichever login arrived last. `POST /dev/sign-up` registers. Both are in `:dev_routes`, `pipe_through :api` (`router.ex:432`).

**It makes you *a* user, not an *arbitrary* user.** `sign-in` requires the account's password and checks it, so it cannot hand out a session for an account whose password nobody knows; `sign-up` only mints fresh accounts. The router's comment — "that one can message an agent, this one can become a user" — distinguishes the route from `/dev/agents/:id/message`; it is not a promise you can become the project owner.

**A question asked through the local harness is addressed to nobody real.** `Scope.for_local_project/2` (`scope.ex:127-138`) sets `user = default_local_user()` with no branch — a synthetic non-DB struct, `id: 0, email: "cli@localhost"` (`:201-208`). `HarnessScope` (what `:4004` runs through) resolves the scope this way and `AgentScope` runs after it, setting only `:agent_id` and never touching `user`. So every question a fixture asks carries `user_id: 0`, **not** the account owner — which is what both the QA plan and I previously assumed, and it is wrong.

The consequence: no sign-in-able account, existing or freshly minted, can ever equal a sentinel that is not a row. Story 1009 proved it by minting a throwaway user via `/dev/sign-up` (`user_id: 99`) and getting "Question not found or not authorized" on a fixture-asked question, while a real pre-existing question stayed viewable in the same browser session. `DevAgentController.answer` is no way round it either: it only reaches `status == "pending"` requests, so it can never touch one the main agent already answered.

So any criterion needing the **user** side of a locally-asked question — answering, overruling, approving — is blocked today. Story 1009's 3220/3222 stay partial; issues `19b0d2d4` (the QA gap) and `7ba12775` (the mechanism, and whether it is also a product defect). Remedies are a QA-owned project seeded end to end, or a dev seam that answers as a named user. Neither exists; don't burn a pass improvising one.

**Magic-link login (fallback)** — fill `user[email]`, click "Log in with email", then read the swoosh mailbox at `http://127.0.0.1:4000/dev/mailbox` (banner on the login page links to it) to grab the token and visit `/users/log-in/:token`. Persist with `browser_storage_state`. Use when you specifically need to test the mail path; otherwise it is the slow, contended route.

The seed user is **pre-confirmed**, which matters: an account with a password set and no confirmation is refused a magic link on purpose — allowing it is a session-fixation vulnerability — and with no password form on the page that account has no way in at all. `qa_seeds.exs` now confirms the user it creates, and confirms an existing one that predates that. If you meet "Confirm your email address before signing in with a link", the user is in that state; re-run the seed.

Quick smoke test of auth gating: GET `/app` while unauthenticated → 302 to `/users/log-in`.

**Local login (port 4004 dev / 4003 published):** none — `LocalOnly` accepts the loopback IP directly. Just navigate.

**LiveView click reliability:** card-link clicks on `/projects/:project_name` occasionally do not navigate (URL doesn't change). Direct `browser_navigate` to the destination URL is more reliable; reserve clicks for in-page interactions where you're already mounted.

**One browser, shared by everyone — serialize browser work.** Vibium has no
per-caller isolation. `browser_new_page` opens a **tab**, not a browser context:
the cookie jar is shared, and `browser_switch_page` moves one global "current
page" pointer that every other call acts against. There is no per-call page
targeting anywhere in the tool surface.

What that costs, measured by three agents independently during a 6-way QA
fan-out (issue `9fe95b42`):

- `browser_get_url` answered correctly and the very next `browser_get_html`
  returned a different agent's page — another caller's tab switch landed
  between the two calls. **A `get_url` answer is stale for the call after it.**
- `browser_delete_cookies` is global. Clearing cookies to break a stale
  re-auth logs out every concurrent agent.
- Logging into a second account while another is active silently failed the
  submit — it read as a wrong password — and left the page on the other
  account.

So: **only one caller touches the browser at a time.** Others do non-browser
prep and wait. "Re-verify carefully between steps" is not a mitigation; it was
tested and another caller can flip the shared login state between your own two
steps. Anything needing two simultaneously-authenticated accounts cannot run
correctly at all while another vibium session is live.

The risk this is really guarding against is a QA agent recording a **false
PASS** against evidence gathered from somebody else's session.

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

### `qa_as_agent.sh` — making a call *as* an agent

`.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json-args>'`

For the class of story where the *asker* is an agent: a question routed to the
main agent, a task claimed by a named agent, anything that reads
`frame.assigns[:agent_id]`. Those tools take no `agent_id` parameter on
purpose — `Plugs.AgentScope` says who is calling comes off the connection
rather than out of the caller's words — so a QA session cannot reach them from
its own MCP connection, whatever it passes.

This opens a second connection with `X-Agent-Id` set. The header is still
resolved inside the project the request is already scoped to, so it can only
name an agent you are already authenticated for.

**Make your own fixture; never borrow a working agent.** Attributing a
synthetic question to a real mid-task agent corrupts the main agent's and the
owner's read of its state, which is the one thing a QA pass must not do.
Everything except the call itself is already a tool you have:

1. `create_working_copy` — a scratch checkout
2. `start_agent` with `role: "coding"` — the reply names the agent id
3. `qa_as_agent.sh <id> <tool> '<args>'`
4. `stop_agent`, then `offboard_working_copy`

The coding role is the point: `MainAgent.holder_for/2` treats `:main` as
"user", so a main-role fixture routes exactly like no fixture at all. That is
why the sandbox project's existing agents were no use for this (`e2b72303`).

**A standing fixture already exists — reuse it rather than provisioning.**

    agent        5e603bd6-ba8d-4072-bcad-bb45fb506314   role coding, continuous false
    working copy d6019ba0-4846-4a6c-ac57-7647aced8753   qa-3252-3253-verify-v2

It is parked, holds no tasks and runs no turns, so naming it costs nothing and
corrupts nobody's state. Confirm it still answers before you build on it:

    qa_as_agent.sh 5e603bd6-ba8d-4072-bcad-bb45fb506314 run_script '{"script":"return list_tasks({})"}'
    → Returned:
      No tasks.

An empty queue *is* the proof: your own session holds tasks, so "No tasks."
means `X-Agent-Id` resolved to the fixture and not to you. `:agent_not_found`
or your own task list means the hop did not happen and nothing downstream of it
is evidence about anything.

Build a fresh one only if you need two askers at once, or if that one has been
offboarded — then leave this note pointing at whatever you leave behind.

**Most tools are code mode, but the ones this story needs are not.** A tool that
moved answers a direct `tools/call` by telling you to use
`run_script({script = "return tool({…})"})` — `list_tasks` is one, and that
refusal still proves the identity hop reached the tool layer, though it is not a
result. Wrap it and send it again.

The exceptions are deliberate and are exactly the asker's surface:
`ask_user_question`, `check_answer`, `list_user_questions`, `send_message`,
`start_agent` and `stop_agent` stay directly callable, because a script sandbox
cannot wait on a person or spawn a process (`local_server.ex:63`). Call those
straight through `qa_as_agent.sh`, with no `run_script` wrapper.

Goes through the harness proxy on :4004, which forwards the header and
supplies the harness identity — so it drives the real MCP surface rather than a
QA-only shortcut, and a pass through it is evidence about the thing agents
actually use. Sending straight to :4000 needs a bearer and `X-Project-ID`
instead.

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

### `qa@codemyspec.local` lands on the wrong account, not off the real project

Browser QA against the real "Code My Spec" project (`708492f9-...`) at
`/app/projects/708492f9-.../...` redirects to `/app/projects` with "That
project is not yours, or does not exist." This reads as a missing membership
and is not one — `qa@codemyspec.local` genuinely belongs to account `0f27281c`
("Code My Spec"), which owns that project. The account exists; it just isn't
the *active* one.

**Why:** the seed user belongs to nine accounts (eight of them QA-owned
leftovers from past runs — `QA Account`, `QA Second Account`, `QA Team 605`,
several `QA 878 Recheck/Verify` variants). Login lands on whichever one the
session happens to pick, and every project page checks membership against the
*active* account, not every account the user belongs to.

**Fix before navigating to a project page:**

```
/app/accounts/picker    -> choose "Code My Spec"
/app/projects/picker    -> choose the project
```

Then `/app/projects/<id>/...` resolves normally. Do this once per fresh QA
session, right after login, before any project-scoped browser QA (`5d9bdc2d`).

The eight stale QA-owned accounts are cruft from past runs and worth pruning
periodically so a fresh login has fewer wrong accounts to land on — not done
as part of this plan fix.

### Machine saturation looks exactly like a broken tool

A shared box running many agents' worktrees at once (load average 20+, swap
pressure) produces intermittent `Unknown tool: X` / `No such tool available`
failures that are indistinguishable from a real tool-dispatch bug — and the
tool is reported working again on the very next call, with no restart, once
load drops (`6a8a4186`).

**Before concluding a tool is broken or restarting an agent to "fix" it:**
check machine load (`check_machinery`, or `uptime` if you have shell access).
A `load_average` well above the core count is the more likely explanation than
a genuine dispatch defect, especially if the same tool worked moments earlier
from another session. Restarting an agent on a saturated box adds load rather
than relieving it — `check_machinery`'s own guidance already says so — so a
restart in this state may make the underlying symptom worse, not better.

### Graph provenance is on :4000's page, not on the local JSON API

`GET /api/projects/:project_name/requirements/graph` returns `computed_at`,
`served_from` and the watcher's state, and is the surface story 1021's criteria
were written against. It lives on `CodeMySpecLocalWeb.Endpoint` — the desktop
app — and **nothing on this box serves it**. Port 4004 is
`CmsHarness.Web.Endpoint`, a light harness whose router proxies `/mcp`,
`/api/harnesses/*/hooks`, `/analysis`, `/promotion`, `/skills` and `/health`
and nothing else; 4003 is the same shape. A QA session on 1021 lost time
establishing that (`5dab2365`).

**Read it on `:4000` instead.** `/app/projects/:project_id/requirements/graph`
renders the same four facts, and carries machine-readable hooks so you do not
have to parse prose:

    data-served-from="cache" | "computed"
    data-test="graph-computed-at"      (title attribute holds the timestamp)

`RequirementsLive.provenance/2` builds them from the same
`Requirements.cached_all/1` metrics the JSON route would, plus
`GraphWatcher.status/1`. Its own comment says why the watcher is beside the
timestamp: a graph that has not changed and a graph that has *stopped being able
to change* both show an unmoving `computed_at`, and only the watcher's state
tells them apart.

So cache-vs-recompute criteria are reachable — 3231, 3232, 3239, 3240 and the
cache-hit halves of 3235–3238 / 3346–3349. What is not reachable is the JSON
shape itself, and no criterion is about the JSON shape.

Do not reach for the MCP read tools for this. `show_story_requirements` and
`list_requirements` go through `RequirementGraph.compute_all/1` and always
recompute, so they can never demonstrate a cache hit; `get_next_requirement` is
cache-aware and exposes no timestamp.
