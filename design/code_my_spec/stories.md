# Stories

## Purpose
Manages user stories lifecycle including creation, editing, versioning, and change tracking.

## Entity Ownership
- User Story entities with title, description, acceptance criteria, and metadata
- Story versioning and change tracking via PaperTrail
- Story locking mechanism for concurrent editing prevention
- Downstream artifact dependency tracking and "dirty" state management

## Public API
```elixir
# Story Management
@spec create_story(story_attrs()) :: {:ok, Story.t()} | {:error, Changeset.t()}
@spec update_story(story_id(), story_attrs()) :: {:ok, Story.t()} | {:error, Changeset.t()}
@spec delete_story(story_id()) :: {:ok, Story.t()} | {:error, Changeset.t()}
@spec get_story(story_id()) :: {:ok, Story.t()} | {:error, :not_found}
@spec list_stories(project_id()) :: [Story.t()]

# Story Locking
@spec lock_story(story_id(), user_id()) :: {:ok, :locked} | {:error, :already_locked}
@spec unlock_story(story_id(), user_id()) :: {:ok, :unlocked} | {:error, :not_locked}
@spec get_story_lock(story_id()) :: {:ok, Lock.t()} | {:error, :not_found}

# Change Tracking & Versioning
@spec get_story_versions(story_id()) :: [PaperTrail.Version.t()]
@spec get_story_at_version(story_id(), version()) :: {:ok, Story.t()} | {:error, :not_found}

# Custom Types
@type story_id() :: binary()
@type user_id() :: binary()
@type project_id() :: binary()
@type artifact_id() :: binary()
@type version() :: integer()
@type change_type() :: :title | :description | :acceptance_criteria | :created | :deleted
@type action() :: :create | :update | :delete | :list | :get
@type story_attrs() :: %{
  title: binary(),
  description: binary(),
  acceptance_criteria: [binary()],
  project_id: project_id()
}
```

## State Management Strategy
### Persistence
- Ecto schemas for Story and Lock entities
- PaperTrail for automatic versioning and change tracking
- Database transactions for atomic story updates with version creation

### Change Tracking
- PaperTrail handles version creation and metadata capture
- Event-driven architecture using Phoenix PubSub for change notifications
- Downstream artifact dependency graph maintained in memory/cache

### Locking Strategy
- Lock fields stored directly on Story entity (locked_by, locked_at, lock_expires_at)
- UI checks lock expiration before allowing edits
- Expired locks automatically cleared when user attempts to edit
- Lock duration typically 15-30 minutes with UI-based extension

## Component Diagram
```
Stories
├── Story (Schema)
|   ├── title, description, acceptance_criteria
|   ├── project_id, inserted_at, updated_at, lock fields
|   └── PaperTrail versioning
└── Repository
    ├── Basic CRUD operations
    └── Lock management queries
```

## Dependencies
- **PaperTrail**: For automatic versioning and change tracking
- **Phoenix.PubSub**: For broadcasting change events
- **Ecto**: For database persistence and transactions

## Execution Flow
1. **Story Creation**: Validate input, create story with PaperTrail version, broadcast change event
2. **Story Locking**: UI checks lock expiration, clears expired locks, sets new lock on edit attempt
3. **Story Update**: Validate lock ownership, update story in transaction, PaperTrail creates version, broadcast via PubSub
4. **Change Tracking**: Identify downstream dependencies, mark artifacts as dirty, trigger regeneration approval workflow
5. **Event Broadcasting**: Notify interested contexts about story changes for workflow coordination