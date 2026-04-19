# Project Configuration

## Story: Engineer configures quality gates for their project

An engineer controls what's required and what blocks through a local
ProjectConfiguration. No server-side policy. Their machine, their rules.

---

### Requirement Toggles

Scenario: Engineer turns off specs for rapid prototyping
  Given a project with default configuration (require_specs: true)
  When the engineer sets require_specs to false
  Then components no longer require a spec file to be considered done
  And the requirements graph updates to remove specification requirements

Scenario: Engineer requires specs but not design reviews
  Given a project with default configuration
  When the engineer sets require_reviews to false and keeps require_specs true
  Then components require a spec file
  And components do not require a design review file

Scenario: Engineer turns off unit tests
  Given a project with default configuration (require_unit_tests: true)
  When the engineer sets require_unit_tests to false
  Then the requirements graph removes test file and tests_passing requirements
  And the stop hook does not run mix test --stale

Scenario: Engineer turns everything off
  Given a project with default configuration
  When the engineer sets require_specs, require_reviews, and require_unit_tests to false
  Then only implementation file requirements remain in the graph

Scenario: Engineer re-enables unit tests
  Given a project with require_unit_tests set to false
  When the engineer sets require_unit_tests back to true
  Then test requirements reappear for all components

---

### Analyzer Configuration

Scenario: Default configuration is created on first use
  Given a project that has never had its configuration accessed
  When the stop hook fires for the first time
  Then a ProjectConfiguration record is created with defaults
  And compile_warnings is set to block
  And credo is set to block_changed
  And exunit is set to block_all
  And spex is set to off

Scenario: Engineer turns off credo during a large refactor
  Given a project with credo set to block_changed
  When the engineer sets credo to off
  Then credo does not run during the stop hook
  And no credo problems are persisted

Scenario: Engineer sets exunit to block_changed for a refactor
  Given a project with exunit set to block_all
  When the engineer sets exunit to block_changed
  And the agent modifies files in the Accounts component
  And mix test --stale finds failures in the Sessions component
  Then the test failures are persisted as problems
  But the stop is not blocked because the failures are on untouched components

Scenario: Engineer sets exunit to don't block
  Given a project with exunit set to dont_block
  When the agent stops and mix test --stale finds failures
  Then the test failures are persisted as problems
  But the stop is allowed regardless

Scenario: Engineer enables spex
  Given a project with spex set to off
  When the engineer sets spex to block_all
  Then mix spex --stale runs on every stop hook
  And any spex failure blocks the stop

Scenario: Engineer turns off compile warning blocking
  Given a project with compile_warnings set to block
  When the engineer sets compile_warnings to dont_block
  And the agent introduces an unused variable warning
  Then the stop is allowed
  But compiler errors still block

---

### Cheap Validations (Not Configurable)

Scenario: Spec file with missing required section blocks
  Given the agent modified a spec file during the task
  And the spec file is missing the required Dependencies section
  When the stop hook fires
  Then spec validation runs on the changed file
  And the stop is blocked with the validation error
  And this check is not affected by any configuration setting

Scenario: Spec validation only runs on changed spec files
  Given an existing spec file with validation errors
  And the agent did not modify that file
  When the stop hook fires
  Then spec validation does not run on the untouched file
  And the agent is not blocked by its errors

---

### Blocking Check Always Runs

Scenario: No changes but outstanding compiler errors block
  Given the agent made no file changes during the task
  And there are compiler error problems in the DB from a previous run
  When the stop hook fires
  Then no compilation runs (nothing changed)
  And no analyzers run
  But the blocking check still queries the problems table
  And the stop is blocked with the outstanding compiler errors

Scenario: No changes and no problems allows stop
  Given the agent made no file changes during the task
  And there are no problems in the DB
  When the stop hook fires
  Then the blocking check runs and finds nothing
  And the stop is allowed
