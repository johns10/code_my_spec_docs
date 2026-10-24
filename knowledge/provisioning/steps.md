# Provisioning steps

How each devops step is verified against its provider and run — the design
behind `lib/code_my_spec/provisioning/steps.ex`, and the lessons that shaped
it. `Steps` adapts every provider module (Hetzner, Cloudflare, Resend, sops,
kamal, object storage) to the two calls the sequence makes per step:
`verify/3` and `run/3`. Code comments point here by section name.

| Module | Role |
|---|---|
| `Provisioning.Steps` | `verify/3` and `run/3` per step key; account-server provisioning; secrets helpers. |
| `Provisioning` | Sequences steps: `run_step/3` verifies, then runs only when absent; `run_and_record/5` records resources. |
| `ProvisioningPlan` | Devops level and the permitted environment set. |
| `ProvisioningPlan.StepRepository` | Recorded step rows and their resources. |
| `Environments` | Environment rows: name, host, server name, ip, `first_deployed_at`. |
| `Provisioning.{Hetzner, Cloudflare, Resend, Sops, Storage, Registry, Database, Builder, Deploy, Backups, Widget, ContentPublishing, Dns}` | Providers; each asks for what it needs. |

## Contract

- **`verify/3` asks the provider, never persisted state.** `{:ok, :satisfied,
  resources}`, `{:ok, :absent}` ("run it") or `{:error, _}`. Anything a
  provider cannot answer for is absent: a false absent repeats an idempotent
  step; a false satisfied skips real work forever, because `run_step/3` never
  runs a step whose verify is satisfied and replaces the recorded resources
  with verify's list.
- **`run/3` returns** `{:ok, resources}`, `{:paused, message}`,
  `{:paused, message, made}`, `{:error, reason}` or `{:error, reason, made}`.
  Anything made before a pause or failure is returned so it is recorded —
  teardown works only from recorded resources, so an unreported resource
  leaks.
- **Pause vs. error.** Paused means waiting on a person or the world (buy a
  domain, paste console-only keys, a first widget message, Resend still
  verifying, confirm an apex repoint); resuming re-verifies. Error means
  broken.
- **Unknown keys** return `{:error, {:not_implemented, key}}` from `run/3`
  and `{:ok, :absent}` from `verify/3`.
- **Fan-out.** Steps fan out over `environments/2`: `opts[:environments]`, or
  the devops level's permitted environments. A caller passing
  `:environment` (deploy, telemetry) gets just that one.
- **Helpers live below all `run/3` clauses.** Interleaving splits the clauses;
  that compiler warning makes the analyzer skip exunit, credo and spex.

## Verify

- **repository**: never satisfied from the provider. The claim is that the
  project's history reached the remote; a repository can exist and be the
  wrong one, or the right one and reject the push. `run/3` adopts or asks,
  then pushes; re-pushing is idempotent.
- **server**: every permitted environment has its box, the database secrets
  (`DATABASE_URL`, `CMS_RESTORE_ADMIN_URL`) in its encrypted env, and a
  registry that answers. All three are things only this step's `run/3`
  produces, so only this verify can notice them gone. The encrypted env is a
  working-tree file and vanishes with a fresh checkout, a revert or a rotated
  age key. A box left by an earlier errored run can carry stale secrets, so the
  registry probe (SSH + curl) runs on every verify, last, once the cheap checks
  agree. Without sops the secrets check reports present — nothing could deploy
  anyway. A satisfied server also reports its shared firewall and ssh key.
  Verify writes the provider's ip/server name back onto the environment row
  (`reconcile_environment_server/4`); DNS, deploy and the TLS diagnostic read it.
- **dns**: asks the Cloudflare zone whether each pointable environment's A
  record still holds that environment's current ip. Unreadable zone → absent.
- **email**: Resend says verified *and* the records Resend lists exist in the
  zone (authoritative lookup). See "Email".
