# CodeMySpec.Components.SimilarComponent

Ecto schema representing a similarity relationship between two components.
Similar components serve as design inspiration and context when creating or
modifying components, enabling pattern reuse and consistency.

## Fields

| Field                | Type         | Required   | Description                        | Constraints                  |
| -------------------- | ------------ | ---------- | ---------------------------------- | ---------------------------- |
| id                   | integer      | Yes (auto) | Primary key                        | Auto-generated               |
| component_id         | binary_id    | Yes        | Component receiving similar refs   | References components.id     |
| similar_component_id | binary_id    | Yes        | Component marked as similar        | References components.id     |
| inserted_at          | utc_datetime | Yes (auto) | Creation timestamp                 | Auto-generated               |
| updated_at           | utc_datetime | Yes (auto) | Last update timestamp              | Auto-generated               |

## Dependencies

- CodeMySpec.Components.Component

## Functions

### changeset/2

Creates a changeset for a similar component relationship with validation rules.

```elixir
@spec changeset(%SimilarComponent{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast component_id and similar_component_id from attributes
2. Validate both fields are required
3. Validate component cannot be marked as similar to itself (no self-similarity)
4. Add unique constraint on component_id/similar_component_id pair
5. Add foreign key constraints for both component references

**Test Assertions**:
- creates valid changeset with valid component and similar_component IDs
- returns error changeset when component_id is missing
- returns error changeset when similar_component_id is missing
- returns error changeset when component and similar_component are the same (self-similarity)
- returns error changeset for duplicate component/similar_component pair
- returns error changeset with invalid component_id foreign key
- returns error changeset with invalid similar_component_id foreign key
