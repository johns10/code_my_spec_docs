# Infrastructure

See [machine identity](machine-identity.md) for the unified server/device model.

The modules around provisioning: what is deployed where, the servers and
provider resources an account holds, the deploy artifacts a project carries,
the OAuth integrations that act on the user's accounts, the execution
environments every shell-out and file read goes through, and the plugin
release packager. The provisioning engine itself is documented in
`knowledge/provisioning` (index.md, steps.md); this doc does not repeat it.
Code comments point here by section name.

| Module | Role |
|---|---|
| `Deploys` | Read model of what is deployed per story and environment; the `deploy` requirement's checker. |
| `ExecutionContexts` | Execution primitives (files, commands) over an opaque `ExecutionContext`, dispatched by type. |
| `ExecutionContexts.ExecutionContextsBehaviour` | The contract every environment implementation meets. |
| `Generators.DeployArtifacts` | Writes the deploy artifacts a project is missing. |
| `Generators.DeployBoilerplate` | Audits a project for those artifacts and their deploy traps. |
| `Integrations` | OAuth and API-key provider connections; token freshness and refresh. |
| `Integrations.IntegrationRepository` | User-scoped integration rows, encrypted tokens, the refresh row lock. |
| `Integrations.Providers.Cloudflare` | Cloudflare's OAuth config, scopes and identity normalisation. |
| `Resources` | Account health: expected versus actual resources, dangling detection, trim and fix. |
| `Servers` | Account-owned servers: provider list merged with links, creation, access key, containers. |
| `Release.PackageExtension` | Lays out the plugin marketplace repo (Claude Code, Antigravity, Codex) for release. |

## Deploy records

- A deploy row exists per `{project, story, environment}`; `record/4` upserts,
  because redeploying is ordinary and "is this story on UAT" must stay a
  lookup.
- Only `health_verified_at` makes a deploy count (`healthy?/1`, the single
  predicate both the querying and preloaded checkers use). `record/4` and
  `verify/4` are separate because the deploy goes out before anything checks
  it.
- The `deploy` requirement used to be satisfied by an agent-written file
  containing "verified" — the gated party could assert its own gate. The read
  model exists so only a passing health check can satisfy it.
- `record_environment_deploy/3` records every story that has cleared QA
  (`Verdict.complete_check/2`), called by the deploy step after its probe
  passed. Stories still in QA are not recorded even though their code is in
  the image.
- `environment_deployed?/2` counts only `ready_for_dev` stories, matching the
  graph's own filter; no released stories means not deployed.
  `server_deployed?/2` is false for a server no environment points at.
- `uat_check` asks about UAT only; prod promotion is the release process's.
- Every successful write announces a `deploy_changed` graph event per row
  (`record/4` has callers of its own). The event names the story; a row with
  no story names nothing and recomputes the project.

## Execution contexts

`CodeMySpec.ExecutionContexts` dispatches filesystem and command operations
through `%CodeMySpec.ExecutionContexts.ExecutionContext{}`. This is execution
location and transport, separate from deployment environments such as dev,
UAT, and prod. Local/CLI adapter configuration uses `:execution_context_adapter`;
container overrides use `:container_execution_context_adapter`.

`WorkingCopies.execution_context/1` resolves the explicitly selected working
copy in the active project. Missing, mismatched, or unrooted copies return nil;
it does not choose Main or another checkout. Remote agent access should build
on this explicit target selection and the existing harness transport.
`WorkingCopies.tool_execution_context/2` additionally supports a configured
stdio working directory when no working copy was selected.

Execution options and setup context fields use `execution_context:`.
The existing `:no_environment` error is retained for caller compatibility.

- Types: `:cli`, `:local` (local filesystem; `Cli` delegates `cmd` to
  `Local`), `:container`, `:harness` (a working copy on another machine, over
  its channel; not configurable, since swapping it means swapping the
  transport), `:memory` (spex). `impl/1` has no catch-all: an unknown type
  raises `FunctionClauseError`.
