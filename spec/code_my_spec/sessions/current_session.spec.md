# CodeMySpec.Sessions.CurrentSession

File-based persistence for tracking the active CLI session between process invocations. Stores session state in `.code_my_spec/internal/current_session/session.json` so the evaluate command can pick up context from the start command without bash script intermediaries.

## Module Attributes

| Attribute     | Value                                           | Description                    |
| ------------- | ----------------------------------------------- | ------------------------------ |
| @session_dir  | ".code_my_spec/internal/current_session"        | Directory for session files    |
| @session_file | "session.json"                                  | Filename for session state     |

## Functions

### save/1

Persists current session state to disk as JSON.

```elixir
@spec save(map()) :: :ok
```

**Parameters**:
- session_data: Map containing session_id, session_type, component_id, component_name, module_name

**Process**:
1. Ensure session directory exists (mkdir_p)
2. Encode session_data as pretty JSON
3. Write to session file path
4. Return :ok

**Test Assertions**:
- creates session directory if not exists
- writes valid JSON to session file
- overwrites existing session file
- returns :ok on success

### load/0

Loads current session state from disk.

```elixir
@spec load() :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Read session file
2. If file not found, return {:error, "No active session. Run a start command first."}
3. Decode JSON content
4. Convert string keys to atoms
5. Return {:ok, data}

**Test Assertions**:
- returns {:ok, map} when session file exists
- returns {:error, _} when no session file
- returns {:error, _} when file contains invalid JSON
- atomizes string keys in returned map

### get_session_id/0

Convenience function to get just the session ID from disk.

```elixir
@spec get_session_id() :: {:ok, integer()} | {:error, String.t()}
```

**Process**:
1. Call load/0
2. Extract session_id from result
3. Return {:ok, id} or pass through error

**Test Assertions**:
- returns {:ok, id} when session exists
- returns {:error, _} when no session

### clear/0

Removes current session state after successful completion.

```elixir
@spec clear() :: :ok
```

**Process**:
1. Delete session file if exists
2. Remove session directory if empty
3. Return :ok

**Test Assertions**:
- removes session file
- removes empty session directory
- returns :ok even if no session exists

### active?/0

Checks if there's an active session on disk.

```elixir
@spec active?() :: boolean()
```

**Process**:
1. Check if session file exists
2. Return boolean result

**Test Assertions**:
- returns true when session file exists
- returns false when no session file

## Dependencies

- Jason
- File
