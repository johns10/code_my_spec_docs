# Provisioning

How setup builds a project's infrastructure in the user's own provider
accounts — Hetzner servers and networks, Cloudflare domains and DNS, Resend
mail, object storage, a database and registry on the app box, sops secrets,
the build on a shared burst box, the deploy — and how teardown takes it down
again. The design behind `lib/code_my_spec/provisioning*` (the step dispatch
in `Provisioning.Steps` has its own doc, `knowledge/provisioning/steps.md`).
Code comments point here by section name.

| Module | Role |
|---|---|
| `Provisioning` | The runner: verify-then-run per step, halting, resuming, async runs under `RunLock`, resource-record merging. Never destroys. |
| `ProvisioningPlan` | Read side: options, permitted environments, the plan and the checklist. Runs nothing. |
| `Provisioning.Credentials` | Which credentials a run needs, where each is stored, and a real call to prove each. |
| `Provisioning.Hetzner` | Req client: servers, firewalls, networks, SSH keys, snapshots. |
| `Provisioning.Cloudflare` | Req client: domain registration/adoption, zones, DNS records. |
| `Provisioning.Resend` | Req client: sending/receiving domains, webhooks, probes, verification. |
| `Provisioning.Dns` | What DNS actually answers, authoritative first. |
| `Provisioning.Storage` | Buckets, lifecycle retention and objects in the user's Hetzner account. |
| `Provisioning.Database` | The shared `cms-postgres` container and per-project tenants. |
| `Provisioning.Registry` | The shared `cms-registry` container, credentials, image references, pruning. |
| `Provisioning.Sops` | Age-encrypted per-environment env files. |
| `Provisioning.Repository` | Create or adopt the GitHub remote and prove it with a push. |
| `Provisioning.Builder` | Builds on the burst box; builds the burst box's snapshot. |
| `Provisioning.Builder.Remote` | SSH runner, source delivery, docker build/push, kamal install. |
| `Provisioning.BurstBox` | Find-or-create the account's burst box; FLAME runner processes; busy check. |
| `Provisioning.Deploy` | migrate → health → swap through `bin/deploy`, run from the builder. |
| `Provisioning.Backups` | Dump, restore-proof, schedule, health. |
| `Provisioning.Widget` | Install the support widget and prove a message arrives. |
| `Provisioning.Teardown` | Remove only what steps recorded, verified. |

## Running the sequence

- `Provisioning.run/3` walks `Sequence.for_options/1` in order and calls
  `run_step/3` per step; it halts at the first step that errors or pauses and
  leaves the rest `:not_started`. Pressing on would build later steps on a
  broken foundation (a deploy against a domain never registered) and the
  failure would surface far from its cause. A pause is not failure, but the
  steps after it still depend on it.
- Every step is verified against its provider before it runs
  (`verify/3` → `Steps.verify/3`). `{:ok, :satisfied, resources}` marks the row
  `:done`; `{:ok, :absent}` runs it; `{:error, _}` halts. Filtering on
  `state == :done` instead would make a stale row permanent.
- A verify error against a row that was already `:done` halts without
  demoting the row, so the next attempt re-verifies instead of rebuilding real
  infrastructure on the strength of a timeout. A verify or execute that raises
  is caught, logged with its stacktrace, and recorded as `:errored`.
- Per-environment steps fan out over `opts[:environment]`, then
  `opts[:environments]`, then `Steps.permitted_environments/1`, one at a time,
  halting the walk on the first failure. `:content` runs once, against
  `primary_environment/1`.
- `resume/3` skips steps whose rows are all `:done` and runs the rest through
  the same verify-first path: an `:errored` step is retried, a `:paused` one is
  re-verified — a person returning is not evidence the errand was done.
- `reverify/3` (page load) re-checks only `:done` rows. `:absent` drops the
  row to `:not_started` but keeps its recorded resources (absent can mean
  partial — one of two buckets missing); an error leaves the row alone.
- The scope's project is re-read before each step: one step writes fields a
  later step reads (secrets mints `deploy_key`, widget reads it; dns writes
  `client_api_url`, content reads it).
- Failure reasons are rendered with `inspect(…, printable_limit: :infinity)`:
  provider errors are tuples, and long ones are build logs whose cause is the
  last line.

## Async runs and the run lock

- `run_async/3`, `resume_async/3` and `run_step_async/3` start a task and
  return; `mark/5` broadcasts `{:provisioning, :step, row}` on every state or
  `verified_at` change and the task broadcasts `{:provisioning, :finished,
  result}` on `"provisioning:<project_id>"`. Watchers subscribe; nothing holds a
  connection open for a multi-minute step.
- All three run under `RunLock.with_lock/2` per project, so a start, a resume
  and a per-step retry never write the same rows at once. A refused run is
  logged, not surfaced.
- `:provisioning_run_async` is false in test: runs execute inline so they share
  the ExUnit sandbox connection and cannot outlive the test (or its cassette
  session).
- `await_run/2` polls `RunLock` (a `Registry`, not a broadcaster). MCP tools
  return the moment a run starts because the request cap and code-mode's 30s
  wall clock are shorter than a real run (`:deploy` is minutes).

## Forcing a step

- `run_step(…, force: true)` skips `verify/3` and runs the step. It exists
  because `verify/3` can be narrower than `run/3`'s side effects:
  `verify(:server, …)` is satisfied by the box and `DATABASE_URL` existing,
  while `run(:server, …)` also rewrites the docker daemon's registry trust via
  `Registry.serve/2`. A stale trust config is invisible to verify.
- Every step's `run/3` is idempotent, so forcing a step with nothing to do
  costs redundant provider calls, not a wrong state.