- A `nil` execution context is the server with no local working copy, and every
  file operation answers rather than raising: `{:error, :no_environment}`,
  `[]` for `glob`/`stream_files`, `false` for `file_exists?`, `{"no
  environment", 1}` for `cmd`. Before this, task prompts for whole classes of
  requirements could not render.
- That makes "no disk" and "not there" the same reply from `file_exists?/2`.
  A checker that must tell them apart uses `unobservable?/1` or
  `AgentTasks.Setup.Context.dir_status/2` (`:unobservable`); flattening them
  tells an agent to redo work that is probably done.
- `exec_file_exists?/2` asks the filesystem `cmd/4` runs in. In-memory test
  environments fake the domain filesystem but execute on the real one, so a
  tool-availability check must follow `cmd/4`.
- `cmd/4` output has ANSI stripped and invalid UTF-8 scrubbed, never trimmed
  (porcelain output's leading space is data).
- `lookup_registered/1` returns `nil` when the registry is not running, asked
  via `Process.whereis/1` rather than rescued: a rescue cannot tell "not
  started" from a wrong registry name.
- `mix_exs_app_name/1` reads `app:` from `mix.exs`; `nil` (never a guess)
  when unreadable.

## Child process environment

- The packaged harness is an OTP release whose `erl` exports `ROOTDIR`,
  `RELEASE_*` and friends. A child `mix`/`erl` inheriting them resolves boot
  files to our ERTS and dies "cannot get bootfile". `clean_otp_env/0` returns
  `{var, nil}` entries clearing them, plus our Mix vars (`MIX_ENV` etc.),
  which would otherwise change which of the child project's dependencies
  exist (a `:dev`-only generator reported "task could not be found").
- Clearing vars is not enough: the release's `erts-*/bin` is on PATH (first,
  under the Windows MSI), so the child still finds our `erl`.
  `path_without_release_dirs/0` drops every PATH entry under `RELEASE_ROOT`
  (case- and separator-insensitive on Windows). Off a release, PATH is
  untouched; stripping that would empty PATH leaves it alone.
- `merge_clean_env/1` is for callers running a child `mix` in another
  project's directory. It keeps the caller's explicit `:env` entries (a
  caller may choose `MIX_ENV`, e.g. `test` for the analyzer) and moves the
  asdf/mise shim directories to the front of PATH, so the child resolves the
  toolchain its own `.tool-versions` pins. Under a version manager the
  parent's PATH has its resolved bin dir ahead of the shims; without the move
  a generated app pinning a newer Elixir refused to run.
- Shims are moved, not added: they are usually already on PATH, behind the
  resolved version, and skipping present ones left the fix inert.
- `clean_otp_env/0` stays a pure scrub: it never emits a PATH it was not
  asked to clean.

## Generated deploy artifacts

- `DeployArtifacts.generate/2` writes only missing files, never overwriting;
  a failed write halts and names the file. Scripts under `bin/` and
  `rel/overlays/bin/` are `chmod +x`'d (a non-executable script fails with
  `:enoent`).
- Content follows `priv/knowledge/devops/hetzner-docker-deploy.md`: the image
  is built (CI for a human, the builder for setup), Kamal deploys by tag, and
  kamal-proxy terminates TLS and routes by hostname.
- `otp_app_name/1` underscores `module_name`; the slug fallback replaces
  hyphens, since the name becomes a release name, a `_build` path and module
  names.
- Image options: `:image` is the full reference CI pushes; `:kamal_image` is
  the bare repository path kamal's `image:` wants (kamal reads the host from
  `registry.server`); `:prod_registry`/`:uat_registry` are per-environment
  registry hosts. The self-hosted `Provisioning.Registry` has no owner
  segment, so its callers pass `Registry.image/2`.
- One kamal config per environment; `servers.web` is the environment's
  hostname, which the DNS step points at the box before the deploy step.
