# CreateStories

MCP tool for batch creation of user stories. Processes multiple story creation requests in a single operation, returning successful creations and validation errors for failed attempts.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes batch creation of multiple user stories within the authenticated scope.

```elixir
@spec execute(%{stories: [map()]}, Hermes.Server.Frame.t()) ::
        {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame contains a valid scope with active account and project
2. Iterate through the stories list with index tracking
3. For each story, attempt creation via Stories.create_story/2
4. Accumulate successes and failures separately (with index for failures)
5. Reverse both accumulator lists to maintain original order
6. If no failures, return success response with all created stories
7. If failures exist, return partial failure response with successes and indexed errors
8. If scope validation fails, return error response

**Test Assertions**:
- executes with valid params and scope
- creates multiple stories successfully
- returns tool response with isError false
- includes all created stories in response
- handles validation errors for individual stories
- returns partial success when some stories fail
- includes error index mapping for failed stories
- returns error when scope validation fails
- preserves story order in response