## Resource records

- A step row's `resources` is an `embeds_many` with `on_replace: :delete`;
  teardown works only from it. A resource a step made but did not record
  leaks by construction, so success, pause and partial failure
  (`{:error, reason, partial}`, `{:paused, instructions, partial}`) all record.
- The run path merges (`keeping_earlier/4`): earlier resources not returned
  this run are kept with `observed_in_latest_run: false`; this run's entries
  replace same-`{kind, location}` entries wholesale except `origin`, which is
  sticky. A stale `identifier` must not win — a server rebuilt at a new
  address would keep the old one on record.
- Run-scoped kinds (`deploy_phase`, `live_version`, `deploy_failure`) are
  dropped before merging: they describe the latest run, so a failed deploy
  must not show the previous deploy's swap.
- The verify-satisfied path replaces the list with the provider's answer
  (`still_ours/4`), but keeps earlier `origin` in both directions. `ensure_*`
  calls report `adopted` when they find something already there, which would
  demote a record setup created and make teardown spare it (a DNS record left
  pointing at a released, recyclable IP). The reverse — a later `created`
  over an earlier `adopted` — would license teardown to destroy something the
  user had before setup ran.

## The plan

- `ProvisioningPlan` is the read side: the step catalogue (`Sequence`), the
  persisted rows (`Step`, `StepRepository`) and the plan built from them. It
  runs nothing, so the requirement graph's `deploy` gate can ask what is
  missing without depending on the engine.
- Options: `available_options/0` is derived from the sequence. A project's
  `setup_options` of `nil` means "never chosen" (everything); `[]` means
  "chose nothing". Unknown stored options are ignored.
- Environments: every row is seeded; `devops: :uat` filters `prod` out of
  `permitted_environments/1`. `permitted_existing_environments/1` and
  `plan(…, seed: false)` never write — the requirement graph uses them on
  every load.
- `primary_environment/1`: `prod` if permitted, else the first environment.
  `:content` is attributed to it because it cannot yet act per environment.
- `plan/3`: one entry per project-wide step, one per environment for a
  per-environment step; excluded steps are absent.
- `checklist/3`: a step is `:present` when `:done` **or** it holds resources
  (a stopped run may already have made real things). `setup_missing/3`
  narrows it to one environment plus project-wide steps; the deploy
  requirement and `devops_status` read this one answer.

## Credentials

- `Credentials.catalogue/0` lists every credential in the order the run needs
  them; `required/1` filters to the enabled options (`:always` entries are
  GitHub and the Hetzner API token). A credential for a disabled step is not
  asked for — asking trains people to paste over-privileged tokens.
- Grain: `grain: :account` secrets (the Hetzner API token) live in
  `AccountSecrets`, all other secrets in `ProjectSecrets`, connections in
  `Integrations`. `stored?/2` and `put_value/3` share the rule, so the form
  writes where `Hetzner.token/1` reads. When they disagreed, a pasted token
  went to a grain the runtime ignored.
- `check/3` proves each credential with the provider's cheapest read and
  returns `:verified`, `:missing`, `:unchecked` (inconclusive, or the client
  raised) or `{:rejected, permission}` (401/403 from any provider's
  `{tag, status, body}` error). Cloudflare checks zones and then the
  registrar, because a zone-only grant cannot buy a domain.
- `missing/1` is what `start_setup` refuses on: a run that starts without
  its credentials fails partway with resources already made.
- The S3 key pair can only be minted in the Hetzner console and the secret is
  shown once; the catalogue's `directions` say so.

## Hetzner

- Hand-written Req client, a top-level boundary leaf that `Servers` and
  `Provisioning` both call. Token: `AccountSecrets`, then `ProjectSecrets`
  (older installs), then app config (the platform's own token, which drives
  cassette recording and platform-scoped work).
- Firewall policy is fixed data: 22, 80, 443 to the world; 5000 (registry)
  to `10.0.0.0/16` only. 22 is required — kamal deploys as root over it, and
  closing it once made the deploy step impossible. Password login is not a
  risk because `create_server/3` refuses without SSH keys and Hetzner
  disables root passwords for keyed servers.
- `ensure_firewall/2` reconciles an adopted firewall's rules
  (`reconcile_rules/2`), compared on direction/protocol/port/sources, so a
  policy change reaches projects that already ran setup.
- Server defaults: arm `cax11`/`fsn1`, x86 `cpx11`/`ash`. The `cx*` line is
  retired; do not reintroduce it. A 412 (no capacity) or 422 "unsupported
  location for server type" retries once on the other architecture unless
  `:server_type` is pinned; both failing becomes `:capacity_unavailable` in
  words the user can act on. Because of this fallback, a server's
  architecture is always read back (`server_architecture/1`).
- `/datacenters` answers "can I create this now"; `/server_types` is only the
  catalogue (ARM types have been listed while sold out everywhere). Fetch
  `per_page=50` — the default page silently truncates.
- Networks: `10.N.0.0/16` with one `10.N.0.0/24` cloud subnet (a network
  without a subnet hands out no address). The subnet's zone must match the
  servers' locations (`network_zone/1`); a wrong zone gives both boxes
  addresses and no route. Hetzner refuses overlapping ranges per project, so
  each additional network takes the next free index. Attach at creation so
  the box has its private IP from first boot; read the assigned IP back
  (`private_ip/2`).
- Idempotent repeats Hetzner reports as errors: `server_already_attached`
  (409/422) and `firewall_already_applied` (422) are successes.
- `ensure_server/3` attaches firewalls to a found server explicitly; SSH keys
  cannot be added to an existing server through the API.
