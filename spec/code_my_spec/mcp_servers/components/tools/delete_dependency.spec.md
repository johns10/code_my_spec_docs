# CodeMySpec.McpServers.Components.Tools.DeleteDependency

MCP tool for deleting dependency relationships between components. This tool exposes the dependency deletion capability to AI agents via the Hermes MCP protocol, allowing them to manage component architecture by removing dependency relationships.

## Functions

### execute/2

Executes the delete dependency tool with the provided parameters and frame context.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) ::
        {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame to ensure active account and project are present
2. Retrieve dependency by ID using scope and params.id
3. Delete dependency via Components context
4. Build response containing deleted dependency data with source and target component summaries
5. Return reply tuple with response and frame

**Test Assertions**:
- executes successfully with valid params and scope
- returns response with deleted: true flag
- includes source component summary with id, name, type, and module_name
- includes target component summary with id, name, type, and module_name
- raises Ecto.NoResultsError for non-existent dependency
- validates scope has active account
- validates scope has active project

### dependency_response/1

Builds a Hermes tool response for a deleted dependency.

```elixir
@spec dependency_response(CodeMySpec.Components.Dependency.t()) ::
        Hermes.Server.Response.t()
```

**Process**:
1. Create new tool response using Hermes.Server.Response
2. Build JSON payload containing dependency id, source_component summary, target_component summary, and deleted: true flag
3. Return formatted response

**Test Assertions**:
- returns tool response type
- includes dependency id
- includes deleted: true flag
- includes source_component summary
- includes target_component summary

### component_summary/1

Creates a summary map for a component with essential identification fields.

```elixir
@spec component_summary(CodeMySpec.Components.Component.t()) :: map()
```

**Process**:
1. Extract id, name, type, and module_name from component struct
2. Build map with these four fields
3. Return summary map

**Test Assertions**:
- returns map with id field
- returns map with name field
- returns map with type field
- returns map with module_name field

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
- Ecto.Changeset
