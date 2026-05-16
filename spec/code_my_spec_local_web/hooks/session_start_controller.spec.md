# CodeMySpecLocalWeb.Hooks.SessionStartController

## Type

controller

Handles the `SessionStart` Claude Code hook event. Receives POST requests at `/api/hooks/session-start` with a `session_id` in the body. Finds or creates a session in the database via the Sessions context and returns the session ID and status.

## Dependencies

- CodeMySpec.Sessions