- SSH keys are matched by MD5 fingerprint, never by name (a name match once
  attached a stale key to a new server, which then timed out silently). A
  name collision with different material uploads under a suffixed name.
- `user_data` (cloud-init) is logged by size only.

## Cloudflare

- Hand-written Req client against the user's own account. Token: the
  delegated OAuth grant from `Integrations`; with no integration at all, the
  configured `:api_token` (CLI, cassette recording). A connected but unusable
  grant returns `{:error, {:cloudflare_token_unusable, reason}}` and never
  falls back — that would silently act on another account.
- Cloudflare answers 200 with `success: false` for some failures, so
  `handle_response/1` checks the body, not just the status.
- Registration is the one human gate in setup: non-refundable, so
  `register_domain/3` refuses without `confirmed: true`. Step code calls
  `ensure_domain/3`, which adopts an owned domain (registered here or served
  by a zone) and only otherwise registers.
- Availability: the registrar API details only domains already on the
  account. For anything else `available` is absent, which means `:unknown`
  (cannot price), not `:taken`. New names are a dashboard errand.
- Registration errors: unsupported TLD and missing billing become pauses
  with a named errand; anything unrecognised stays an error.
- Zones: `find_zone/2` picks the longest zone covering the name on a label
  boundary, so subdomain projects resolve to their parent zone.
- Account id: `GET /accounts` (answers even with no zones — a brand-new
  account), then the zone list.
- DNS: records default to `proxied: false`, TTL 60. `ensure_dns_record/5`
  creates, updates on different content/priority/proxy, or returns the
  existing record marked `__adopted__`. For MX, a different priority is a
  different record: Resend receives only on the lowest-priority MX.
- `request/4` is public for the devops `ProviderRequest` tool; the token
  never leaves this module.

## DNS checks

- `Dns` asks DNS itself, never a provider's record list: a provider keeps
  "verified" long after the record is deleted, and "did setup disturb mail
  already arriving" is about what a third party sees.
- `resolution_status/3` asks the zone's own nameservers first (apex NS,
  resolved to addresses), then DoH (Google, then Cloudflare only if Google
  returned nothing). A recursive resolver asked just after a publish caches
  the negative for the zone's negative TTL (1800s is common), so retrying
  cannot help; the authoritative answer is immediate.
- An authoritative NXDOMAIN is conclusive; any other authoritative error is
  `:unavailable` and falls through to DoH, never "not published".
- `{:absent, :cached, seconds}` — DoH only: the SOA in the negative answer's
  authority section has a TTL below the zone minimum, so a resolver is
  holding a stale "no". Names that cycle (spex labels, drill domains) hit
  this constantly.
