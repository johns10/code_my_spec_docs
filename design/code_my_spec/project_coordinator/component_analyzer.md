# Component Analyzer

## Purpose
Analyzes project implementation status using set-based operations to compare expected component file paths against actual file system contents, identifying completion status and orphaned files.

## Entity Ownership
- **Set-Based Analysis**: Uses set intersections and differences to determine file status
- **Component Status Calculation**: Determines individual component implementation progress
- **Orphan Detection**: Identifies files that exist but aren't mapped to components
- **Missing File Detection**: Identifies expected files that don't exist

## Public API

```elixir
@spec analyze_components([Component.t()], file_tree :: MapSet.t(String.t())) :: analysis_result()

@type analysis_result :: %{
  component_statuses: [component_status()],
  orphaned_files: [String.t()],
  project_stats: project_stats()
}

@type component_status :: %{
  component: Component.t(),
  design_exists: boolean(),
  code_exists: boolean(), 
  test_exists: boolean(),
  missing_files: [String.t()],
  next_action: action_atom()
}

@type project_stats :: %{
  total_components: integer(),
  design_complete: integer(),
  code_complete: integer(),
  test_complete: integer(),
  orphaned_files_count: integer()
}

@type action_atom :: :create_design | :implement_code | :write_tests | :fix_tests | :complete
```

## Set-Based Analysis Algorithm

### Core Set Operations
```elixir
# Generate all expected file paths from components
expected_files = components 
  |> Enum.flat_map(&FilePathMapper.map_component_to_paths/1)
  |> MapSet.new()

# Actual files from file system  
actual_files = MapSet.new(file_tree)

# Set intersections and differences
existing_files = MapSet.intersection(expected_files, actual_files)
missing_files = MapSet.difference(expected_files, actual_files)  
orphaned_files = MapSet.difference(actual_files, expected_files)
```

### Component Status Analysis
For each component:
1. **Get Expected Paths**: `{design_file, code_file, test_file}`
2. **Check Existence**: Test each path against `existing_files` set
3. **Determine Status**: Based on which files exist
4. **Calculate Next Action**: Apply business rules

### Next Action Logic
```elixir
defp determine_next_action(design_exists, code_exists, test_exists, test_results) do
  cond do
    not design_exists -> :create_design
    not code_exists -> :implement_code  
    not test_exists -> :write_tests
    test_exists and failing_tests?(test_results) -> :fix_tests
    true -> :complete
  end
end
```

## Implementation Strategy

### Set Construction
```elixir
def analyze_components(components, file_tree) do
  # Convert file tree keys to MapSet for efficient operations
  actual_files = MapSet.new(Map.keys(file_tree))
  
  # Generate all expected file paths
  expected_paths = 
    components
    |> Enum.map(&build_component_expected_paths/1)
    |> List.flatten()
    |> MapSet.new()
  
  # Perform set analysis
  existing_files = MapSet.intersection(expected_paths, actual_files)
  missing_files = MapSet.difference(expected_paths, actual_files)
  orphaned_files = MapSet.difference(actual_files, expected_paths)
  
  # Analyze each component
  component_statuses = Enum.map(components, &analyze_single_component(&1, existing_files))
  
  %{
    component_statuses: component_statuses,
    orphaned_files: MapSet.to_list(orphaned_files),
    project_stats: calculate_project_stats(component_statuses, orphaned_files)
  }
end
```

### Single Component Analysis
```elixir
defp analyze_single_component(component, existing_files) do
  paths = FilePathMapper.map_component_to_paths(component)
  
  %{
    component: component,
    design_exists: MapSet.member?(existing_files, paths.design_file),
    code_exists: MapSet.member?(existing_files, paths.code_file),
    test_exists: MapSet.member?(existing_files, paths.test_file),
    missing_files: find_missing_files(paths, existing_files),
    next_action: determine_next_action(...)
  }
end
```

## Usage Examples

```elixir
# Components from database
components = [
  %Component{module_name: "MyApp.Users"},
  %Component{module_name: "MyApp.Orders"}
]

# File tree from client/filesystem
file_tree = %{
  "docs/design/my_app/users.md" => %{size: 1234},
  "lib/my_app/users.ex" => %{size: 2345},
  "lib/my_app/legacy_helper.ex" => %{size: 500}  # orphaned
  # Missing: test/my_app/users_test.exs, all Orders files
}

result = ComponentAnalyzer.analyze_components(components, file_tree)

# Result:
%{
  component_statuses: [
    %{
      component: %Component{module_name: "MyApp.Users"},
      design_exists: true,
      code_exists: true,
      test_exists: false,
      missing_files: ["test/my_app/users_test.exs"],
      next_action: :write_tests
    },
    %{
      component: %Component{module_name: "MyApp.Orders"}, 
      design_exists: false,
      code_exists: false,
      test_exists: false,
      missing_files: ["docs/design/my_app/orders.md", "lib/my_app/orders.ex", "test/my_app/orders_test.exs"],
      next_action: :create_design
    }
  ],
  orphaned_files: ["lib/my_app/legacy_helper.ex"],
  project_stats: %{
    total_components: 2,
    design_complete: 1,
    code_complete: 1, 
    test_complete: 0,
    orphaned_files_count: 1
  }
}
```

## Performance Characteristics
- **Time Complexity**: O(n + m) where n = components, m = files
- **Space Complexity**: O(n + m) for set operations
- **Set Operations**: Constant time lookups with MapSet
- **Scalability**: Efficient for large codebases

## Dependencies
- **FilePathMapper**: Generate expected file paths from components
- **MapSet**: Efficient set operations
- **Component schema**: Access to module_name field