# CodeMySpec.Sessions.Command

Embedded schema representing a command to be executed during a session. Commands encapsulate executable actions with their target module, execution strategy, and metadata. Used by session orchestration to track and dispatch work to session step modules.

## Fields

| Field              | Type                | Required   | Description                                      | Constraints                                |
| ------------------ | ------------------- | ---------- | ------------------------------------------------ | ------------------------------------------ |
| id                 | binary_id           | Yes (auto) | Primary key                                      | Auto-generated UUID                        |
| module             | CommandModuleType   | Yes        | Target step module to execute the command        | Must be a valid session step module        |
| execution_strategy | enum                | No         | How the command should be executed               | Values: :task, :async, :sync (default)     |
| command            | string              | Yes        | Command identifier (e.g., "claude", "spawn_sessions") | -                                    |
| pipe               | string              | No         | Pipe identifier for chaining commands            | -                                          |
| metadata           | map                 | No         | Additional data for command execution            | Default: %{}                               |
| timestamp          | utc_datetime_usec   | Yes (auto) | When the command was created                     | Auto-set to current UTC time               |

## Delegates

None.

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Sessions.CommandModuleType

## Functions

### changeset/1

Creates a changeset for a new Command struct with the given attributes.

```elixir
@spec changeset(map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the attributes for module, execution_strategy, command, pipe, and metadata fields
2. Validate that module and command are present
3. Set the timestamp to current UTC time if not already set

**Test Assertions**:
- returns valid changeset when module and command are provided
- returns invalid changeset when module is missing
- returns invalid changeset when command is missing
- auto-generates timestamp when not provided
- preserves existing timestamp when already set
- accepts valid execution_strategy values (:task, :async, :sync)
- rejects invalid execution_strategy values

### changeset/2

Creates a changeset for an existing Command struct with the given attributes.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the attributes for module, execution_strategy, command, pipe, and metadata fields onto the existing struct
2. Validate that module and command are present
3. Set the timestamp to current UTC time if not already set

**Test Assertions**:
- updates existing command with new attributes
- validates required fields on existing command

### new/2

Creates a new Command struct with the given module and command.

```elixir
@spec new(module(), String.t()) :: t()
```

**Process**:
1. Build a new Command struct with the provided module and command
2. Set execution_strategy to :sync (default)
3. Set metadata to empty map
4. Set timestamp to current UTC time

**Test Assertions**:
- creates command with specified module and command
- sets default execution_strategy to :sync
- sets default metadata to empty map
- sets timestamp to current time

### new/3

Creates a new Command struct with the given module, command, and options.

```elixir
@spec new(module(), String.t(), keyword()) :: t()
```

**Process**:
1. Build a new Command struct with the provided module and command
2. Extract execution_strategy from opts, defaulting to :sync
3. Extract metadata from opts, defaulting to empty map
4. Set timestamp to current UTC time

**Test Assertions**:
- creates command with custom execution_strategy from opts
- creates command with custom metadata from opts
- supports metadata with prompt and options for Claude SDK commands
- supports metadata with child_session_ids for spawn_sessions commands

### runs_in_terminal?/1

Check if a command requires terminal visualization.

```elixir
@spec runs_in_terminal?(t()) :: boolean()
```

**Process**:
1. Pattern match on the command field
2. Return true if command is "claude"
3. Return false for all other command types

**Test Assertions**:
- returns true for commands with command field set to "claude"
- returns false for commands with command field set to "spawn_sessions"
- returns false for commands with any other command value
