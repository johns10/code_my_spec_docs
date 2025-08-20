# Project Coordinator

## Purpose
Analyzes project implementation status by comparing database component definitions against file system data, providing real-time next-action recommendations for development workflows.

## Entity Ownership
- **On-Demand Analysis**: Compares components to file system without persistent caching
- **File System Analysis**: Processes file tree data and test results
- **Next Action Logic**: Determines what user should work on next based on dependencies and file existence
- **Project Status Reporting**: Provides overview of project completion status

## Scope Integration

### Accepted Scopes
- **Secondary Scope**: Project-scoped for team coordination

### Scope Configuration
All operations are scoped to the user's active project. File system paths and component updates are isolated within project boundaries.

### Access Patterns
- Components belong to a specific project
- Analysis is performed on-demand with file tree data
- No persistent state - all analysis is stateless

## Public API

```elixir
# On-Demand Project Analysis
@spec analyze_project(Scope.t(), file_tree :: map(), test_results :: map()) :: 
  {:ok, analysis_result()} | {:error, String.t()}

# Types
@type analysis_result :: %{
  next_actions: [action_item()],
  project_status: project_status(),
  component_statuses: [component_status()]
}

@type action_item :: %{
  component_id: integer(),
  component_name: String.t(),
  action: :create_design_session | :create_implementation_session | :create_test_session | :fix_tests,
  reason: String.t(),
  priority: integer()
}

@type project_status :: %{
  total_components: integer(),
  design_complete: integer(),
  code_complete: integer(),
  test_complete: integer()
}
```

## Analysis Strategy

### Stateless Design
No persistent status fields in components. All analysis computed on-demand by comparing:
- Database component definitions (source of truth for what should exist)
- File tree (source of truth for what actually exists)
- Test results (source of truth for test status)

### Data Source Flexibility
The context accepts standard Elixir data structures, making it testable with:
- **Real file systems**: Use `File.ls!/1` or directory walker libraries
- **Mock data**: Create file tree maps manually in tests
- **Test results**: Parse ExUnit JSON formatter output or mock test status

### File Mapping Logic
Components map to files via naming conventions:
- **Design File**: `docs/design/{snake_case_name}_context.md`
- **Code File**: Derived from `module_name` field → `lib/my_app/users.ex`
- **Test File**: Code file path + `_test.exs` → `test/my_app/users_test.exs`

### Data Format
File tree is a simple map of file paths to file metadata:
```elixir
file_tree = %{
  "docs/design/users_context.md" => %{size: 1234},
  "lib/my_app/users.ex" => %{size: 2345},
  "test/my_app/users_test.exs" => %{size: 456}
}
```

Test results are module names mapped to status atoms:
```elixir
test_results = %{
  "MyApp.UsersTest" => :passing,
  "MyApp.AccountsTest" => :failing
}
```

### Next Action Logic
For each component, determine action based on file existence:

1. **Design Phase**: No design file → `:create_design_session`
2. **Implementation Phase**: Design exists, no code file → `:create_implementation_session`
3. **Testing Phase**: Code exists, no test file → `:create_test_session`
4. **Validation Phase**: Tests exist but failing → `:fix_tests`
5. **Complete**: All files exist and tests pass → No action needed

Priority ordering by dependency satisfaction - dependencies must be complete before dependents.

## Component Diagram

- ProjectCoordinator
  - FilePathMapper (component → file path logic)
  - ComponentAnalyzer (individual component status analysis)
  - NextActionEngine (dependency-aware action prioritization)
  - ProjectStatusCalculator (aggregate statistics)

## Dependencies

- **CodeMySpec.Components**: Component queries and dependency resolution
- **CodeMySpec.Users.Scope**: Access control and project scoping

## Execution Flow

### Project Analysis (Single API Call)
1. **Load Components**: Get all project components with dependencies
2. **Map File Paths**: Calculate expected file paths for each component
3. **Check File Existence**: Compare expected paths to file tree
4. **Parse Test Results**: Extract test status for components with tests
5. **Determine Actions**: Apply next-action rules per component
6. **Resolve Dependencies**: Filter actions based on dependency satisfaction
7. **Calculate Statistics**: Aggregate project completion status
8. **Return Results**: Provide actionable items with context

## Error Handling
- **Data Validation**: Invalid file tree or test results
- **Component Mapping**: Files that don't map to expected component patterns
- **Dependency Resolution**: Circular dependencies or invalid dependency graphs

All errors are logged and return structured error responses. Analysis continues for valid components even if some have errors.