- **secrets**: every environment's stored age key still opens its own file,
  and `SECRET_KEY_BASE` plus `minted_secrets/0` are present.
  `.sops.yaml` (public recipient) is in the repository and the private key is
  in `ProjectSecrets`; when they drift sops still encrypts but nothing
  decrypts. No file yet is not drift.
- **tls**: an HTTPS probe per host through the same injectable `:probe` as
  `run(:tls)` — verify runs first, so a stubbed probe must reach it too.
- **callback_credential**: `CMS_REFRESH_SECRET` in each environment's file, not
  the project-wide `ProjectSecrets` flag (which says only "succeeded once").
- **inbound**: receiving domain + enabled webhook + a recorded delivery proof
  for this Resend domain id. See "Inbound".
- **storage**: each environment's bucket listed under that environment's own
  credentials (Hetzner lists only buckets the presented key owns).
- Every fan-out verify requires a non-empty environment list.

## Environments

- Prod and uat rows are always seeded; the devops level filters them at read
  time (`ProvisioningPlan.permitted_environments/1`). A row is not
  infrastructure, and promoting is one setting. Unfiltered fan-out once built a
  production server, DNS record and database for a `:uat` project — and the
  status read complete because those steps succeeded.
- `permitted_hosts/2` applies the same filter to `assign_hosts/2` for dns, tls
  and the deploy config check.
- An empty permitted list is an error naming the devops level
  (`no_permitted_environments_message/1`), never a vacuous success.
- Server name is `<project>-<environment>` unless the environment is linked to
  an account server, whose name is used.
- `environment_host/2` is the environment's own host; callers fall back to the
  domain. `primary_environment/2` is prod when present, else the first; the
  single-valued `content_bucket` and `client_api_url` both describe it.

## Account servers and networks

- `provision_account_server/3` is the only path to `Hetzner.create_server/3`:
  the account-level tool or servers page. It brings up the box, its private
  network, host baseline, registry and database containers.
- `server_creation_gate/3`: an unlinked environment pauses (listing the
  account's servers) — `Hetzner.ensure_server/3` is find-or-create with no
  notion that creating is the sensitive half. A linked environment may create
  (linking is the authorization) until it has recorded an ip; after that a
  missing server pauses as vanished rather than being rebuilt under a guess.
- The private network belongs to the box. Project steps only adopt it, by id
  off the server's `private_net`, never by a project-derived name (that once
  created a second, overlapping network on a shared box). Adoption is keyed by
  server id: two servers in one zone can be on different networks. A server
  with no network pauses.
- `existing_network_id/2` prefers the attached network in the server's own
  zone: a shared box can hold a wrong-zone network, which Hetzner refuses for
  anything new ("networks must be in the same network zone").
- New account networks are `codemyspec-<zone>`, with an index free across all
  the account's networks (Hetzner refuses any overlapping range).
- Adopted resources carry `__adopted__`; teardown deletes anything unmarked.
- The SSH access key is account-grain (`AccountSecrets`, project fallback for
  older installs) so one key opens every box; firewalls are project-scoped.

## Server baseline

- `run(:server)`: storage credentials checked first (everything after the
  firewall costs money, and the registry needs the S3 keys); then firewall,
  ssh key, servers, each recorded as soon as it exists. The environment list
  is read once and threaded through so the fan-out and its checks agree.
- Each box gets the Docker image, `HostBaseline`, a registry and a database
  — baseline infrastructure, not a build artifact. One registry per
  environment because images do not cross architectures.
- Wait for SSH (`Remote.await_ssh`, `:ssh_attempts` default 90) before any
  command: Hetzner returns a server while it is still initializing.
- Registries are served over the servers found, not the rows, and every server
  is attempted regardless of another's failure; one failing environment must
  not block the others forever.
- `environment_servers/3` refuses naming any missing box rather than serving a
  partial baseline.
