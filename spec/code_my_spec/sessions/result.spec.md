# CodeMySpec.Sessions.Result

**Type**: module

Embedded schema representing the result of executing a command during a session. Provides factory functions for creating result structs with different status types (pending, success, error, warning) and handles automatic timestamp generation.

## Fields

| Field         | Type         | Required   | Description                              | Constraints                              |
| ------------- | ------------ | ---------- | ---------------------------------------- | ---------------------------------------- |
| id            | binary_id    | Yes (auto) | Primary key                              | Auto-generated UUID                      |
| status        | enum         | Yes        | Result status                            | Values: :ok, :error, :warning            |
| data          | map          | No         | Arbitrary result data                    | Default: %{}                             |
| code          | integer      | No         | Exit code from command execution         |                                          |
| error_message | string       | No         | Error or warning message                 |                                          |
| stdout        | string       | No         | Standard output from command             |                                          |
| stderr        | string       | No         | Standard error from command              |                                          |
| duration_ms   | integer      | No         | Execution duration in milliseconds       |                                          |
| timestamp     | utc_datetime | No         | When the result was created              | Auto-set if not provided                 |

## Functions

### changeset/2

Build a changeset for a Result struct with validation.

```elixir
@spec changeset(t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast all fields from attributes (status, data, code, error_message, stdout, stderr, duration_ms, timestamp)
2. Validate that status is required
3. Auto-set timestamp to current UTC time if not provided

**Test Assertions**:
- requires status field
- accepts all valid status values (:ok, :error, :warning)
- rejects invalid status values
- auto-sets timestamp when not provided
- preserves existing timestamp when provided
- casts all optional fields correctly
- defaults data to empty map when not provided

### pending/2

Create a pending result indicating an operation is in progress.

```elixir
@spec pending(map(), keyword()) :: t()
```

**Process**:
1. Create Result struct with status :pending
2. Set data from first argument (defaults to empty map)
3. Apply optional stdout, code (defaults to 0), and duration_ms from opts
4. Set timestamp to current UTC time

**Test Assertions**:
- creates result with :pending status
- uses empty map as default data
- accepts custom data map
- applies stdout from opts
- defaults code to 0
- applies duration_ms from opts
- sets timestamp to current time

### success/2

Create a success result indicating an operation completed successfully.

```elixir
@spec success(map(), keyword()) :: t()
```

**Process**:
1. Create Result struct with status :ok
2. Set data from first argument (defaults to empty map)
3. Apply optional stdout, code (defaults to 0), and duration_ms from opts
4. Set timestamp to current UTC time

**Test Assertions**:
- creates result with :ok status
- uses empty map as default data
- accepts custom data map
- applies stdout from opts
- defaults code to 0
- applies duration_ms from opts
- sets timestamp to current time

### error/2

Create an error result indicating an operation failed.

```elixir
@spec error(String.t(), keyword()) :: t()
```

**Process**:
1. Create Result struct with status :error
2. Set error_message from first argument
3. Apply optional data (defaults to empty map), stderr, code, and duration_ms from opts
4. Set timestamp to current UTC time

**Test Assertions**:
- creates result with :error status
- sets error_message from argument
- defaults data to empty map
- accepts custom data from opts
- applies stderr from opts
- applies code from opts (no default)
- applies duration_ms from opts
- sets timestamp to current time

### warning/3

Create a warning result indicating an operation completed with warnings.

```elixir
@spec warning(String.t(), map(), keyword()) :: t()
```

**Process**:
1. Create Result struct with status :warning
2. Set error_message from first argument
3. Set data from second argument (defaults to empty map)
4. Apply optional stdout, stderr, code, and duration_ms from opts
5. Set timestamp to current UTC time

**Test Assertions**:
- creates result with :warning status
- sets error_message from first argument
- uses empty map as default data
- accepts custom data map as second argument
- applies stdout from opts
- applies stderr from opts
- applies code from opts
- applies duration_ms from opts
- sets timestamp to current time

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Jason.Encoder
