# CodeMySpec.McpServers.Components.Tools.OrphanedContexts

Lists all contexts with no user story and no dependencies. This MCP tool identifies orphaned contexts - components of type "context" that are not linked to any user stories and are not dependencies of any components that have stories.

## Functions

### execute/2

Executes the OrphanedContexts tool to retrieve all orphaned contexts within the current project scope.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, map(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the scope from the frame using Validators.validate_scope/1
2. If scope validation succeeds, call Components.list_orphaned_contexts/1 with the scope
3. Transform the list of orphaned contexts to a response format using ComponentsMapper.components_list_response/1
4. Return a reply tuple with the response and frame
5. If scope validation fails, transform the error to a response using ComponentsMapper.error/1 and return

**Test Assertions**:
- executes with valid params and scope
- returns tool response type
- validates scope before executing
- returns error response when scope is invalid

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
