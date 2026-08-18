# QA Brief — Story 852: My app answers on my own server over HTTPS

## Tool

web

## Auth

Log in as the owner. GitHub, Cloudflare and Resend are per-user OAuth
integrations and only his account holds the grants, so no other user can drive
these steps.

1. `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `johns10@gmail.com`
3. Click `form button.btn-secondary` ("Email me a login link")
4. `http://127.0.0.1:4000/dev/mailbox` — the mailbox is shared, so confirm the
   message is addressed to that user before opening it
5. The link is issued for `dev.codemyspec.com`; swap the host to `127.0.0.1:4000`

If the email field renders `readonly`, a session is already open — log out via
`a[href="/users/log-out"]` (`data-method="delete"`, so navigating there does
nothing), then start again.

The active account resets on a server restart. Re-pick at
`/app/accounts/picker`; entries are `a[phx-value-account-id=...]`.

## Seeds

No story-specific seeding. Use the **devops-drill** project, not the QA Fixture
Project — see Setup Notes for why.

- Project: `ee33ba64-fe35-419a-9de0-46d699499023` ("devops-drill")
- Working copy: `/Users/johndavenport/Documents/github/code_my_spec_test_repos/devops_drill_v2`
  (a real `cms new` app; the `devops_drill` path the project records holds an
  older stub, so the two must be swapped for the run and swapped back after)
- Domain: `drill.astralbi.com`; uat host `uat.drill.astralbi.com`
- Provisioning page: `http://127.0.0.1:4000/app/projects/ee33ba64-fe35-419a-9de0-46d699499023/provisioning`

The `spex drill` project (`bbd970c8-…`) looks like the better fixture — it is a
real generated app that has previously reached `deploy: done` — but it belongs
to "Test Account 17702", whose user holds none of the OAuth grants. GitHub,
Cloudflare and Resend are per-user, so it cannot be driven as the owner.

Baseline: John's two real servers (`fuellytics`, `fuellytics-prod`) and nothing
else. Anything named for a project is one this session created.

**Read the Hetzner token from `envs/.env`, not `envs/dev.env`** — `dev.env` has
no `HETZNER_API_TOKEN` line at all, so a probe built from it sends an empty
bearer, gets `{"error":{"code":"unauthorized"}}`, and a `.get("servers", [])`
turns that into a confident "0 servers". Check the instrument against a known
positive before believing a zero: the first correct query returned three
servers where the broken one had returned none.

## What To Test

Drive the provisioning page and run the sequence: **server → dns → deploy →
tls**. Verify each claim at the provider or over the wire, never only in our
own rows.

- **The server shows up in Sam's own console (2026).** Query the Hetzner API
  with his own token and confirm the box is listed under his account, running.
- **The database is not reachable from outside (2027).** Read the firewall's
  whole inbound rule set at Hetzner — confirm there is no 5432 rule and that
  the default is deny. Corroborate with `nc` against the public IP.
- **The deployed image is the one the repo built (2028).** The product does not
  use the boilerplate's `gh run watch` path: it boots a builder box, builds from
  the checkout, pushes to a private registry, destroys the builder, and deploys
  with `--skip-push`. Confirm the digest kamal is running is the digest that was
  built for this commit, not `latest` and not a stale tag.
- **Sam's app answers on his domain over a valid certificate (2029).**
  `curl https://uat.spex-drill.earwitness.app/health` → 200 with
  `ssl_verify_result: 0`. Check the chain, not just the status code.
- **Migrations land before the swap, not after (2030).** The step records
  `deploy_phase` resources. Confirm **both** `migrate` and `swap` are recorded
  with timestamps and that migrate precedes swap — the last completed run
  recorded only `migrate`, so an ordering that cannot be read back is itself
  the finding.
- **A failed migration leaves the old version serving (2031).** Needs a
  deployed version first. Introduce a migration that fails, deploy, and confirm
  the previously running version still answers `/health`.
- **An unhealthy deploy does not become the live version (2032).** Deploy an
  image whose `/health` does not answer and confirm the swap is withheld.
- **Every public hostname is answering before setup calls the environment done
  (2033).** Confirm the environment is not reported done while any of its
  public hostnames fails to answer.
- **UAT stands alone, and prod arrives on its own box when Sam is ready
  (2034).** Add prod and confirm it provisions its own server and its own
  record without disturbing uat.

## Setup Notes

**Why not the QA Fixture Project.** `qa_sandbox` cannot satisfy this story and
no amount of running the page will change that. It is a bare mix project —
`app: :qa_sandbox`, credo as its only dependency, `lib/` holding one file, no
Phoenix, no release config, and its generated `router.ex` deleted. Its
Dockerfile runs `mix assets.deploy` (not a task in that project) and copies
`_build/prod/rel/qa-fixture-project`, a release name `mix release` cannot
produce — release names must be valid atoms, and that one is hyphenated and
does not match the OTP app. Its remote, `johns10/qa-fixture-project`, is a
private mirror of the CodeMySpec repository whose `main` is `3df593ad`, while
the local tree has a single unrelated `Initial commit` (`11986f2`) — so the
push is rejected as unrelated history, permanently, not as a transient
divergence. `cms_drill_app` is a real `cms new` project with a `/health` plug
in its endpoint, a clean tree, and a remote it has pushed to.

**Do not provision the QA Fixture Project's prod environment.** Its host is the
apex `astralbi.com`, which serves a real site. `spex-drill.earwitness.app` is a
subdomain, so prod on the drill project is safe.

**Tear everything down at the end** and verify at the providers: Hetzner back
to 0 servers, DNS records removed, no builder boxes left. Note that teardown
deliberately does not delete repositories — `repository` is in the
"nothing provider-side to remove" list — so anything created at GitHub stays.

**The spex are not the QA.** They run against fakes and prove the contract, not
the product. Drive the real page and check the real providers.

## Result Path

`.code_my_spec/qa/852/result.md`
