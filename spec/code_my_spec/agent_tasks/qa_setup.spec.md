# CodeMySpec.AgentTasks.QaSetup

## Type

skill

## Intent

Produce a project-wide QA plan (`.code_my_spec/qa/plan.md`) that
captures every running surface of the app and the testing infrastructure
(tools, seeds, auth scripts) needed to exercise it. The plan is consumed
by qa_story (per-story testing) — without it, story-level QA can't
authenticate, seed data, or pick the right tool for each pipeline.

The task is multi-router aware: many Phoenix apps ship more than one
endpoint in a single OTP release (hosted SaaS UI + localhost CLI server,
marketing site + app). The plan covers every endpoint or it's wrong.

It's also probe-driven: reading config files isn't enough — compile-time
`:url`, OAuth issuer config, and live_session gating only show real
behavior when you hit them. The agent works in two phases — Probe (run
discovery commands, hit every listening port) then Write — drawing the
plan only on what was observed.

When a plan already exists, the task patches sections that drifted
rather than rewriting from scratch. Working scripts and credentials
are preserved as institutional memory.

## Done signal

`.code_my_spec/qa/plan.md` exists, parses against the registered
`qa_plan` document spec via `Documents.create_dynamic_document/2`, and
has non-empty content under each required H2 section (`App Overview`,
`Tools Registry`, `Seed Strategy`). Extra H2 sections fail validation;
empty required sections fail.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `qa_setup` (id 14), gated by `issues_resolved` (id 7). The
per-story QA chain (`qa_story` via story_graph) and the project-level
QA journey chain (`all_bdd_specs_passing` → `qa_journey_*`) all depend
on this plan existing.

## Out of scope

- The task does not run tests. It writes the plan that other tasks use
  to know how to test.
- The task does not write story-level test briefs or results — that's
  qa_story's job.
- The task does not write integration verification scripts — those come
  from qa_integration_plan.
- The task does not invent infrastructure. If the app is missing
  necessary endpoints, fix that upstream before planning QA.

## Failure modes the agent should avoid

- Skipping the Probe phase and writing the plan from config inspection
  alone. Phoenix compile-time `:url` and OAuth issuer config lie under
  dev environments.
- Producing a plan that only covers one endpoint when the app has
  multiple. Multi-router apps are common; check the Router Files
  section in the prompt — every router maps to at least one row in the
  plan.
- Writing bash `for` loops that call `mix run -e '…'` per entity.
  Cold-boots the BEAM each iteration. Use `.exs` files that run
  in-process.
- Writing curl wrappers for session-authenticated routes. Browser auth
  needs Vibium; curl is for `:api` pipelines only.
- Promising selectors / paths / headers that haven't been verified
  against the running app.
- Rewriting an existing plan from scratch instead of patching the
  sections that drifted.

## Resources

Required input:
- The running app — Phoenix endpoints must be listening so the agent
  can probe them.
- `lib/*_web/router.ex` — discovered by the prompt and embedded in the
  Router Files section.

Optional input:
- `priv/repo/qa*.exs` — existing seed scripts, listed in the Inventory
  section.
- `.code_my_spec/qa/scripts/*` — existing helper scripts, listed in the
  Inventory section.
- Existing `.code_my_spec/qa/plan.md` — if present, the agent patches
  sections that drifted rather than rewriting.

Required reading:
- `priv/knowledge/qa_setup/workflow.md` — full two-phase procedure
  (probe protocol with the 5 discovery steps, writing conventions,
  seed/auth script rules, idempotent-rerun procedure).
- `priv/knowledge/qa-tooling.md` — tool selection (Vibium vs curl) and
  authentication patterns.
- `priv/knowledge/qa-tooling/` — per-tool cheat sheets
  (`curl.md`, `vibium_reference.md`, `authenticated_curl_example.sh`).

Produced:
- `.code_my_spec/qa/plan.md` — the QA plan, validated against the
  `qa_plan` document spec.
- `priv/repo/qa_*.exs` — seed scripts (one per Repo/DB target).
- `.code_my_spec/qa/scripts/*.sh` — auth wrapper scripts (only for
  auth models confirmed working during probing).

## Tools

- **MCP browser tools** (Vibium) — required for the probe's auth-mapping
  step (login pages, real selectors).
- `lsof`, `curl`, `grep` via Bash — required for the probe phase
  (listening ports, HTTP reachability, Repo discovery).

Built-ins (Read, Write, Bash, Glob) handle the rest. The playbook lives
at `priv/knowledge/qa_setup/workflow.md`.

## Dependencies

- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Paths
