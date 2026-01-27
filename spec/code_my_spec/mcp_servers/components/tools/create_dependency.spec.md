# CodeMySpec.McpServers.Components.Tools.CreateDependency

MCP tool that creates dependency relationships between components and validates the dependency graph for circular dependencies.

## Functions

### execute/2

Executes the create dependency operation, validating scope, creating the dependency, and checking for circular dependency violations.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame has a valid scope (active account and project) using Validators.validate_scope/1
2. Create the dependency using Components.create_dependency/2 with scope and params
3. Validate the entire dependency graph for circular dependencies using Components.validate_dependency_graph/1
4. If successful, fetch the created dependency with preloaded associations using Components.get_dependency!/2
5. Return a tool response with dependency details including source and target component summaries
6. Handle errors: validation errors (Ecto.Changeset), circular dependency errors (list of cycles), or atom errors

**Test Assertions**:
- creates dependency with valid source and target component IDs
- returns tool response with dependency ID and component details
- prevents self-dependencies (source equals target)
- detects circular dependencies between two components
- returns error response for circular dependencies with cycle description
- validates scope requirements before execution

### dependency_response/1

Formats a successful dependency creation response with component summaries.

```elixir
@spec dependency_response(CodeMySpec.Components.Dependency.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create a tool response using Hermes.Server.Response.tool/0
2. Build JSON payload with dependency ID, source component summary, and target component summary
3. Return formatted response using Response.json/2

**Test Assertions**:
- formats dependency with ID and component summaries
- includes source component details (id, name, type, module_name)
- includes target component details (id, name, type, module_name)

### component_summary/1

Extracts essential component information for inclusion in responses.

```elixir
@spec component_summary(CodeMySpec.Components.Component.t()) :: map()
```

**Process**:
1. Build map with component ID, name, type, and module_name
2. Return component summary map

**Test Assertions**:
- extracts id, name, type, and module_name fields
- returns map with all required fields

### circular_dependency_error/1

Formats an error response when circular dependencies are detected.

```elixir
@spec circular_dependency_error(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Map over the list of cycle maps to format each cycle path
2. Join component names in each cycle path with " -> " separator
3. Append the first component to complete the cycle visualization (path -> first component)
4. Create error message with "Circular dependency detected" header and formatted cycle descriptions
5. Return tool error response using Response.error/2

**Test Assertions**:
- formats single cycle with path visualization
- formats multiple cycles with separate path descriptions
- includes descriptive error message header
- shows complete cycle path (A -> B -> A format)

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
- Ecto.Changeset
