# The harness

The light harness (`cms_harness`) is the process on the machine that holds the
working copies. It has no Repo and no tools of its own: it serves checkouts to
the server over one channel each, runs analyzers and agents against the local
disk, answers hooks, and proxies MCP to the server. This doc covers everything
except the channel itself, which is in `knowledge/harness/channel.md`. Code
comments point here by section name.

| Module | Role |
|---|---|
| `CmsHarness.Application` | Boots the harness (or `cms migrate`): toolchain PATH, log handler, endpoint, CLI flags. |
| `CmsHarness.Config` | Server URL, credential, local state directory, ports, scrubbed env. |
| `CmsHarness.HarnessConfig` | Reads and writes a working copy's `.cms_harness.json`. |
| `CmsHarness.Credentials` | Which credential to present for a working copy. |
| `CmsHarness.Token` | Exchanges a deploy key for a short-lived access token; caches per copy. |
| `CmsHarness.Device` | This machine's identity (`device.json`) and the announce. |
| `CmsHarness.WorkingCopyReporter` | Reports which known checkouts are still on disk; serves the ones the server names. |
| `CmsHarness.WorkingCopies.Create` | Makes a worktree beside a checkout and gives it an identity. |
| `CmsHarness.Channel` | What the rest of the harness asks of a copy's channel client. |
| `CmsHarness.Sync` | Scans a copy and reports the manifest plus facts only this machine can read. |
| `CmsHarness.Analysis` | Runs one analyzer and returns raw diagnostics. |
| `CmsHarness.AnalysisSlots` | Machine-wide limit on concurrent analyzer runs, in two lanes. |
| `CmsHarness.TestDatabase` | Names the test database partition per copy and source. |
| `CmsHarness.Agents` | Translates a server launch request into engine options. |
| `CmsHarness.Agents.Engine.Impl` | One agent: a supervised process running an Alloy loop. |
| `CmsHarness.Agents.Provider` | A provider name and credential as Alloy options. |
| `CmsHarness.AppInstance` (+ `Runner`, `Runner.Local`) | One copy's own running app, its database clone and its tunnel. |
| `CmsHarness.Browser` | One vibium MCP session per copy. |
| `CmsHarness.Mcp.Transport.Anubis` | MCP sessions: HTTP to our server, stdio to local subprocesses. |
| `CmsHarness.HookDecision` | What a hook answers when the harness could not ask. |
| `CmsHarness.Web.McpController` | Forwards MCP JSON-RPC to the server with auth and routing headers. |
| `CmsHarness.Web.HealthController` | `/health`: up, and separately what is reachable. |

## Working-copy identity

- One file per checkout, `.cms_harness.json` at the root: `working_copy_id`
  (also written as `harness_id` for older readers, including the published
  `cms` binary), `project_id`, `root`, and when known `deploy_key`,
  `preview_url`, `server_url`. Other writers keep their own keys there
  (`preview_tunnel_secret`).
- The root is recorded so nothing has to discover it: walking up from a hook's
  directory, environment path lists and server lookups were each wrong.
- Gitignored, at the checkout root rather than under `.code_my_spec/` (a
  submodule, where a file would be stageable), and `chmod 0600`.
- **No environment fallback.** `read/1` and `read_file/1` both answer from the
  file only. `CMS_HARNESS_ID` belongs to whatever launched the daemon; the
  daemon serves many roots, and letting it answer collapsed every root onto
  one id (each join then evicted the previous one). The variable exists only
  for the Claude Code MCP mount's `X-Harness-Id` header.
- Writes merge over the raw JSON, so keys this module does not model survive.
- An existing file that cannot be read is never overwritten: it is the only
  record of the id its rows are filed under.
- `server_url` records which server minted the id; `Config.server_url_for/1`
  prefers it over the reading build's server.

## Credentials

- Resolution per working copy: `:harness_token` (a signed-in user's token,
  good for every project), then the copy's own `deploy_key`, then
  `:harness_deploy_key`. A deploy key reaches exactly one project, and one
  daemon serves several projects, so a machine-wide key could only ever join
  one of them.
- The credential lives with the identity it authenticates, in
  `.cms_harness.json`, not in a second store.
- `Credentials.any/0` is for rootless lookups (asking where an id lives, the
  device announce). It reads served roots and durable served-root hints, never
  the cwd: under the test suite the cwd is this repository, holding a real key.
  Hints supply a credential only; the server's roster decides what is served.
- `Token` trades a deploy key for an OAuth access token at
  `POST /api/sprite/token`, because `/mcp/harness` accepts only OAuth tokens.
  The key stays narrow, a leaked token expires, and one token is revocable
  alone. Tokens are cached per working copy in memory only, re-exchanged 5
  minutes before expiry, dropped on a failed exchange; `invalidate/0` clears
  them after an unexplained 401.

