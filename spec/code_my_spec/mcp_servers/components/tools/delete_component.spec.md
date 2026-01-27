# CodeMySpec.McpServers.Components.Tools.DeleteComponent

MCP tool that deletes a component from the system. Validates scope (active account and project), retrieves the component, deletes it from the database, and broadcasts the deletion event. Implements the Hermes MCP tool protocol for integration with AI agents via Claude Code/Desktop.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the delete component tool with scope validation and error handling.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Extract and validate scope from frame using Validators.validate_scope/1
2. Retrieve component by ID using Components.get_component!/2 (raises if not found)
3. Delete component using Components.delete_component/2
4. Map successful result to tool response using ComponentsMapper.component_response/1
5. Handle Ecto.Changeset errors with ComponentsMapper.validation_error/1
6. Handle atom errors with ComponentsMapper.error/1
7. Rescue Ecto.NoResultsError and return ComponentsMapper.not_found_error/0

**Test Assertions**:
- executes with valid params and scope, returns success response with component data
- returns error response for non-existent component ID
- returns error response for invalid scope (missing active account or project)
