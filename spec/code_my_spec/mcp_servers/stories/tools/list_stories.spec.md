# ListStories

MCP tool for listing stories in a project with pagination and optional search filtering. Returns full story details including acceptance criteria. For lightweight operations that only need titles, use list_story_titles instead.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the list stories tool with pagination and optional search filtering.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:

1. Validate the frame contains a valid scope (active account and project) using Validators.validate_scope/1
2. Extract limit parameter from params, defaulting to 20, capping at maximum of 100
3. Extract offset parameter from params, defaulting to 0
4. Build options keyword list with limit and offset
5. Add search parameter to options if provided in params
6. Call Stories.list_project_stories_paginated/2 with scope and options to retrieve paginated results
7. Receive tuple of {stories, total_count} from the stories context
8. Map the results to hybrid response format using StoriesMapper.stories_list_response/4
9. Return reply tuple with response and original frame
10. Handle validation errors by mapping to error response via StoriesMapper.error/1

**Test Assertions**:

- returns paginated results with default limit of 20 when no limit specified
- includes pagination metadata showing range (e.g., "Showing 1-20 of 25 stories")
- displays "Use offset: N to see more" hint when more results available
- respects custom limit parameter (e.g., limit: 3 returns 3 stories)
- respects offset parameter for pagination navigation
- filters results by search term matching title or description (case-insensitive)
- enforces maximum limit of 100 even when higher limit requested
- returns empty state message "No stories found" when project has no stories
- returns structured JSON data in response alongside human-readable summary
- validates scope contains active account and project before executing query