## Device

- `device.json` lives in `Config.local_state_dir/0`, never in a checkout:
  announcing per checkout minted a machine per worktree.
- `local_state_dir/0` is `~/.codemyspec`, or the directory above
  `CMS_PROJECT_DIR` when set, because a workspace shares the box's `$HOME` and
  must not present as the box's own device.
- The machine mints its id once and never re-asks. Server-issued ids were
  rewritten by every daemon on the box on its own schedule, so the id never
  held still. `write/1` refuses to move an id on file; a disagreeing server
  reply is logged and ignored.
- The id is the lowest globally-unique MAC (locally administered addresses,
  set by virtual adapters that come and go, are excluded unless nothing else
  exists), hashed to UUID shape; else a random UUID.
- Minted and written before the announce round trip: deferring the write left
  an unreachable machine with no id, and its next join went out empty.
- Announce failure is soft: a harness that cannot announce still serves.

## Working-copy reporting

- `WorkingCopyReporter` announces every 2 minutes with
  `%{working_copy_id => present?}`.
- It remembers every copy it has known: a removed worktree takes its config
  with it and stops naming itself, so removal is inferred from the directory
  going away.
- The server's reply (copies attached to this device) is merged into `known`,
  with locally known roots winning, and those copies on disk are served. A
  restart otherwise served only copies a hook touched, which dropped every
  background agent's copy.
- Reporting never deletes anything; offboarding is a person's act.
- Pending local projects the server offers are generated in a background task,
  once each, and only where a `CopiesSupervisor` exists.

## Creating working copies

- `git worktree add -b <name>` beside the checkout, named
  `<checkout>-<slug>`, never under `.claude/worktrees`. An existing target is
  refused.
- The project's `just init-worktree <name> <target>` does the setup when it
  exists (`cms_new` generates it). Without it: the worktree, its submodules,
  `deps/` copied from the source (a fresh worktree cannot always `deps.get`
  shallow git deps), and dotenv files symlinked. The result says
  `:project_recipe` or `:bare_worktree`.
- Submodules matter: an empty `.code_my_spec` reads as a project with no work
  done, not as a broken checkout.
- Recipes run with the daemon's `MIX_ENV` and `CMS_*` scrubbed
  (`Config.scrubbed_env/0`).
- The id arrives with the request and is written to `.cms_harness.json`, then
  onboarding records the test partition. Neither onboarding nor submodule
  failure fails the creation; both log loudly.
- A copy created with `prepare: true` (the promotion gate) runs `just
  gate-setup` in the background and carries `.cms_harness_preparing` until it
  succeeds; it is not served while the marker exists.

## Sync

- Scans run in the copy's `Task.Supervisor`, never in the channel process.
- An empty scan is logged at error and handed to the channel, which decides
  whether to send it.
- Reported each sync because the server cannot read this disk: the app name
  from `mix.exs`, the health-route check of `router.ex`, and HEAD. HEAD is
  also reported at each agent turn end, since a commit changes no watched file.
- Preview health is measured against `preview_url` on the channel's timer,
  not only on scans: an app crashes and recovers while no file changes.
  Cloudflare edge codes (530 for no origin, 502 and the 52x family) are
  `down`; `erroring` means the app itself answered 5xx.
- Machine load (1-minute load average, available memory, CPU count given to
  the BEAM) is read with `sysctl`/`vm_stat` or `/proc`, never `:os_mon`.
- Files the scanner gives no role never sync, which reads exactly like a dead
  watcher; the set is logged at info whenever it changes.

## Analysis

- The harness runs tools and returns raw diagnostics; the server converts them
  to Problems. Sources: compiler, credo, exunit, spex, sobelow.
- `{:ok, result}` and `{:error, reason}` are never merged: "did not start" and
  "ran clean" both print no diagnostics.
- The compiler's exit status is derived from its diagnostics
  (`--return-errors` exits 0 on findings); `diagnostics_available` tells
  "clean" from "nobody looked". Credo and sobelow exit status comes from the
  finding count. exunit carries `execution_status` so a suite that never
  started cannot clear every exunit Problem.
- exunit and spex results carry `partition`, the test database that answered.
- A run refused because `deps/` is behind `mix.lock` fetches once, under a
  per-checkout `:global` lock, and retries; a failed fetch is reported as
  such.
- Spex stands down while a recording session owns the copy.
- Output is scrubbed of invalid UTF-8 and capped at 100 KB on a character
  boundary before it crosses the channel.
