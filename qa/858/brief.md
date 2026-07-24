# QA Story Brief — 858: Agent does my DevOps for me

## Tool

curl (agent/API surfaces) + web (configuration LiveView on the local app)

## Auth

None — the local app (http://localhost:4004) is LocalOnly; API routes resolve
scope from the URL project name. The dev server must be running TODAY'S build
(the devops_setup/deploy requirements shipped in `5a7ee192`).

## Seeds

No seeds needed — QA drives real projects already in the local DB:
- `Code My Spec` (dogfood project) for prompt/config scenarios
- `Todo` (test-bed, chain satisfied through code_generation) for graph placement

URL-encode project names: `Code%20My%20Spec`, `Todo`.

## What To Test

- **Prompt contracts** — `curl http://localhost:4004/api/projects/Code%20My%20Spec/requirements/devops_setup/prompt`
  must carry every contract: Hetzner/AWS/Cloudflare collected once, no further
  input beyond credentials; user's own accounts (never CodeMySpec-owned);
  UAT + prod default; automatic TLS + /health verification; SSM secrets store
  seeded once + fetched at boot; fail-fast boot naming the missing key; never
  in repo or deploy tool; backups with retention + uptime monitors; scripts
  checked in + idempotent; halt-and-name on under-scoped credentials.
  (Criteria: tokens-once, own-consoles, uat+prod-live, secrets, missing-secret,
  https, backups/monitors, rebuild-from-scratch, under-scoped-token.)
- **Prod opt-out** — flip `devops_prod` to off on
  http://localhost:4004/projects/Code%20My%20Spec/configuration (real form),
  re-curl the prompt: UAT-only plan, no prod environment demanded. Flip back.
  (Criterion: opting out of prod completes setup UAT-only.)
- **Graph placement** — `curl http://localhost:4004/api/projects/Todo/requirements`
  shows `devops_setup` as an unsatisfied project requirement on the test-bed
  whose chain is satisfied through code_generation; the requirements LiveView
  (`/projects/Code%20My%20Spec/requirements`) renders it as a graph node.
  (Criterion: DevOps setup surfaces after code generation.)
- **Deploy in the loop** — a story's requirement listing
  (`/api/projects/Todo/stories/<id>`) includes the `deploy` requirement after
  qa_complete, and its description/prompt orders UAT before prod with a halt
  on failing UAT health. (Criteria: rides to UAT then prod; failing UAT stops
  the promotion.)

## Result Path

.code_my_spec/qa/858/result.md (evidence only — canonical record is the DB
attempt via submit_qa_result + any filed issues)

## Setup Notes

The installed :4003 server is v1.5.35 and does NOT have these requirements —
all testing goes against :4004 (dev build). Infra-real criteria (live Hetzner
provisioning, real DNS/TLS) are exercised by the first real dogfood run on the
todo project, not this session; here we verify every harness-observable
surface of the feature.
