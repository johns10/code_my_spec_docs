# CodeMySpec.Sessions.EventHandler

**Type**: module

Processes incoming events from CLI/VSCode clients, persists them to the interaction_events table, applies session-level side effects, and broadcasts notifications to connected clients. Events are append-only and processed with transactional guarantees. Side effects are applied based on event type and data content.

## Functions

### handle_event/3

Process a single event for an interaction.

```elixir
@spec handle_event(Scope.t(), binary(), map()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Extract event_type from event_attrs (supports both string and atom keys)
2. Fetch interaction by interaction_id via InteractionsRepository
3. Fetch session by interaction.session_id via SessionsRepository with scope
4. Return {:error, :interaction_not_found} if interaction or session lookup fails
5. Call process_single_event within Repo.transaction for atomicity:
   - Add interaction_id to event attributes
   - Build and validate event via InteractionEvent.changeset
   - Process side effects based on event type and data content
   - Insert validated event to database
   - Apply session updates if side effects produced any
   - Log event processing completion
   - Update InteractionRegistry with runtime status
   - Broadcast activity via SessionsBroadcaster
6. Return {:ok, updated_session} on success or {:error, reason} on failure

**Test Assertions**:
- valid event with all required fields passes validation and persists event
- missing required fields (event_type, sent_at, data) fails validation and returns changeset error
- invalid event_type fails validation
- data field accepts any map structure (nested, mixed types, empty)
- returns :interaction_not_found when interaction does not exist

## Side Effects

The module applies side effects based on event type and data content. Most events have no side effects.

### Status Change Detection

Events with `new_status` in data trigger session status updates.

**Process**:
1. Check if data contains "new_status" key
2. Parse status string to atom (active, complete, failed, cancelled)
3. Return session update map with new status
4. Broadcast status change to account and user channels

**Test Assertions**:
- session_status_changed updates session status to complete
- broadcasts status change to account and user channels

### Session Start (external_conversation_id)

Sets external_conversation_id when session receives first session_start event.

**Process**:
1. Match on session_start event type with nil external_conversation_id
2. Extract session_id from event data as conversation_id
3. Return error if session_id missing from data
4. Set external_conversation_id on session
5. If already set to same value, no-op
6. If different value, log warning and preserve original (no change)

**Test Assertions**:
- conversation_started sets external_conversation_id when nil
- conversation_started no-ops when already set to same value
- conversation_started logs warning when attempting to change conversations

### Notification Broadcasting

Broadcasts notification events to subscribed clients.

**Process**:
1. Match on notification event type
2. Extract notification_type from data
3. Build payload with session_id, notification_type, and data
4. Broadcast {:notification, payload} to account and user channels

### Session End

Finalizes session when session_end event received.

**Process**:
1. Match on session_end event type
2. Extract result from data (default to empty map)
3. Add status: :ok to result
4. Call Sessions.handle_result to process result and update session
5. Broadcast {:session_ended, session_id} to account and user channels

## Interaction Registry Updates

Updates runtime interaction status in InteractionRegistry based on event type.

**Process**:
1. notification: Set agent_state to "notification", record last_notification with timestamp
2. session_start: Set agent_state to "started", record conversation_id and last_activity
3. proxy_request with new_status: Set agent_state to new status value
4. proxy_request/proxy_response without status: Set agent_state to "running", record tool activity
5. post_tool_use: Set agent_state to "running", record tool_name and tool_use_id
6. user_prompt_submit: Set agent_state to "running", clear last_notification and last_stopped, record prompt preview
7. stop: Set agent_state to "idle", record last_stopped with stop_hook_active flag
8. session_end: Set agent_state to "ended", record reason
9. Other event types: No registry update

**Test Assertions**:
- post_tool_use updates last_activity with tool details
- user_prompt_submit clears last_notification and last_stopped
- stop event sets agent_state to idle and records last_stopped
- registry merges updates preserving previous fields

## Broadcasting

All session updates are broadcast to multiple PubSub channels.

**Channels**:
- `account:{account_id}:sessions` - Account-wide session events
- `user:{user_id}:sessions` - User-specific session events

**Messages**:
- `{:conversation_id_set, %{session_id, conversation_id}}` - When external_conversation_id is set
- `{:session_status_changed, %{session_id, status}}` - When status changes
- `{:session_updated, %{session_id, field, value}}` - Generic field updates
- `{:notification, %{session_id, notification_type, data}}` - Notification events
- `{:session_ended, session_id}` - Session completion
- `{:session_activity, %{session_id}}` - General activity indicator

**Test Assertions**:
- conversation_started broadcasts to account and user channels
- session_status_changed broadcasts to account and user channels

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Users.Scope
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.InteractionEvent
- CodeMySpec.Sessions.InteractionsRepository
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.SessionsBroadcaster
- CodeMySpec.Sessions.InteractionRegistry
- CodeMySpec.Sessions
