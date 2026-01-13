# CodeMySpec.Sessions.Interaction

**Type**: Schema

Ecto schema representing an interaction within a session. An interaction encapsulates a command to be executed and its result, forming the atomic unit of work in session-based workflows. Interactions track execution state through embedded command and result schemas, enabling audit trails and status queries for session orchestration.

## Fields

| Field              | Type                | Required   | Description                                      | Constraints                     |
| ------------------ | ------------------- | ---------- | ------------------------------------------------ | ------------------------------- |
| id                 | binary_id           | Yes (auto) | Primary key                                      | Auto-generated UUID             |
| session_id         | integer             | Yes        | Foreign key to parent session                    | References sessions.id          |
| step_name          | string              | No         | Name of the workflow step this interaction represents |                                 |
| command            | Command.t()         | Yes        | Embedded command to be executed                  | embeds_one, required            |
| result             | Result.t()          | No         | Embedded execution result                        | embeds_one, on_replace: :update |
| completed_at       | utc_datetime_usec   | No         | Timestamp when interaction completed             | Auto-set when result is present |
| interaction_events | [InteractionEvent.t()] | No      | Associated real-time events during execution     | has_many association            |
| inserted_at        | utc_datetime_usec   | Yes (auto) | Record creation timestamp                        | Auto-generated                  |
| updated_at         | utc_datetime_usec   | Yes (auto) | Record update timestamp                          | Auto-generated                  |

## Functions

### changeset/2

Validates and casts interaction attributes for create/update operations.

```elixir
@spec changeset(t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast session_id, step_name, and completed_at from input attributes
2. Cast embedded command schema (required)
3. Cast embedded result schema (optional)
4. Validate session_id is required
5. Add foreign key constraint for session_id
6. Auto-set completed_at timestamp when result is present and completed_at is nil

**Test Assertions**:
- returns valid changeset with valid session_id and command
- returns invalid changeset when session_id is missing
- returns invalid changeset when command is missing
- accepts result as optional embedded schema
- auto-sets completed_at when result is provided and completed_at is nil
- preserves existing completed_at when already set
- does not set completed_at when result is nil
- validates foreign key constraint on session_id

### new_with_command/1

Creates a new interaction struct with a pre-built command.

```elixir
@spec new_with_command(Command.t()) :: t()
```

**Process**:
1. Generate a new UUID for the interaction id
2. Set the command field to the provided command
3. Initialize result as nil
4. Initialize completed_at as nil

**Test Assertions**:
- returns interaction with generated UUID id
- returns interaction with provided command
- returns interaction with nil result
- returns interaction with nil completed_at

### pending?/1

Checks if an interaction is still awaiting execution result.

```elixir
@spec pending?(t()) :: boolean()
```

**Process**:
1. Check if the result field is nil
2. Return true if nil, false otherwise

**Test Assertions**:
- returns true when result is nil
- returns false when result is present

### completed?/1

Checks if an interaction has received an execution result.

```elixir
@spec completed?(t()) :: boolean()
```

**Process**:
1. Check if the result field is not nil
2. Return true if present, false otherwise

**Test Assertions**:
- returns true when result is present
- returns false when result is nil

### successful?/1

Checks if an interaction completed with success status.

```elixir
@spec successful?(t()) :: boolean()
```

**Process**:
1. Check if the interaction is completed
2. Check if the result status is :ok
3. Return true only if both conditions are met

**Test Assertions**:
- returns true when completed with :ok status
- returns false when completed with :error status
- returns false when completed with :warning status
- returns false when result is nil (pending)

### failed?/1

Checks if an interaction completed with error status.

```elixir
@spec failed?(t()) :: boolean()
```

**Process**:
1. Check if the interaction is completed
2. Check if the result status is :error
3. Return true only if both conditions are met

**Test Assertions**:
- returns true when completed with :error status
- returns false when completed with :ok status
- returns false when completed with :warning status
- returns false when result is nil (pending)

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Sessions.Command
- CodeMySpec.Sessions.Result
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.InteractionEvent
