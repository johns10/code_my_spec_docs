# CodeMySpecCli.Hooks.ValidateEdits

A Claude Code stop hook that validates files edited during an agent session. Delegates to `CodeMySpec.Sessions.AgentTasks.ValidateEdits` for the actual validation logic.

## Functions

### run_and_output/0

Run validation and output JSON result to stdout for hook protocol.

```elixir
@spec run_and_output() :: :ok
```

**Process**:
1. Get current session ID from `CurrentSession.get_session_id/0`
2. If no session, output `%{}` and return `:ok`
3. Call `AgentTasks.ValidateEdits.run/2` with session ID
4. Call `AgentTasks.ValidateEdits.format_output/1` to format result
5. Encode as JSON and output to stdout
6. Return `:ok`

**Test Assertions**:
- outputs {} when no active session
- outputs {} when validation passes
- outputs {"decision": "block", "reason": "..."} when validation fails
- delegates to AgentTasks.ValidateEdits for actual validation

## Dependencies

- CodeMySpec.Sessions.CurrentSession
- CodeMySpec.Sessions.AgentTasks.ValidateEdits
