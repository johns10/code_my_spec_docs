# CodeMySpec.Components.Dependency

Ecto schema representing a directed dependency relationship between two components.
Models "source depends on target" semantics where the source component requires
the target component to function.

## Fields

| Field               | Type       | Required   | Description                      | Constraints                   |
| ------------------- | ---------- | ---------- | -------------------------------- | ----------------------------- |
| id                  | integer    | Yes (auto) | Primary key                      | Auto-generated                |
| source_component_id | binary_id  | Yes        | Component that has the dependency | References components.id      |
| target_component_id | binary_id  | Yes        | Component being depended upon    | References components.id      |
| inserted_at         | utc_datetime | Yes (auto) | Creation timestamp             | Auto-generated                |
| updated_at          | utc_datetime | Yes (auto) | Last update timestamp          | Auto-generated                |

## Dependencies

- CodeMySpec.Components.Component

## Functions

### changeset/2

Creates a changeset for a dependency with validation rules.

```elixir
@spec changeset(%Dependency{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast source_component_id and target_component_id from attributes
2. Validate both fields are required
3. Validate source and target are not the same component (no self-dependency)
4. Add unique constraint on source/target pair
5. Add foreign key constraints for both component references

**Test Assertions**:
- creates valid changeset with valid source and target component IDs
- returns error changeset when source_component_id is missing
- returns error changeset when target_component_id is missing
- returns error changeset when source and target are the same (self-dependency)
- returns error changeset for duplicate source/target pair
- returns error changeset with invalid source_component_id foreign key
- returns error changeset with invalid target_component_id foreign key