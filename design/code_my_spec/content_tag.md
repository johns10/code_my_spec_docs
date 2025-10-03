# ContentTag Schema

## Purpose

Represents the many-to-many join table between Content and Tag entities, enabling content to be associated with multiple tags and tags to be applied across multiple content items within the same project and account scope.

## Field Documentation

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | integer | Yes | Primary key | Auto-incrementing |
| content_id | integer | Yes | Foreign key to content | Must reference existing content.id |
| tag_id | integer | Yes | Foreign key to tag | Must reference existing tag.id |
| inserted_at | utc_datetime | Yes | Record creation timestamp | Auto-set by Ecto |
| updated_at | utc_datetime | Yes | Record update timestamp | Auto-set by Ecto |

## Associations

### belongs_to

- **content** - References content.id, cascade delete when content is removed
- **tag** - References tag.id, cascade delete when tag is removed

## Validation Rules

### Association Validation
- content_id required
- tag_id required
- Both foreign keys must reference existing records

### Business Rules
- A content item can have the same tag only once (enforced by unique constraint)
- Tags and content must belong to the same account and project (enforced through parent relationships)

## Database Constraints

### Indexes
- Primary key on id
- Index on content_id for efficient content-to-tags queries
- Index on tag_id for efficient tag-to-content queries
- Composite unique index on (content_id, tag_id) to prevent duplicate associations

### Unique Constraints
- Unique on (content_id, tag_id) - prevents duplicate tag assignments to the same content

### Foreign Keys
- content_id references content.id, on_delete: delete_all (cascade)
- tag_id references tags.id, on_delete: delete_all (cascade)

## Implementation Notes

This is a pure join table with minimal additional logic. The schema exists primarily to establish the many_to_many relationship while maintaining referential integrity. Multi-tenancy scoping is enforced through the parent Content and Tag relationships rather than denormalizing account_id and project_id into this table.

When content is deleted, all associated ContentTag records are automatically removed via cascade. Similarly, when a tag is deleted, all its content associations are cleaned up automatically.