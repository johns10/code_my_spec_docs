# Project Coordinator

## Purpose
Synchronizes project component requirements with file system reality. Takes file tree and test results, analyzes what files exist for each component, checks requirements against that reality, and returns components with updated requirements.

## Public API

```elixir
@spec sync_project_requirements(Scope.t(), file_tree :: map(), test_results :: map()) :: 
  [Component.t()]

# Returns list of components with:
# - :dependencies preloaded 
# - :requirements preloaded with current satisfaction status
```

## What We Need from Components Context

The ProjectCoordinator depends on the Components context, not its internals. We need these functions:

```elixir
# Get all components with dependencies loaded
Components.list_components_with_dependencies(scope)

# Sync requirements for a component (Components calls RequirementsRepository)
Components.create_component_requirements(scope, component, requirement_attrs_list)
```

The Components context handles all the Repository details. ProjectCoordinator just orchestrates the analysis and calls Components functions.

## Analysis Flow

1. **Get Components**: Call `Components.list_components_with_dependencies(scope)`
2. **Analyze Files**: Use ComponentAnalyzer to build component status (includes file path mapping, existence checks, test status)
3. **Check Requirements**: Get Registry specs, run checkers against component status
4. **Sync Requirements**: Call `Components.sync_component_requirements/3` with requirement data
5. **Return Enhanced Components**: Components now have updated requirements

## File System Analysis

### ComponentAnalyzer
Takes components, file tree, test results. Returns component status for each:
```elixir
ComponentAnalyzer.analyze_components(components, file_tree, test_results)
# => %{component_id => %{design_exists: true, code_exists: false, test_exists: false, test_status: :not_run}}
```

### Analysis State
ComponentAnalyzer uses an internal state struct to build up the analysis:

```elixir
defmodule ComponentAnalyzer.State do
  @type t :: %__MODULE__{
    component: Component.t(),
    expected_files: %{atom() => String.t()},  # %{design_file: "path", code_file: "path", test_file: "path"}
    actual_files: [String.t()],               # files that actually exist from expected
    failing_tests: [String.t()],              # failing test modules for this component
    component_status: Components.component_status() # final result
  }
  
  defstruct [:component, expected_files: %{}, actual_files: [], failing_tests: [], component_status: %{}]
end
```

The ComponentAnalyzer builds up this state for each component:
1. **Map Expected Files**: Use internal file path mapping logic to populate expected_files
2. **Check Actual Files**: Compare expected_files against file_tree to find actual_files
3. **Find Failing Tests**: Look up component's test modules in test_results
4. **Build Component Status**: Create final `Components.component_status()` from the state

## Implementation Strategy

```elixir
def sync_project_requirements(scope, file_tree, test_results) do
  # Get components with dependencies
  components = Components.list_components_with_dependencies(scope)
  
  # Analyze file system state
  component_statuses = ComponentAnalyzer.analyze_components(components, file_tree, test_results)
  
  # For each component, sync its requirements
  Enum.map(components, fn component ->
    component_status = Map.get(component_statuses, component.id)
    requirement_attrs = build_requirement_attrs(component, component_status)
    
    # Components context handles the persistence/creation details
    Components.sync_component_requirements(scope, component, requirement_attrs)
  end)
end

defp build_requirement_attrs(component, component_status) do
  # Get requirement specs from Registry
  requirement_specs = Registry.get_requirements_for_type(component.type)
  
  # Check each requirement against component status
  Enum.map(requirement_specs, fn spec ->
    checker = spec.checker
    check_result = checker.check(spec, component_status)
    
    # Return attrs map for Requirements creation
    %{
      name: Atom.to_string(spec.name),
      type: spec.type,
      description: spec.description,
      checker_module: Atom.to_string(spec.checker),
      satisfied_by: if(spec.satisfied_by, do: Atom.to_string(spec.satisfied_by)),
      satisfied: match?({:satisfied, _}, check_result),
      checked_at: DateTime.utc_now(),
      details: extract_details(check_result)
    }
  end)
end
```

## Components

- **ComponentAnalyzer**: File system analysis and state building (includes file path mapping)

## Dependencies

- **Components**: Main dependency - handles all component and requirement operations
- **Registry**: Requirement specs and checkers

## What This Doesn't Do

- No persistence logic (Components handles that)
- No complex types or result structures  
- No NextActions complexity
- No changeset manipulation
- No Repository calls (Components does that)

Just: analyze files → check requirements → sync via Components → return enhanced components.

Simple orchestration with clear dependencies.