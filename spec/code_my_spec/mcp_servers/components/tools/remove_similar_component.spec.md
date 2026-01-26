# CodeMySpec.McpServers.Components.Tools.RemoveSimilarComponent

MCP tool that removes a similar component relationship between two components. This tool is exposed via the ComponentsServer MCP interface for AI agent consumption.

## Fields

| Field | Type | Required | Description | Constraints |
| ----- | ---- | -------- | ----------- | ----------- |
| component_id | integer | Yes | ID of the source component | Must reference existing component |
| similar_component_id | integer | Yes | ID of the similar component to remove | Must reference existing component |

## Functions

### execute/2

Executes the remove similar component operation via MCP tool protocol.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope contains active account and project via Validators.validate_scope/1
2. Fetch source component using Components.get_component!/2 with component_id
3. Fetch similar component using Components.get_component!/2 with similar_component_id
4. Remove similar component relationship via Components.remove_similar_component/3
5. Build success response with component summaries and deleted flag
6. Handle validation errors by formatting changeset via ComponentsMapper.validation_error/1
7. Handle atom errors by formatting via ComponentsMapper.error/1
8. Return {:reply, response, frame} tuple for Hermes protocol

**Test Assertions**:
- executes with valid params and scope, returning deleted: true response
- returns error when relationship does not exist
- raises Ecto.NoResultsError when component does not exist
- response contains component and similar_component summaries
- response type is :tool
- successful response includes deleted: true flag

### similar_component_response/2

Builds MCP tool response for successful similar component removal.

```elixir
@spec similar_component_response(Component.t(), Component.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create base tool response via Response.tool/0
2. Build JSON payload with component and similar_component summaries
3. Add deleted: true flag to indicate removal success
4. Return formatted Hermes response

**Test Assertions**:
- returns tool response with JSON content
- includes component summary with id, name, type, module_name
- includes similar_component summary with id, name, type, module_name
- includes deleted: true flag

### component_summary/1

Extracts summary fields from component struct for response payload.

```elixir
@spec component_summary(Component.t()) :: map()
```

**Process**:
1. Extract id, name, type, and module_name from component
2. Return map with these four fields

**Test Assertions**:
- returns map with id, name, type, module_name keys
- all values match component struct values

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
- Ecto.Changeset