- Under stubs (an injected `:resolver`, or a `:plug` in config) the
  authoritative path is skipped: the records live in the stub. A configured
  `:dns_nameserver` (the local fleet's DNS container) is always asked, over
  TCP, because colima's port forwarding carries no UDP.
- `lookup/3`: A goes through `:inet.gethostbyname/1` (`:inet_res` returns
  nothing for A); CNAME falls back to A; TXT chunks are joined; MX keeps
  priority. `mx_records/2` sorts so before/after readings compare.

## Resend

- Hand-written Req client on the user's OAuth grant
  (`Integrations.fetch_access_token/2`, which refreshes under a lock: tokens
  live 15 minutes and the refresh token rotates on every use). Configured
  `:api_key` only when there is no integration; an unusable grant surfaces as
  `{:resend_token_unusable, reason}`.
- Rate limit: 10 req/s. `send_request/5` retries 429 itself (5 × 1.1s) with
  Req's retry disabled — stacked retries made every attempt three.
- Domains: prod sends from `<domain>`, others from `<env>.<domain>`. The base
  is what Resend gets; it places `send.<domain>` and
  `resend._domainkey.<domain>` itself (prefixing `send.` yields
  `send.send.…`).
- Apex rule: outbound setup never writes the apex MX — inbound depends on it
  and it may already receive mail elsewhere. Record names come back relative
  to the zone, so a subdomain's apex MX is named by its label.
- Capabilities: the email step creates `sending: "enabled"` only; the
  inbound step creates `sending: "disabled", receiving: "enabled"`. A
  receiving-only domain asked to send would sit `pending` forever on records
  nobody publishes, and Resend then bounces its mail. Capabilities PATCH as a
  whole object: always send both flags, reading the other back. Confirm
  with a GET (the PATCH body has none). Never delete-and-recreate (rotates
  DKIM).
- Inbound MX is `record: "Receiving"`; the `record: "SPF"` MX belongs on
  `send.`. Resend only receives on the lowest-priority MX.
- Verification: trigger `POST /domains/:id/verify` before and periodically
  during polling — Resend does not re-check on its own. A give-up names
  `faulted_records/1` (status `failed`/`failure`/`temporary_failure`) or
  reports `:still_verifying`; never call pending records wrong. Inbound waits
  on the apex MX's own status (`await_inbound_verified/4`), not the domain's.
- Webhooks: a disabled webhook looks configured and delivers nothing;
  `ensure_webhook/3` re-enables it.
- Proofs: outbound by sending to `delivered@resend.dev` from the project's
  own domain; inbound by reading `/emails/receiving` (contents only from
  `/emails/receiving/:id`). The inbound probe sends with an explicit `:from`
  so it does not depend on outbound. Clear the probe address from
  suppressions first — one early bounce suppresses it account-wide forever.
- Cassette rule: polls must issue the same requests on record and replay;
  `:settle_ms` waits before the first read, and waits are no-ops on replay.

## Storage

- Buckets live in the user's own Hetzner account, signed with their keys,
  so uploads and dumps stay theirs when they stop paying us. Recorded
  resources carry `owner: "user"`.
- One bucket per environment, `<slug>-<env>`; no generic fallback name
  (bucket names are account-unique, so unnamed projects would share one).
- S3 keys come only from the Hetzner console. `credentials/2` reads
  `hetzner_s3_access_key_id`/`hetzner_s3_secret_access_key` from
  `ProjectSecrets` — per environment first, then the shared secret — and
  never the platform's environment. A paused step names the page to save
  them on; an agent is never handed a credential to relay.
- Hetzner's object storage is Ceph and eventually consistent; "written" and
  "readable" are separate moments:
  - a new bucket lists immediately but 404s writes for ~1s, so
    `ensure_bucket/3` waits on HEAD;
  - a lifecycle PUT right after can 404 NoSuchBucket, so it retries;
  - `get_object` retries `NoSuchBucket` (another gateway answered) but never
    `NoSuchKey`;
  - `delete_bucket` gets 409 for ~30s after emptying, so it backs off from
    500ms.
- Lifecycle XML is hand-built in the documented element order with the
  namespace; ExAws's builder output is MalformedXML to Ceph.
- Path-style addressing always (`<location>.your-objectstorage.com`), with
  `Content.ExAwsReqClient`; never `Content.S3Client`, which signs against the
  global `:ex_aws` config.
- Deleting a bucket means emptying it page by page from the start
  (continuation tokens die with the deleted page) and aborting unfinished
  multipart uploads, which `list_objects_v2` does not show and which Hetzner
  reports as a timeout rather than `BucketNotEmpty`.

## Database

- One `cms-postgres` container per box (`pgvector/pgvector:pg18`, network
  `db_net`, volume `cms-postgres-data` at `/var/lib/postgresql`), shared by
  every project on the box. An account with two projects on one server is the
  ordinary case.
- Split: `ensure_container/2` is account-side (container, readiness,
  `vector` on `template1`); `serve/3` is project-side (tenant role and
  database, password sync, restore role) and refuses with
  `:database_not_provisioned` when the container is not running.
- Never `docker rm -f` a running container: it restarts every other
  project's database under live connections. A running container on the
  wrong image is reported (`:database_image_outdated`) and left for a human,
  because recreating it means wiping a volume that may hold real data.
- Tenants: role `app_<slug>`, database `app_<slug>_<env>`, slug from
  `Repository.default_name/1` with dashes as underscores. Passwords per
  project and environment in `ProjectSecrets`; the admin password is
  account-grained in `AccountSecrets`.
- `POSTGRES_PASSWORD` only applies when the data directory is first
  initialised, and the volume outlives the container. So `ALTER USER … WITH
  PASSWORD` runs on every serve; otherwise a rotated password passes the step
  and fails the deploy with `28P01`.
- Readiness is `pg_isready -h 127.0.0.1`: the unix socket answers during
  first boot while TCP still refuses, and the app connects over TCP.
- pgvector is untrusted: tenants cannot `CREATE EXTENSION vector` even as
  owner. The admin installs it into each tenant database, and into
  `template1` so the restore's short-lived scratch database inherits it.
- Restore role `app_<slug>_restore` has `CREATEDB` and nothing else; its
  scratch database is `app_<slug>_<env>_restore_check`, per tenant because a
  role can only drop what it owns. The app's own role never gets `CREATEDB`:
  it is the credential a SQL injection reaches first, and the running app
  never needs it. The restore URL travels via the encrypted env like
  `DATABASE_URL`.
- The container is never published to a host port.

## Registry

- One `cms-registry` (`registry:3`, `distribution`) per app box, shared by
  every project on it. A registry of ours shared across customers would hold
  every customer's images behind one auth bug; a registry per project on a
  shared box is a second process nobody needs. Isolation is the repository
  path and a per-project htpasswd entry (`cms_<slug>`).
- Same split as `Database`: `ensure_container/2` (account-side, starts it
  once, never restarts a running one) and `serve/2` (project-side: upsert
  htpasswd, trust on the box's daemon, wait for `/v2/`; refuses with
  `:registry_not_provisioned`).
- Address: the steps bind the registry to the app box's private IP and use
  `<ip>:5000` as the image host for both push (builder on the same network)
  and pull; the reference is baked into the image, so it must be identical
  at both ends. `running_bind/2` reads the bind off `docker port` rather than
  trusting a re-derived network. Port 5000 is open only to `10.0.0.0/16`.
- Plain HTTP on the private network, so both daemons need
  `trust_command/1` (`HostBaseline.docker_command/1`), which restarts Docker
  only when the config changes.
- Real credentials even on a private network: kamal refuses a config without
  a registry password and logs in before pulling; the password is minted
  once into `ProjectSecrets`.
- `image:` in a kamal config is the bare repository path; kamal reads the
  host from `registry.server`. A host-qualified `image:` silently duplicates
  it.
- Storage is a box volume. On Hetzner's bucket, `docker push` failed with
  `unknown blob`: the registry reads back a layer it just wrote and the
  eventually consistent store says it is not there — not fixed by the
  in-memory descriptor cache. Images are rebuildable from a commit, so
  surviving the box is not worth an unreliable push.
- Retention is `prune/2`: keep the newest `keep_images` (5) by the mtime of
  each tag's `current/link`, DELETE older manifests (only a 202 counts),
  then `registry garbage-collect` (no `-m`). Requires
  `REGISTRY_STORAGE_DELETE_ENABLED=true`, else every delete is a 405.
  `retention_enforced?/1` is true only for `:s3`; anything rendering a
  retention window must ask it.
- htpasswd is rewritten with `cat tmp > path`, never `mv`: the container
  bind-mounts the inode, and a rename leaves it reading the old file forever.

## Secrets (sops)

- Age-encrypted `envs/<env>.enc.env` files committed to the project repo,
  one age key per environment (`.sops.yaml` `creation_rules`, one recipient
  per file). A UAT key given production's file fails with "at least one key
  has to be successful" — with one project-wide key, whoever can deploy
  staging could read production.
- The real `sops`/`age` binaries, never a reimplementation: the server
  decrypts with real `sops`, and a near-miss in a credential path is worse
  than a dependency.
- Private keys live in `ProjectSecrets`, never in the working tree. They
  reach the server only as `SOPS_AGE_KEY` from the deploy, so rotation is a
  re-encrypt plus a redeploy.
- `put_secret/5` uses `sops set` on the ciphertext — no decrypt-to-tempfile
  window for a `git add` to sweep up — and takes the private key explicitly.
- `ensure_file/2` seeds `SOPS_INITIALIZED=true` and encrypts; it always
  attempts `sops encrypt --in-place` and treats "already encrypted" as
  success, because an interrupted write can leave plaintext at an `.enc.env`
  path.
- `missing_secrets/4` treats an absent file and an unencrypted scaffold
  ("sops metadata not found") as "nothing set", not as errors.
- `recipients/2` reads the file, not `.sops.yaml`: an edited config says
  nothing about existing ciphertext. `public_key/1` lets the stored private
  key be checked against the recipient.
- sops resolves `.sops.yaml` from its cwd, so it runs from the project root
  with relative paths, through `ExecutionContexts.cmd/4`.

## Onboarding a legacy app's secrets

- A pre-existing app usually fetches secrets at boot from its own store (AWS
  SSM, Varlock, a `.env` loader) and crashes with a provider-auth error after
  `:server` and `:deploy` succeed. Migrate the app onto sops rather than
  teaching the deploy to carry an arbitrary provider's credentials:
  `SOPS_AGE_KEY` is already the one secret every deploy delivers.
- Steps: read the legacy parameter *names* (they match `System.get_env/1` in
  `config/runtime.exs`); decrypt the existing file first and skip names the
  platform already owns (`SECRET_KEY_BASE`, `DEPLOY_KEY`, and above all
  `DATABASE_URL`, whose legacy value points at the old box); migrate the rest
  verbatim with `put_secret/5` — a regenerated Cloak key silently makes
  encrypted rows unreadable.
- Replace the boot-time fetch with `exec sops exec-env "$ENV_FILE" "<cmd>"`
  in `rel/overlays/bin/boot` and in `bin/migrate` (migrate runs as its own
  `kamal app exec`); copy `envs/` into the release overlay and `sops` into
  the runtime image; delete the provider call from `config/runtime.exs`.
- In `config/deploy*.yml`, replace the old provider's `env.secret` entries
  with `SOPS_AGE_KEY` (resolved from kamal's process env).
- An environment still deployed by a legacy script has no route to
  `SOPS_AGE_KEY`; migrate its values early, but do not point that script at
  the new image until the key can reach it.

## Repository

- GitHub access is an OAuth App grant (`repo` scope): access to everything
  the user can reach, revocable only wholesale. There is no installation
  picker, so repository choice is ours. (The `Ov23` client-id prefix does not
  mean GitHub App.)
- Adoption vs collision: `adopt: true` uses the chosen repository; an
  unchosen existing name returns `{:name_taken, %{choices: [:adopt,
  :rename]}}`. Auto-adopting could write over an unrelated project;
  auto-renaming leaves a repository nobody chose.
- No fallback credential: platform tokens, machine accounts and local `gh`
  all act as the wrong account in a multi-tenant product.
- The owner defaults to `GitHub.authenticated_login/1` so "adopt rather than
  duplicate" works without the caller knowing it.
- Repositories are created private and empty (no `auto_init`).
- `push/3` inits, commits, sets the remote and pushes through
  `ExecutionContexts.cmd/4`. It refuses to repoint an `origin` that names a
  different repository (SSH/HTTPS forms compare equal): a misconfigured
  working directory once republished a real checkout's history and rewrote
  origin for every worktree.
- It substitutes `<GITHUB_OWNER>` in `.github/workflows/build.yml` with the
  repository's real owner (the org when created under one) and commits only
  that path.
- `push_remote: false` exists for cassette replays (git is not HTTP); the
  sha is still real.

## Builder

- Images are built at deploy time, never at project creation: coupling them
  made every new project wait on a build and conflated "history reached the
  remote" with "CI finished".
- `Builder.build/3` runs on the account's one persistent burst box
  (`BurstBox.ensure_box/3`). Cross-project isolation is Docker containers;
  same-project ordering is `RunLock`, held by the caller of `run_step`.
- Every exit path — success, error, raise, throw — calls `release_box/3` →
  `BurstBox.Lifecycle.check/3`. The disposition is returned on failures too
  (`{:error, reason, %{builder: …, builder_destroyed: …}}`), because a box left
  billing an extra hour is invisible behind a failed deploy.
- Build on the architecture the servers run on; `matches?/3` refuses a
  mismatched image before publish. A wrong-architecture image only fails at
  container start, after the deploy looks healthy.
- Builder types: `cax21` (arm) and `cpx31` (x86), a step above app servers —
  a build is CPU-bound and short, and an Elixir release compile does not fit
  in 2GB. `cpx31` over the identical `cpx32` because `cpx31` exists in every
  location; the box joins a private network whose subnet lives in one zone,
  so the type must exist where the app box is. ARM types go in and out of
  stock, so an arm request may simply fail. Check availability against
  `/datacenters` and `/server_types`, not the docs.
- `:build_fun` (not `:build` — in the deploy step's opts that is a boolean) is
  injected in tests; Hetzner calls stay real.
- `:then` runs `bin/deploy` on the builder over the same SSH, installing kamal
  first. A kamal install failure becomes a `Deploy.Result`, not a bare error.
- Source delivery: a local checkout (`opts[:env].cwd`) is shipped; otherwise
  the builder clones from GitHub with the project's integration token.

## Burst box image

- `ensure_burst_box_image/3` finds the snapshot labelled
  `cms-burst-image-role=<arch>` or builds one: a temporary `docker-ce` server
  labelled `cms-bootstrap-role`, kamal, the caller's `:install_release`,
  `sync`, `create_image`, then poll.
- Never destroy a snapshot's source while Hetzner may still be reading it.
  The source is destroyed only when the image is `available` or has vanished;
  a poll that runs out leaves the server running and returns
  `{:image_not_confirmed, image_id, server_id}`. `BurstBox.Sweep` reaps a
  bootstrap server once `burst_box_image_available?/3` is true.
- The poll lists without a `status` filter and matches the exact id, so
  "creating" and "dropped" are distinguishable and an older available image
  is never mistaken for this one. Budget ~20 minutes with backoff: a
  populated disk snapshots slowly, and giving up early once destroyed a
  finished build.
- Run `sync` before `create_image`: the snapshot is crash-consistent, and
  unflushed writes (a just-finished `gem install kamal`) came back as empty
  gemspecs.
- A failed destroy of the temp server is logged as an error naming
  `mix cms.provisioning_leaks`, never swallowed.

## Burst box

- One persistent box per Hetzner account, named `BurstBox.box_name/0`
  (`"burst-platform"`), labelled with `Sweep.role_label/0`. Customer builds
  run on it as Docker containers; on the platform's own box, the app's
  embedding jobs run as FLAME runners straight from an installed release.
- `ensure_box/3` must be cheap: `HetznerFlameBackend` calls it on every runner
  boot, so the found case is a single list call. Only creation pays for the
  snapshot (`Builder.ensure_burst_box_image/3`) and the server.
- "Platform scope" is a scope with neither `active_account_id` nor
  `active_project_id` — the same shape `Hetzner.token/1` falls back to app
  config for. Only those boxes get Fly peering; a customer's box has no
  Fly-hosted parent to dial back to.
- Fly peer parameters come from config, set once by a human with
  `flyctl wireguard create`; nothing here talks to Fly's API. Missing config
  logs a warning and the box still serves builds.
- Runners: `nohup bin/code_my_spec start` with closed stdio and a per-runner
  PID and log file under `<release>/run/`. `bin/<release> daemon` is not used:
  it assumes one node per `RELEASE_ROOT`, and many runners share one release.
  The runner name must be unique per runner even though all share the box's
  IP; `CMS_FLAME_RUNNER_IP` is the configured peer's `:address`.
- `busy?/3` = build marker container present OR the caller-supplied
  `:embed_runner_busy?`. Any failed check reads as busy: `Lifecycle.check/3`
  acts only on `false`, so unknown costs an hour, never a box mid-build.
- `install_release/3` builds the app's own Dockerfile on the box, never
  pushes, checks architecture against the server's record (proceeding when
  the record does not say), and extracts `/app` to `/opt/cms-release`.

## SSH to provisioned boxes

- `Builder.Remote.ssh_runner/2` is the shared way to run commands on a box
  setup made (builder, registry, database). One ssh invocation per command.
- Every remote command is `timeout -k 10 <s> sh -c '<cmd>'` (default 600s).
  `sh -c` so the bound covers the whole `&&`/`|` chain; `-k 10` escalates to
  SIGKILL because `docker build`'s children can outlive SIGTERM. Without it a
  build blocked on a `RUN` prompt ran 30+ minutes silently.
- Flags, each learned the hard way:
  - `LogLevel=ERROR` — with `UserKnownHostsFile=/dev/null`, ssh prints
    "Permanently added …" on every call, merged onto stdout; callers that
    test "is the output empty" (container-exists checks) read it as "yes".
  - `BatchMode=yes`, `IdentitiesOnly=yes` — otherwise ssh offers every agent
    key first and the server's `MaxAuthTries` disconnects before ours
    ("Too many authentication failures", easily misread as unreachable).
  - `ConnectTimeout=10` — callers poll; a 75s OS-default attempt only delays
    the retry that would succeed.
  - `ServerAliveInterval=15`, `ServerAliveCountMax=4` — the only thing that
    notices a connection that died quietly after the command started.
- `await_ssh/5` polls `true` (90 × 2s). Its error carries the wait and SSH's
  last words: a broken box and an impatient caller need opposite fixes.
- Source delivery retries ssh's own exit 255 (cloud-init restarts sshd right
  after the first answer); any other status is a real remote error.
- Parse the last line of output, not all of it: stderr is folded into
  stdout.
- `:ssh_port` exists only for the local fleet (containers on loopback ports),
  which must run this same function rather than an imitation.

## Kamal on the builder

- `ensure_kamal/1` checks `command -v kamal` **and**
  `ruby -e "require 'ed25519'; require 'bcrypt_pbkdf'"`. Net::SSH needs
  `ed25519` to parse an OpenSSH-format key of any algorithm; when it fails to
  load, kamal logs it below its own log level and auth silently falls through
  to keyboard-interactive, dying `Errno::ENOTTY`.
- `gem list -i` is not a check: a native-extension compile can fail and leave
  a gem RubyGems calls installed with no working `.so`. Install with
  `--force` (otherwise a retry skips the compile) and retry up to 3 times.
- `build-essential` is required for the native extensions; `ruby-full` does
  not pull it in. `NEEDRESTART_MODE=a` suppresses needrestart's chatter, which
  otherwise pushes the real error past every truncation budget.
- Failure output is `Truncate.head_and_tail/1`: apt's cause is at the end, a
  gem crash's message precedes its backtrace. `--backtrace` makes RubyGems
  attach the message.

## Builds and the registry push

- Delivery: `ssh_deliver/2` pipes an archive of the deploy checkout's commit
  over the existing SSH, so no GitHub credential lands on the builder;
  `github_deliver/2` curls the API tarball with the token in that one request
  when there is no local checkout (`--location-trusted` because the redirect
  to codeload would strip `-u`).
- `docker build --force-rm` with `commit` and kamal's required `service`
  labels (setup deploys with `--skip-push`, so kamal never stamps it).
- An `alpine:3 sleep infinity` container labelled `cms-build-in-progress`
  brackets each build: BuildKit steps are invisible to `docker ps`, and the
  shared box's busy check needs something that is.
- Never pass `:platform` in production: emulation would make the
  architecture check permanently green and useless.
- Push: trust the registry host first (it speaks plain HTTP on the private
  network; without trust the push times out, which reads as unreachable),
  skip trust for loopback, `docker login --password-stdin` with the shared
  registry's configured credential. A failed push attaches interfaces, ping,
  port 5000 and `/v2/` diagnostics.

## Deploy

- `Deploy.run/3`: migrate → health → swap, each through the project's
  `bin/deploy <phase> <env>`. A refusal is a returned `Result` (phase, reason,
  output), never an exception; `Result` has no success flag — only
  `swapped_at`.
- A failed migration means the new image is broken against the schema:
  promoting it would take the site down, so nothing swaps. A failed health
  check also never swaps.
- First deploy: `kamal app exec` needs `env/roles/<role>.env`, which kamal
  writes only when booting a container. When migrate fails for that reason,
  swap runs once as `:bootstrap` and migrate retries. This is detected from
  the real error each time; a remembered "already bootstrapped" flag would
  be wrong exactly after this failure. If the retried migrate fails, the
  reason says an unmigrated version is live with nothing to fall back to.
- Health runs before the swap, so it probes the version already serving. On
  a first deploy there is none, and the probe could never pass. It is
  skipped when migrate printed `first_deploy=1`, a bootstrap happened, or
  `opts[:environment_previously_deployed]` is false. That last signal (the
  environment's `first_deployed_at`, set only after a real swap) is the
  authoritative one: kamal leaves its env file behind when a first boot
  crashes, which made every retry health-check a version that was never
  live.
- `probe/2` never follows redirects (a 301 to HTTPS would let a broken
  `force_ssl` pass while kamal-proxy's own probe fails). `scheme: :http`
  distinguishes "proxy up, issuance failed" from "nothing listening".
- The script runs on the builder via `opts[:run]`, with env spelled out as
  quoted exports: `CMS_IMAGE`, `CMS_DEPLOY_HOST(_IP)`, `SOPS_AGE_KEY`,
  `KAMAL_REGISTRY_*`, `CMS_SSH_KEY_PATH`, `CMS_SSH_PORT`. The IP of a server
  created at run time cannot be in committed config. Empty values are
  dropped.
- Refusal logs carry an excerpt anchored on the last error marker, and every
  phase logs its duration: a refusal at ~600s is the remote timeout.

## Kamal host keys

- kamal, on the builder, opens its own ssh to the app host. Nothing told that
  client to skip host-key checks, and it reads `CMS_SSH_KEY_PATH` on the
  builder's filesystem, so `deliver_ssh_key/1` writes the key there first.
- Root cause of recurring `HostKeyMismatch` with correct fingerprints:
  SSHKit's own known_hosts reader (`KnownHostsKeys#keys_for`) returns only
  the first hashed line matching a host and discards other key types. If
  the negotiated algorithm is not that type, verification fails.
- The fix: wipe `~/.ssh/known_hosts[2]` and `/etc/ssh/ssh_known_hosts[2]`
  (net-ssh merges global files; the box image can carry stale entries),
  `ssh-keyscan -t rsa -H` with retries until the file is non-empty, and pin
  `HostKeyAlgorithms ssh-rsa,rsa-sha2-512,rsa-sha2-256` in `~/.ssh/config`
  so what is negotiated is what was scanned. kamal has no host-key option,
  but `Net::SSH.start` reads the config by default; net-ssh's parser has no
  `+`/`-` modifiers, so the list is explicit.
- The `diagnose_*` probes in the remote command print versions, types and
  fingerprints only — never key material — and stay on.

## Backups

- A file is not a backup until it has restored. `Backups.run/3` puts the
  bucket's lifecycle rule in force, dumps, restores into a scratch database,
  compares the restored row count with the source count `dump` printed, then
  installs the schedule. An object listing cannot tell an empty-database dump,
  a truncated upload and a good backup apart.
- Equal counts are the proof, zero included (a freshly migrated database has
  no rows). Only an older `bin/backup` that prints no source count falls back
  to `restored > 0`.
- The systemd timer is necessary but never evidence: a timer that fires into
  a broken script produces nothing and reports nothing. Evidence is a dated
  object in the bucket.
- `bin/backup dump` uploads from the server straight to the user's bucket and
  prints `key=`/`rows=`; `restore` pulls it back. A dump never passes through
  the control plane, whose memory must not scale with the user's data.
- The scripts must run on the server (`opts[:run]`): locally, `DATABASE_URL`
  names `cms-postgres` on the server's private docker network and is
  unresolvable, and `schedule` would `sudo` a timer onto whatever machine ran
  setup — succeeding on a host with passwordless sudo.
- `CMS_RESTORE_ADMIN_URL` is the restore's own credential for creating and
  dropping its scratch database, never the app's. `SOPS_AGE_KEY` is passed
  because sops reads its identity only from it.
- `health/2`: `never` (no dumps), `stalled` (newest older than 48h — one late
  run should not cry wolf), else `healthy`. A backup that quietly stops removes
  the pressure to check.

## Widget

- The step must run the generator new projects actually get:
  `cms_gen.support_widget` (socket transport via `WidgetSocket` /
  `ConversationChannel`, deploy-key auth). It has twice named a deprecated
  generator (`client_utils.gen.chat_widget`, then `cms_gen.feedback_widget`,
  which uses OAuth/REST), and then it verified something no project had.
- The generator prompts before overwriting its own files, so it runs only
  when no `lib/*_web/live/support_widget_live.ex` exists in the checkout; a
  re-run would otherwise hang forever on the prompt.
- Presence is a published marker contract (`markers/0`); never guess at
  DaisyUI classes. Openable = present + toggle marker.
- `probe_degraded/2` can only see the negative over HTTP: the page renders
  and the served state is not `connected` (and not `absent`).
- Proof is a message whose origin is `deployed_site`. The step first asks
  the deployed app to send one (`POST /_cms/verify/widget`, recorded
  `via=loopback`), waits for the async round trip, then looks. The trigger
  is optional and never fails the step.
- Anonymous visitors are allowed by design — people who bounced have the
  most useful feedback — and there is deliberately no switch to require
  sign-in.

## Teardown

- Separate from `Provisioning`, which exposes nothing that destroys (a test
  asserts it): a routine that can destroy is one nobody runs unattended.
- Works only from resources a `Step` recorded, never by name pattern — a
  search for `*-prod` would find production.
- Outcomes per resource: `{:ok, r}` removed (or already absent),
  `{:skipped, r}` adopted and left, `{:error, r}` left behind. Skipped is
  distinct so a summary cannot report a still-live adopted record as removed.
- Adopted resources are spared — teardown once deleted a long-standing
  Resend domain that setup had merely adopted. The exception is a DNS record
  whose name is an environment's assigned host, or whose recorded address is
  an environment's current IP: setup pointed it at our machine, and sparing
  it hands the name to whoever Hetzner gives the address next.
- `environment/3` deletes the DNS record before the server (subdomain
  takeover otherwise), deletes the environment row even when something is
  left behind, and strips that environment's tagged resources
  (`environment=<name>` token) from every step.
- `step/3` resets the row to `:not_started` with no resources on full
  success only; a surviving proof (`inbound_proof`) would otherwise satisfy
  `verify/3` on a rebuilt environment.
- DNS at the apex: prod's host is the bare domain, and "the subtree under
  the apex" is the whole zone — this once wiped every record on a real
  domain. At the apex only the exact name pointing at a project address is
  removed; confirmation uses the same predicate.
- Ordering and waits: servers before networks and firewalls (Hetzner refuses
  while attached; they retry 15 × 2s, outlasting the servers' 20s); deletes
  are confirmed by polling `find_*` until `:not_found`; buckets are emptied,
  deleted with backoff, and polled out of the listing.
- Never removed: registered domains (non-refundable). No-op kinds (age keys,
  proofs, verification records, commits, …) are listed explicitly so they do
  not read as leaks; an unknown kind logs and is reported left behind.

## Lessons

- **A persisted row is a claim about the past.** Verify against the provider
  before running or reporting; filtering on `state == :done` makes a stale
  row permanent.
- **An unreachable provider is not a deleted resource.** Never demote a
  `:done` step or rebuild infrastructure on a timeout.
- **Record every resource a step makes, on every exit path** — success,
  pause and partial failure. Teardown works only from records, so an
  unrecorded resource leaks by construction.
- **Ownership is sticky.** Earlier `origin` wins in both directions: an
  `ensure_*` that finds its own earlier work reports `adopted`, and a later
  `created` claim would license deleting something the user had first.
- **Accepted is not done.** Hetzner deletes, Ceph writes and deletes, Resend
  verification and DNS propagation all finish later; poll for the observable
  effect.
- **Idempotent repeats often come back as errors** (`server_already_attached`,
  `firewall_already_applied`, S3 409 on an owned bucket); match them by code
  and treat them as success.
- **Never restart shared infrastructure.** Database and registry containers
  serve every project on a box; ensure means "start if absent".
- **Parse only what you expect.** ssh folds banners into stdout; count
  container ids, read the last line, silence the banner at the source.
- **Bound every remote command** (remote `timeout -k`, `ServerAliveInterval`):
  nothing else notices a silent hang.
- **A check that cannot fail is not a check.** Read the built image's
  architecture rather than echoing the request; never force `--platform` in
  production.
- **Delete DNS before releasing an IP.** Hetzner recycles addresses; a record
  left behind is a subdomain takeover. At a zone apex, "everything under the
  name" is the customer's whole zone.
- **Never fall back to another credential.** A connected-but-unusable grant
  surfaces; falling back to a configured token acts on someone else's
  account and reports success.
- **Name the cause, not the symptom.** Errors carry the provider's words,
  the step's phase, the last SSH output, the rejected records — a bare
  timeout sends people to the wrong fix.
- **Polls must make the same requests on record and replay**; sequential
  cassettes desynchronise otherwise.
- **Check availability against what the API can create now** (`/datacenters`),
  not the catalogue or the docs.
