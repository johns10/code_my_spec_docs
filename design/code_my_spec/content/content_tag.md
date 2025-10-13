# ContentAdminTag Schema

## Purpose

Represents the many-to-many join table between ContentAdmin and Tag entities, enabling content_admin to be associated with multiple tags and tags to be applied across multiple content_admin items within the same project and account scope.

## Field Documentation

| Field            | Type         | Required | Description                  | Constraints                              |
| ---------------- | ------------ | -------- | ---------------------------- | ---------------------------------------- |
| id               | integer      | Yes      | Primary key                  | Auto-incrementing                        |
| content_admin_id | integer      | Yes      | Foreign key to content_admin | Must reference existing content_admin.id |
| tag_id           | integer      | Yes      | Foreign key to tag           | Must reference existing tag.id           |
| inserted_at      | utc_datetime | Yes      | Record creation timestamp    | Auto-set by Ecto                         |
| updated_at       | utc_datetime | Yes      | Record update timestamp      | Auto-set by Ecto                         |

## Associations

### belongs_to

- **content_admin** - References content_admin.id, cascade delete when content_admin is removed
- **tag** - References tag.id, cascade delete when tag is removed

## Validation Rules

### Association Validation
- content_admin_id required
- tag_id required
- Both foreign keys must reference existing records

### Business Rules
- A content_admin item can have the same tag only once (enforced by unique constraint)
- Tags and content_admin must belong to the same account and project (enforced through parent relationships)

## Database Constraints

### Indexes
- Primary key on id
- Index on content_admin_id for efficient content_admin-to-tags queries
- Index on tag_id for efficient tag-to-content_admin queries
- Composite unique index on (content_admin_id, tag_id) to prevent duplicate associations

### Unique Constraints
- Unique on (content_admin_id, tag_id) - prevents duplicate tag assignments to the same content_admin

### Foreign Keys
- content_admin_id references content_admin.id, on_delete: delete_all (cascade)
- tag_id references tags.id, on_delete: delete_all (cascade)

## Implementation Notes

This is a pure join table with minimal additional logic. The schema exists primarily to establish the many_to_many relationship while maintaining referential integrity. Multi-tenancy scoping is enforced through the parent ContentAdmin and Tag relationships rather than denormalizing account_id and project_id into this table.

When content_admin is deleted, all associated ContentAdminTag records are automatically removed via cascade. Similarly, when a tag is deleted, all its content_admin associations are cleaned up automatically.