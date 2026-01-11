# CodeMySpec.Content.Tag

Ecto schema representing content tags for categorization and organization. Tags have a many-to-many relationship with content items through a join table.

## Fields

| Field       | Type         | Required   | Description                        | Constraints              |
| ----------- | ------------ | ---------- | ---------------------------------- | ------------------------ |
| id          | integer      | Yes (auto) | Primary key                        | Auto-generated           |
| name        | string       | Yes        | Display name of the tag            | Min: 1, Max: 50          |
| slug        | string       | Yes        | URL-friendly identifier            | Unique (tags_slug_index) |
| content     | association  | No         | Content items with this tag        | many_to_many, on_replace: :delete |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp                 | Auto-generated           |
| updated_at  | utc_datetime | Yes (auto) | Last modification timestamp        | Auto-generated           |

## Functions

### changeset/2

Validates and casts tag attributes for create/update operations.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the `:name` and `:slug` fields from the input attributes
2. Validate that `:name` and `:slug` are present
3. Validate `:name` length is between 1 and 50 characters
4. Apply unique constraint on `:slug` using the `tags_slug_index` index

**Test Assertions**:
- returns valid changeset with valid name and slug
- returns invalid changeset when name is missing
- returns invalid changeset when slug is missing
- returns invalid changeset when name exceeds 50 characters
- returns invalid changeset when name is empty string
- enforces unique constraint on slug

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Content.Content