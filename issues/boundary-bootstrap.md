# Boundary Bootstrap

**Logged:** 2026-04-26
**Type:** Architectural enforcement / cleanup

## Problem

The `:boundary` lib (~> 0.10.4) is in `mix.exs` and `test/support/code_my_spec_test_boundary.ex` declares a `CodeMySpecTest` boundary, but **nothing is actually being enforced**:

- `:boundary` is missing from the compilers list in `mix.exs` (line 49, 51).
- Only 2 modules use `Boundary` out of ~50 contexts: `CodeMySpec.Configurations` and `CodeMySpec.AgentTasks.Setup.TestBoundaries` (the latter is just a setup-step module with strings, not a real declaration).
- Top-level modules `CodeMySpec` and `CodeMySpecWeb` have no `use Boundary` at all, so the `CodeMySpecTest` boundary's `deps: [CodeMySpec]` resolves to an undeclared boundary.
- `Configurations` declares `deps: [CodeMySpec.Repo, CodeMySpec.Users]` referencing boundaries that don't exist either.

Net effect: the project ships Boundary as a documented pattern (see `lib/code_my_spec/agent_tasks/setup/test_boundaries.ex`) and uses it in CodeMySpec project setup, but it isn't running on this repo. Cross-context coupling is unchecked.

## Why a Single-Shot Branch

Enabling the `:boundary` compiler globally on `main` while contexts are partially declared will:

1. Break any in-flight agent work the moment they save a context that crosses an undeclared boundary.
2. Surface a wall of violations from the ~50 contexts at once if top-level boundaries use restrictive `exports: []`.
3. Block the running `mix phx.server` reload loop on the first violation.

The work needs to land cohesively: declarations on every context, then compiler flip, then merge. Worktree or branch — not piecemeal commits to `main`.

## Plan

### Phase 1 — Declare every boundary (no compiler change)

Branch: `boundary-bootstrap` (or worktree).

1. **Top-level boundaries** in `lib/code_my_spec.ex` and `lib/code_my_spec_web.ex`:
   - Start permissive: `use Boundary, top_level?: true, deps: [...], exports: [...]` listing every public child boundary in `exports` so cross-namespace calls keep working.
   - `CodeMySpecWeb` gets `deps: [CodeMySpec, ...]` for whatever public contexts it consumes.

2. **Per-context declarations** for each `lib/code_my_spec/<context>.ex`:
   - Add `use Boundary, deps: [...]` listing the contexts it actually calls (derived from `alias CodeMySpec.X` lines plus inline references).
   - Suggested order (leaves first):
     - **Pure leaves** (zero project deps): `Vault`, `Mailer`, `Paths`, `Repo`, `Utils.*` sub-helpers
     - **Schema-only deps**: `Tags`, `AcceptanceCriteria`, `Personas`, `Documents`, `Questions`, `Issues`, `Rules`
     - **Mid-tier**: `Authorization`, `Authentication`, `Users`, `Accounts`, `Projects`, `Components`, `Stories`
     - **Heavy consumers**: `Sessions`, `AgentTasks`, `Requirements`, `Architecture`, `Specs`, `Tests`, `BddSpecs`, `Code`, `StaticAnalysis`
     - **Orchestrators**: `ProjectCoordinator`, `McpServers`, `ContentSync`, `FrameworkSync`, `Compile`, `Release`

3. **Test boundary** (`test/support/code_my_spec_test_boundary.ex`):
   - Currently has `use Boundary, top_level?: true, deps: [CodeMySpec]`. Expand `deps:` to list every context the tests reach into, or add `check: [in: false]` if we want loose test-side rules.

### Phase 2 — Enable the compiler

Add `:boundary` to `compilers/1` in `mix.exs`:

```elixir
defp compilers(:test),
  do: [:diagnostics, :phoenix_live_view, :erlang, :elixir, :spex, :boundary, :app]

defp compilers(_),
  do: [:diagnostics, :phoenix_live_view, :erlang, :elixir, :boundary, :app]
```

Run `mix compile`. Expect violations. Fix by either:
- Adding the missing dep to the consumer boundary's `deps:`, or
- Refactoring the call out (it's a real architectural smell).

### Phase 3 — Tighten

Once compilation is clean, walk back through and replace permissive `exports: ...` with the minimal public surface (just the context module itself, not its internal sub-modules).

### Phase 4 — Wire into CI

Add `mix compile --warnings-as-errors` (or a dedicated `mix boundary.check` step) to the CI pipeline so future drift fails the build.

## Cost Estimate

- Phase 1: 4–8 hrs. Mechanical but ~50 contexts to inspect.
- Phase 2: 2–4 hrs depending on how many real cross-boundary calls exist.
- Phase 3: 1–2 hrs.
- Phase 4: 30 min.

Total: ~1–2 days of focused work, end-to-end on a branch.

## Out of Scope

- The 542 credo issues (separate cleanup; mostly mechanical, do after Boundary lands).
- The stale `CodeMySpec.TestContext` component remaining in the project DB (filesystem refs were deleted on 2026-04-26, but the DB component still surfaces from `get_next_requirement`). Track separately.

## References

- `mix.exs:48-51` — current compilers list
- `lib/code_my_spec/configurations.ex:12` — only real existing boundary declaration
- `test/support/code_my_spec_test_boundary.ex` — test top-level boundary
- `lib/code_my_spec/agent_tasks/setup/test_boundaries.ex` — the project's *own* setup pattern that this repo isn't following
