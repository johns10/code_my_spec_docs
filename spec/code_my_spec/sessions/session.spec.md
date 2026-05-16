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