- The kamal `ssh:` block is ERB, rendered by kamal at deploy time and guarded
  on `CMS_SSH_KEY_PATH`. With it: `keys_only: true` (otherwise kamal offers
  every agent identity, exceeds `MaxAuthTries`, and falls to a password
  prompt that crashes with `Errno::ENOTTY` non-interactively) and
  `log_level: debug` (kamal's default `:fatal` hides why publickey auth was
  abandoned). A human run without the var keeps kamal's defaults.
- Both release overlays (`boot`, `migrate`) share `sops_preamble/1`: each
  starts the release, whose `runtime.exs` needs `DATABASE_URL` and
  `SECRET_KEY_BASE`, so each decrypts `envs/<APP_ENV>.enc.env` with
  `SOPS_AGE_KEY` via `sops exec-env`. They once drifted and every migration
  died "DATABASE_URL is missing". A missing file or key is reported before
  sops runs (sops says "no identity matched", which misleads).
- The Dockerfile's `CMD` is `bin/boot`, not `bin/<app> start`, for the same
  reason. The image carries ciphertext; the key arrives at run time.
- `bin/deploy` has two callers: `Provisioning.Deploy.run/3` calls
  `migrate <env>` and `swap <env>` with `CMS_IMAGE` set to the image it
  already built and pushed (no GitHub involved), and a human runs the default
  branch (push, wait for CI, migrate, swap). `swap` uses `--skip-push`
  (kamal's redundant push failed against an HTTP-only registry). `migrate`
  passes `-e SOPS_AGE_KEY` (the host's role env file is from the last boot,
  so a rotated key deadlocked) and uses `--config-file` (kamal has no
  `--config`; Thor folded it into the command). A host never deployed has no
  env file; `Deploy.run/3` handles that bootstrap, not the script.
- `release_module/1` generates `<App>.Release.migrate`, which the migrate
  overlay calls inside the release where Mix is absent.
- `backup_script/0` must stay byte-identical to the `cms_new` template
  `templates/deploy/backup_script.eex`. It exists only for projects not
  scaffolded by `mix cms.new` and for the spex harness; two copies drifting
  is the known risk.
- `runtime_config/1` keys config on the real OTP app (it once shipped under
  `:app`, configuring nothing) and excludes `/health` from `force_ssl` with
  `exclude: [hosts: [...], paths: ["/health"]]`, restating the default hosts
  because Plug drops them once `:exclude` is given.
- The generated router serves `/health` outside every pipeline.

## Deploy readiness audit

- `DeployBoilerplate` audits any project, including ones this generator did
  not produce, so it reads files rather than trusting generation.
- `present?/3` checks the live environment first and falls back to the
  synced `Files` table: a harness-scoped devops caller has a directoryless
  environment, and reported every committed artifact missing until the
  fallback existed. A scope with no project cannot use the fallback.
- `force_ssl_excludes_health/2` accepts only a `paths:` list naming health.
  `Plug.SSL` reads a bare list of strings as hosts, so a flat
  `exclude: ["/health", ...]` excludes nothing, the probe gets a 301 and the
  deploy fails "target failed to become healthy". Full-line comments are
  dropped first (`phx.new` ships `force_ssl` commented out); mid-line ones
  are not, since `#` may be in a string.
- `health_route_unpiped/2` checks the router scope holding `/health` has no
  `pipe_through`; with no router route, an `endpoint.ex` mentioning
  `"/health"` passes (a plug before the router runs no pipeline). That
  fallback is textual on purpose: atom plugs are implemented by a `defp`
  further down.
- `plaintext_env_files/2` reports a plaintext env file only if it could ship:
  ignored by both `.gitignore` (`git check-ignore`) and `.dockerignore`
  (simple `*`/`?` globs) means no exposure path. No proof of exclusion (no
  checkout, git cannot answer) counts as not excluded.

## Integrations and token refresh

- Providers: GitHub, Google, Cloudflare, Resend, OpenAI. Login scopes exist
  only for GitHub and Google; infrastructure providers cannot be used to sign
  in.
- `fetch_access_token/2` is what provider code calls; `get_integration/2`
  returns whatever is stored, often dead for short-lived grants (Resend:
  fifteen minutes).
- A token is stale `@refresh_skew_seconds` (120) before its expiry: an
  exact-instant check passes a token with seconds left that then fails mid
  request.
- Refresh is serialised per grant: a transaction takes a `FOR UPDATE` row
  lock (`lock_integration/2`), re-checks freshness, and makes the provider
  call while holding it. Rotating providers (Resend rotates every use)
  invalidate the old refresh token, and presenting a spent one can revoke the
  whole grant.
- No refresh token: still valid returns the token; expired is
  `:reauthorize_required`. API-key and GitHub tokens are stored with a
  one-year expiry so they take the fresh path.
- `connect_api_key/3` verifies with the provider before storing; a refusal
  and an unreachable provider are distinct errors.
- `assent_refresh/2` merges `strategy.default_config/1` under the provider
  config only when the strategy defines it; plain `Assent.Strategy.OAuth2`
  providers (Cloudflare, Resend) do not, and calling it crashed the first
  Resend refresh.
- Writes never lose state: a response without `refresh_token` keeps the
  stored one (Google omits it outside fresh consent, and social login drops
  `prompt=consent`); scopes accumulate across grants; an `id_token` is kept in
  `provider_metadata` and a response without one leaves it alone. `codex
  exec` refuses an `auth.json` with no `id_token`.
- `:integration_client_overrides` swaps a provider's client per build (the
  desktop app has no server secret: public clients, loopback redirect).

