# CodeMySpecTui.Screens.Sessions

**Type**: screen

Displays a list of active sessions with navigation and actions. Allows viewing session details, opening terminal, and deleting sessions.

## Functions

### init/0

Initialize the sessions list screen.

```elixir
@spec init() :: {t(), nil}
```

**Process**:
1. Get scope using Scope.for_cli()
2. If scope is nil, return error state with message
3. Load active sessions using Sessions.list_sessions(scope, status: [:active])
4. Sort sessions by inserted_at descending
5. Initialize state with sessions list and selected_session_index of 0
6. Return {state, nil}

**Test Assertions**:
- init/0 returns error state when no scope exists
- init/0 loads active sessions when scope exists
- init/0 sorts sessions by newest first
- init/0 sets selected_session_index to 0

### update/2

Handle keyboard input and system messages.

```elixir
@spec update(t(), term()) :: {:ok, t()} | {:switch_screen, atom(), t()}
```

**Process**:

**Arrow Up Key**:
1. Decrement selected_session_index
2. Clamp to minimum of 0
3. Return {:ok, updated_state}

**Arrow Down Key**:
1. Increment selected_session_index
2. Clamp to maximum of (length(sessions) - 1)
3. Return {:ok, updated_state}

**Enter Key**:
1. Get selected session at selected_session_index
2. Switch to session detail screen
3. Return {:switch_screen, :session_detail, state}

**'n' Key (Execute Next Command)**:
1. Get selected session at selected_session_index
2. Call Sessions.execute(scope, session.id)
3. If {:ok, updated_session}:
   - Update session in sessions list
   - Clear error_message
4. If {:error, :interaction_pending}:
   - Set error_message "Session has pending interaction"
5. If {:error, :session_complete}:
   - Set error_message "Session is already complete"
6. If {:error, reason}:
   - Set error_message with reason
7. Return {:ok, updated_state}

**'t' Key (Open Terminal)**:
1. Get selected session at selected_session_index
2. Check if session has any interactions with terminal-bound commands
3. If yes:
   - Call TerminalPanes.show_terminal(session.id)
   - Update state with terminal_session_id
4. If no:
   - Set error_message "Session has no terminal commands"
5. Return {:ok, updated_state}

**'d' Key (Delete Session)**:
1. Get selected session at selected_session_index
2. Call Sessions.delete_session(scope, session.id)
3. Remove session from sessions list
4. Adjust selected_session_index if needed
5. Return {:ok, updated_state}

**Esc Key**:
1. If terminal is open, call TerminalPanes.hide_terminal()
2. Return {:switch_screen, :repl, state}

**Test Assertions**:
- update/2 navigates up with arrow up
- update/2 navigates down with arrow down
- update/2 clamps index at boundaries
- update/2 switches to session detail on Enter
- update/2 executes next command on 'n' key
- update/2 updates session after successful execution
- update/2 shows error for pending interaction
- update/2 shows error for complete session
- update/2 opens terminal for sessions with terminal commands
- update/2 shows error for sessions without terminal commands
- update/2 deletes session on 'd' key
- update/2 adjusts selection after delete
- update/2 closes terminal on exit

### render/1

Render the sessions list screen.

```elixir
@spec render(t()) :: Ratatouille.View.t()
```

**Process**:
1. Render sessions list:
   - Header row with title "Active Sessions (count)"
   - If error_message is set, render flash message bar below header with error styling
   - Instructions: "↑/↓: navigate | Enter: details | n: next cmd | t: terminal | d: delete | q: exit"
   - List panel with sessions
   - For each session:
     - Show selection indicator if selected
     - Show display_name or "Session #id"
     - Show status with color coding
     - Show pending step name if available
2. Return rendered view

**Test Assertions**:
- render/1 shows flash message when error_message set
- render/1 shows session count in header
- render/1 shows all keyboard shortcuts
- render/1 highlights selected session
- render/1 shows session status with colors
- render/1 shows pending step name
- render/1 shows sessions list even when error_message is present

## Fields

| Field                  | Type          | Required | Description                         |
| ---------------------- | ------------- | -------- | ----------------------------------- |
| scope                  | Scope.t()     | No       | User scope for CLI                  |
| sessions               | [Session.t()] | Yes      | List of active sessions             |
| selected_session_index | integer()     | Yes      | Index of currently selected session |
| error_message          | String.t()    | No       | Error message to display            |
| terminal_session_id    | integer()     | No       | ID of session with terminal open    |

## Dependencies

- code_my_spec/sessions.spec.md
- code_my_spec/sessions/command.spec.md
- code_my_spec_cli/terminal_panes.spec.md
- code_my_spec_cli/screens/session.spec.md