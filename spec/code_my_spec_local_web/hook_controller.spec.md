# CodeMySpecLocalWeb.HookController

## Type

controller

Dispatches Claude Code hook events for the local CLI server. All hooks POST to `/api/hooks` with an `X-Working-Dir` header. Routes by `hook_event_name` to handle session lifecycle, tool enrichment, and agent assignment.

## Functions

### dispatch/2

Entry point for all hook events. Extracts the `hook_event_name` from the request body and delegates to the appropriate handler.

```elixir
@spec dispatch(Plug.Conn.t(), map()) :: Plug.Conn.t()
```

## Dependencies

- CodeMySpec.Sessions
- CodeMySpec.Sessions.Session
