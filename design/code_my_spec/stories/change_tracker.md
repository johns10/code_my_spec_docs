# Stories Change Tracker

## Purpose
Publishes standardized events when stories are created, updated, or deleted to notify other contexts about changes requiring downstream artifact updates.

## Event Types

### Story Created
- **Topic**: `"stories:created"`
- **Payload**: Story struct with full data
- **Triggered**: After successful story creation
- **Purpose**: Notify other contexts that new story is available

### Story Updated
- **Topic**: `"stories:updated"`
- **Payload**: Story struct with updated data plus change metadata
- **Triggered**: After successful story update
- **Purpose**: Mark downstream artifacts as dirty, trigger regeneration workflows

### Story Deleted
- **Topic**: `"stories:deleted"`
- **Payload**: Story struct with full data
- **Triggered**: After successful story deletion
- **Purpose**: Clean up references and dependent artifacts

### Story Locked
- **Topic**: `"stories:locked"`
- **Payload**: Story struct with full data
- **Triggered**: When editing lock is acquired
- **Purpose**: Prevent concurrent editing attempts

### Story Unlocked
- **Topic**: `"stories:unlocked"`
- **Payload**: Story struct with full data
- **Triggered**: When editing lock is released
- **Purpose**: Allow other users to edit story

## Event Structure
```elixir
%{
  event_type: :story_created | :story_updated | :story_deleted | :story_locked | :story_unlocked,
  timestamp: DateTime.t(),
  data: %{
    # Event-specific payload
  },
  metadata: %{
    # Additional context like IP, user agent, etc.
  }
}
```

## Publishing Pattern
- Events published via Phoenix.PubSub after successful database operations
- Events are fire-and-forget - publishing failures don't affect core operations

## Subscriber Topics
- **Project-specific**: `"stories:project:#{project_id}"`
- **Global stories**: `"stories:*"`

## Integration Points
- Called from Stories context after successful CRUD operations
- Triggered by PaperTrail callbacks for automatic change detection
- Used by regeneration approval workflows to detect dirty artifacts
- Consumed by real-time UI updates via Phoenix LiveView

## Downstream Effects
- **Specifications**: Mark as dirty when stories change
- **Test Cases**: Mark as dirty when stories change
- **Documentation**: Mark as dirty when stories change
- **UI Updates**: Real-time story list updates
- **Audit Logs**: Enhanced logging with business context

## Error Handling
- Event publishing failures logged but don't affect core operations
- Malformed events caught and logged for debugging
- Retry logic for transient PubSub failures
- Dead letter queue for failed events if needed

## Dependencies
- **Phoenix.PubSub**: For event broadcasting
- **Stories Context**: For story data and operations
- **PaperTrail**: For change detection and metadata