- `:run` and `:bind` are injectable (`put_new`) so a local box can stand in.
- The registry bucket is recorded as `kind: "bucket"`, `origin: "created"`
  (teardown matches on kind and skips the default "adopted"); nothing under
  filesystem storage.
- A failed environment-row write halts: an unrecorded box leaks.

## DNS

- One A record per permitted host, pointing at that environment's ip (recorded,
  else looked up). Production on the apex is data from `assign_hosts/2`.
- `apex_repoint/4`: pauses rather than move an apex whose A record already
  points elsewhere, unless `confirm_apex_repoint: true`. Only the apex; decided
  from records already listed.
- After writing, `Dns.resolution_status/3` must resolve the name. A cached
  negative (`{:absent, :cached, s}`) is logged and passed: no retry outlasts a
  half-hour negative TTL, and names cycle constantly in drills and spex.
  Anything else fails this step rather than surfacing later at `tls`.
- Resolver polling uses `:resolver_attempts` (15), not the step-wide attempts
  sized for provider verification. A settle (5 s) precedes the first lookup —
  asking too early caches the negative — and is zero on replay.
- `client_api_url` is written here (this step assigns names), only when unset.

## Email

- Only prod sends mail; a verified `uat.<domain>` would let staging mail real
  customers. `Resend.sending_domain/2` maps prod to the apex, which is also the
  inbound domain — without its sending records the apex stays `pending` and
  Resend bounces inbound mail.
- Orphans: a prod sending domain left at Resend after the devops level narrowed
  makes verify absent and run pause naming it.
- Resend's "verified" is its memory of a past check and survives the records
  being deleted, so verify also checks the zone (existence, not content, so
  deliberate edits are not fought). Zone unreadable → Resend's answer stands.
- Records come from Resend's own list (DKIM is per-domain), read by id — the
  only form carrying `records`.
- Publish before polling: Resend will not verify unpublished records.
- The zone is resolved from the sending name itself, never the project or
  opts, and Resend's relative names are qualified against that zone;
  `covered_by?/2` refuses anything outside it. No `ttl` (Resend's "Auto" is
  rejected by Cloudflare).
- Still verifying → paused; unverified → error naming the faulted records.

## Inbound

- Configured is not proven. `run/3` sends a probe and waits for it; verify is
  satisfied only by a recorded delivery proof, read from the step row (verify
  must never send mail), on this domain (anchored on `@`), stamped with the
  current Resend domain id — a teardown and rebuild creates a new domain object
  at the same name. Unstamped proofs are not current.
- Receiving is at the apex by decision; `:inbound_subdomain` moves it aside.
- Await the inbound records, not the domain: a receiving-only domain stays
  `pending` on sending records this step leaves alone, and mail to an
  unverified name is dropped.
- The probe address is given (`:inbound_probe_to`), never invented: Resend
  silently drops mail to addresses not configured for the domain and cannot
  list them. A catch-all on another domain once made an invented address look
  fine. Missing or off-domain addresses pause.
- Sender: a verified domain, preferring the one under test (otherwise the
  outcome depends on sort order in a shared account). Not
  `onboarding@resend.dev`, which only sends to the account owner.
- Arrival is matched by message id absent from the mailbox before the send —
  exact on record and replay, and immune to a previous probe's residue (a
  per-run subject token cannot replay). Suppression is cleared first: one
  bounce suppresses the address forever. Settle 60 s, then poll; read from
  Resend's `GET /emails/receiving`, not the webhook (which needs the site
  deployed).
- Existing MX elsewhere pauses (`competing_mx`) unless
  `confirm_inbound_mx_repoint`; then the whole competing set is deleted before
  publishing (`ensure_dns_record/5` would update only the first match) and any
  survivor afterwards is an error. MX can legitimately be split, so this holds
  only on confirm.
- `never_arrived` pauses: an unconfigured address looks identical to a broken
  webhook. `receiving_disabled` pauses; setup never deletes and recreates the
  domain (that rotates DKIM).
- `RESEND_WEBHOOK_SECRET` is seeded when Resend returns `signing_secret` (create
  only); best-effort and logged.

