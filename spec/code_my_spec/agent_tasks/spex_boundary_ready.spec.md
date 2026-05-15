# CodeMySpec.AgentTasks.SpexBoundaryReady

## Type

skill

## Intent

Install the project-local infrastructure that protects the BDD spec
boundary, so subsequent `write_bdd_specs` and `fix_bdd_specs` work
runs against a sealed surface. The boundary exists to prevent specs
from cheating past the public interaction surfaces (LiveView, HTTP
hooks, MCP tools) — without it, the BDD test suite can pass for the
wrong reasons.

Four artifacts must be on disk before any story can write specs:

1. **Framework Credo checks** copied into the project (universal
   stdlib + send/2 denies).
2. **A project-local Credo check** denying internal namespaces this
   project's specs must not reach — derived from the architecture
   proposal.
3. **A curated fixtures bridge** (`<App>Spex.Fixtures`) — the only
   sanctioned door from a spec into in-app state.
4. **A project-specific BDD spec plan** complementing the generic
   framework docs.

The task is one-shot setup — once installed, downstream BDD work just
runs against the boundary.

## Done signal

The requirement is satisfied when
`Requirements.SpexBoundaryChecker.complete?/2` returns success — an
existence-only check:

- `.code_my_spec/credo_checks/framework/spex_denied_calls.ex` exists.
- `.code_my_spec/credo_checks/framework/no_direct_send_in_spex.ex`
  exists.
- At least one `.ex` file exists under
  `.code_my_spec/credo_checks/local/`.
- `test/support/fixtures/<app>_spex_fixtures.ex` exists.
- At least one `.md` file exists under
  `.code_my_spec/knowledge/bdd/spex/`.

The checker does not validate content quality. The prompt is the
quality bar — file existence is the gate.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `spex_boundary_ready` (id 16), gated by
`architecture_designed` (id 5) so the proposal is available for
mining project-specific denies.

## Out of scope

- The task does not write any spex files. That's `write_bdd_specs`.
- The task does not run the test suite. The Credo checks fire when
  `mix credo` or `mix spex` runs — that's a separate concern.
- The task does not edit the framework Credo checks. Project-specific
  denies go in `.code_my_spec/credo_checks/local/`, not the framework
  dir.
- The task does not curate the architecture proposal — it consumes
  one. If the proposal is missing or wrong, fix it in
  `architecture_designed` first.

## Failure modes the agent should avoid

- Denying schemas or public-surface modules (LiveViews, controllers,
  MCP tool modules) in the project-local Credo check. Those are the
  legal surfaces specs need to drive.
- Re-exporting half the application from `<App>Spex.Fixtures`.
  The bridge is a curated minimum, not a convenience wrapper. Every
  re-export is a sanctioned shortcut past the UI.
- Skipping the architecture proposal read. The list of internal
  namespaces to deny comes from there — guessing produces a check
  that protects nothing useful.
- Writing the BDD spec plan as a copy of the framework docs. The
  plan's value is in the project-specific tailoring (concrete
  surface module names, fixture inventory, observable shapes).

## Resources

Required input:
- `.code_my_spec/architecture/proposal.md` — mined for internal
  namespaces to deny in the project-local Credo check.

Required reading (framework BDD knowledge):
- `priv/knowledge/bdd/spex/philosophy.md` — why specs are sealed.
- `priv/knowledge/bdd/spex/boundaries.md` — what a spec may call.
- `priv/knowledge/bdd/spex/writing_a_spex.md` — DSL and setup template.

Produced:
- `.code_my_spec/credo_checks/framework/spex_denied_calls.ex` and
  `no_direct_send_in_spex.ex` — copied by `install_credo_checks`.
- `.code_my_spec/credo_checks/local/<short_name>_spex_denies.ex` —
  project-specific deny list.
- `test/support/fixtures/<app>_spex_fixtures.ex` — the curated
  bridge.
- `.code_my_spec/knowledge/bdd/spex/*.md` — at least one project
  BDD spec plan file (filename is the agent's call; the checker
  requires only one `.md`).

## Tools

- **`install_credo_checks`** (MCP tool) — required for step 1. Copies
  the framework Credo checks from the harness into the project.

Built-ins (Read, Write, Bash, Edit) handle the rest. The playbook
lives at `priv/knowledge/spex_boundary_ready/workflow.md`.

## Dependencies

- CodeMySpec.AgentTasks.Setup.Helpers
- CodeMySpec.Environments
- CodeMySpec.Paths
- CodeMySpec.Requirements.CheckerResult
- CodeMySpec.Requirements.SpexBoundaryChecker
