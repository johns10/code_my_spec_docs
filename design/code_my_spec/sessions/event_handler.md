# Event Handler

## Purpose

Processes incoming events from VS Code clients, persists them to the session_events table, applies session-level side effects, and broadcasts notifications to connected clients.

## Responsibilities

### 1. Event Validation
Ensures incoming event data conforms to the SessionEvent schema wrapper requirements (event_type, timestamp, session_id, etc.). Does NOT validate the contents of the `data` field.

### 2. Event Persistence
Inserts validated events into the `session_events` table. Supports both single event and batch event insertion with transactional guarantees.

### 3. Side Effect Processing
Applies state mutations to the parent Session based on specific event types. Most events have no side effects - they're simply logged. Only a small subset trigger session updates.

### 4. Broadcast Notifications
Publishes lightweight notifications via PubSub when events are processed. Notifications indicate that new events exist but don't include full event data (clients query separately for performance).

## Event Processing Flow

### Single Event Processing

1. **Validate Session Existence** - Look up session by ID with scope validation
2. **Build Event** - Create SessionEvent struct from incoming attributes
3. **Validate Event** - Run changeset validation on event wrapper
4. **Process Side Effects** - Check if event type requires session updates
5. **Persist Transaction** - Insert event + apply session updates in single transaction
6. **Broadcast Notification** - Notify clients of new events
7. **Return Session** - Return updated session to caller

### Batch Event Processing

1. **Validate Session Existence** - Look up session once for entire batch
2. **Build Events** - Create SessionEvent structs for all events in batch
3. **Validate Events** - Run changeset validation on all events (fail fast on first error)
4. **Process Side Effects** - Collect session updates from all events
5. **Persist Transaction** - Insert all events + apply session updates atomically
6. **Broadcast Notification** - Single notification for entire batch
7. **Return Session** - Return updated session to caller

The batch transaction ensures all-or-nothing semantics: if any event fails validation or persistence, the entire batch is rolled back.

## Side Effect Handlers

Side effects are implemented as private functions that pattern match on event_type and return session updates.

### conversation_started

**Trigger**: When a Claude Code conversation begins

**Logic**:
- If session.external_conversation_id is nil, set it to the conversation_id from event data
- If already set and matches, no-op
- If already set but different, log warning

### Default (All Other Events)

**Logic**: No side effects, event is simply persisted

**Session Updates**: None

## Public Functions

### handle_event/3

```elixir
@spec handle_event(Scope.t(), session_id :: integer(), event_attrs :: map()) ::
  {:ok, Session.t()} | {:error, term()}
```

Processes a single event for a session.

**Parameters**:
- `scope` - User scope for authorization
- `session_id` - ID of session to add event to
- `event_attrs` - Event attributes including event_type, timestamp, data, etc.

**Returns**:
- `{:ok, session}` - Event processed successfully, returns updated session
- `{:error, :session_not_found}` - Session doesn't exist or not accessible by scope
- `{:error, changeset}` - Event validation failed
- `{:error, reason}` - Other persistence or processing error

**Transaction Scope**: Single database transaction for event insert + session update

### handle_events/3

```elixir
@spec handle_events(Scope.t(), session_id :: integer(), events_attrs :: [map()]) ::
  {:ok, Session.t()} | {:error, term()}
```

Processes multiple events in a batch for a session.

**Parameters**:
- `scope` - User scope for authorization
- `session_id` - ID of session to add events to
- `events_attrs` - List of event attribute maps

**Returns**:
- `{:ok, session}` - All events processed successfully, returns updated session
- `{:error, :session_not_found}` - Session doesn't exist or not accessible by scope
- `{:error, changeset}` - First event validation that failed
- `{:error, reason}` - Other persistence or processing error

**Transaction Scope**: Single database transaction for all event inserts + session update

**Error Handling**: Fails fast on first invalid event. Entire batch is rolled back on any error.

## Query Functions

### get_events/3

```elixir
@spec get_events(Scope.t(), session_id :: integer(), opts :: keyword()) ::
  [SessionEvent.t()]
```

Queries events for a session with optional filtering and pagination.

**Parameters**:
- `scope` - User scope for authorization
- `session_id` - ID of session to query events for
- `opts` - Query options (see below)

**Options**:
- `:event_type` - Filter by specific event type atom (e.g., `:tool_called`)
- `:limit` - Maximum number of events to return
- `:offset` - Number of events to skip (for pagination)
- `:order` - `:asc` or `:desc` (default: `:asc` by timestamp)

**Returns**: List of SessionEvent structs (empty list if session not found or no events)

**Query Performance**: Uses composite index on (session_id, timestamp) for efficient ordered queries

## Error Handling Strategy

### Validation Errors
Return `{:error, changeset}` with detailed error information. Client can inspect changeset errors to understand what failed.

### Session Not Found
Return `{:error, :session_not_found}` - distinct from validation errors. Client should check if session was deleted.

### Database Errors
Return `{:error, reason}` with database error. Log error for monitoring. Client should retry with exponential backoff.

### Side Effect Errors
If side effect processing fails (e.g., invalid status atom), log error but don't fail the entire operation. Event is still persisted. This prevents malformed event data from blocking event logging.

## Concurrency Considerations

### Race Conditions
Multiple clients may submit events concurrently for the same session. This is safe:
- Events are append-only (no conflicts)
- Session updates use last-write-wins (acceptable for side effects)
- Composite index on (session_id, timestamp) maintains ordering

### Transaction Isolation
Uses default READ COMMITTED isolation level. Session updates within transaction are atomic.

### Broadcast Ordering
PubSub broadcasts are asynchronous and may arrive out of order. Clients should query events by timestamp, not rely on broadcast order.

## Performance Optimizations

### Batch Processing
Clients should buffer events and submit in batches every 1-2 seconds. Single transaction is much more efficient than N individual transactions.

### Minimal Broadcasts
Broadcast notifications include only session_id and event_count. Full event data is NOT sent over PubSub. Clients query for events explicitly when needed.

### No Event Preloading
Session queries do NOT preload events by default. Events are only loaded when explicitly requested via get_events/3 or Repo.preload.

### Index Utilization
Queries use composite (session_id, timestamp) index for O(log n) lookup and ordered scanning.

## Testing Strategy

### Unit Tests

**Validation Tests**:
- Valid event with all required fields passes validation
- Missing required fields fails validation
- Invalid event_type fails validation
- Data field accepts any map structure

**Side Effect Tests**:
- conversation_started sets external_conversation_id when nil
- conversation_started no-ops when already set to same value
- conversation_started logs warning when changing conversations
- session_status_changed updates session status
- error_occurred logs error but doesn't update session
- Unknown event types have no side effects

**Batch Processing Tests**:
- Multiple valid events insert successfully
- First invalid event fails entire batch
- Transaction rolls back on error

### Dependencies
- `CodeMySpec.Sessions.SessionEvent` - Event schema
- `CodeMySpec.Sessions.Session` - Session schema
- `CodeMySpec.Sessions.SessionsRepository` - Session queries
- `CodeMySpec.Repo` - Database operations
- `Phoenix.PubSub` - Broadcasting