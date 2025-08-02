# Story Schema

## Purpose
Defines the Story entity structure representing user stories with title, description, acceptance criteria, and project association.

## Core Fields
- **id**: Binary UUID primary key
- **title**: Story name (3-200 characters, required)
- **description**: Detailed story description (10-2000 characters, required)
- **acceptance_criteria**: Array of acceptance criteria strings (at least one required)
- **priority**: Integer priority level (default: 1)
- **status**: Enum values - in_progress, completed, dirty (default: in_progress)
- **project_id**: Required foreign key to parent project
- **component_id**: Optional foreign key to component that satisfies this story
- **locked_by**: Optional user ID who currently has the story locked
- **locked_at**: Timestamp when story was locked
- **lock_expires_at**: Automatic lock expiration timestamp (prevents permanent locks)
- **timestamps**: Standard inserted_at and updated_at fields

## Schema Structure
```elixir
schema "stories" do
  field :title, :string
  field :description, :string
  field :acceptance_criteria, {:array, :string}
  field :priority, :integer, default: 1
  field :status, Ecto.Enum, values: [:in_progress, :completed, :dirty], default: :in_progress
  
  field :locked_by, :binary_id
  field :locked_at, :utc_datetime
  field :lock_expires_at, :utc_datetime
  
  belongs_to :project, CodeMySpec.Projects.Project
  belongs_to :component, CodeMySpec.Components.Component
  
  timestamps()
end
```

## Validations
- Title and description are required fields
- Acceptance criteria must have at least one criterion
- Each acceptance criterion must be at least 5 characters
- Priority must be positive integer

## PaperTrail Integration
- Automatic versioning enabled for all Story changes
- Captures user information as originator when available
- Stores metadata including IP address, user agent, and change reason
- Versions accessible through PaperTrail.Version queries

## Database Indexes
- Primary key on id (integer)
- Foreign key index on project_id for query performance
- Foreign key index on component_id for query performance
- Status index for filtering stories by current state
- Priority index for ordering by importance

## Associations
- **Project**: Required parent project relationship (belongs_to)
- **Component**: Optional component that satisfies this story (belongs_to)

## Lock Prevention Strategy
- Lock expiration timestamp prevents permanent locks
- Background job cleans up expired locks automatically
- Lock duration typically 15-30 minutes with ability to extend
- Lock removed at the end of edit operation

## Query Patterns
Common query helpers for filtering by project, status, priority, tags, and text search. Stories typically ordered by priority descending, then by creation date.