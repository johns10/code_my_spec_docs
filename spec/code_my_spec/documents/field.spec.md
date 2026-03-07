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

## Functions

### changeset/2

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

Build a changeset for a Field struct with validation.

**Process**:
1. Cast attrs to field, type, required, description, and constraints
2. Validate that field, type, and required are present
3. Validate field name length is between 1 and 255 characters

**Test Assertions**:
- changeset/2 returns valid changeset with all required fields
- changeset/2 returns invalid changeset when field is missing
- changeset/2 returns invalid changeset when type is missing
- changeset/2 returns invalid changeset when required is missing
- changeset/2 returns invalid changeset when field name exceeds 255 characters
- changeset/2 returns invalid changeset when field name is empty
- changeset/2 accepts optional description and constraints
- changeset/2 allows nil for optional fields

## Dependencies

- Ecto.Schema
- Ecto.Changeset