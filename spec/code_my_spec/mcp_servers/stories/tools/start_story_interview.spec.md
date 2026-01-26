# StartStoryInterview

MCP tool that initiates an interactive interview session to help develop and refine user stories. Acts as an expert Product Manager guiding users through thoughtful questions about requirements, acceptance criteria, dependencies, and edge cases.

## Type

module

## Functions

### execute/2

Starts an interactive interview session with context about existing project stories and prompts to guide story refinement.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) ::
        {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that the frame contains a valid scope with active account and project
2. Retrieve all stories for the current project scope
3. Format existing stories into a contextual summary
4. Build a comprehensive prompt that includes:
   - Role definition as expert Product Manager
   - Current stories context (formatted with titles, descriptions, acceptance criteria)
   - Instructions for conducting the interview
   - Guidelines for story refinement (format, dependencies, tenancy, security, complexity)
5. Return prompt response using StoriesMapper

**Test Assertions**:
- executes successfully with valid scope and returns tool response
- response contains Product Manager role description
- response is not an error

### format_stories_context/1

Formats a list of stories into a readable context string for the interview prompt.

```elixir
@spec format_stories_context([CodeMySpec.Stories.Story.t()]) :: String.t()
```

**Process**:
1. Check if stories list is empty - return "No stories currently exist" message
2. Map each story through format_story_summary/1
3. Join formatted summaries with double newlines

**Test Assertions**:
- returns appropriate message when story list is empty
- formats multiple stories with proper spacing

### format_story_summary/1

Formats a single story into a summary with title, description, and acceptance criteria.

```elixir
@spec format_story_summary(CodeMySpec.Stories.Story.t()) :: String.t()
```

**Process**:
1. Extract acceptance_criteria from story
2. If criteria is empty, use "No acceptance criteria defined" placeholder
3. If criteria exists, format as bulleted list with "- " prefix
4. Build formatted string with:
   - Bold title
   - Description
   - "Acceptance Criteria:" label
   - Formatted criteria list

**Test Assertions**:
- formats story with title and description
- shows placeholder when no acceptance criteria exist
- formats acceptance criteria as bulleted list

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
