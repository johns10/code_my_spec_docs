# CodeMySpec.Sessions.InteractionEvent

Ecto schema representing a single event capturing real-time activity during a specific interaction execution. Events are stored in an append-only log, providing visibility into agent operations between command issuance and result submission.

## Fields

| Field          | Type              | Required   | Description                                      | Constraints                                                                                      |
| -------------- | ----------------- | ---------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| id             | integer           | Yes (auto) | Primary key                                      | Auto-generated                                                                                   |
| interaction_id | binary_id         | Yes        | Foreign key to the parent Interaction            | References interactions.id                                                                       |
| event_type     | EventType         | Yes        | Type of event captured                           | Values: [:proxy_request, :proxy_response, :session_start, :session_end, :notification, :post_tool_use, :user_prompt_submit, :stop] |
| data           | map               | Yes        | Event payload data                               | Accepts any map structure                                                                        |
| metadata       | map               | No         | Optional additional metadata                     |                                                                                                  |
| sent_at        | utc_datetime_usec | Yes        | Client-provided timestamp when event was sent    |                                                                                                  |
| inserted_at    | utc_datetime_usec | Yes (auto) | Record creation timestamp                        | Auto-generated                                                                                   |
| updated_at     | utc_datetime_usec | Yes (auto) | Record update timestamp                          | Auto-generated                                                                                   |

## Functions

### changeset/2

Creates a changeset for InteractionEvent. Used for creating new events in the append-only log.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast interaction_id, event_type, sent_at, data, and metadata fields from input attributes
2. Validate that interaction_id, event_type, sent_at, and data are required
3. Apply foreign key constraint on interaction_id

**Test Assertions**:
- returns valid changeset with all required fields present
- returns invalid changeset when interaction_id is missing
- returns invalid changeset when event_type is missing
- returns invalid changeset when sent_at is missing
- returns invalid changeset when data is missing
- accepts valid event_type values (:proxy_request, :proxy_response, :session_start, :session_end, :notification, :post_tool_use, :user_prompt_submit, :stop)
- returns invalid changeset for unknown event_type values
- allows metadata to be nil or omitted
- accepts any map structure for data field
- handles camelCase event_type input via EventType custom type

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.EventType
