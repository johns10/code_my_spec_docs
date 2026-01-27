# CodeMySpec.Tests.TestStats

Embedded schema for capturing ExUnit test execution statistics and timing information. This struct is used within TestRun to aggregate test results and provides a standardized representation of test suite performance metrics.

## Fields

| Field        | Type             | Required   | Description                                      | Constraints      |
| ------------ | ---------------- | ---------- | ------------------------------------------------ | ---------------- |
| duration_ms  | integer          | No         | Total execution time in milliseconds             | Non-negative     |
| load_time_ms | integer          | No         | Test loading time in milliseconds                | Non-negative     |
| passes       | integer          | No         | Number of passed tests                           | Default: 0       |
| failures     | integer          | No         | Number of failed tests                           | Default: 0       |
| pending      | integer          | No         | Number of pending tests                          | Default: 0       |
| invalid      | integer          | No         | Number of invalid tests                          | Default: 0       |
| tests        | integer          | No         | Total number of tests executed                   | Default: 0       |
| suites       | integer          | No         | Total number of test suites executed             | Default: 0       |
| started_at   | naive_datetime   | No         | Timestamp when test execution started            | ISO8601 format   |
| finished_at  | naive_datetime   | No         | Timestamp when test execution finished           | ISO8601 format   |

## Functions

### changeset/2

Creates a changeset for TestStats with special handling for JSON field mapping from ExUnit JSON formatter output.

```elixir
@spec changeset(t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast standard integer fields (duration_ms, load_time_ms, passes, failures, pending, invalid, tests, suites)
2. Cast datetime fields (started_at, finished_at)
3. Apply JSON field mapping transformations to handle ExUnit formatter's JSON keys
4. Map "duration" JSON key to duration_ms field with rounding
5. Map "loadTime" JSON key to load_time_ms field with rounding
6. Map "start" ISO8601 string to started_at NaiveDateTime
7. Map "end" ISO8601 string to finished_at NaiveDateTime

**Test Assertions**:
- accepts empty attributes and returns valid changeset
- casts all standard integer fields correctly
- casts datetime fields correctly
- maps JSON "duration" field to duration_ms with rounding
- maps JSON "loadTime" field to load_time_ms with rounding
- maps JSON "start" ISO8601 string to started_at NaiveDateTime
- maps JSON "end" ISO8601 string to finished_at NaiveDateTime
- handles nil values for optional JSON fields
- handles invalid ISO8601 datetime strings gracefully
- handles non-numeric duration values gracefully
- handles non-numeric loadTime values gracefully
- sets default values (0) for count fields when not provided

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
- NaiveDateTime
