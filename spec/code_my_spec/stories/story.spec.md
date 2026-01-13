# CodeMySpec.Stories.Story

Ecto schema representing user stories in the system. Stories capture requirements with titles, descriptions, and acceptance criteria. Each story is scoped to an account and project, and can be optionally linked to a component. Stories support locking mechanisms for concurrent editing protection and integrate with PaperTrail for version tracking.

## Fields

| Field            | Type                                       | Required   | Description                              | Constraints                              |
| ---------------- | ------------------------------------------ | ---------- | ---------------------------------------- | ---------------------------------------- |
| id               | integer                                    | Yes (auto) | Primary key                              | Auto-generated                           |
| title            | string                                     | Yes        | Title of the story                       | Unique per project                       |
| description      | string                                     | Yes        | Detailed description of the story        |                                          |
| acceptance_criteria | list(string)                            | Yes        | List of acceptance criteria              |                                          |
| status           | enum (:in_progress, :completed, :dirty)    | No         | Current status of the story              |                                          |
| locked_at        | utc_datetime                               | No         | Timestamp when story was locked          |                                          |
| lock_expires_at  | utc_datetime                               | No         | Timestamp when lock expires              |                                          |
| locked_by        | id                                         | No         | User ID who locked the story             |                                          |
| project_id       | binary_id                                  | No         | Associated project identifier            |                                          |
| account_id       | id                                         | No         | Associated account identifier            |                                          |
| component        | belongs_to Component                       | No         | Associated component                     | References components.id, binary_id      |
| first_version    | belongs_to PaperTrail.Version              | No         | Initial version for audit trail          |                                          |
| current_version  | belongs_to PaperTrail.Version              | No         | Current version for audit trail          | on_replace: :update                      |
| inserted_at      | utc_datetime                               | Yes (auto) | Creation timestamp                       | Auto-generated                           |
| updated_at       | utc_datetime                               | Yes (auto) | Last update timestamp                    | Auto-generated                           |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Components.Component
- PaperTrail.Version

## Functions

### changeset/2

Builds a changeset for creating or updating a story with the given attributes.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast title, description, acceptance_criteria, status, locked_at, lock_expires_at, locked_by, project_id, and component_id attributes from the input map
2. Validate that title, description, and acceptance_criteria are required
3. Add foreign key constraint on component_id with custom error message
4. Add unique constraint on title scoped to project_id

**Test Assertions**:
- returns valid changeset when title, description, and acceptance_criteria are provided
- returns invalid changeset when title is missing
- returns invalid changeset when description is missing
- returns invalid changeset when acceptance_criteria is missing
- allows empty acceptance_criteria list
- allows nil status
- allows status values :in_progress, :completed, and :dirty
- validates component_id references an existing component
- enforces unique title constraint within the same project
- allows duplicate titles across different projects
- casts locking fields (locked_at, lock_expires_at, locked_by)

### lock_changeset/2

Builds a changeset specifically for updating story lock fields.

```elixir
@spec lock_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast only locked_at, lock_expires_at, and locked_by attributes from the input map

**Test Assertions**:
- returns valid changeset when lock fields are provided
- returns valid changeset when clearing lock fields with nil values
- only casts lock-related fields, ignoring other attributes
- does not require any fields