# CodeMySpecLocalWeb.Hooks.StopController

## Type

controller

Handles the `Stop` Claude Code hook event. Receives POST requests at `/api/hooks` (dispatched when `hook_event_name` is `Stop`). Validates the session transcript, then determines whether the agent should be allowed to stop or should be directed to continue working. Blocks the stop with a `get_next_requirement` instruction when actionable project requirements remain. Fires an async `task_complete` push notification on all allowed-stop paths.

## Functions

### handle/2

Entry point for the Stop hook. Extracts `session_id` and `transcript_path` from params, runs validation via `Validation.validate_stop/2`, then either passes validation output directly to the JSON response or — when validation succeeds — delegates to `maybe_continue_with_next_task/3` to check for remaining work.

```elixir
@spec handle(Plug.Conn.t(), map()) :: Plug.Conn.t()
```

**Process**:
1. Extract `current_scope` from `conn.assigns`
2. Extract `session_id` and `transcript_path` from `params` (both may be nil)
3. Generate a short hex `req_id` for log correlation using `:crypto.strong_rand_bytes(4)`
4. Call `Validation.validate_stop(scope, transcript_path: transcript_path, session_id: session_id)`
5. If result is `{:ok, :valid}`, call `maybe_continue_with_next_task(scope, session_id, req_id)` to get the response map
6. If result is anything else (validation error), call `Validation.format_output(result)` to get the response map
7. Render the response map as JSON with `json(conn, response)`

**Test Assertions**:
- returns empty JSON map when validation succeeds and no more work remains
- returns block decision with get_next_requirement instruction when validation succeeds and actionable requirements exist
- returns block decision from Validation.format_output when validate_stop returns an error
- renders JSON for all response paths

---

### maybe_continue_with_next_task/3 (private)

Decides whether the agent may stop after passing validation. Looks up the session by `session_id`, checks for active sub-agent or manual tasks (which indicate the stop is legitimate mid-flow), and otherwise queries for actionable project requirements.

```elixir
@spec maybe_continue_with_next_task(Scope.t(), String.t() | nil, String.t()) :: map()
```

**Process**:
1. Resolve session: `session = session_id && Sessions.get_by_external_id(scope, session_id)` (nil when session_id is nil or no matching active session found)
2. Evaluate in order via `cond`:
   a. If session is nil — log "No session, allowing stop", call `notify_complete/0`, return `%{}`
   b. If `has_active_subagent_task?(session)` — log "Active subagent task, allowing stop", call `notify_complete/0`, return `%{}`
   c. If `has_active_manual_task?(session)` — log "Active manual task, allowing stop", call `notify_complete/0`, return `%{}`
   d. Otherwise — call `Requirements.next_actionable_project(scope)` and branch:
      - Non-empty list: log "More work available, blocking stop", return block map with `get_next_requirement` reason
      - Empty list: log "No more work, allowing stop", call `notify_complete/0`, return `%{}`

**Return values**:
- Allow stop (all permit paths): `%{}`
- Block stop: `%{"decision" => "block", "reason" => "Task completed successfully. There is more work to do on this project.\n\nCall `get_next_requirement` to find your next assignment, then `start_task` to begin.\n"}`

**Test Assertions**:
- returns empty map when session_id is nil
- returns empty map when no active session is found for the given session_id
- returns empty map when session has an active sub-agent task
- returns empty map when session has an active manual task
- returns block map with get_next_requirement reason when Requirements.next_actionable_project returns a non-empty list
- returns empty map when Requirements.next_actionable_project returns an empty list
- calls notify_complete on all allow-stop paths
- does not call notify_complete on the block path

---

### has_active_subagent_task?/1 (private)

Returns true when any task in the session has `status: :active` and `execution_type: :sub_agent`.

```elixir
@spec has_active_subagent_task?(Session.t()) :: boolean()
```

**Process**:
1. Call `Enum.any?(session.tasks || [], fn task -> task.status == :active and task.execution_type == :sub_agent end)`

**Test Assertions**:
- returns true when session has a task with status :active and execution_type :sub_agent
- returns false when active task has execution_type :main_agent
- returns false when sub_agent task is not :active (e.g. :completed)
- returns false when session has no tasks

---

### has_active_manual_task?/1 (private)

Returns true when the session's currently active task has `validation_type: :manual`.

```elixir
@spec has_active_manual_task?(Session.t()) :: boolean()
```

**Process**:
1. Call `Session.active_task(session)` to retrieve the first task with `status: :active`
2. If the result matches `%{validation_type: :manual}`, return true
3. Otherwise return false (covers nil and any other validation_type)

**Test Assertions**:
- returns true when the active task has validation_type :manual
- returns false when the active task has validation_type :automatic
- returns false when there is no active task

---

### notify_complete/0 (private)

Fires a `task_complete` push notification asynchronously so the hook response is not delayed by network latency.

```elixir
@spec notify_complete() :: {:ok, pid()}
```

**Process**:
1. Call `Task.start/1` with an anonymous function that calls `NotificationClient.notify/1`
2. The notification payload is `%{type: "task_complete", title: "Claude has finished", body: "Claude Code has completed its current task"}`
3. Returns the `{:ok, pid}` tuple from `Task.start/1` (caller ignores the return value)

**Test Assertions**:
- spawns an async task (does not block the hook response)
- passes the correct payload to NotificationClient.notify

## Dependencies

- CodeMySpec.Validation — `validate_stop/2`, `format_output/1`
- CodeMySpec.Sessions — `get_by_external_id/2`
- CodeMySpec.Sessions.Session — `active_task/1`
- CodeMySpec.Requirements — `next_actionable_project/1`
- CodeMySpec.Notifications.NotificationClient — `notify/1`
