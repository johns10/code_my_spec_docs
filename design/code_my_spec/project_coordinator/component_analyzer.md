# Component Analyzer

## Purpose
Analyzes components against file system reality by mapping expected file paths, checking file existence, and looking up test status. Returns Component structs with ComponentStatus embedded, requirements checked and persisted, and nested dependency trees built using topological sorting.

## Public API

```elixir
@spec analyze_components([Component.t()], [String.t()], [TestResult.t()], keyword()) :: [Component.t()]

# Returns components with:
# - component_status embedded (file existence, test status)
# - requirements checked and created (with persistence option)
# - nested dependency trees built via DependencyTree.build()
```

## Analysis Flow

**Three-Pass Algorithm**: Component status analysis, requirements checking, and dependency tree building.

### First Pass: Component Status Analysis
For each component:
1. **Map Expected Files**: Generate expected file paths based on module naming conventions
2. **Check File Existence**: Compare expected files against file_list
3. **Find Failing Tests**: Look up test modules in test_results
4. **Build ComponentStatus**: Create ComponentStatus struct from analysis
5. **Update Component**: Persist component_status (with persistence option)

### Second Pass: Base Requirements Checking  
For each component with component_status:
1. **Clear Existing Requirements**: Remove old requirements if persisting
2. **Check Requirements**: Use Registry specs and checkers (exclude `:dependencies_satisfied`)
3. **Create Requirements**: Create and persist Requirement records
4. **Attach Requirements**: Add requirements list to component

### Third Pass: Dependency Trees and Dependency Requirements
1. **Build Dependency Trees**: Use DependencyTree.build() with topological sorting
2. **Check Dependency Requirements**: Run `:dependencies_satisfied` checker on nested trees
3. **Merge Requirements**: Add dependency requirements to existing requirements

## Key Features

### File Path Mapping
Maps component module names to expected file paths using standard Elixir conventions:
- Design: `docs/design/{module_path}.md`  
- Code: `lib/{module_path}.ex`
- Test: `test/{module_path}_test.exs`

### Component Status Analysis
Computes ComponentStatus by checking file existence and test results against expected files.

### Requirements Integration
Uses Components.check_requirements() with Registry specs and checker modules to evaluate component requirements.

### Dependency Tree Building
Leverages DependencyTree.build() for optimal topological sorting and nested tree construction.

### Persistence Options
Supports both persistent (database) and in-memory modes via `persist: true/false` option.

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

- **Components**: Uses check_requirements(), create_requirement(), clear_requirements()
- **DependencyTree**: Uses build() for topological sorting and nested tree construction  
- **ComponentStatus**: Uses from_analysis() to build status structs
- **Registry**: Component type requirements and checker specifications
- **TestResult**: Test status analysis from test runner results

## What This Module Does

- File system analysis (expected vs actual files, test status)
- Component status computation and persistence
- Requirements checking via Registry specs and checker modules
- Requirement creation and persistence (with options)
- Nested dependency tree building via DependencyTree
- Full component enhancement with status, requirements, and dependencies

## What This Module Doesn't Do

- File system access (works with provided file_list data)
- Test execution (analyzes provided test_results data)
- Direct database access (delegates through Components context)