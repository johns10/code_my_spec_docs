# CodeMySpec.Sessions.Session

## Type

schema

Embedded schema representing an agent task session. Serialized to/from JSON for filesystem storage — no database table. Uses Ecto embedded schema for casting and validation via changesets.

## Fields

| Field                    | Type    | Required | Description                              | Constraints                                                    |
| ------------------------ | ------- | -------- | ---------------------------------------- | -------------------------------------------------------------- |
| id                       | string  | Yes      | Session identifier                       | UUID, auto-generated on create                                 |
| type                     | string  | Yes      | Agent task module name                   | Must map to a valid AgentTasks module via SessionType           |
| priority                 | integer | No       | Evaluation order in the stack            | Higher = evaluated first. Derived from type if not set         |
| status                   | string  | Yes      | Lifecycle state                          | One of: active, complete, failed, cancelled. Default: active   |
| component_module_name    | string  | No       | Module name of the target component      | Set when task operates on a specific component                 |
| external_conversation_id | string  | No       | Claude Code conversation ID              | Links session to the agent conversation that created it        |
| state                    | map     | No       | Arbitrary task state                     | Agent task modules read/write task-specific data here          |

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
