# ValidateDependencyGraph

MCP tool that validates the component dependency graph for circular dependencies. Returns validation result indicating success or detailed list of detected cycles. Circular dependencies violate clean architecture principles and make code harder to test and maintain.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response

## Functions

### execute/2

Validates the dependency graph for the current scope and returns results indicating whether circular dependencies exist.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the current scope has active account and project using `Validators.validate_scope/1`
2. If scope is valid, call `Components.validate_dependency_graph/1` with the scope
3. Transform the validation result into an MCP response using `ArchitectureMapper.validation_result_response/1`
4. Return the formatted response with the frame
5. If scope validation fails, return error response via `ArchitectureMapper.error/1`

**Test Assertions**:
- returns valid result when no circular dependencies exist
- returns valid result when no components exist
- returns valid result when components have no dependencies
- detects simple circular dependency (A→B, B→A)
- includes component information (id, name, type, module_name) in cycle details
- detects multiple separate circular dependencies
- handles complex dependency graph with one cycle
- returns error response for invalid scope (missing active account/project)
- validates complex architecture with no cycles (controllers → contexts → schemas)
- response includes validation status, message, and cycles array when invalid
- response is tool type with isError=false for validation results
- response is tool type with isError=true for scope errors
