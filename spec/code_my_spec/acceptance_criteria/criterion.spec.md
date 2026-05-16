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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Stories.Story
