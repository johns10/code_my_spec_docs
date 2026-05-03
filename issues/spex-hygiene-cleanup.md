# Spex Hygiene Cleanup

Follow-up cleanup pass on `test/spex/` and `test/support/` after the
graph stories (561, 562, 671) land. Two distinct issues, neither
graph-blocking.

## Issue 1: Duplicated `defp response_text/1` across spex files

Many spex files define a private `response_text/1` helper for parsing
MCP tool responses (anubis frame `%{content: parts}` or `%{text: ...}`).
A canonical version already lives in
`test/support/task_response_helpers.ex` as
`CodeMySpecSpex.TaskResponseHelpers.response_text/1`.

### Scope

Search: `grep -rn "defp response_text" test/spex/`

Each occurrence is structurally identical. Replace the local defp with:

```elixir
import CodeMySpecSpex.TaskResponseHelpers, only: [response_text: 1]
```

…at the top of the module. Do NOT modify behavior — just delete the
defp and add the import. Run `mix spex` per affected file to confirm
green after each batch.

### Files affected (incomplete — re-grep before starting)

- `test/spex/76_component_specification_generation/criterion_*.exs` (8 files)
- `test/spex/559_three_amigos/criterion_*.exs` (~15 files)
- `test/spex/668_plan_qa_infrastructure_for_every_surface_of_the_app/criterion_*.exs`
- A handful in `test/spex/554_*` and `test/spex/555_*`

### Risks

- Some specs may have *slightly different* `response_text/1` impls
  that handle response shapes the canonical helper doesn't. Diff each
  one before deleting; if there's a real divergence, extend the
  canonical helper rather than keep the duplicate.

## Issue 2: Inline spec-content fixtures in 460 (BDD lifecycle specs)

Multiple specs under `test/spex/460_bdd_specification_lifecycle/`
define private content generators:

- `defp valid_spec_content` — repeated across at least 2 files
- `defp scenarioless_spec_content` — `criterion_5537`
- `defp stepless_spec_content` — `criterion_5538`
- `defp broken_spec_content` — `criterion_5539`
- `defp conncase_only_spec_content` — `criterion_5557`

These are **BDD spec content** (i.e., the body of a Spex `_spex.exs`
file under test) — different beast from the *graph-related* spec
content the new `GraphContentFixtures` module produces. They belong
together but in their own module.

### Proposed extraction

Create `test/support/bdd_lifecycle_fixtures.ex`:

```elixir
defmodule CodeMySpecSpex.BddLifecycleFixtures do
  @moduledoc """
  Spex file content fixtures for the BDD spec lifecycle stories
  (Story 460). Each function returns a string suitable to be
  written into the in-memory environment as a `_spex.exs` file
  under test by the lifecycle pipeline.
  """

  def valid_spec_content, do: ...
  def scenarioless_spec_content, do: ...
  # ...
end
```

Update each spex file in 460 to call the extracted version. Do NOT
attempt to merge variants that differ even slightly — preserve every
string verbatim.

### Risks

- Tiny string differences across specs may be intentional (testing
  edge cases). Diff rigorously before merging two `valid_spec_content`
  versions into one.

## Out of scope for this cleanup

- The `defp fixture_path/1` + `@fixture_dir` pattern in `test/spex/554/*`
  and `test/spex/555/*`. Those reference real on-disk fixture trees for
  compiler/credo cassettes. Self-contained, working as designed.
- Anything that requires changing spex behavior or assertions. This is
  a pure refactor — every spec must remain green after each commit.

## Acceptance signal

- `mix spex` is green at every commit
- `grep -rn "defp response_text" test/spex/` returns zero matches
- All inline content fixtures in `test/spex/460_*` resolve to the new
  `BddLifecycleFixtures` module
- No new exports added to `CodeMySpecSpex.Fixtures` (the bridge stays
  scoped to server-originated state)
