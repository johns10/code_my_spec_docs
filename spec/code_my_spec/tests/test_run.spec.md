# CodeMySpec.Tests.TestRun

Embedded schema representing a single test execution run with execution metadata, test statistics, results, and failure details. Used throughout the system for test-driven development workflows, quality validation, and project requirement coordination.

## Delegates

None - this is a data structure module with only changeset functionality.

## Functions

### changeset/2

Creates or updates a TestRun changeset with provided attributes.

```elixir
@spec changeset(t() | map(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast scalar fields (project_path, command, exit_code, execution_status, seed, including, excluding, raw_output, executed_at)
2. Cast embedded stats association
3. Cast embedded tests collection with TestResult changeset
4. Cast embedded failures collection with TestResult changeset
5. Cast embedded pending collection with TestResult changeset
6. Return changeset with all validations applied

**Test Assertions**:
- accepts valid attributes for all scalar fields
- casts stats as embedded TestStats struct
- casts tests as collection of TestResult structs
- casts failures as collection of TestResult structs
- casts pending as collection of TestResult structs
- validates execution_status is one of: success, failure, timeout, error
- handles empty attributes gracefully
- preserves including/excluding as arrays of strings
- accepts NaiveDateTime for executed_at field

## Fields

| Field | Type | Required | Description | Constraints |
| --- | --- | --- | --- | --- |
| project_path | string | No | Absolute or relative path to the project where tests were executed | - |
| command | string | No | The exact mix command that was executed (e.g., "mix test --formatter ExUnitJsonFormatter") | - |
| exit_code | integer | No | Unix exit code from the test execution process | Non-negative integer |
| execution_status | enum | No | High-level execution outcome | Values: :success, :failure, :timeout, :error |
| seed | integer | No | ExUnit seed value used for test randomization | Non-negative integer |
| including | array of strings | No | List of tags or test patterns that were included in the run | Default: [] |
| excluding | array of strings | No | List of tags or test patterns that were excluded from the run | Default: [] |
| raw_output | string | No | Complete stdout/stderr output from the test execution | - |
| executed_at | naive_datetime | No | Timestamp when the test execution began | - |
| stats | TestStats | No | Embedded test statistics (duration, counts, timing) | - |
| tests | array of TestResult | No | All test results from the execution | - |
| failures | array of TestResult | No | Only the failed test results | - |
| pending | array of TestResult | No | Only the pending/skipped test results | - |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
- CodeMySpec.Tests.TestStats
- CodeMySpec.Tests.TestResult
