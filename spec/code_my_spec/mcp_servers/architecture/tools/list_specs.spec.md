# ListSpecs

MCP tool that lists all component specs in the project with optional filtering by component type.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the ListSpecs tool to retrieve and return component specifications.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the scope from the frame using Validators.validate_scope/1
2. Call list_components/2 with the validated scope and params
3. Map the components to a specs list response using ArchitectureMapper.specs_list_response/1
4. Return reply tuple with response and frame
5. On error, map error to error response using ArchitectureMapper.error/1

**Test Assertions**:
- lists all specs in project when no type filter provided
- filters specs by type when type parameter is provided
- returns empty list when no components exist
- returns empty list when filtering by type with no matches
- includes component metadata in response (id, name, type, module_name, description, spec_path)
- returns error when scope is invalid (missing current_scope in frame assigns)
- handles various component types (context, module, schema, repository, liveview, coordinator)
- generates correct spec_path in format docs/spec/underscore_module_name.spec.md

## Delegates

None
