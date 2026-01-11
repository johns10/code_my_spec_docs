# CodeMySpecTui.TerminalPanes

**Type**: context

Manages a single terminal pane for visualizing CLI-bound session commands. Only displays when a session has terminal-bound commands (currently only "claude" commands).

## Functions

### show_terminal/1

Show the terminal pane for a specific session.

```elixir
@spec show_terminal(session_id :: integer()) :: :ok | {:error, term()}
```

**Process**:
1. Check if terminal pane already exists
2. If exists, update to show new session (or do nothing if same session)
3. If doesn't exist:
   - Check if running inside tmux
   - Get current session name
   - Split Window 0 horizontally (top/bottom) at 50%
   - Set pane title to "terminal"
   - Enter copy mode for scrollability
4. Store current session_id in process state
5. Return :ok

**Test Assertions**:
- show_terminal/1 creates pane when not exists
- show_terminal/1 is idempotent when called with same session
- show_terminal/1 returns error when not in tmux
- show_terminal/1 enters copy mode automatically

### hide_terminal/0

Hide/close the terminal pane.

```elixir
@spec hide_terminal() :: :ok | {:error, term()}
```

**Process**:
1. Check if terminal pane exists
2. If exists, kill the pane
3. Clear current session_id from process state
4. Return :ok (idempotent - succeeds even if pane doesn't exist)

**Test Assertions**:
- hide_terminal/0 removes terminal pane
- hide_terminal/0 is idempotent when pane doesn't exist
- hide_terminal/0 clears stored session_id

### terminal_open?/0

Check if the terminal pane is currently open.

```elixir
@spec terminal_open?() :: boolean()
```

**Process**:
1. Check if pane with title "terminal" exists in Window 0
2. Return true if found, false otherwise

**Test Assertions**:
- terminal_open?/0 returns true when pane exists
- terminal_open?/0 returns false when pane doesn't exist
- terminal_open?/0 returns false when not in tmux

### current_session/0

Get the session_id currently displayed in the terminal.

```elixir
@spec current_session() :: {:ok, integer()} | {:error, :not_open}
```

**Process**:
1. Check process state for stored session_id
2. Return {:ok, session_id} if set
3. Return {:error, :not_open} if terminal not showing

**Test Assertions**:
- current_session/0 returns session_id when terminal open
- current_session/0 returns :not_open when terminal closed

## Dependencies

- code_my_spec/environments/cli/tmux_adapter.spec.md
