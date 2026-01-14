# CodeMySpec.Sessions.EventHandler

**Type**: module

Processes incoming events from CLI/VSCode clients, persists them to the interaction_events table, applies session-level side effects, and broadcasts notifications to connected clients. Events are append-only and processed with transactional guarantees. Side effects are applied based on event type and data content.

## Delegates

(none)

## Functions

### handle_event/3

Process a single event for an interaction, applying side effects and broadcasting updates.

```elixir
@spec handle_event(Scope.t(), binary(), map()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Extract event_type from event_attrs (supports both string and atom keys)
2. Fetch interaction by interaction_id via InteractionsRepository.get/1
3. Fetch session by interaction.session_id via SessionsRepository.get_session/2 with scope
4. Return {:error, :interaction_not_found} if interaction or session lookup fails
5. Begin Repo.transaction for atomicity
6. Add interaction_id to event attributes map
7. Build and validate event via InteractionEvent.changeset; return {:error, changeset} if invalid
8. Process side effects based on event type and data:
   - If data contains "new_status" key: parse status string (active/complete/failed/cancelled) to atom and prepare session status update
   - If event_type is :session_start and external_conversation_id is nil: extract session_id from data as conversation_id, return error if missing, prepare external_conversation_id update
   - If event_type is :session_start and external_conversation_id already set: no-op if same value, log warning if different and preserve original
   - If event_type is :notification: broadcast {:notification, payload} to account and user PubSub channels
   - If event_type is :session_end: call Sessions.handle_result with result from data, broadcast {:session_ended, session_id} to channels
   - Default: no side effects
9. Insert validated event to database via Repo.insert
10. Apply session updates if side effects produced any via Session.changeset and Repo.update
11. Broadcast session field updates to PubSub channels:
    - `{:conversation_id_set, %{session_id, conversation_id}}` for external_conversation_id
    - `{:session_status_changed, %{session_id, status}}` for status changes
    - `{:session_updated, %{session_id, field, value}}` for other fields
12. Log event processing completion with session updates if any
13. Update InteractionRegistry with runtime status based on event type:
    - :notification: agent_state "notification", record last_notification
    - :session_start: agent_state "started", record conversation_id and last_activity
    - :proxy_request with new_status in data: agent_state to new status value
    - :proxy_request/:proxy_response without status: agent_state "running", record tool activity
    - :post_tool_use: agent_state "running", record tool_name and tool_use_id
    - :user_prompt_submit: agent_state "running", clear last_notification and last_stopped, record prompt preview
    - :stop: agent_state "idle", record last_stopped with stop_hook_active flag
    - :session_end: agent_state "ended", record reason
    - Other: no registry update
14. Broadcast activity via SessionsBroadcaster.broadcast_activity/2
15. Return {:ok, updated_session} on success, rollback transaction and return {:error, reason} on failure

**Test Assertions**:
- valid event with all required fields passes validation and persists event
- missing required fields (event_type, sent_at, data) fails validation and returns changeset error
- invalid event_type fails validation
- data field accepts any map structure (nested, mixed types, empty)
- returns :interaction_not_found when interaction does not exist
- session_status_changed updates session status when data contains new_status
- conversation_started sets external_conversation_id when nil
- conversation_started no-ops when already set to same value
- conversation_started logs warning when attempting to change conversations
- unknown event types have no side effects
- conversation_started broadcasts to account and user channels
- session_status_changed broadcasts to account and user channels
- post_tool_use updates last_activity with tool details in InteractionRegistry
- user_prompt_submit clears last_notification and last_stopped in InteractionRegistry
- stop event sets agent_state to idle and records last_stopped in InteractionRegistry
- registry merges updates preserving previous fields

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