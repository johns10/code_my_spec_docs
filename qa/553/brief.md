# Qa Story Brief

## Tool

mix spex (spex-only, no LiveView or HTTP surface)

## Auth

No auth required. Tests run via `mix spex` which boots the test environment directly.

## Seeds

No seeds required. Spex tests use `RecordingEnvironment` and tmp directories — no database fixtures needed.

## What To Test

Run all BDD spex files for story 553:

```
mix spex test/spex/553_project_configuration_local_quality_gate_settings/
```

Scenarios covered by the spex suite:

- Criterion 5081: Turning off specs removes spec requirements from the graph
- Criterion 5082: Turning off reviews keeps spec requirements but removes review requirements
- Criterion 5083: Turning off unit tests removes test_file and tests_passing requirements
- Criterion 5084: Turning off specs + reviews + unit tests leaves only implementation requirements
- Criterion 5085: Re-enabling unit tests after turning them off causes test requirements to reappear
- Criterion 5086: First access auto-creates ProjectConfiguration with defaults when none exists
- Criterion 5087: Setting credo to off prevents credo from running and blocks no stop
- Criterion 5088: exunit block_changed — test failures outside the task scope are persisted but do not block
- Criterion 5089: exunit dont_block — test failures are persisted but stop is always allowed
- Criterion 5090: Enabling spex causes mix spex --stale to run on every stop hook; spex failures block
- Criterion 5108: spec_validation off — validator does not run, no problems persisted
- Criterion 5109: qa_validation block_changed — stale problems on untouched qa files do not block
- Criterion 6028: credo block_all — scans whole project; violations in untouched files block
- Criterion 6029: credo block_changed — runs only on changed files; outside violations do not block
- Criterion 6030: credo dont_block — violations persisted but stop is allowed
- Criterion 6071: spec_validation block_changed — stale problems on untouched spec files do not block
- Criterion 6072: spec_validation block_all — stale problems on untouched spec files still block
- Criterion 6073: spec_validation dont_block — problems persisted but stop is always allowed
- Criterion 6075: compile_warnings off — compile warning blocking is disabled
- Criterion 6076: spec file with missing required section blocks when changed
- Criterion 6077: No changes but outstanding compiler errors block

## Result Path

`.code_my_spec/qa/553/result.md`
