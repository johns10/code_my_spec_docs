# CodeMySpec.Components.HierarchicalTree

Build nested hierarchical trees for components based on parent-child relationships.

Unlike dependency trees which require topological sorting to handle cycles,
hierarchical trees are naturally acyclic tree structures that can be built
through simple recursive traversal.

## Dependencies

- CodeMySpec.Components.Component

## Functions

### build/1

Build hierarchical trees for all components. Returns components with nested
child_components built recursively. Root components (those without parents)
are returned at the top level.

```elixir
@spec build([Component.t()]) :: [Component.t()]
```

**Process**:

1. Return empty list for empty input
2. Build lookup map of components by id
3. Find root components (those with nil parent_component_id)
4. For each root, recursively build nested tree with cycle detection

**Test Assertions**:

- returns empty list for empty input
- builds simple parent-child hierarchy
- builds multi-level hierarchy
- handles multiple root components

### build/2

Build hierarchical tree for a single component. Recursively builds nested
child_components using all available components.

```elixir
@spec build(Component.t(), [Component.t()]) :: Component.t()
```

**Process**:

1. Build lookup map from all components
2. Initialize empty visited set for cycle detection
3. Recursively build nested tree starting from the given component

**Test Assertions**:

- builds hierarchy for single component with its children populated

### get_all_descendants/2

Get all descendants of a component (children, grandchildren, etc).

```elixir
@spec get_all_descendants(Component.t(), [Component.t()]) :: [Component.t()]
```

**Process**:

1. Build lookup map from all components
2. Recursively collect all children, tracking visited to prevent cycles
3. For each child, recursively collect its descendants
4. Return flat list of all descendant components

**Test Assertions**:

- returns empty list for leaf component with no children
- returns all descendants including children and grandchildren

### get_component_path/2

Get the full path from root to a component.

```elixir
@spec get_component_path(Component.t(), [Component.t()]) :: [Component.t()]
```

**Process**:

1. Build lookup map from all components
2. Starting from component, prepend to path and traverse to parent
3. Continue until reaching root (nil parent_component_id) or missing parent
4. Return path ordered from root to the target component

**Test Assertions**:

- returns single component for root with no parent
- returns path from root to deeply nested component in correct order

### is_ancestor?/3

Check if component A is an ancestor of component B.

```elixir
@spec is_ancestor?(Component.t(), Component.t(), [Component.t()]) :: boolean()
```

**Process**:

1. Return false if both components have the same id (component cannot be its own ancestor)
2. Get the full path from root to the target component
3. Check if the potential ancestor appears anywhere in that path

**Test Assertions**:

- returns true when component is a direct parent
- returns true when component is an indirect ancestor (grandparent)
- returns false when components are siblings
- returns false when component is the same as potential ancestor