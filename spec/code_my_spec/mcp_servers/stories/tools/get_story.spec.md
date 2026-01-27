# CodeMySpec.McpServers.Stories.Tools.GetStory

MCP tool that retrieves a single story by ID with full details including acceptance criteria. Part of the Stories MCP Server exposing story data to AI agents (Claude Code/Desktop).

## Functions

### execute/2

Executes the GetStory tool to retrieve a story by ID with full details.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame contains a valid scope (active account and project) using Validators
2. Extract story_id from params
3. Fetch the story using Stories.get_story/2 with the validated scope
4. Pattern match on the result:
   - If story found: Map to hybrid response format via StoriesMapper.story_get_response/1
   - If story is nil: Return not_found_error via StoriesMapper
   - If validation error: Return error response via StoriesMapper
5. Return {:reply, response, frame} tuple

**Test Assertions**:
- returns tool response with story data for valid story ID
- returns not found error for non-existent story ID
- response type is :tool for successful retrieval
- response includes isError flag for not found cases
- error message indicates story not found and suggests verifying ID

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
