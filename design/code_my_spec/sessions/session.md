# Sessions.Session Schema

## Purpose

Represents a tracked AI-assisted development session with workflow state, tracking the session type, execution status, agent configuration, and the complete history of command/result interactions as embedded documents.

## Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | integer | Yes (auto) | Primary key | Auto-generated |
| type | SessionType | Yes | Session workflow type  | Must be valid session type module |
| agent | enum | No | AI agent used for session | Values: :claude_code |
| environment | enum | No | Execution environment | Values: :local, :vscode |
| status | enum | No | Session lifecycle status | Values: :active, :complete, :failed (default: :active) |
| state | map | No | Session-type-specific state storage | JSONB field for flexible state |
| project_id | integer | No | Associated project | References projects.id |
| account_id | integer | Yes | Owning account for scoping | References accounts.id |
| component_id | integer | No | Associated component (if applicable) | References components.id |
| interactions | array | No | Embedded interaction history | Array of Interaction embedded schemas |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp | Auto-generated |
| updated_at | utc_datetime | Yes (auto) | Last update timestamp | Auto-generated |

## Associations

### belongs_to
- **project** - References projects.id for project scoping
- **account** - References accounts.id for multi-tenancy, required
- **component** - References components.id for component-specific sessions

### embeds_many
- **interactions** - Embedded Interaction schemas containing command/result pairs

## Validation Rules

### Required Fields
- `type` - Must be present to determine session workflow
- `account_id` - Automatically set from Scope, enforces multi-tenancy

### Type Validation
- `type` - Must be a valid SessionType (custom Ecto.Type validates against allowed session modules)

### Scope Integration
- `account_id` - Always set from `user_scope.active_account.id` in changeset
- `project_id` - Always set from `user_scope.active_project.id` in changeset

### Embedded Schema Casting
- `interactions` - Cast and validated through Interaction.changeset/2

## Database Constraints

### Indexes
- Primary key on id
- Index on account_id for scoped queries
- Index on project_id for project filtering
- Index on component_id for component filtering
- Composite index on (account_id, status) for active session queries

### Foreign Keys
- account_id references accounts.id, on_delete: restrict (preserve session history)
- project_id references projects.id, on_delete: nilify
- component_id references components.id, on_delete: nilify

### Check Constraints
- status must be one of: active, complete, failed
- agent must be one of: claude_code
- environment must be one of: local, vscode