- There is no pre-run truncate of any database.

## Analysis slots

- `Project.AnalysisServer` runs one thing at a time per copy; `AnalysisSlots`
  bounds runs across copies. At saturation (tens of load on ten cores) the
  heaviest test dies with an `EXIT` and passes in isolation, and the victim
  moves between sweeps.
- Limit per lane: a quarter of the cores by default, because each suite
  already runs `max_cases` at twice the schedulers.
- Two lanes: runs of named exunit/spex files wait in `:fast`, everything else
  in `:full`, so a targeted test is not queued behind gate sweeps.
- A caller waits up to `wait_ceiling/0` (30 minutes), then gets `:busy`. The
  analyzer's kill timer arms only once a slot is granted.
- The slot is held by a monitored process and freed when it exits; there is no
  `release/0`.

## Test databases

- Partition per working copy, read from what onboarding recorded
  (`Onboarding.resolve_partition!/2`), never derived here.
- Suffixes per concurrent suite: `<p>` for the session's own `mix test`,
  `<p>a` for the analyzer's exunit, `<p>s` for its spex. The session's
  partition is exported into Claude Code by onboarding, so sharing it with the
  analyzer let one suite's truncates fail another's tests.
- This module names databases only. `mix cms.check_test_migrations` creates and
  migrates in-VM, in `MIX_ENV=test`, which cannot be dev.

## Agents

- Agents are harness-side because the working copy is here: hundreds of file
  and shell calls per session stay local. The sprite is the isolation boundary.
- `Agents.launch/1` passes server-resolved pieces through: system prompt parts,
  `direct_tools`, `tool_reach`, `app_url`, `working_copy_id` (falls back to the
  copy's own config), `messages` (the transcript to resume from), `model`,
  `base_url`.
- Turn events go per event, fire and forget, to the channel of the one copy the
  agent runs in. Broadcasting to every served copy duplicated each line once per
  sibling checkout.
- A failed tool call is logged at `:warning`: otherwise only Alloy's crash
  branch logs, and an agent failing every call is silent in `harness.log`.
  Never `:error`, because refusals are ordinary and spex fail on any error log.

## Agent engine

- Each agent is a `GenServer` under its own `Keeper` (restarts on crash, gives
  up on a crash loop), under the copy's agents `DynamicSupervisor`. Liveness is
  watched per engine start and once per Keeper.
- The transcript is the state: an agent dies with the harness and restarts with
  the history it had. After a crash the Keeper's checkpoint is restored and an
  in-flight turn is told it was interrupted.
- One turn at a time, in a linked `Task` while the engine traps exits, so the
  agent stays reachable mid-turn.
- A turn's duration is the turn's property, not the sender's: the sender's
  timeout bounds only its own wait. There is no wall-clock ceiling (a 24h loop
  deadline exists because Alloy needs a number); `@max_turns` (150) bounds a
  runaway, each HTTP request has a 10-minute idle timeout, and each tool call
  its own limit.
- Every outcome is announced: Alloy reports failures both as `{:error, _}` and
  as `{:ok, %{status: :error}}`; `:max_turns` is announced as a cut-off; an
  empty turn is logged with its shape; a tool call leaked as DSML text is a
  failure. An interrupt is not a failure.
- Steps stream through `stream_chat/4`, not the server's PubSub (which only
  fires on completion). Text and thinking deltas are never steps; text deltas
  go to `on_draft`, a live draft that is never stored.
- Usage rides on `turn_ended`: asking the loop afterwards answers busy.
- Tools: read, write, edit, bash, plus the launch request's `direct_tools`:
  `ToolIndex.carried_definitions/1`, each tool's name, description and schema
  as the server registers it. A harness module of that name is used where it
  does more than forward (`run_script`, `run_browser_script`, `tool_docs`);
  every other one is `Tools.Direct.tool/1`, an Alloy inline tool forwarding
  over MCP. No copy of a server tool's text lives in the harness. Tools
  `CodeMode.Catalog` excludes from scripts (the graph spine,
  `assign_subagent`) must be carried directly. An uncarried tool's call is
  told where it is reachable. `Engine.tool_name/1` names a tool of either kind.
- The MCP session is opened in `init/1`, never during validation in the
  caller's process, which may be the channel.
- The tool context carries `agent_id`: the server scopes a script's tools and
  appends agent alerts only for a caller that names itself.
- Tool results over the cap spill to a file outside the checkout; the agent
  sees head, tail and path. Spill files older than 24h are pruned at start.

## Providers

- `:provider` is `{module, config}`; settings outside the config half are
  silently dropped by Alloy.
