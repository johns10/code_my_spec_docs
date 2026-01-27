# CodeMySpec.Tests.TestResult

Embedded Ecto schema representing an individual test result from ExUnit execution. Captures test metadata (title, full title), execution outcome (passed/failed), and error details for failures. Used within TestRun to track test execution results.

## Fields

| Field      | Type                | Required | Description                                      | Constraints        |
| ---------- | ------------------- | -------- | ------------------------------------------------ | ------------------ |
| title      | string              | No       | Test description/title                           | None               |
| full_title | string              | No       | Complete test title including describe blocks    | None               |
| status     | enum                | No       | Test execution status                            | Values: passed, failed |
| error      | TestError (embedded)| No       | Error details if test failed                     | Embedded schema    |

## Functions

### changeset/2

Creates a changeset for casting and validating TestResult attributes.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast scalar attributes (title, full_title, status) from the provided attrs map
2. Cast the embedded error association using TestError.changeset/2
3. Return the changeset for validation and insertion

**Test Assertions**:
- casts valid attributes successfully
- casts status as enum with valid values (:passed, :failed)
- casts embedded error with TestError changeset
- returns valid changeset for valid data
- handles nil error field correctly
- validates status must be one of allowed enum values

## Dependencies

- CodeMySpec.Tests.TestError
- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
