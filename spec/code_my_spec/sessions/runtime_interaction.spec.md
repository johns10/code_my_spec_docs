# CodeMySpec.Sessions.RuntimeInteraction

**Type**: module

Ephemeral runtime state for interactions executing asynchronously. Holds non-durable status updates from agent hook callbacks that provide real-time visibility into interaction execution. Uses Ecto embedded schema with changesets for clean partial updates. Not persisted to the database - only lives in the InteractionRegistry.

## Fields

| Field             | Type             | Required | Description                              | Constraints         |
| ----------------- | ---------------- | -------- | ---------------------------------------- | ------------------- |
| interaction_id    | binary_id        | Yes      | Unique identifier for the interaction   | Required            |
| agent_state       | string           | No       | Current state of the agent               |                     |
| last_notification | map              | No       | Most recent notification from agent      |                     |
| last_activity     | map              | No       | Most recent activity update from agent   |                     |
| last_stopped      | map              | No       | Most recent stopped event from agent     |                     |
| conversation_id   | string           | No       | Identifier for the agent conversation    |                     |
| timestamp         | utc_datetime_usec | Yes (auto) | Last update timestamp                  | Auto-generated      |

## Functions

### changeset/2

Creates a changeset for a RuntimeInteraction. Only includes fields present in attrs - enables natural partial updates.

```elixir
@spec changeset(%RuntimeInteraction{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast all fields from attrs (interaction_id, agent_state, last_notification, last_activity, last_stopped, conversation_id, timestamp)
2. Validate interaction_id is required
3. Set timestamp to current UTC time if not explicitly provided

**Test Assertions**:
- creates valid changeset with interaction_id
- returns error changeset when interaction_id is missing
- auto-generates timestamp when not provided
- preserves explicit timestamp when provided
- allows partial updates with subset of fields

### new/2

Creates a new RuntimeInteraction from attrs.

```elixir
@spec new(binary(), map()) :: %RuntimeInteraction{}
```

**Process**:
1. Merge interaction_id into attrs map
2. Build changeset from empty struct with merged attrs
3. Apply changes to return struct

**Test Assertions**:
- creates RuntimeInteraction with interaction_id
- creates RuntimeInteraction with additional attrs
- creates RuntimeInteraction with default timestamp
- creates RuntimeInteraction with empty attrs

### update/2

Updates a RuntimeInteraction with new attributes. Only updates fields present in attrs - other fields are preserved.

```elixir
@spec update(%RuntimeInteraction{}, map()) :: %RuntimeInteraction{}
```

**Process**:
1. Build changeset from existing struct with new attrs
2. Apply changes to return updated struct

**Test Assertions**:
- updates specified fields while preserving others
- updates timestamp on each update
- allows explicit nil values to clear fields
- handles empty attrs map

### to_map/1

Convert RuntimeInteraction to a plain map.

```elixir
@spec to_map(%RuntimeInteraction{}) :: map()
```

**Process**:
1. Convert struct to map using Map.from_struct

**Test Assertions**:
- converts RuntimeInteraction to map with all fields
- returns map without __struct__ key

## Dependencies

- Ecto.Schema
- Ecto.Changeset
