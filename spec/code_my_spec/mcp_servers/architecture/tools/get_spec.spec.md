# CodeMySpec.McpServers.Architecture.Tools.GetSpec

MCP tool that retrieves a component specification with metadata and content. Accepts either a module name or component ID, loads the component with dependencies and dependents, resolves the spec file path, reads the file content, and returns a structured response containing component details and spec content.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Main entry point for the GetSpec tool that retrieves a component spec file.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame assigns using Validators.validate_scope/1
2. Create a CLI environment instance for file operations
3. Find component by module_name or component_id parameter
4. Build spec file path from component module name
5. Read spec file content using environment
6. Destroy environment instance
7. Return spec response with component details, path, and content via ArchitectureMapper
8. If any step fails, return error response via ArchitectureMapper

**Test Assertions**:
- retrieves spec by module name successfully
- retrieves spec by component ID successfully
- includes dependency information in response
- includes dependent components in response
- returns error when neither module_name nor component_id provided
- returns error when component not found by module_name
- returns error when component not found by ID
- returns error when spec file doesn't exist
- returns error when scope is invalid
- handles spec files with complex content including all sections

### find_component/2

Finds a component by module name or component ID and loads dependencies.

```elixir
@spec find_component(Scope.t(), map()) :: {:ok, Component.t()} | {:error, String.t()}
```

**Process**:
1. Check if params contains module_name key with non-nil value
2. If module_name present, call Components.get_component_by_module_name/2
3. If found, load dependencies via load_dependencies/2
4. Check if params contains component_id key with non-nil value
5. If component_id present, call ComponentRepository.get_component_with_dependencies/2
6. If neither parameter provided, return error message
7. If component not found, return appropriate error message

**Test Assertions**:
- finds component by module name
- finds component by component ID
- loads dependencies for component found by module name
- returns error when component not found
- returns error when neither parameter provided

### load_dependencies/2

Ensures component has dependencies loaded by fetching full version from repository.

```elixir
@spec load_dependencies(Component.t(), Scope.t()) :: Component.t()
```

**Process**:
1. Call ComponentRepository.get_component_with_dependencies/2 with component ID
2. If result is nil, return original component
3. Otherwise return component with loaded dependencies

**Test Assertions**:
- returns component with loaded dependencies
- returns original component when repository lookup fails

### build_spec_path/1

Constructs the file path for a component's spec file based on module name.

```elixir
@spec build_spec_path(String.t()) :: {:ok, String.t()}
```

**Process**:
1. Split module name by dots to get path segments
2. Convert each segment to underscore case using Macro.underscore/1
3. Join segments with "docs/spec" prefix using Path.join/1
4. Append ".spec.md" extension
5. Return path wrapped in :ok tuple

**Test Assertions**:
- converts module name to correct spec path format
- handles single segment module names
- handles multi-segment module names with proper underscoring

### read_spec_file/2

Reads the content of a spec file using the environment file operations.

```elixir
@spec read_spec_file(Environment.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
```

**Process**:
1. Call Environments.read_file/2 with environment and spec path
2. If successful, return content wrapped in :ok tuple
3. If error is :enoent, return formatted "Spec file not found" error
4. For other errors, return formatted error with inspected reason

**Test Assertions**:
- returns file content when file exists
- returns specific error message when file not found
- returns generic error message for other file read errors
