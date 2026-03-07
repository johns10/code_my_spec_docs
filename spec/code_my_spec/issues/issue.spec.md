# CodeMySpec.Issues.Issue

## Type

schema

Ecto schema representing a QA issue or braindump item. Issues track defects, improvements, and observations discovered during QA testing or captured from braindump files. Each issue has a severity-based lifecycle (incoming → accepted/dismissed → resolved) and is scoped to an account and project. Issues can be linked to a specific story via story_id.

## Fields

| Field        | Type                                                    | Required   | Description                                 | Constraints                              |
| ------------ | ------------------------------------------------------- | ---------- | ------------------------------------------- | ---------------------------------------- |
| id           | binary_id                                               | Yes (auto) | Primary key (UUID)                          | Auto-generated                           |
| title        | string                                                  | Yes        | Short title describing the issue            | Unique per project + story_id            |
| severity     | enum (:critical, :high, :medium, :low, :info)           | Yes        | Impact severity                             |                                          |
| scope        | enum (:app, :qa, :docs)                                 | No         | Area of the codebase affected               | Default: :app                            |
| description  | string                                                  | Yes        | Detailed description with reproduction info |                                          |
| status       | enum (:incoming, :accepted, :dismissed, :resolved)      | Yes        | Lifecycle status                            | Default: :incoming                       |
| resolution   | string                                                  | No         | Reason for dismissal or description of fix  |                                          |
| story_id     | integer                                                 | No         | Associated story ID                         |                                          |
| source_path  | string                                                  | No         | Path to the artifact that created this issue |                                         |
| project_id   | binary_id                                               | Yes        | Associated project identifier               |                                          |
| account_id   | binary_id                                               | Yes        | Associated account identifier               |                                          |
| inserted_at  | utc_datetime                                            | Yes (auto) | Creation timestamp                          | Auto-generated                           |
| updated_at   | utc_datetime                                            | Yes (auto) | Last update timestamp                       | Auto-generated                           |

## Dependencies

- Ecto.Schema
- Ecto.Changeset

## Functions

### changeset/2

Builds a changeset for creating or updating an issue.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast title, severity, scope, description, status, resolution, story_id, source_path
2. Validate required: title, severity, description
3. Validate severity inclusion in [:critical, :high, :medium, :low, :info]
4. Validate scope inclusion in [:app, :qa, :docs]
5. Validate status inclusion in [:incoming, :accepted, :dismissed, :resolved]
6. Add unique constraint on [:title, :story_id, :project_id]

**Test Assertions**:
- returns valid changeset when required fields are provided
- returns invalid changeset when title is missing
- returns invalid changeset when severity is missing
- returns invalid changeset when description is missing
- validates severity values
- validates scope values
- defaults scope to :app
- defaults status to :incoming
- enforces unique title per project + story_id
- allows nil story_id (for braindump issues)

### status_changeset/2

Builds a changeset for status transitions only.

```elixir
@spec status_changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast only status and resolution
2. Validate required: status
3. Validate status transition is valid

**Test Assertions**:
- allows incoming → accepted transition
- allows incoming → dismissed transition (requires resolution)
- allows accepted → resolved transition (requires resolution)
- rejects invalid transitions (e.g., dismissed → accepted)
- only casts status and resolution fields

### severity_index/1

Returns a numeric index for severity ordering (lower = more severe).

```elixir
@spec severity_index(atom()) :: integer()
```

**Test Assertions**:
- critical returns 0
- high returns 1
- medium returns 2
- low returns 3
- info returns 4
