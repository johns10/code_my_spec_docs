# CodeMySpec.Quality.Tdd

Validates test execution state for TDD workflows.

Handles parsing test results, validating test run data, and checking that tests are in the expected state (all failing for TDD test generation). Returns binary scores indicating whether the codebase is in the correct TDD state.

## Delegates

None

## Functions

### check_tdd_state/1

Checks test execution state from a command result and validates TDD compliance.

Parses test results, validates the test run data, and ensures all tests are failing (correct TDD state for test generation). Returns a binary score where 1.0 indicates all tests are failing (correct TDD state) and 0.0 indicates validation failures or passing tests.

```elixir
@spec check_tdd_state(map()) :: Result.t()
```

**Process**:
1. Extract test run data from the result map (handles both JSON strings and maps)
2. Validate the test run data against the TestRun schema using Ecto changesets
3. Verify that all tests are failing (failures > 0, passes = 0)
4. Return Result.ok() with score 1.0 if all checks pass
5. Return Result.error() with descriptive errors if any validation fails

**Test Assertions**:
- Returns score 1.0 when all tests are failing (TDD state correct)
- Returns score +0.0 when test results JSON is invalid
- Returns score +0.0 when test run data is missing from result
- Returns score +0.0 when test run data fails schema validation
- Returns score +0.0 when some tests are passing
- Returns score +0.0 when no tests were executed
- Handles test results as both JSON strings and decoded maps
- Includes descriptive error messages explaining TDD state violations

## Dependencies

- CodeMySpec.Quality.Result
- CodeMySpec.Tests.TestRun
- Jason
- Ecto.Changeset
