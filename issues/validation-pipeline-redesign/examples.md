# Validation Pipeline — Examples

## Rule: Changed files determine what analysis runs

- Task Agent stops after modifying two implementation files
- Task Agent stops after only reading files, no modifications
- Freestyle Agent stops after FileWatcher saw changes to a test file
- Freestyle Agent stops with no changes on disk at all

## Rule: Blocking check always runs, regardless of whether analysis ran

- Task Agent stops with no changes but compiler errors from a previous run are in the DB
- Freestyle Agent stops with no changes but credo violations from a previous run are in the DB
- Task Agent stops with no changes and no problems in the DB

## Rule: Compilation blocks before anything else runs

- Compilation produces one error, stop is blocked, no credo or tests run
- Compilation produces one warning, stop is blocked
- Compilation passes clean, pipeline continues to analyzers

## Rule: Credo blocks only on violations in changed files

- Agent changed file A, credo finds violation on file A, stop is blocked
- Agent changed file A, credo finds violation only on untouched file B, stop is allowed
- Agent changed files A and B, credo finds violations on both, both are listed in the block reason

## Rule: Default blocking mode is block-all for tests

- mix test --stale finds 3 failures on the agent's component, stop is blocked
- mix test --stale finds failures only on a different component the agent didn't touch, stop is still blocked
- mix test --stale passes clean, stop is allowed

## Rule: Spex defaults to off, opt-in only via task module

- Task Agent on a ComponentCode task (no spex in analyzers/0), spex does not run
- Task Agent on a WriteBddSpecs task (spex_stale in analyzers/0), spex runs
- Freestyle Agent, spex never runs regardless of what files changed

## Rule: Test/spex execution errors are treated as blocking problems

- mix test --stale crashes because test_helper.exs has a syntax error
- mix spex --stale returns a parse error

## Rule: Freestyle Agent is blocked by problems only, not requirements

- Freestyle Agent stops with unsatisfied requirements but no problems, stop is allowed
- Freestyle Agent stops with test failures in the DB, stop is blocked
- Task Agent stops with unsatisfied requirements, stop is blocked (evaluation runs)
