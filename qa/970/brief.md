# QA Brief — Story 970: My new project ships deploy-ready

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`).

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`.

**Check `local_path` before generating anything.** It must point at a disposable
directory:

    /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox

It previously pointed at the CodeMySpec checkout itself (issue `b400d0d3`), in
which case `[data-test="generate-project"]` writes `.github/workflows/build.yml`,
`Dockerfile`, `bin/`, `config/` and `envs/` **into the live repository**.

The project needs a `domain` set for the deploy configs to render hosts, and its
environments decide which config files appear (`config/deploy.yml` for prod,
`config/deploy.<env>.yml` for the rest).

## What To Test

Click `[data-test="generate-project"]` on the provisioning page, then inspect the
generated tree — this story is about artifacts, not about the running app.

- **Each environment has its own deploy configuration (7976)** — expect
  `config/deploy.yml` and `config/deploy.<env>.yml`. Diff them: `service`, `host`,
  `APP_ENV` and `PHX_HOST` must all differ per environment, not just a name.
- **The project already contains everything a build needs** — expect
  `Dockerfile`, `.github/workflows/build.yml`, `bin/deploy`, `bin/backup`,
  `config/runtime.exs`, `envs/<env>.enc.env`, `.sops.yaml`.
- **No unrendered template markers** — `grep -rn "<%=" config/ bin/ Dockerfile .github/`
  must be empty. **Currently fails** (issue `4400616e`): the `servers.web` entry is
  emitted as a literal `<%= prod_host %>`.
- **The health check answers without session, auth or database (7977)** — the
  generator writes `get "/health", <Web>.HealthController, :show` and a controller.
  Verifying it actually answers needs a generated project booted with no database
  reachable; the artifacts alone only show the wiring.
- **Forced SSL does not redirect the proxy's probe (7978)** — `config/runtime.exs`
  must carry `force_ssl: [rewrite_on: [:x_forwarded_proto], exclude: ["/health"]]`.
  A 301 on the probe reads as unhealthy and stalls the deploy.
- **A generated project is safe to push as-is (7979)** — `envs/<env>.enc.env` are
  scaffolding holding comments and no values. Confirm no real secret is present,
  and that no plaintext `.env` was created alongside.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**The `.enc.env` scaffolding is deliberately plaintext.** It ships with the
encrypted *name* and a comment explaining why — so there is never a moment when
the easy path is an unencrypted file. Do not report it as a leak; it holds no
values.

It does, however, mean every generated project starts with a plaintext file at the
`.enc.env` path, which is exactly the condition that made `Sops.ensure_file/2`
skip encryption forever (issue `536e9691`, fixed in `64341808`). Before that fix
the first secret write on any generated project would have failed with "sops
metadata not found". Re-test the first secret write on a freshly generated project
whenever that code changes.

**The image and registry are placeholders** — `ghcr.io/your-org/<app>`, from
`Keyword.get(opts, :owner, "your-org")`, which nothing overrides on the generate
path. That also points at GitHub's registry, which story 992 decided against
(criterion 8240). Noted inside `4400616e`; the two stories need reconciling.