## TLS

- kamal-proxy requests the certificate when the service comes up; the step
  polls (`:tls_attempts` 20, `:tls_interval_ms` 5000) and halts on the first
  host without one, keeping what verified.
- The failure message carries diagnosis gathered while the host still exists
  (teardown destroys it soon after, so "go read the log" is impossible advice):
  - plain HTTP on 80 — any status counts as answering (a healthy proxy 301s);
    answering on 80 but not 443 means issuance failed, not reachability;
  - the ACME challenge path over HTTP — a redirect makes HTTP-01 impossible; a
    404 for an unknown token is healthy;
  - DNS — the probe uses this machine's resolver, which can cache a negative;
    only a "does not resolve" failure implicates a resolver;
  - the proxy log and `kamal-proxy list` over SSH, every line compressed to a
    few JSON fields (filtering hid absences). Best-effort; never fails the step.

## Secrets

- One age key per environment, private half only in `ProjectSecrets`.
- `key_for/3` reuses the key on record unless it no longer opens its file.
  Minting unconditionally destroyed every secret on re-run (config rewritten
  to new recipients, files still encrypted to the overwritten keys). Genuine
  drift mints and discards the undecryptable `.enc.env`, which would otherwise
  keep verify absent forever.
- `.sops.yaml` names every environment with a stored key, not just this run's,
  so a devops-filtered run cannot drop another environment's rule.
- `ensure_age_key/3` mints on demand; no secret write depends on the secrets
  step having run.
- `SECRET_KEY_BASE` and `DEPLOY_KEY` are minted only when absent (rotation
  breaks sessions or a running app). `DEPLOY_KEY` and `CODEMYSPEC_WIDGET_URL`
  (this server's widget socket — generated apps default to the hosted
  service) are written at the secrets step because the app reads them at boot.
- `check_secrets/2` runs before deploy: the age key travels as deploy config,
  and a missing `SECRET_KEY_BASE`/`DATABASE_URL` refuses by name. A missing-
  secrets verdict the harness reported at sync wins (dotenv sops leaves key
  names plaintext).
- `import_age_key/3` records a key generated on a harness-only checkout, so the
  next decrypting step does not mint a different one.

## Deploy and build

- `deploy_ready/1` runs `Generators.audit/3` before anything is built; a config
  it can prove will fail otherwise costs a build, a migration and a health
  timeout that reads as an app fault.
- Per environment: `check_secrets/2`, the deploy-target guard,
  `require_script/2`, `commit_generated_configuration/1` (before the build:
  the builder archives HEAD and the image is versioned by HEAD), then the image.
- Deploy halts on the first failing environment (a prod deploy after a failed
  uat has no evidence) and keeps what landed. `Deploys` and
  `first_deployed_at` are written only after the health probe passes.
- Image: explicit `:image` wins; `build: false` deploys unbuilt; otherwise
  build — `bin/deploy` without `CMS_IMAGE` falls through to a CI path.
- The tag is the head commit (12 chars), from the working directory, else the
  `head_commit` the harness reports. Architecture is asked of Hetzner (the
  server step may fall back to the other one).
- The registry address is the app box's private IP; the builder joins the same
  network, so one image reference works for push and pull. The build finds
  the registry; only the server step creates it. `registry_address/3` gives
  the same address for generated deploy files.
- The deploy runs on the builder box right after the push, via `Builder`'s
  `opts[:then]` — never from wherever the caller is connected. An unbuilt
  image deploys against `env(scope)` instead.
- Deploy-target guard: kamal deploys wherever the checkout's config says, so
  a foreign `proxy.host` is refused. Only `proxy.host` is compared; an ERB
  host (`CMS_DEPLOY_HOST`) passes. `parse_deploy_config/1` strips ERB
  statement tags (invalid YAML otherwise, which silently disabled the guard).
