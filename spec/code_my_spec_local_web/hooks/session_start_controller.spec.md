# CodeMySpecLocalWeb.Hooks.SessionStartController

## Type

controller

Handles the `SessionStart` Claude Code hook event. Receives POST requests at `/api/hooks/session-start` with a `session_id` in the body. Finds or creates a session in the database via the Sessions context and returns the session ID and status.

## Functions

### handle/2

Processes the SessionStart hook. Extracts `session_id` from the request body, delegates to `Sessions.find_or_create_session/2`, and returns the session as JSON.

```elixir
@spec handle(Plug.Conn.t(), map()) :: Plug.Conn.t()
```

**Process**:
1. Extract `current_scope` from `conn.assigns` and `session_id` from `conn.body_params`
2. If `session_id` is nil or empty, return 400 with error message
3. Call `Sessions.find_or_create_session(scope, session_id)`
4. On success, return JSON with `session_id` and `status`
5. On error, return 422 with error details

**Test Assertions**:
- returns 400 when session_id is missing
- returns 400 when session_id is empty string
- creates a new session and returns session_id and status
- returns existing session when session_id already exists
- returns 422 when session creation fails

## Dependencies

- CodeMySpec.Sessions
