# CodeMySpec.Sessions.Session

## Type

schema

Embedded schema representing an agent task session. Serialized to/from JSON for filesystem storage — no database table. Uses Ecto embedded schema for casting and validation via changesets.

## Fields

| Field                       | Type    | Required | Description                                      | Constraints                                                    |
| --------------------------- | ------- | -------- | ------------------------------------------------ | -------------------------------------------------------------- |
| id                          | uuid    | Yes      | Session identifier                               | UUID, auto-generated on create                                 |
| type                        | string  | No       | Agent task module name (session-level)           | Must map to a valid AgentTasks module via SessionType          |
| status                      | string  | Yes      | Lifecycle state                                  | One of: active, complete, failed, cancelled. Default: active   |
| component_module_name       | string  | No       | Module name of the target component              | Set when session targets a specific component                  |
| external_conversation_id    | string  | No       | Claude Code conversation ID                      | Links session to the agent conversation that created it        |
| state                       | map     | No       | Arbitrary session state                          | Currently used for `pending_tap_out` (Story 704)               |
| continuous                  | boolean | No       | Continuous-mode flag (Story 538)                 | Default: false. R2: read by the stop hook to gate continuation |
| last_eval_feedback_hash     | string  | No       | sha256 hex of the most recent evaluate_task feedback (Story 538 R8) | Set when evaluate_task returns `{:ok, :invalid, feedback}`; cleared on `{:ok, :valid}` |
| eval_feedback_count         | integer | No       | Consecutive matching-hash count (Story 538 R8)   | Default: 0. Incremented when new feedback hash matches `last_eval_feedback_hash`; reset to 1 on a different hash; cleared (→ 0) on `{:ok, :valid}`. When it reaches 5, the stop hook terminates continuous mode |
| tasks                       | array   | No       | Embedded list of `Sessions.Task` (units of work) | `embeds_many` JSONB. See `Sessions.Task`                       |
| subagents                   | array   | No       | Embedded list of `Sessions.Subagent` (Story 704) | `embeds_many` JSONB. TTL-pruned on read                        |
| project_id                  | uuid    | Yes      | Project scope                                    | Validated via `scoped_changeset`                               |
| account_id                  | uuid    | Yes      | Account scope                                    | Validated via `scoped_changeset`                               |
| user_id                     | integer | No       | Creating user                                    | Set when scope carries one                                     |
| component_id                | uuid    | No       | Component scope                                  | Optional foreign key                                           |

## Dependencies

- CodeMySpec.Sessions.SessionType

## Functions

### changeset/2

Build a changeset for creating or updating a session.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast fields from attrs
2. Validate type is required and maps to a valid agent task module
3. Generate id if not present
4. Default status to :active if not set

**Test Assertions**:
- casts valid attributes into changeset
- validates type is required
- auto-generates id when not provided
- defaults status to active
- rejects unknown type values

### to_json/1

Serialize a Session struct to a JSON-encodable map.

```elixir
@spec to_json(t()) :: map()
```

**Process**:
1. Convert struct to map
2. Convert atom values (type, status) to strings

**Test Assertions**:
- produces a map that roundtrips through Jason.encode/decode
- converts atom fields to strings

### from_json/1

Deserialize a JSON map into a Session struct.

```elixir
@spec from_json(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Cast the map through changeset/2
2. Apply the changeset to produce a struct

**Test Assertions**:
- reconstructs a Session struct from a JSON-decoded map
- returns error for invalid data
