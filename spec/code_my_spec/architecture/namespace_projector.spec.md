# CodeMySpec.Architecture.NamespaceProjector

## Type

module

Generates hierarchical tree views of components organized by Elixir module namespace. Produces indented text trees showing the structural organization of the codebase by module path.

## Delegates

None

## Functions

### project/1

Generates a namespace hierarchy tree from a list of components, returning a formatted string showing the hierarchical organization by module namespace.

```elixir
@spec project([Component.t()]) :: String.t()
```

**Process**:

1. Return empty string for empty component list
2. Extract module names from all components
3. Parse module names into namespace segments by splitting on "."
4. Build nested tree structure from namespace paths using a map-based approach
5. Sort tree nodes alphabetically at each level
6. Format tree with tree-style characters (├──, └──, │) for visual hierarchy
7. At leaf nodes, append component type in brackets and brief description
8. Return formatted string with proper indentation

**Test Assertions**:

- returns empty string for empty component list
- displays single component as root without tree characters
- builds simple two-level namespace hierarchy (e.g., CodeMySpec.Components)
- builds deep namespace hierarchy with 5+ levels
- shows multiple components in same namespace grouped together
- uses tree characters (├──, └──) for non-last siblings
- uses └── for last child at each level
- includes component type in brackets at leaf nodes
- includes component description after type
- sorts siblings alphabetically within each namespace level
- handles components with same namespace prefix sharing parent nodes
- uses 2-space indentation per level

### project/2

Generates a namespace hierarchy tree with configurable options for display formatting and filtering.

```elixir
@spec project([Component.t()], keyword()) :: String.t()
```

**Process**:

1. Extract options from keyword list (show_types, show_descriptions, max_depth, filter_prefix)
2. Filter components by prefix if filter_prefix option is provided
3. Build namespace tree structure as in project/1
4. Apply max_depth limit by truncating branches that exceed specified depth
5. Format tree with options:
   - Conditionally include type badges based on show_types option
   - Conditionally include descriptions based on show_descriptions option
6. Return formatted string respecting all options

**Test Assertions**:

- respects show_types: false to hide type badges
- respects show_descriptions: false to hide descriptions
- respects max_depth to limit tree depth
- respects filter_prefix to show only matching namespace subtree
- combines multiple options correctly
- defaults to showing types and descriptions when options not specified

## Dependencies

- CodeMySpec.Components.Component
