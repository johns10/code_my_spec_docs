# Sessions.Result Schema

## Purpose

Captures the outcome of command execution with status, output streams, error information, and timing data as an embedded document within Interaction schemas.

## Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | binary_id | Yes (auto) | Primary key (UUID) | Auto-generated UUID |
| status | enum | Yes | Execution outcome status | Values: :ok, :error, :warning |
| data | map | No | Structured result data | Default: %{}, JSONB for flexible data |
| code | integer | No | Exit code or status code | Typically 0 for success |
| error_message | string | No | Human-readable error description | Present when status is :error or :warning |
| stdout | string | No | Standard output from command | Captured command output |
| stderr | string | No | Standard error from command | Captured error output |
| duration_ms | integer | No | Execution duration in milliseconds | Performance tracking |
| timestamp | utc_datetime | No | Result creation timestamp | Auto-set to current time |

## Validation Rules

### Required Fields
- `status` - Must be present (:ok, :error, or :warning)

### Automatic Timestamping
- `timestamp` - Set to DateTime.utc_now() if not provided in changeset

### Default Values
- `data` - Defaults to empty map %{}
- `code` - Typically 0 for successful operations

## Constructor Functions

### Success Results
- `success(data \\ %{}, opts \\ [])` - Creates :ok result with optional stdout, code, duration_ms
- `pending(data \\ %{}, opts \\ [])` - Creates :pending result (for async operations)

### Error Results
- `error(error_message, opts \\ [])` - Creates :error result with message, optional data, stderr, code, duration_ms

### Warning Results
- `warning(message, data \\ %{}, opts \\ [])` - Creates :warning result with message, data, optional stdout, stderr, code, duration_ms

## Usage Patterns

### Synchronous Command Success
```elixir
Result.success(%{parsed_data: value}, stdout: "output", code: 0, duration_ms: 150)
```

### Command Error
```elixir
Result.error("File not found", stderr: "No such file", code: 1, duration_ms: 50)
```

### Partial Success Warning
```elixir
Result.warning("Some items skipped", %{processed: 10, skipped: 2}, stdout: "logs")
```

### Async Pending State
```elixir
Result.pending(%{job_id: "abc123"}, stdout: "Job queued")
```