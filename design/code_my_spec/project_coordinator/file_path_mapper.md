# File Path Mapper

## Purpose
Maps component definitions to their expected file system paths based on module naming conventions, ensuring design/code/test files follow identical path structures.

## Entity Ownership
- **Path Generation**: Converts component module names to consistent file system paths
- **Naming Convention Enforcement**: Ensures design, code, and test files use identical base paths
- **Module-to-Path Conversion**: Applies Elixir underscore conventions consistently

## Public API

```elixir
@spec map_component_to_paths(Component.t()) :: component_paths()

@type component_paths :: %{
  design_file: String.t(),
  code_file: String.t(),
  test_file: String.t()
}
```

## Path Mapping Logic

All three file types follow the exact same path structure, derived from the component's `module_name`:

### Base Path Generation
Module name is converted to a file path using Elixir conventions:
- "MyApp.Users" → `my_app/users`
- "EcommercePlatform.Orders.OrderService" → `ecommerce_platform/orders/order_service`

### File Type Mapping
1. **Design File**: `docs/design/{base_path}.md`
2. **Code File**: `lib/{base_path}.ex`
3. **Test File**: `test/{base_path}_test.exs`

### Examples
- Module: "CodeMySpec.Components"
  - Design: `docs/design/code_my_spec/components.md`
  - Code: `lib/code_my_spec/components.ex`
  - Test: `test/code_my_spec/components_test.exs`

- Module: "MyApp.Users.UserService"
  - Design: `docs/design/my_app/users/user_service.md`
  - Code: `lib/my_app/users/user_service.ex`
  - Test: `test/my_app/users/user_service_test.exs`

## Implementation Strategy

### Module Name Processing
```elixir
# Public API
def map_component_to_paths(%Component{module_name: module_name}) do
  base_path = module_to_base_path(module_name)
  
  %{
    design_file: "docs/design/#{base_path}.md",
    code_file: "lib/#{base_path}.ex",
    test_file: "test/#{base_path}_test.exs"
  }
end

# Private implementation
defp module_to_base_path(module_name) do
  module_name
  |> String.split(".")
  |> Enum.map(&Macro.underscore/1)
  |> Path.join()
end
```

### Path Validation
- Ensure module names follow Elixir conventions
- Validate generated paths don't escape project boundaries
- Handle edge cases in module naming

## Usage Examples

```elixir
# Component with module "CodeMySpec.ProjectCoordinator"
component = %Component{
  name: "Project Coordinator",
  module_name: "CodeMySpec.ProjectCoordinator"
}

paths = FilePathMapper.map_component_to_paths(component)
# => %{
#   design_file: "docs/design/code_my_spec/project_coordinator.md",
#   code_file: "lib/code_my_spec/project_coordinator.ex",
#   test_file: "test/code_my_spec/project_coordinator_test.exs"
# }

# Nested module example
component = %Component{
  module_name: "MyApp.Users.UserRegistrationService"
}

paths = FilePathMapper.map_component_to_paths(component)
# => %{
#   design_file: "docs/design/my_app/users/user_registration_service.md",
#   code_file: "lib/my_app/users/user_registration_service.ex", 
#   test_file: "test/my_app/users/user_registration_service_test.exs"
# }
```

## Error Handling
- **Invalid Module Names**: Raise clear errors for malformed module names
- **Path Injection**: Sanitize module names to prevent directory traversal
- **Empty Modules**: Handle edge cases like single-word modules

## Dependencies
- **Macro.underscore/1**: Convert CamelCase to snake_case
- **Path.join/1**: Safe path construction
- **String manipulation**: Module name processing