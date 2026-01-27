# CodeMySpec.Tests.TestError

Embedded schema representing test failure information from ExUnit test runs. Captures error details including file location, line number, and error message. Used within TestResult to provide detailed failure context.

## Fields

| Field   | Type    | Required | Description                                    | Constraints |
| ------- | ------- | -------- | ---------------------------------------------- | ----------- |
| file    | string  | No       | File path where the test failure occurred      | None        |
| line    | integer | No       | Line number in the file where error occurred   | Non-negative|
| message | string  | No       | Error message describing the test failure      | None        |

## Functions

### changeset/2

Creates an Ecto changeset for casting TestError attributes.

```elixir
@spec changeset(t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Accept a TestError struct (defaults to new struct) and attributes map
2. Cast the attributes for :file, :line, and :message fields
3. Return the changeset (no validations applied)

**Test Assertions**:
- casts valid attributes successfully
- handles nil file path
- handles nil line number
- casts string message field
- works with empty attributes map
- preserves existing struct values when not overridden

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
