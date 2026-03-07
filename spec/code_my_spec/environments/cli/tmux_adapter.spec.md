# CodeMySpec.Environments.Cli.TmuxAdapter

## Type

logic

Adapter for tmux operations, enabling Cli environment to be tested without actual tmux dependency.

## Functions

### inside_tmux?/0

Check if currently running inside a tmux session.

```elixir
@spec inside_tmux?() :: boolean()
```

**Process**:
1. Check for TMUX environment variable
2. Return true if present and non-empty, false otherwise

**Test Assertions**:
- inside_tmux?/0 returns true when TMUX env var is set
- inside_tmux?/0 returns false when TMUX env var is not set
- inside_tmux?/0 returns false when TMUX env var is empty string

### get_current_session/0

Get the name of the current tmux session.

```elixir
@spec get_current_session() :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Execute tmux command: `tmux display-message -p "#{session_name}"`
2. Trim output and return session name
3. Return error if command fails

**Test Assertions**:
- get_current_session/0 returns session name when inside tmux
- get_current_session/0 returns error when not inside tmux

### create_window/1

Create a new tmux window with specified name.

```elixir
@spec create_window(window_name :: String.t()) :: {:ok, window_id :: String.t()} | {:error, term()}
```

**Process**:
1. Get current session name via get_current_session/0
2. Execute tmux command: `tmux new-window -t session -n window_name -d -P -F "#{window_id}"`
3. Parse and return window ID
4. Return error if command fails

**Test Assertions**:
- create_window/1 creates window and returns window ID
- create_window/1 creates window in detached mode (doesn't switch focus)
- create_window/1 returns error when not inside tmux
- create_window/1 handles duplicate window names gracefully

### kill_window/1

Kill/close a tmux window by name.

```elixir
@spec kill_window(window_name :: String.t()) :: :ok | {:error, term()}
```

**Process**:
1. Get current session name via get_current_session/0
2. Execute tmux command: `tmux kill-window -t session:window_name`
3. Return :ok if successful
4. Return :ok if window doesn't exist (idempotent)
5. Return error only for actual tmux failures

**Test Assertions**:
- kill_window/1 kills the specified window
- kill_window/1 is idempotent (returns :ok if window already gone)
- kill_window/1 returns error when not inside tmux

### send_keys/2

Send a command string to a tmux window.

```elixir
@spec send_keys(window_name :: String.t(), command :: String.t()) :: :ok | {:error, term()}
```

**Process**:
1. Get current session name via get_current_session/0
2. Execute tmux command: `tmux send-keys -t session:window_name command C-m`
3. C-m sends Enter key to execute the command
4. Return :ok if successful, error otherwise

**Test Assertions**:
- send_keys/2 sends command to window and presses Enter
- send_keys/2 returns error when window doesn't exist
- send_keys/2 returns error when not inside tmux

### window_exists?/1

Check if a tmux window exists by name.

```elixir
@spec window_exists?(window_name :: String.t()) :: boolean()
```

**Process**:
1. Get current session name via get_current_session/0
2. List all windows via `tmux list-windows -t session -F "#{window_name}"`
3. Check if window_name appears in output
4. Return true if found, false otherwise

**Test Assertions**:
- window_exists?/1 returns true for existing windows
- window_exists?/1 returns false for non-existent windows
- window_exists?/1 returns false when not inside tmux

## Dependencies

None (leaf module, wraps System.cmd/3 for tmux operations)