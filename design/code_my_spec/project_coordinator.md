# Project Coordinator

## Purpose
Synchronizes project component requirements with file system reality. Takes components, file list, and test results, analyzes everything, and returns the full nested component tree with statuses and requirements. Can filter to get the next actionable components.

## Public API

```elixir
@spec sync_project_requirements(Scope.t(), file_list :: [String.t()], test_results :: [TestResult.t()], opts :: keyword()) :: 
  [Component.t()]

# Returns list of components with:
# - ComponentStatus embedded (file existence, test status)
# - Requirements checked (satisfied/unsatisfied) - persisted if persist: true
# - Nested dependency trees built with topological sorting
# - Ready for filtering to find next actionable components

@spec get_next_actions(Scope.t(), limit :: integer()) :: [Component.t()]
@spec get_next_actions([Component.t()], limit :: integer()) :: [Component.t()]

# Two modes:
# 1. From scope: Gets persisted unsatisfied components from database
# 2. From component list: Filters analyzed components for unsatisfied requirements
# Returns up to `limit` components - these are the "next 5 actions"
```

## Analysis Flow

### sync_project_requirements/4
1. **Get Components**: Call `Components.list_components_with_dependencies(scope)`
2. **Full Analysis**: Call `ComponentAnalyzer.analyze_components(components, file_list, test_results, opts)`
   - This does the full three-pass algorithm
   - Returns components with status, requirements, and nested trees
3. **Return Enhanced Components**: Ready for filtering and action planning

### get_next_actions/2 (from persisted data)
1. **Get Unsatisfied Components**: Call `Components.components_with_unsatisfied_requirements(scope)`
2. **Limit Results**: Take first `limit` components 
3. **Return Action List**: These are the next components to work on

### get_next_actions/2 (from component list)
1. **Filter Unsatisfied**: Find components with unsatisfied requirements from the analyzed list
2. **Limit Results**: Take first `limit` components
3. **Return Action List**: These are the next components to work on

## What We Get

After `sync_project_requirements/4`, each component has:
- **ComponentStatus**: File existence, test status 
- **Requirements**: List of Requirement structs with satisfied/unsatisfied status
- **Dependencies**: Nested tree of dependencies (also with their status/requirements)

This gives us the full picture to filter for actionable components.

## Dependencies

- **Components**: All component and requirement operations
- **ComponentAnalyzer**: Full component analysis with status, requirements, and nested trees
- **RequirementsRepository**: (via Components) For filtering unsatisfied requirements

## Implementation Notes

The ProjectCoordinator is a thin orchestration layer that:
1. Calls ComponentAnalyzer for full analysis
2. Provides filtering functions for both persisted and in-memory data

## Usage Patterns

### Controller with persistence (persist: true)
```elixir
# Analyze and persist to database
components = ProjectCoordinator.sync_project_requirements(scope, files, tests, persist: true)

# Get next actions from database
actions = ProjectCoordinator.get_next_actions(scope, 5)
```

### Controller without persistence (persist: false)
```elixir
# Analyze in memory only
components = ProjectCoordinator.sync_project_requirements(scope, files, tests, persist: false)

# Get next actions from the analyzed component list
actions = ProjectCoordinator.get_next_actions(components, 5)
```

Both patterns give you the full analyzed component tree AND the next actionable components.