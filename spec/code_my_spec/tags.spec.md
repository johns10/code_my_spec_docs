# CodeMySpec.Tags

**Type**: context

Simple tagging system for organizing stories. Tags are strings scoped to a project, and stories can have multiple tags.

## Purpose

Enable flexible organization of stories beyond hierarchical structures. Tags allow stories to be grouped by theme (e.g., "fraud-detection", "onboarding"), feature area, or any other user-defined category.

## Key Concepts

- **Tags are strings** - Simple identifiers like `"accounts"`, `"driver-onboarding"`, `"fraud-detection"`
- **Project-scoped** - Tags are unique by name within a project
- **Many-to-many** - Stories can have multiple tags, tags can have multiple stories

## Delegates

- list_project_tags/1: Tags.TagRepository.list_project_tags/1
- get_tag!/2: Tags.TagRepository.get_tag!/2
- get_tag/2: Tags.TagRepository.get_tag/2
- get_or_create_tag/2: Tags.TagRepository.get_or_create_tag/2

## Functions

### add_tag/3

Adds a tag to a story. Creates the tag if it doesn't exist.

```elixir
@spec add_tag(Scope.t(), Story.t(), String.t()) :: {:ok, StoryTag.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:
- creates tag if it doesn't exist
- creates story_tag association
- returns error for duplicate (idempotent)

### remove_tag/3

Removes a tag from a story.

```elixir
@spec remove_tag(Scope.t(), Story.t(), String.t()) :: :ok | {:error, :not_found}
```

### list_story_tags/2

Lists all tags for a story.

```elixir
@spec list_story_tags(Scope.t(), Story.t()) :: [Tag.t()]
```

### find_stories_by_tag/2

Finds all stories with a given tag.

```elixir
@spec find_stories_by_tag(Scope.t(), String.t()) :: [Story.t()]
```

## Dependencies

- CodeMySpec.Tags.Tag
- CodeMySpec.Tags.StoryTag
- CodeMySpec.Tags.TagRepository
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope

## Components

### Tags.Tag

Ecto schema for tags. Fields: id, name, project_id. Unique on (name, project_id).

### Tags.StoryTag

Join table: tag_id (FK to tags), story_id (FK to stories). Unique on (tag_id, story_id).

### Tags.TagRepository

Repository for CRUD operations.