- Cost models are not auth kinds. `openai-codex`: ChatGPT plan, flat, reports
  no token counts. `zai`: coding plan, flat and counted, only on the coding
  URL. `anthropic`: metered API key (subscription credentials are not allowed
  in third-party harnesses). `deepinfra`: OpenAI-compatible API key.
  `claude-code`: this machine's own `claude` login.
- `codex exec` runs on this machine's own Codex login. ChatGPT refresh tokens
  are single-use and the CLI rotates them on start, so any copied token dies,
  taking the owner's own login with it. `ignore_user_config` borrows the login
  without the owner's plugins, MCP servers and approvers. No default model: the
  plan decides which models it serves.
- CLI providers run with `workdir` set to the working copy: `codex` otherwise
  runs in a temp dir, and `claude --resume` hits the prompt cache only from the
  same directory.
- CLI timeouts are 10 minutes of wall clock, long enough for a silent
  auto-compaction inside the call.
- Codex agents compact at 160k estimated tokens: `codex exec` refuses prompts
  over 1,048,576 characters.
- In test, a `command_runner` replaces the real CLIs.

## App instances

- Each non-main copy runs its app on its own ports and a database cloned from
  main's dev database (dump and restore; `TEMPLATE` is refused while main has
  connections), then the `seed` recipe. Main keeps its fixed ports and real
  database from `config/dev.exs`, and is never idled out.
- Lives under the copy's supervisor beside the channel chain, so it survives
  reconnects. State persists to `~/.codemyspec/app-instances/<hash>/state.json`
  so a restarted harness still knows a running app; `reported/1` reads it at
  join.
- Liveness is alive and cwd equal to the copy's root: a persisted pid may have
  been recycled. Main's port, if held by an untracked process, is reclaimed
  only when that process runs in this checkout.
- A first start (no commit yet) waits a short window, then replies `starting`
  and polls in the background up to 10 minutes, pushing `app_status` when it
  resolves. `erroring` does not end a health wait: a booting app answers it.
- Reload runs `just reload` against the live app; without a recipe or a
  running app it restarts instead.
- After a successful restart or reload of main only, the optional
  `after-promote` recipe runs. The recipe lives in the shared justfile, so
  running it for every copy would bounce the shared harness. The reply goes
  out first and the start line is flushed, because the recipe may kill this
  BEAM.
- The harness holds the tunnel, not the app, so an app restart keeps the
  connector; a harness restart drops it and the join's `ensure_tunnel_only/2`
  restores it. A copy holds a tunnel when one is handed over; copies handed the
  same tunnel share one connector keyed by tunnel id. `CMS_TUNNEL_HELD_BY_HARNESS`
  tells the app not to start its own, and `CMS_MAIN_COPY` keeps a non-main app
  from answering for main's tunnel. Tunnel config lives per tunnel id under
  harness state, never under the cwd.
- `app.log` is appended, never truncated: the dying process may still hold it
  open.

## Browser

- One `vibium mcp` process per copy, each with its own Chrome, owned by
  `Browser.Owner` in the copy's project supervisor. A single machine-wide
  session name made every copy but one fail at join.
- vibium speaks protocol `2024-11-05` and does not answer a newer proposal.
- Its tools go into the script catalog by discovered name, never onto the
  agent.
- `probe/1` runs unlinked, monitored, with a 5s deadline, because it is called
  from the join and Anubis links to its caller. Not memoised.
- `:absent` (no vibium) and `{:unreachable, reason}` both report no tools; only
  the second is a fault. Both are logged, since an agent without a browser
  never fails, it just never looks.

## MCP transport

- Our server is reached over HTTP (`Mcp.Http`), one request per call in the
  caller's process. Only stdio subprocesses use `anubis_mcp`.
- Anubis clients are addressed by name (the returned pid is a supervisor),
  unlinked from the caller, and ready only after a `tools/list` succeeds
  (`initialize` completes asynchronously; not every server implements `ping`).
- A client left registered by a gone session is replaced, never reused. Its
  `:one_for_all` supervisor would restart it under the same name, so the
  supervisor is stopped (found through the child, after proving the parent is
  a supervisor), and the name's release from the Registry is awaited.
- `client_info["name"]` is unique per session: Anubis keys a `:private` ETS
  table on it.
- Transport names wrap the Registry key, never the `{registry, key}` pair.
- HTTP sessions carry `authorization`, `x-harness-id` and, for an agent,
  `x-agent-id` (minted by the server, checked against the copy).

## MCP proxy

- Forwards whole JSON-RPC messages to `/mcp/harness` with no knowledge of the
  tools, adding `authorization` (from `Token`), `x-project-id` and
  `x-harness-id`. Sessions are per working copy.
