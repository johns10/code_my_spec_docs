# CodeMySpec.Stories

## Type

context

Phoenix context for managing user stories within projects. Provides the public API for story CRUD operations, component assignments, and PubSub notifications. Supports pluggable implementations for local database access (StoriesRepository) or remote HTTP API (RemoteClient) based on configuration.

## Delegates

- list_stories/1: StoriesRepository.list_stories/1
- list_project_stories/1: StoriesRepository.list_project_stories/1
- list_project_stories_by_priority/1: StoriesRepository.list_project_stories_by_priority/1
- list_unsatisfied_stories/1: StoriesRepository.list_unsatisfied_stories/1
- list_component_stories/2: StoriesRepository.list_component_stories/2
- get_story!/2: StoriesRepository.get_story!/2
- get_story/2: StoriesRepository.get_story/2

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Stories.Story
- CodeMySpec.Stories.StoriesRepository
- CodeMySpec.Tags
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Components

### Stories.Story

Ecto schema representing a user story with title, description, acceptance criteria, and optional component assignment. Supports locking for concurrent editing.

### Stories.StoriesRepository

Repository for story CRUD operations with direct database access. Provides query composables for filtering, searching, and pagination. Includes pessimistic locking support with time-based expiration.

### Stories.RemoteClient

HTTP client for Stories API using Req. Used in CLI/VSCode environments to communicate with remote server via OAuth2 authentication.

### Stories.Markdown

Handles parsing and formatting of user stories in markdown format for import/export functionality. Converts between markdown documents and story attribute maps.
