# CodeMySpec.Documents.Field

## Type

schema

Embedded schema representing a schema field from a spec document's Fields section. Used by FieldParser to store structured field metadata parsed from markdown tables.

## Fields

| Field       | Type   | Required | Description                              | Constraints      |
| ----------- | ------ | -------- | ---------------------------------------- | ---------------- |
| field       | string | Yes      | Field name identifier                    | Min: 1, Max: 255 |
| type        | string | Yes      | Ecto type of the field                   |                  |
| required    | string | Yes      | Whether the field is required            |                  |
| description | string | No       | Human-readable field description         |                  |
| constraints | string | No       | Validation constraints (length, format)  |                  |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
