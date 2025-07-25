# Stories Repository

## Purpose
Provides data access layer for Story entities with standardized CRUD operations, query builders, and transaction management.

## Core Operations

### Basic CRUD
- **create/2**: Insert new story with changeset validation
- **get/1**: Retrieve story by ID, returns {:ok, story} or {:error, :not_found}
- **get!/1**: Retrieve story by ID, raises if not found
- **update/2**: Update story with changeset validation
- **delete/1**: Remove story from database
- **list/1**: List all stories with optional filtering

### Query Builders
- **by_project/2**: Filter stories by project_id
- **by_status/2**: Filter stories by status enum
- **by_priority/2**: Filter stories with minimum priority
- **search_text/2**: Full-text search across title and description
- **locked_by/2**: Filter stories locked by specific user
- **lock_expired/1**: Find stories with expired locks

### Ordering and Pagination
- **ordered_by_priority/1**: Order by priority desc, then inserted_at
- **ordered_by_status/1**: Order by status workflow progression
- **paginate/3**: Apply limit/offset pagination to queries
- **with_preloads/2**: Eager load associated data

## Lock Management
- **acquire_lock/3**: Set lock fields on story (locked_by, locked_at, lock_expires_at)
- **release_lock/2**: Clear lock fields on story
- **extend_lock/3**: Update lock expiration timestamp
- **is_locked?/1**: Check if story has active lock
- **lock_owner/1**: Get user_id of lock owner

## Query Composition
Repository functions return Ecto.Query structs that can be composed:
```elixir
Story
|> Repository.by_project(project_id)
|> Repository.by_status(:draft)
|> Repository.ordered_by_priority()
|> Repository.paginate(page, per_page)
|> Repo.all()
```

## Error Handling
- Database constraint violations return {:error, changeset}
- Not found errors return {:error, :not_found}
- Lock conflicts return {:error, :already_locked}
- Transaction failures return {:error, :transaction_failed}

## Performance Considerations
- Queries use appropriate database indexes
- Preloading strategies defined for common access patterns
- Pagination limits prevent large result sets
- Query composition allows for efficient filtering

## Validation Layer
- All operations use Story.changeset/2 for validation
- Business rules enforced at changeset level
- Database constraints provide final safety net
- Lock validation ensures concurrency safety

## Dependencies
- **Ecto**: For database operations and query building
- **Story Schema**: For changeset validation and struct definition
- **Repo**: Application repository for database execution
- **Papertrail**: Uses papertrail to version all changes