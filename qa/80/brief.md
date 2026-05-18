# Qa Story Brief

## Tool

mix spex (BDD specification runner — all 8 criteria test the `start_task` and `evaluate_task` MCP tools, not a UI surface)

## Auth

No auth required. The spex test suite uses `setup :register_log_in_setup_account` and `setup :setup_active_project` internally, which create a test user + account + project through `UsersFixtures` and `ProjectsFixtures`. No manual login steps needed.

The MCP surface under test is the local endpoint, which uses no user auth — scope comes from `X-Working-Dir` headers handled by the test helpers.

## Seeds

No manual seeding required. The spex test framework sets up all fixtures in memory (InMemoryEnvironment) per-scenario via the shared givens and `Fixtures.*` helpers defined in `test/support/fixtures/code_my_spec_spex_fixtures.ex` and `test/support/fixtures/technical_strategy_fixtures.ex`.

Run the full spex suite to exercise all criteria:

```
mix spex --no-color
```

All 8 criteria for story 80 are in `test/spex/80_architecture_decision_records/`.

## What To Test

The story has no UI surface. All 8 acceptance criteria are tested exclusively through the `start_task` and `evaluate_task` MCP tool modules (`CodeMySpec.McpServers.Tasks.Tools.StartTask` and `EvaluateTask`), exercised via the `technical_strategy` requirement.

- **Criterion 5269 — Bootstrap developer sees the core stack ADRs after running the phase:**
  Given a fresh project with no decision files, when `start_task` is called for `technical_strategy`, then ADR files for `elixir`, `phoenix`, `liveview`, `tailwind`, and `daisyui` must exist in `.code_my_spec/architecture/decisions/`.

- **Criterion 5270 — Partially-setup project fills in only the pre-made ADRs it was missing:**
  Given a project with a custom `elixir.md` already present and `phoenix.md` missing, when `start_task` runs, then `phoenix.md` is created AND `elixir.md` still contains the retrofit marker (not overwritten).

- **Criterion 5271 — Retrofit developer's customized phoenix.md survives the auto-write pass:**
  Given a project with a hand-written `phoenix.md` containing custom rationale, when `start_task` runs, then `phoenix.md` still contains the original hand-written content.

- **Criterion 5272 — Bare project produces a minimal prompt with only pre-made context:**
  Given a project with no components, no `mix.exs`, and no stories, when `start_task` runs, then the returned prompt omits `Architecture Overview`, `Current Dependencies`, and `User Stories` sections but includes `Existing Decisions` listing `elixir` and `phoenix`.

- **Criterion 5273 — Populated project's prompt includes architecture, deps, and story context:**
  Given a project with a `mix.exs`, at least one component, and at least one story titled "Fleet manager suspends a driver card", when `start_task` runs, then the prompt includes `Architecture Overview`, `Current Dependencies`, and `User Stories` sections with the story title verbatim.

- **Criterion 5274 — Prompt lays out identify, research, ADR, update index, stop:**
  Given any session, when `start_task` returns the prompt, then it contains:
  - Reference to `priv/knowledge/technical_strategy/workflow.md`
  - The decisions directory path `.code_my_spec/architecture/decisions/`
  - The decisions index path `.code_my_spec/architecture/decisions.md`
  - A `stop` instruction

- **Criterion 5275 — Evaluate passes when the decisions index exists:**
  Given `start_task` has run and `.code_my_spec/architecture/decisions.md` exists, when `evaluate_task` is called, then the response signals passing (matches `passed|completed|satisfied|valid`).

- **Criterion 5276 — Missing decisions index yields needs-work feedback referencing the expected path:**
  Given `start_task` has run but `.code_my_spec/architecture/decisions.md` does NOT exist, when `evaluate_task` is called, then the response signals failure (matches `needs work|incomplete|missing|invalid`) and names the expected path `.code_my_spec/architecture/decisions.md`.

Execute: `mix spex --no-color` and verify all 497 tests pass with 0 failures.

## Result Path

`.code_my_spec/qa/80/result.md`

## Setup Notes

The spex files in `test/spex/80_architecture_decision_records/` are not loaded by `mix test` (they don't match the `test_load_filters`). They are compiled by the `:spex` compiler and run via `mix spex`. This is by design — the spex runner handles the BDD lifecycle.

The implementation under test is `lib/code_my_spec/agent_tasks/technical_strategy.ex`. The `TechnicalStrategy.command/2` function writes pre-made ADRs as a side effect of `start_task` and builds the dynamic prompt. `TechnicalStrategy.evaluate/2` gates on the presence of `.code_my_spec/architecture/decisions.md`.
