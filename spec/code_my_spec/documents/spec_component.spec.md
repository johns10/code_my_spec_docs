# CodeMySpec.Documents.SpecComponent

**Type**: schema

Embedded schema representing a component reference from a context design document. Contains module name and description for components listed in the Components section of context specs.

## Fields

| Field       | Type   | Required | Description                                    | Constraints      |
| ----------- | ------ | -------- | ---------------------------------------------- | ---------------- |
| module_name | string | Yes      | Fully qualified Elixir module name             | Min: 1, Max: 255 |
| description | string | No       | Human-readable description of the component    |                  |

## Functions

### changeset/1

```elixir
@spec changeset(map()) :: Ecto.Changeset.t()
```

Build a changeset for a new SpecComponent struct with validation.

**Process**:
1. Create a new SpecComponent struct
2. Cast attrs to module_name and description fields
3. Validate that module_name is present

**Test Assertions**:
- changeset/1 returns valid changeset with module_name provided
- changeset/1 returns invalid changeset when module_name is missing
- changeset/1 accepts optional description
- changeset/1 allows nil for description field

### changeset/2

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

Build a changeset for an existing SpecComponent struct with validation.

**Process**:
1. Cast attrs to module_name and description fields
2. Validate that module_name is present

**Test Assertions**:
- changeset/2 returns valid changeset with module_name provided
- changeset/2 returns invalid changeset when module_name is missing
- changeset/2 updates existing struct with new values
- changeset/2 accepts optional description
- changeset/2 allows nil for description field
- changeset/2 preserves existing values when not provided in attrs

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder