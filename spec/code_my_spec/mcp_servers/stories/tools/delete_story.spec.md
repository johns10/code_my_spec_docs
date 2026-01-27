# CodeMySpec.McpServers.Stories.Tools.DeleteStory

MCP tool that permanently deletes a user story from the system. This tool integrates with the Hermes MCP framework to expose story deletion functionality to AI agents like Claude Code.

## Functions

### execute/2

Executes the story deletion operation with validation and error handling.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that the frame contains a valid scope with active account and project via Validators.validate_scope/1
2. Retrieve the story by ID using Stories.get_story/2
3. Delete the story using Stories.delete_story/2
4. Map the successful deletion to a human-readable response via StoriesMapper.story_deleted_response/1
5. Handle error cases:
   - Return not_found_error if story is nil
   - Return validation_error for Ecto.Changeset errors
   - Return generic error for atom errors

**Test Assertions**:
- executes successfully with valid params and scope
- returns tool response with isError false on success
- returns not found error when story does not exist
- returns validation error for invalid deletion
- returns error response for missing scope

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
- Ecto.Changeset
