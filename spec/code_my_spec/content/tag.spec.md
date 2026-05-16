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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Content.Content
