# CodeMySpecLocalWeb.Hooks.StopController

## Type

controller

Handles the `Stop` Claude Code hook event. Receives POST requests at `/api/hooks` (dispatched when `hook_event_name` is `Stop`). Validates the session transcript, then determines whether the agent should be allowed to stop or should be directed to continue working. Blocks the stop with a `get_next_requirement` instruction when actionable project requirements remain. Fires an async `task_complete` push notification on all allowed-stop paths.

## Dependencies

- CodeMySpec.Validation — `validate_stop/2`, `format_output/1`
- CodeMySpec.Sessions — `get_by_external_id/2`
- CodeMySpec.Sessions.Session — `active_task/1`
- CodeMySpec.Requirements — `next_actionable_project/1`
- CodeMySpec.Notifications.NotificationClient — `notify/1`
