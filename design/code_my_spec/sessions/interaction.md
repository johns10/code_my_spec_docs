# Sessions.Interaction Schema

## Purpose

Represents a single command/result pair within a session workflow, tracking the command to be executed, its execution result, and completion timestamp as an embedded document within the Session schema.

## Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | binary_id | Yes (auto) | Primary key (UUID) | Auto-generated UUID |
| step_name | string | No | Human-readable step identifier | Descriptive name for workflow step |
| command | Command | Yes | Command to execute | Embedded Command schema |
| result | Result | No | Execution result (nil until completed) | Embedded Result schema, on_replace: :update |
| completed_at | utc_datetime | No | Completion timestamp | Set when result is added |

## Associations

### embeds_one
- **command** - Embedded Command schema defining what to execute (required)
- **result** - Embedded Result schema capturing execution outcome (nil when pending)

## Validation Rules

### Required Fields
- `command` - Must be present, defines the executable action

### Embedded Schema Casting
- `command` - Cast and validated through Command.changeset/2, required
- `result` - Cast and validated through Result.changeset/2, optional until completion

### Completion Logic
- `completed_at` - Automatically set to current UTC time when result is added
- Status derived from result presence: nil result = pending, non-nil result = completed

## Helper Functions

### Status Predicates
- `pending?(interaction)` - Returns true if result is nil
- `completed?(interaction)` - Returns true if result is non-nil
- `successful?(interaction)` - Returns true if completed and result.status == :ok
- `failed?(interaction)` - Returns true if completed and result.status == :error

### Construction
- `new_with_command(command)` - Creates new interaction with generated UUID, given command, nil result