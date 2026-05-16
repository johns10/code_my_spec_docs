# CodeMySpec.Tags

## Type

context

Simple tagging system for organizing stories. Tags are strings scoped to a
project, and stories can have multiple tags. Enables flexible organization
beyond hierarchical structures: stories can be grouped by theme
(e.g., `"fraud-detection"`, `"onboarding"`), feature area, or any
user-defined category. Tags are simple identifiers, project-scoped (unique by
name within a project), and many-to-many with stories.

## Delegates

- list_project_tags/1: Tags.TagRepository.list_project_tags/1
- get_tag!/2: Tags.TagRepository.get_tag!/2
- get_tag/2: Tags.TagRepository.get_tag/2
- get_or_create_tag/2: Tags.TagRepository.get_or_create_tag/2

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
