# CodeMySpec.Components.DependencyTree

Build nested dependency trees for components by processing them in optimal order.

Uses topological sorting to ensure all dependencies are fully analyzed before
dependent components, enabling efficient construction of nested dependency trees.

## Functions

### build/1

Apply dependency tree processing to all components.

```elixir
@spec build([Component.t()]) :: [Component.t()]
```

**Process**:
1. Return empty list if input is empty
2. Perform topological sort on components to process dependencies before dependents
3. Reduce over sorted components, building a map of processed components
4. For each component, build nested dependencies using already-processed components from the map
5. Handle `Ecto.Association.NotLoaded` by returning empty dependencies list
6. Return map values sorted by component id

**Test Assertions**:
- returns empty list for empty input
- builds nested trees for components with no dependencies
- builds nested trees in topological order for simple chain (Leaf -> Middle -> Root)
- builds nested trees with multiple dependencies
- handles cycles gracefully by logging warning and processing remaining components
- handles complex dependency graph with multiple roots
- handles diamond dependency pattern
- handles single component with no dependencies
- preserves component attributes during tree building

### build/2

Apply dependency tree processing to a single component.

```elixir
@spec build(Component.t(), [Component.t()]) :: Component.t()
```

**Process**:
1. Build component map from all available components (id -> component)
2. Initialize empty visited set for cycle detection
3. Build nested dependency tree recursively using component map
4. For each dependency, look up full component in map and recurse
5. Track visited components to detect and break cycles
6. Handle missing dependencies by keeping original dependency reference

**Test Assertions**:
- builds nested tree for component with no dependencies
- builds nested tree for component with single dependency
- builds nested tree for component with nested dependencies (3 levels deep)
- handles cycle detection in nested tree building by breaking cycles
- handles missing dependencies gracefully by preserving original reference

## Dependencies

- CodeMySpec.Components.Component
