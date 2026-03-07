# CodeMySpec.Sessions.SessionStack

## Type

module

Evaluates the session stack on stop hook. Reads all active sessions via SessionsRepository, sorts by priority (highest first), and calls each agent task module's evaluate function in order. The first evaluation that returns invalid blocks the agent with feedback. Passing evaluations remove the session. When no sessions remain, the agent stops cleanly.

## Dependencies

- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.SessionType

## Functions

### evaluate/2

Evaluate the session stack and return a hook decision map.

Called by the stop hook. Lists sessions, evaluates in priority order (highest first), and returns the first blocking result or an empty map if all pass.

```elixir
@spec evaluate(Environment.t(), keyword()) :: map()
```

**Process**:

1. List all sessions via `SessionsRepository.list_sessions/1`
2. Sort by priority (highest first)
3. For each session, resolve its agent task module from the type via SessionType and call `evaluate/3`
4. If evaluate returns `{:ok, :valid}`, delete the session via `SessionsRepository.delete_session/2`
5. If evaluate returns `{:ok, :invalid, feedback}`, stop iteration and return `%{"decision" => "block", "reason" => feedback}`
6. If no sessions exist, return `%{}` (allow stop)

**Test Assertions**:

- returns empty map when no sessions exist
- evaluates sessions in descending priority order (highest first)
- returns block decision with feedback from first invalid evaluation
- deletes session when evaluation passes
- stops iteration at first invalid result (does not evaluate lower-priority sessions)
