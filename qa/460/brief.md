# Qa Story Brief

## Tool

mix spex (Elixir spex runner for BDD spec execution)

## Auth

No auth required. The spex test suite uses the test database sandbox and runs against
the app's internal module interfaces. No browser session or OAuth token needed.

Run the specs with:
```
mix spex test/spex/460_bdd_specification_lifecycle/
```

## Seeds

No seed data required. The spex files use in-memory environments and
`CodeMySpecSpex.SharedGivens` to set up test state through the app surface.
Ensure the test database is migrated and the app compiles:

```
mix ecto.migrate
mix compile
```

## What To Test

All scenarios are exercised by running the 8 spex files in
`test/spex/460_bdd_specification_lifecycle/`. The acceptance criteria map 1:1 to spec files:

- **Criterion 5530 — Three-criterion story produces three spec paths in the start_task prompt**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5530_*.exs`
  Expected: the prompt from `start_task` for `bdd_specs_exist` names exactly three
  harness-assigned paths, each starting with `test/spex/<story_id>_<slug>/`.

- **Criterion 5531 — Missing spec file is reported with criterion id and expected path**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5531_*.exs`
  Expected: `evaluate_task` called when two of three spec files exist returns "Needs work"
  naming criterion id, description, and the missing file path.

- **Criterion 5536 — Valid spec set → evaluate_task passes**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5536_*.exs`
  Expected: `evaluate_task` with all criteria having valid spec files returns
  "WriteBddSpecs: Passed" and no failure feedback.

- **Criterion 5537 — Spec with no scenarios → "Must contain at least one scenario"**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5537_*.exs`
  NOTE: The spec's moduledoc marks this KNOWN-RED — the unified Evaluator path
  doesn't reach `WriteBddSpecs.evaluate/2` today.
  Expected: "Needs work" + "Must contain at least one scenario" + criterion id.

- **Criterion 5538 — Scenario with no steps → "All scenarios must have Given/When/Then steps"**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5538_*.exs`
  NOTE: The spec's moduledoc marks this KNOWN-RED — same gap as 5537.
  Expected: "Needs work" + "All scenarios must have Given/When/Then steps" + criterion id.

- **Criterion 5539 — Compilation failure → "Compilation failed" + file:line diagnostic**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5539_*.exs`
  Expected: "Needs work" + "Compilation failed" + spec path with line number.

- **Criterion 5556 — Prompt scaffold opens with `use <App>Spex.Case` for every component type**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5556_*.exs`
  Expected: Both context and LiveView component prompts contain `use <App>Spex.Case`,
  no `use <App>Web.ConnCase`, no `import Phoenix.LiveViewTest`, no `import Phoenix.ConnTest`.

- **Criterion 5557 — ConnCase-only spec → evaluator surfaces missing SpexCase requirement**
  Run `mix spex test/spex/460_bdd_specification_lifecycle/criterion_5557_*.exs`
  Expected: "Needs work" + references `<App>Spex.Case` + names spec path + criterion id.

Run all 8 together to see aggregate results:
```
mix spex test/spex/460_bdd_specification_lifecycle/
```

Watch for:
- All 8 test scenarios pass (green dots)
- No unexpected failures beyond the KNOWN-RED scenarios (5537, 5538)
- If 5537 and 5538 actually pass, that means the wiring gap has been fixed — note it as a positive finding
- Compilation warnings are acceptable; compilation errors are not

## Result Path

.code_my_spec/qa/460/result.md
