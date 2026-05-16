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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
- NaiveDateTime
