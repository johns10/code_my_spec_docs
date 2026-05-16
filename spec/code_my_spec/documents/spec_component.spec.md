# CodeMySpec.Documents.SpecComponent

## Type

schema

Embedded schema representing a component reference from a context design document. Contains module name and description for components listed in the Components section of context specs.

## Fields

| Field       | Type   | Required | Description                                    | Constraints      |
| ----------- | ------ | -------- | ---------------------------------------------- | ---------------- |
| module_name | string | Yes      | Fully qualified Elixir module name             | Min: 1, Max: 255 |
| description | string | No       | Human-readable description of the component    |                  |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