## Cloudflare OAuth

- Delegated OAuth, not a pasted API token, so the user can revoke access
  from Cloudflare's side. PKCE is required: an authorize request without
  `code_challenge` gets `invalid_request`.
- Scopes are dot-separated (`zone.read`); the colon form Cloudflare's
  API-token UI shows is rejected `invalid_scope`. Names are not derivable
  (`registrar-domains.admin`, `dns.write`). An unpermitted scope fails the
  whole request, so probe a new name against the live authorize endpoint
  before adding it.
- No scope reads the user: `GET /client/v4/user` answers 403 (9109) on a
  delegated token, after a successful exchange. `user_url` is the zone list,
  and `normalize_user/1` derives identity and the account id (which zone
  creation needs) from the zones' accounts.
- Sandbox registrar scopes exist for exercising registration without buying
  a domain (`sandbox_config/0`). `cache.purge` is not requested: nothing
  purges cache.
- `offline_access` is not selectable; Cloudflare adds it when the client's
  grant types include `refresh_token`. Requesting it from a client without
  that grant fails `invalid_scope` and makes Cloudflare impossible to
  connect, so it is behind `:cloudflare_offline_access`. Without it there is
  no refresh token and the grant dies at expiry.
- Registered redirect URIs: `codemyspec.com` and `dev.codemyspec.com`
  `/auth/cloudflare/callback`; localhost is not registered.

## Resource health

- `report/1`: per project the expected set is `ProvisioningPlan`'s checklist
  (the same source the run uses — never a second manifest); across the
  account, `Inventory.list/1` asks each provider what exists.
- Projects count when `devops != :off`, not when setup has run: a project
  turned on and never provisioned must show as unhealthy.
- The actual side always comes from providers, never
  `provisioning_steps.state` (a certificate that expired since still reads
  `done`).
- A resource dangles only if it was **ours**: an A record pointing at an
  address setup recorded for a server that no longer exists, or a bucket
  setup recorded that no environment names. Flagging anything unrecognised
  made a real account's own external hosts the bulk of the flags.
- `:unknown` is not a problem (Hetzner unreadable makes A records `:unknown`
  rather than dangling), but any provider error makes the status unhealthy.
- `keep/3` marks a dangling resource `:kept`: still listed, not counted.
  `trim_candidates/1` excludes kept resources by construction, and `trim/1`
  deletes through `Teardown.resource/3`.