- kamal needs the `service` label (read from its config, since setup builds
  and deploys `--skip-push`), the registry password, `CMS_SSH_KEY_PATH` (else
  net-ssh offers every agent identity and trips `MaxAuthTries`), and a clean
  `known_hosts` entry (`ssh-keygen -R`: providers recycle addresses; host-key
  checking stays on).
- Every private key written to a temp dir is removed in an `after`.
- Image retention is claimed only from a mechanism that ran: a bucket
  lifecycle rule, or a prune to `keep_images` after this push. A failed prune
  makes no claim and does not fail the deploy.
- Failure reasons carry the script's output head and tail
  (`Truncate.head_and_tail/2`): the real error can sit at either end.

## Content and widget

- `content_bucket`, `client_api_url` and `deploy_key` are written by setup;
  the content and widget steps refuse without them.
- The content bucket is recorded on both the satisfied-verify and run paths of
  storage, only when unset, with endpoint, region and keys together: ExAws
  with no endpoint defaults to Amazon. `ProjectSecrets` holds the keys for
  provisioning; the project row's `aws_*` serve publishing.
- The deployed app's `Content.PullClient` reads the bucket with its own
  credentials (the bucket is not world-readable), so the four `HETZNER_S3_*`
  values go into each encrypted env.
- The render proof fetches `/<content_type>/<slug>` from `client_api_url` and
  expects the title (a 200 alone passes on a styled 404). No content yet is
  the normal state of a new app.
- Widget: installed and openable with no message yet pauses — only a visitor's
  browser can send the proving message. Messages are tagged by origin host;
  no origin is never trusted.

## Backups

- Run on each environment's own box, where `cms-postgres` resolves and the
  systemd schedule belongs. HEAD is delivered to the fixed `/opt/cms-backup`
  (the unit's WorkingDirectory) because the box runs a container, not a
  checkout.
- The box has no sops, so `DATABASE_URL`, the restore admin URL, bucket, keys
  and `SOPS_AGE_KEY` are handed over in opts. `load_env` skips decryption once
  `DATABASE_URL` and the bucket keys are present, so the restore URL must be
  handed over too.

## Origin

- Providers stamp `__adopted__` on reused resources; unmarked reads created.
- Verify's `find_*` results stay unmarked on purpose. `run_step/3` replaces the
  recorded list from a satisfied verify, and teardown skips adopted — marking
  verify's finds adopted would relabel servers setup created and teardown would
  leave them running. A wrong word on a page is cheaper than a leaked server.
- `origin` is always set explicitly (repository from its disposition, registry
  bucket "created"): the schema default is "adopted".

## Lessons

- **Verify everything `run/3` produces.** `run_step/3` skips a satisfied step,
  so a value verify does not check is never rewritten once lost; this happened
  for `DATABASE_URL`, `DEPLOY_KEY` and `CODEMYSPEC_WIDGET_URL`. Add each newly
  minted secret to `minted_secrets/0` or `@database_secrets`.
- **Put a check in the step that can fix it.** A check in a step whose `run/3`
  cannot produce the value turns "reports done wrongly" into "reruns forever".
- **An empty environment list is not zero work.** `Enum.all?/2` over `[]` is
  true and `reduce_while/3` never enters the loop; guard every fan-out and name
  the devops level.
- **Per-environment facts never come from a project default.** A backup step
  defaulting to prod reported done while uat was never backed up; a deploy
  handed uat the apex.
- **One opts key, one meaning.** Opts flow through every provider; `:location`
  is the object-storage region in `Storage`, so the builder uses
  `:builder_location`.
- **The adapter supplies what a provider `fetch!`es**, so a missing value is
  an errored step, not a crashed run.
- **Diagnose while the host exists.** Teardown removes the evidence minutes
  after a failure; fold it into the message.
- **Never trust a provider's cached "verified".** Check the thing it claims.
- **Match proofs exactly, never by residue.** Id-based arrival and domain-id
  stamps keep an old proof from certifying a new setup.
