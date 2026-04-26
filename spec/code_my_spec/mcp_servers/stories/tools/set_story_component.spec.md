# CodeMySpec.McpServers.Stories.Tools.SetStoryComponent

MCP tool for linking a story to a component that implements it. This tool allows AI agents to track which components satisfy which user stories, enabling traceability from requirements through implementation.

## Type

module

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Ecto.Changeset

## Functions

### execute/2

Executes the tool to link a story to a component.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame using Validators.validate_scope/1 to ensure active account and project exist
2. Retrieve story from Stories context using story_id parameter
3. Call Stories.set_story_component/3 to link the component to the story
4. Map successful result to hybrid response using StoriesMapper.story_component_set_response/1
5. Handle error cases: story not found (nil), validation errors (Ecto.Changeset), not found errors (:not_found), or generic atom errors
6. Return reply tuple with response and frame

**Test Assertions**:
- executes with valid params and scope
- returns error when story not found
- returns error when component not found
- validates scope before executing
- returns tool response with isError false on success
- returns tool response with isError true on failure
- includes story data in successful response

