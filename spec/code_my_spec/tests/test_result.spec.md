# CodeMySpec.Tests.TestResult

Embedded Ecto schema representing an individual test result from ExUnit execution. Captures test metadata (title, full title), execution outcome (passed/failed), and error details for failures. Used within TestRun to track test execution results.

## Fields

| Field      | Type                | Required | Description                                      | Constraints        |
| ---------- | ------------------- | -------- | ------------------------------------------------ | ------------------ |
| title      | string              | No       | Test description/title                           | None               |
| full_title | string              | No       | Complete test title including describe blocks    | None               |
| status     | enum                | No       | Test execution status                            | Values: passed, failed |
| error      | TestError (embedded)| No       | Error details if test failed                     | Embedded schema    |

## Dependencies

- CodeMySpec.Tests.TestError
- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
