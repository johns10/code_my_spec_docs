# Component Analyzer

## Purpose
Analyzes components against file system reality by mapping expected file paths, checking file existence, and looking up test status. Builds nested dependency trees with computed component statuses for requirement checking. Uses a two-pass algorithm to handle dependency cycles safely.

## Public API

```elixir
@spec analyze_components([Component.t()], file_list :: [String.t()], test_results :: [TestResult.t()]) :: 
  %{integer() => Components.component_status()}

# Returns map of component_id => component_status for each component
```

## Analysis State

Internal state struct to build up analysis data:

```elixir
defmodule ComponentAnalyzer do
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

## Analysis Flow

**Two-Pass Algorithm**: Must compute file/test status first, then build nested dependency trees with that status.

### First Pass: Flat Component Status Analysis
1. **Initialize State**: Create State with component 
2. **Map Expected Files**: Generate expected file paths based on component type and naming conventions
3. **Check File Existence**: Compare expected files against file_list to populate actual_files
4. **Find Failing Tests**: Look up test modules in test_results to populate failing_tests
5. **Build Flat Status**: Create basic `Components.component_status()` map (no dependencies yet)
6. **Store Results**: Build flat map of component_id → basic_status for all components

### Second Pass: Nested Dependency Tree Building
1. **Recursive Tree Building**: For each component, recursively build dependency trees
2. **Status Integration**: Attach computed status to each dependency in the tree
3. **Cycle Detection**: Use visited set to prevent infinite recursion on circular dependencies
4. **Enhanced Status**: Add nested dependency tree to component_status.dependencies
5. **Return Status Map**: Component ID → enhanced_component_status with nested trees

## File Path Mapping (Internal)

Simple logic to generate expected file paths:

```elixir
defp map_expected_files(component) do
  module_path = component.module_name |> module_to_path()
  
  %{
    design_file: "docs/design/#{module_path}.md",
    code_file: "lib/#{module_path}.ex", 
    test_file: "test/#{module_path}_test.exs"
  }
end

defp module_to_path(module_name) do
  module_name
  |> String.replace_prefix("", "")  # Remove any prefix
  |> Macro.underscore()
  |> String.replace(".", "/")
  |> String.downcase()
end
```

## File Existence Checking

Check which expected files actually exist:

```elixir
defp check_file_existence(expected_files, file_list) do
  expected_paths = Map.values(expected_files)
  
  expected_paths
  |> Enum.filter(&(&1 in file_list))
end
```

## Test Status Analysis

Find failing tests for the component by looking at test file paths:

```elixir
defp find_failing_tests(component, test_results) do
  # Derive expected test file path
  expected_test_file = map_expected_files(component).test_file
  
  # Find test results that match this test file
  test_results
  |> Enum.filter(fn %TestResult{} = result ->
    # Check if test result is from this component's test file
    result.error && result.error.file == expected_test_file && result.status == :failed
  end)
  |> Enum.map(& &1.full_title)
end
```

## Component Status Building

Convert analysis state to final component_status:

```elixir
defp determine_test_status(failing_tests, actual_files, expected_test_file) do
  has_test_file = expected_test_file in actual_files
  has_failing_tests = length(failing_tests) > 0
  
  cond do
    not has_test_file -> :not_run
    has_failing_tests -> :failing
    has_test_file -> :passing
  end
end
```

## Implementation Strategy

```elixir
def analyze_components(components, file_list, test_results) do
  # First pass: compute flat component statuses
  flat_statuses = build_flat_component_statuses(components, file_list, test_results)
  
  # Second pass: build nested dependency trees with computed statuses  
  components
  |> Enum.map(&analyze_with_nested_dependencies(&1, flat_statuses, MapSet.new()))
  |> Map.new()
end

defp build_flat_component_statuses(components, file_list, test_results) do
  components
  |> Enum.map(&analyze_single_component_flat(&1, file_list, test_results))
  |> Map.new()
end

defp analyze_single_component_flat(component, file_list, test_results) do
  state = %ComponentAnalyzer{component: component}
  
  final_state = 
    state
    |> map_expected_files()
    |> check_file_existence(file_list) 
    |> find_failing_tests(test_results)
    |> build_flat_component_status()  # No dependencies field yet
  
  {component.id, final_state.component_status}
end

defp analyze_with_nested_dependencies(component, flat_statuses, visited) do
  if MapSet.member?(visited, component.id) do
    # Break cycles - return basic status without nested deps
    base_status = Map.get(flat_statuses, component.id)
    cycle_safe_status = Map.put(base_status, :dependencies, [])
    {component.id, cycle_safe_status}
  else
    updated_visited = MapSet.put(visited, component.id)
    
    # Recursively build dependency tree with their statuses
    enhanced_dependencies = 
      component.dependencies
      |> Enum.map(fn dep ->
        {_dep_id, dep_status} = analyze_with_nested_dependencies(dep, flat_statuses, updated_visited)
        %{dep | component_status: dep_status}
      end)
    
    # Get this component's flat status and add the nested dependencies
    base_status = Map.get(flat_statuses, component.id)
    enhanced_status = Map.put(base_status, :dependencies, enhanced_dependencies)
    
    {component.id, enhanced_status}
  end
end

defp build_flat_component_status(state) do
  expected = state.expected_files
  
  component_status = %{
    design_exists: expected.design_file in state.actual_files,
    code_exists: expected.code_file in state.actual_files,
    test_exists: expected.test_file in state.actual_files,
    test_status: determine_test_status(state.failing_tests, state.actual_files, expected.test_file)
    # No dependencies field - added in second pass
  }
  
  %{state | component_status: component_status}
end
```

## Input Data Formats

### File List
List of file paths from directory walker:
```elixir
file_list = [
  "docs/design/users_context.md",
  "lib/my_app/users.ex", 
  "test/my_app/users_test.exs"
]
```

### Test Results  
List of TestResult structs:
```elixir
test_results = [
  %TestResult{
    title: "creates user",
    full_title: "MyApp.UsersTest creates user", 
    status: :passed,
    error: nil
  },
  %TestResult{
    title: "validates email",
    full_title: "MyApp.UsersTest validates email",
    status: :failed,
    error: %TestError{
      file: "test/my_app/users_test.exs",
      line: 15,
      message: "Expected true, got false"
    }
  }
]
```

## Dependencies

- **Components**: Uses `Components.component_status()` type
- **Component**: Works with Component schema fields (name, module_name, type)
- **TestResult**: Uses TestResult and TestError structs for test status analysis

## What This Module Does

- Maps components to expected file paths using naming conventions
- Checks file system for actual file existence  
- Looks up test results for each component's test modules
- Builds nested dependency trees with computed component statuses
- Handles circular dependency cycles with safe fallbacks
- Builds clean `component_status` maps for requirement checking

## What This Module Doesn't Do

- No requirement checking (that's handled by ProjectCoordinator + Registry)
- No database operations (just pure data transformation)
- No file system access (works with provided file list data)
- No persistence (returns computed data structures)