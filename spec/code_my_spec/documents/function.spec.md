# CodeMySpec.Documents.Function

## Type

schema

Embedded schema representing a function from a spec document. Used by the document parsing system to store structured function documentation including name, description, type specification, process steps, and test assertions.

## Fields

| Field           | Type     | Required | Description                                      | Constraints      |
| --------------- | -------- | -------- | ------------------------------------------------ | ---------------- |
| name            | string   | Yes      | Function name with arity (e.g. build/1)          | Min: 1, Max: 255 |
| description     | string   | No       | What the function does                           |                  |
| spec            | string   | No       | Elixir @spec type specification                  |                  |
| process         | string   | No       | Step-by-step process description                 |                  |
| test_assertions | [string] | No       | List of test assertions for the function         | Default: []      |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
