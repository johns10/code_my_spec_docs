# CodeMySpec.AcceptanceCriteria

## Type

context

Phoenix context for managing acceptance criteria as first-class entities. Acceptance criteria belong to stories and represent testable conditions that define when a story is complete. This context extracts acceptance criteria from embedded strings within stories into proper domain entities with status tracking and verification capabilities.

## Delegates

- list_story_criteria/2: AcceptanceCriteria.AcceptanceCriteriaRepository.list_story_criteria/2
- get_criterion!/2: AcceptanceCriteria.AcceptanceCriteriaRepository.get_criterion!/2
- get_criterion/2: AcceptanceCriteria.AcceptanceCriteriaRepository.get_criterion/2

## Dependencies

- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Components

### AcceptanceCriteria.Criterion

Ecto schema representing a single acceptance criterion. Contains the description text, verification status, and belongs to a story. Scoped to account and project for multi-tenancy.

### AcceptanceCriteria.AcceptanceCriteriaRepository

Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filtering by story and verification status filtering.
