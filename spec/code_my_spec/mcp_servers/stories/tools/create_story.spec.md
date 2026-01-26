# CreateStory

MCP tool for creating user stories with title, description, and acceptance criteria. This tool transforms acceptance criteria strings into nested criteria parameters for story creation and returns a hybrid response format containing both human-readable summary and structured JSON data.

## Functions

### execute/2

Executes the create story tool with validated parameters and scope context.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) ::
  {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame using Validators.validate_scope/1
2. Transform input params to convert acceptance_criteria list to nested criteria maps
3. Call Stories.create_story/2 with scope and transformed params
4. Map successful story creation to StoriesMapper.story_response/1
5. Handle Ecto.Changeset errors through StoriesMapper.validation_error/1
6. Handle atom errors through StoriesMapper.error/1
7. Return {:reply, response, frame} tuple

**Test Assertions**:
- executes with valid params and scope
- returns tool response with isError false
- returns story data in response

### transform_params/1

Transforms acceptance_criteria strings into nested criteria parameters.

```elixir
@spec transform_params(map()) :: map()
```

**Process**:
1. Extract acceptance_criteria list from params (default empty list)
2. Map each string to %{description: description} map
3. Put transformed criteria into :criteria key
4. Return transformed params map

**Test Assertions**:
- converts acceptance_criteria strings to criteria maps
- handles empty acceptance_criteria list
- preserves other param keys

## Dependencies

- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- CodeMySpec.Stories
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
- Ecto.Changeset
