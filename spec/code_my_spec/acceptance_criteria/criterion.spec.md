# CodeMySpec.AcceptanceCriteria.Criterion

Ecto schema representing a single acceptance criterion. Contains the description text, verification status, and belongs to a story. Scoped to account and project for multi-tenancy.

## Fields

| Field       | Type         | Required   | Description                                    | Constraints                      |
| ----------- | ------------ | ---------- | ---------------------------------------------- | -------------------------------- |
| id          | integer      | Yes (auto) | Primary key                                    | Auto-generated                   |
| description | string       | Yes        | The text content of the acceptance criterion   | Not blank                        |
| verified    | boolean      | No         | Whether the criterion has been verified        | Default: false                   |
| verified_at | utc_datetime | No         | Timestamp when the criterion was verified      | None                             |
| story_id    | integer      | Yes        | Foreign key to parent story                    | References stories.id            |
| project_id  | binary_id    | Yes        | UUID of the owning project for multi-tenancy   | Not blank                        |
| account_id  | integer      | Yes        | ID of the owning account for multi-tenancy     | Not blank                        |
| inserted_at | utc_datetime | Yes (auto) | Timestamp when record was created              | Auto-generated                   |
| updated_at  | utc_datetime | Yes (auto) | Timestamp when record was last updated         | Auto-generated                   |

## Functions

### changeset/2

Creates a changeset for creating or updating a criterion.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast all permitted attributes (description, verified, verified_at, story_id, project_id, account_id)
2. Validate required fields (description, story_id, project_id, account_id)
3. Return changeset

**Test Assertions**:
- accepts valid attributes with all required fields
- accepts criterion with verified status
- accepts criterion with verified_at timestamp
- accepts criterion with all fields populated
- defaults verified to false when not provided
- accepts nil verified_at
- requires description
- requires story_id
- requires project_id
- requires account_id
- rejects nil description
- rejects empty description
- rejects nil story_id
- rejects nil project_id
- rejects nil account_id

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Stories.Story