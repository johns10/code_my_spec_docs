# CodeMySpec.Sessions.SessionEvent

Ecto schema representing a single event capturing real-time activity during
Claude Code session execution. Events are stored in an append-only log, providing
visibility into agent operations between command issuance and result submission.

## Fields

| Field       | Type         | Required   | Description                           | Constraints                |
| ----------- | ------------ | ---------- | ------------------------------------- | -------------------------- |
| id          | integer      | Yes (auto) | Primary key                           | Auto-generated             |
| session_id  | integer      | Yes        | Reference to parent session           | References sessions.id     |
| event_type  | EventType    | Yes        | Type of event (proxy_request, proxy_response, session_start) | Enum value |
| data        | map          | Yes        | Event payload data                    | Any map structure          |
| metadata    | map          | No         | Optional metadata about the event     | Any map structure          |
| sent_at     | utc_datetime | Yes        | Client-provided timestamp of event    | None                       |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp                    | Auto-generated             |
| updated_at  | utc_datetime | Yes (auto) | Last update timestamp                 | Auto-generated             |

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.EventType

## Functions

### changeset/2

Creates a changeset for SessionEvent used for creating new events.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast session_id, event_type, sent_at, data, and metadata from attributes
2. Validate session_id, event_type, sent_at, and data are required
3. Add foreign key constraint on session_id

**Test Assertions**:
- creates valid changeset with all required fields
- returns error changeset when session_id is missing
- returns error changeset when event_type is missing
- returns error changeset when sent_at is missing
- returns error changeset when data is missing
- creates valid changeset when metadata is omitted
- creates valid changeset with metadata included
- returns error changeset with invalid session_id foreign key
- accepts any map structure for data field
- accepts any map structure for metadata field
