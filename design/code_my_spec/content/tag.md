# Tag Schema

## Purpose

Ecto schema representing content tags for categorizing and organizing content entities. Tags are normalized to lowercase slugified format for consistency and scoped to account and project for multi-tenant isolation. Tags enable flexible content organization through many-to-many relationships.

## Field Documentation

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| name | string | yes | Display name of the tag | Length 1-50 characters |
| slug | string | yes | URL-safe normalized identifier | Lowercase, slugified, unique per project |
| project_id | integer | yes | Foreign key for multi-tenant project isolation | References projects.id |
| account_id | integer | yes | Foreign key for multi-tenant account isolation | References accounts.id |

## Associations

### belongs_to
- **project** - References projects.id, cascade delete. Tags are deleted when project is deleted.
- **account** - References accounts.id, cascade delete. Tags are deleted when account is deleted.

### many_to_many
- **content** - Tags can be associated with multiple content items through the ContentTag join table

## Validation Rules

### Name Validation
- Required field
- Minimum length: 1 character
- Maximum length: 50 characters
- Automatically normalized to lowercase during processing

### Slug Validation
- Generated automatically from name using slugification
- Normalized to lowercase
- URL-safe characters only (alphanumeric, hyphens)
- Unique within project_id and account_id scope

### Multi-Tenancy
- project_id required (foreign key validation)
- account_id required (foreign key validation)
- All tag operations scoped by both account_id and project_id

## Database Constraints

### Indexes
- Primary key on id
- Unique composite index on (slug, project_id, account_id) for fast scoped lookups and uniqueness enforcement
- Index on project_id for join performance
- Index on account_id for join performance

### Unique Constraints
- Unique on (slug, project_id, account_id) - prevents duplicate tags within same project/account scope

### Foreign Keys
- project_id references projects.id, on_delete: cascade
- account_id references accounts.id, on_delete: cascade

## Business Rules

1. **Tag Normalization**: All tag names are automatically converted to lowercase and slugified for the slug field to ensure consistency
2. **Scoped Uniqueness**: Tag slugs must be unique within the combination of account_id and project_id, allowing different projects to have tags with the same name
3. **Automatic Cleanup**: When projects or accounts are deleted, associated tags are automatically removed via cascade delete
4. **Case Insensitive**: Tag matching in upsert operations is case-insensitive since slugs are normalized
5. **Multi-Tenant Isolation**: All tag queries must filter by both account_id and project_id to maintain proper tenant boundaries