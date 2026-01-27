# CodeMySpec.McpServers.Components.Tools.ListComponents

MCP tool that lists all components in a project, providing component summaries with essential metadata.

## Functions

### execute/2

Executes the list components tool operation within an MCP server context.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) ::
  {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame has a valid scope (active account and active project) using Validators.validate_scope/1
2. If validation succeeds, retrieve all components for the scope using Components.list_components/1
3. Map the component list to a tool response format using ComponentsMapper.components_list_response/1
4. Return a reply tuple with the response and frame
5. If validation fails, map the error atom to an error response using ComponentsMapper.error/1

**Test Assertions**:
- executes successfully with valid params and scope
- returns a tool response type
- validates scope requirements before execution
- handles missing active account error
- handles missing active project error
- returns properly formatted component list

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
