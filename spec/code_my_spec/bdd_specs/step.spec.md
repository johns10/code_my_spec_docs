# CodeMySpec.BddSpecs.Step

## Type

schema (non-persisted)

Struct representing a single Given/When/Then step within a scenario. Contains the step type, human-readable description, and source line number for traceability back to the original spec file.

## Fields

| Field       | Type    | Required | Description                                      | Constraints                          |
| ----------- | ------- | -------- | ------------------------------------------------ | ------------------------------------ |
| type        | atom    | Yes      | Step type indicator                              | Values: :given, :when, :then         |
| description | string  | Yes      | Human-readable description of the step           | -                                    |
| line        | integer | No       | Source line number in the spec file              | Used for error reporting and tracing |

## Dependencies

- Ecto.Schema
