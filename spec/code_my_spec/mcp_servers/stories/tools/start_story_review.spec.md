# CodeMySpec.McpServers.Stories.Tools.StartStoryReview

MCP tool that initiates a comprehensive review of user stories in a project by generating an AI prompt with review criteria and story context.

## Type

module

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame

## Functions

### execute/2

Executes the story review tool by validating scope, fetching project stories, and generating a review prompt.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the current scope using Validators.validate_scope/1 to ensure active account and project
2. Fetch all project stories using Stories.list_project_stories/1
3. Generate a comprehensive review prompt containing:
   - Review criteria (story format, business value, acceptance criteria, sizing, dependencies, edge cases)
   - Formatted story context via format_stories_context/1
   - Review process instructions for the AI agent
4. Return prompt response via StoriesMapper.prompt_response/1 on success
5. Return error response via StoriesMapper.error/1 if validation fails

**Test Assertions**:
- executes successfully with valid scope and returns tool response
- response contains "comprehensive story review" text
- response is not an error (isError == false)
- response type is :tool

### format_stories_context/1

Formats a list of stories into human-readable context for the review prompt.

```elixir
@spec format_stories_context(list(Story.t())) :: String.t()
```

**Process**:
1. Return "No stories currently exist for this project." if list is empty
2. Enumerate stories with index starting at 1
3. Map each story to formatted output via format_story_for_review/1
4. Join formatted stories with double newlines

**Test Assertions**:
- returns message for empty story list
- formats multiple stories with proper numbering
- separates stories with double newlines

### format_story_for_review/1

Formats a single story with its index into a review-ready text block.

```elixir
@spec format_story_for_review({Story.t(), integer()}) :: String.t()
```

**Process**:
1. Extract acceptance criteria from story
2. If criteria list is empty, display "❌ No acceptance criteria defined"
3. If criteria exist, format each as "✓ {criterion}" on separate lines
4. Return formatted string with story number, title, description, and criteria section

**Test Assertions**:
- formats story with acceptance criteria properly
- shows "No acceptance criteria defined" for stories without criteria
- includes story index, title, and description
- formats criteria with checkmark prefix
