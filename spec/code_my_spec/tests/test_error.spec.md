# CodeMySpec.Tests.TestError

Embedded schema representing test failure information from ExUnit test runs. Captures error details including file location, line number, and error message. Used within TestResult to provide detailed failure context.

## Fields

| Field   | Type    | Required | Description                                    | Constraints |
| ------- | ------- | -------- | ---------------------------------------------- | ----------- |
| file    | string  | No       | File path where the test failure occurred      | None        |
| line    | integer | No       | Line number in the file where error occurred   | Non-negative|
| message | string  | No       | Error message describing the test failure      | None        |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
