# CodeMySpec.Environments.Cli

## Type

logic

Executes commands in tmux windows for CLI display. Commands run for demonstration purposes; output capture not supported.

## Functions

### create/1

Create a tmux window for command execution and return window reference.

```elixir
@spec create(opts :: keyword()) :: {:ok, window_ref :: String.t()} | {:error, term()}
```

**Process**:
1. Extract session_id from opts (used for window naming)
2. Check if running inside tmux via TmuxAdapter.inside_tmux?/0
3. If not in tmux, return error
4. Generate window name (e.g., "claude-#{session_id}")
5. Create tmux window via TmuxAdapter.create_window/1
6. Return {:ok, window_ref} with the window ID

**Test Assertions**:
- create/1 returns window_ref when inside tmux
- create/1 returns error when not inside tmux
- create/1 generates unique window names per session
- create/1 delegates to TmuxAdapter.create_window/1

### destroy/1

Destroy a tmux window and clean up resources.

```elixir
@spec destroy(env :: Environment.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract window_ref from env.ref
2. Use TmuxAdapter.kill_window/1 to close the window
3. Return :ok or error

**Test Assertions**:
- destroy/1 kills the tmux window
- destroy/1 is idempotent (returns :ok if window already gone)
- destroy/1 delegates to TmuxAdapter.kill_window/1

### run_command/3

Send a command to the tmux window for display. Does not capture output.

```elixir
@spec run_command(env :: Environment.t(), command :: String.t(), opts :: keyword()) ::
        :ok | {:error, term()}
```

**Process**:
1. Extract window_ref from env.ref
2. Extract environment variables from opts[:env] if present
3. If env vars present, prepend export commands to the command string
4. Use TmuxAdapter.send_keys/2 to send command to window
5. Return :ok (does not wait or capture output)

**Test Assertions**:
- run_command/3 sends command to tmux window
- run_command/3 sets environment variables when env option provided
- run_command/3 returns :ok immediately without waiting
- run_command/3 delegates to TmuxAdapter.send_keys/2
- run_command/3 ignores async option (always async for display)

### read_file/2

Read a file from the server-side file system.

```elixir
@spec read_file(env :: Environment.t(), path :: String.t()) ::
        {:ok, content :: String.t()} | {:error, term()}
```

**Process**:
1. Use File.read/1 to read file (env.ref not used)
2. Return content or error

**Test Assertions**:
- read_file/2 returns file content for existing files
- read_file/2 returns error for non-existent files
- read_file/2 handles permission errors

### list_directory/2

List contents of a directory from the server-side file system.

```elixir
@spec list_directory(env :: Environment.t(), path :: String.t()) ::
        {:ok, entries :: [String.t()]} | {:error, term()}
```

**Process**:
1. Use File.ls/1 to list directory (env.ref not used)
2. Return list of entry names or error

**Test Assertions**:
- list_directory/2 returns list of entries for existing directory
- list_directory/2 returns error for non-existent directory
- list_directory/2 handles permission errors

## Dependencies

- Environments.Cli.TmuxAdapter