- The working copy id comes from the path (`/api/harnesses/<id>/mcp`), then
  `?harness=`, then `?dir=` resolved locally, then the `x-harness-id` header.
  The header is interpolated from the ambient `CMS_HARNESS_ID`, which a
  worktree session inherits from its parent, so it ranks last.
- `x-agent-id` is forwarded; dropping it routed every agent question straight
  to the person.
- GET is the server-to-client stream, relayed chunk by chunk with `into: fun`.
  A non-200 is buffered and sent whole so its status survives.
- An HTML error page from a wedged dev server is summarized as a JSON-RPC
  error, never relayed into an agent's context. Refusals are JSON-RPC errors
  that name the failure; a 503 hints at a pending migration.

## Hook decisions

- "I asked and there is nothing to do" and "I could not ask" never render the
  same. Stop and subagent-stop refuse when the harness cannot ask; other hooks
  get an advisory.
- On `stop_hook_active: true` the stop is allowed with a message saying the
  turn was never verified: a block that repeats forever is its own outage.
- The refusal names which end is broken. The server is probed: a 5xx is
  server-side; a 2xx/4xx with this harness holding another copy's channel
  means this copy's channel is still joining; otherwise the harness cannot hold
  a socket.
- `summarize/2` (the log line) and `explain/3` (the agent's text) use the same
  clauses in the same order.
- `:no_reply` says how long the channel has been joined: under a minute means it
  was rebuilt after a server-side death and lost the request.
- A server error reply is quoted, not called a silence. `unmatched topic` is
  usually a reconnect race; boot drift is reported only on failure, with
  whether the drift touched the harness or channel contract and the restart
  command (`just refresh-harness`).
- `:server_unreachable` never blames the id.

## Health

- `/health` reports `status: up` and, separately, per working copy:
  `connected` (belief), `server_replied_ago_s` and `joined_ago_s` (evidence),
  `watching`, and `onboarded` (a recorded test partition).
- `degraded` when nothing is served, or any copy is not connected, not
  onboarded, or never answered more than 60s after joining. A quiet channel is
  not degraded.
- `build` and `build_drift` say which code is answering and whether its
  checkout moved; a checkout behind upstream needs a pull, not just a restart.
- Nothing in `/health` blocks on the network.

## Application

- `MIX_ENV=harness`, under `just harness` or the installed release. Boots the
  harness endpoint (`server: true` only here), the supervisor, then serves
  `CMS_PROJECT_DIR` if set (a sprite).
- No machine-wide credential is a warning, not a halt.
- Under a service supervisor the PATH is bare; the user's interactive shell
  PATH is recovered (fenced in a sentinel, bounded, falling back to `-lc`),
  because version managers initialise in rc files and a wrong-OTP `mix` hangs.
- The log handler always writes `harness.log` with the OS pid as `inst`.
- Only a packaged release parses argv as `cms` subcommands.

## Lessons

- **Identity comes from the copy's own files, never the environment.** One
  inherited variable answered for every root the daemon served.
- **Never read the cwd for anything per-copy.** Under the suite it is this
  repository, with a real credential.
- **Merge over the raw file when another writer shares it.** A decoded
  round-trip dropped a secret that cannot be re-read.
- **A machine decides its own id once.** Re-asking a server, from several
  daemons, produced an id that never held still.
- **Record before the round trip.** A deferred write turned a network failure
  into an identity failure.
- **A turn's duration belongs to the turn.** Threading the sender's timeout in
  killed long turns and blamed the agent.
- **Every outcome is announced.** Silence reads as an agent thinking.
- **Anything called from the channel process is isolated.** Unlinked,
  monitored, bounded; a linked crash takes every copy down.
- **Never reuse a leaked client; stop its supervisor.** Stopping the child
  alone races its restart.
- **Saturation manufactures failures.** Bound concurrent suites machine-wide
  before reading a red test as real.
- **Separate test databases per concurrent suite.** One suite's truncates read
  as another branch's breakage.
- **Never run a sweeper that truncates whatever database it reaches.** One
  emptied the shared dev database because `MIX_ENV` was scrubbed from its
  child; residue shows itself as phantom failures.
- **Reply before running anything that may kill this BEAM.**
- **Report, never decide, from a timer.** Deleting derived state on a timer
  removed copies agents were working in.
- **Name the broken end.** A hedge sent readers to the healthy side.
- **Belief is not evidence.** `connected` stayed true while the server held no
  registration; count server replies.
- **Absent is a state worth logging.** A missing browser or an unclassified file
  fails silently otherwise.
