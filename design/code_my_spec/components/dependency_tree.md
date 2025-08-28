# DependencyTree Module Design

## Purpose
Build nested dependency trees for components by processing them in optimal order (topologically sorted) to ensure all dependencies are fully analyzed before dependent components.

## Core Insight
Process components with no dependencies first, then work up the dependency chain. This ensures when we build a component's nested tree, all its dependencies already have their own nested trees built.

## API

```elixir
defmodule CodeMySpec.Components.DependencyTree do
  @spec apply([Component.t()]) :: [Component.t()]
  def apply(components)
  
  @spec apply(Component.t(), [Component.t()]) :: Component.t()
  def apply(component, all_components)
end
```

## Algorithm

### build_nested_trees/1
**Input**: Components with preloaded `:dependencies` from `list_components_with_dependencies`

1. **Topological Sort**: Order components by dependency depth
   - Components with `dependencies: []` first  
   - Then components that only depend on leaf components
   - Continue until all components ordered
2. **Process in Order**: For each component in sorted order, build its nested tree
3. **Update Dependencies**: Replace flat dependency references with fully processed nested trees

### build_for_component/2
1. **Use Preloaded Dependencies**: component.dependencies already contains Component structs
2. **Lookup Processed**: Find fully-processed versions from component lookup map
3. **Recursive Replace**: Replace each dependency with its nested tree version
4. **Cycle Detection**: Track visited components to break cycles gracefully

## Topological Sort Details

**Input**: Components with preloaded `:dependencies` (Component structs)
**Process**:
1. Calculate in-degree: `length(component.dependencies)` for each component
2. Queue components with in-degree 0 (`dependencies: []`)
3. Process queue: for each component, find its dependents and reduce their in-degree
4. Add newly zero in-degree components to queue
5. Continue until all processed

**Output**: Components ordered such that dependencies come before dependents

## Cycle Handling
- **Detection**: Track processing path with visited set
- **Resolution**: When cycle detected, break by returning component with empty dependencies
- **Logging**: Log cycle information for debugging

## Performance Optimizations
- **Component Lookup**: Build ID�Component map for O(1) lookups
- **Memoization**: Cache built trees to avoid reprocessing
- **Lazy Evaluation**: Only build trees as needed

## Integration with ComponentAnalyzer

```elixir
def analyze_components(components, file_list, test_results, opts) do
  # NOTE: components already come with preloaded :dependencies from 
  # Components.list_components_with_dependencies(scope)
  
  # ... existing status and requirements analysis ...
  
  # Final pass: build all nested dependency trees efficiently  
  DependencyTree.apply(components_with_requirements)
end
```

## Benefits
1. **Correctness**: Ensures all dependencies fully processed before dependents
2. **Performance**: Optimal processing order minimizes redundant work
3. **Maintainability**: Clear separation of dependency tree logic
4. **Testability**: Isolated dependency tree building logic

## Edge Cases
- **Cycles**: Gracefully handled with visited set
- **Missing Dependencies**: Fallback to original component references  
- **Empty Dependencies**: Handled naturally by topological sort
- **Single Components**: Works correctly for components with no dependencies