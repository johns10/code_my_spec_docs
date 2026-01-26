# CodeMySpec.McpServers.Stories.Tools.ListStoryTitles

Lists story titles in a project (lightweight).

Returns just ID, title, and component_id - no criteria or full descriptions. Use this for quick lookups, selection lists, or when you need to find a story ID.

This MCP tool is exposed via the Hermes server framework and provides a lightweight alternative to full story listing operations.

## Functions

### execute/2

Executes the list story titles tool with optional search filtering.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that the frame contains valid scope (active account and project)
2. Extract optional search parameter from params map
3. Build options list with search filter if provided
4. Call Stories.list_story_titles/2 with scope and options
5. Map results to hybrid response format (summary + JSON data)
6. Return reply tuple with response and frame
7. If validation fails, return error response via StoriesMapper

**Test Assertions**:
- returns lightweight list of story titles with id, title, and component_id
- excludes criteria and description fields from response
- filters stories by search term (case-insensitive title matching)
- returns stories sorted alphabetically by title
- returns empty state message when no stories found
- handles missing scope with appropriate error response

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