- `fix/2` runs the whole idempotent sequence with the configured step opts
  (omitting them silently runs real providers). `fix_async/3` returns once
  the run has started or been refused: the task claims `RunLock` and only
  then acks, with a 5s handshake timeout; MCP calls time out long before a
  deploy finishes, and a caller reading that as failure retried into a run in
  flight. Inline when `:provisioning_async` is false (tests).
- `project_report/2` never looks past its one project: a harness-scoped
  caller once saw another project's full state through `report/1`.
- `project_scope/2` keeps the caller's working copy only if it belongs to the
  target project.

## Servers

- Servers belong to the account, not a project; a project environment points
  at one by `server_name` (written by a successful setup run) or `device_id`
  (written immediately by linking). `environments_on/2` matches both.
- Linking touches nothing on the box — it is used on boxes already serving.
- `list/1` is the provider's answer merged with our links: linked but
  unreported is `missing` (things still point at it); unlinked servers are
  shown too (an invisible box keeps billing). When the provider is
  unreachable it returns `{:error, reason, linked}` with links marked
  `unverified`, never an empty list or a bare error.
- `provision/2` creates already linked and never retries at another size or
  architecture; it passes `:server_type` so Hetzner's cross-architecture
  fallback stays off.
- `available_options/1` uses `/datacenters` availability (the catalogue
  lists types sold out everywhere) and prices per location (most types are;
  the first price quoted one city at another's rate).
- The SSH access key is account-grain, generated once with `ssh-keygen` into
  `AccountSecrets` and matched on fingerprint, so every box is reachable by
  one key. `access_public_key/1` is for adopted boxes, added by hand.
- Containers are attributed to projects by exact service name (`<app>` for
  prod, `<app>-<env>` otherwise; `<app>` as the slug or the kebabed module
  name). Unplaceable containers keep `project_id: nil`.
- Machine purpose labels are free strings; `prod`/`uat` are suggestions. Devices owns the record; Servers supplies provider operations.
- `retire/2` refuses while any project points at the machine, then clears the provider link without deleting its device identity or harness credentials.

## Plugin packaging

- `package_plugin_files/3` copies the Claude plugin (never `bin`), stamps the
  git version into each `plugin.json`, writes the marketplace manifests,
  `install.sh` and README, and packages the Antigravity and Codex ports from
  sibling `plugins/<vendor>/` dirs when present.
- `rewrite_dev_port/1` swaps dev values (4004, `dev.codemyspec.com`) across
  the whole tree with `match_dot: true` (`.claude-plugin/` is a dotdir). The
  port fallback pair is `Release.PluginPorts`'s job.
- Hook scripts are `chmod 0o755` after copy; a lost mode makes every hook a
  no-op.

## Lessons

- **A gate the gated party can satisfy by asserting it is no gate.** Read a
  record only the real event writes (a passing health check), not a file the
  agent wrote.
- **Absence of an answer is not an answer.** An unreachable provider, a
  directoryless environment or an unproven exclusion must read as unknown or
  unhealthy, never as empty, absent or clean.
- **Only flag what was ours.** "Dangling" means pointing at something we
  released; anything else is someone else's and none of our business.
- **Never silently substitute.** No fallback server size, no guessed
  container owner, no guessed app name: return the error or `nil`.
- **Two copies of one script drift.** Generated artifacts that exist in two
  places (overlays, the backup script) are shared code or kept
  byte-identical.
- **A child process must not inherit our runtime.** Scrub release vars, our
  Mix env and our release's PATH entries, and let the child's own directory
  pick its toolchain.
- **Verify provider behaviour live before encoding it.** Cloudflare scope
  names, Plug.SSL's `:exclude` shape and kamal flags all differ from the
  obvious guess, and each wrong guess looked fine until a real deploy.
- **A write must not erase what the response omitted.** Refresh tokens,
  scopes and id tokens absent from a response keep their stored values.
