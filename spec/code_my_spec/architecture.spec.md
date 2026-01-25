# CodeMySpec.Architecture

A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides projectors that create documentation artifacts (mermaid diagrams, component hierarchies, namespace trees) written to the repository and synchronized with current project state during full syncs.

## Delegates

- generate_overview/1: CodeMySpec.Architecture.OverviewProjector.project/1
- generate_dependency_graph/1: CodeMySpec.Architecture.MermaidProjector.project/1
- generate_namespace_hierarchy/1: CodeMySpec.Architecture.NamespaceProjector.project/1

## Functions

### generate_views/2

Generates all architectural view files and writes them to the configured output directory.

```elixir
@spec generate_views(Scope.t(), keyword()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Fetch all components with dependencies from Components context
2. Generate each view type by calling appropriate projector delegates
3. Write each view to the output directory (defaults to docs/architecture/)
4. Return list of generated file paths

**Test Assertions**:
- generates all view types when no filter specified
- writes files to configured output directory
- returns list of generated file paths
- filters to specific view types when :only option provided
- handles empty component list gracefully
- creates output directory if it does not exist

### get_architecture_summary/1

Returns a structured summary of architecture metrics for programmatic use.

```elixir
@spec get_architecture_summary(Scope.t()) :: %{
  context_count: non_neg_integer(),
  component_count: non_neg_integer(),
  dependency_count: non_neg_integer(),
  orphaned_count: non_neg_integer(),
  max_depth: non_neg_integer(),
  circular_dependencies: boolean()
}
```

**Process**:
1. Query Components for counts and metrics
2. Check for circular dependencies
3. Calculate maximum namespace depth
4. Count orphaned contexts (no stories, no dependents)
5. Return summary map

**Test Assertions**:
- returns correct context and component counts
- accurately counts dependencies
- detects circular dependencies
- calculates max namespace depth
- identifies orphaned contexts

### list_orphaned_contexts/1

Returns contexts that have no stories and are not dependencies of any entry points.

```elixir
@spec list_orphaned_contexts(Scope.t()) :: [Component.t()]
```

**Process**:
1. Fetch all components with dependencies
2. Identify entry points (components with stories)
3. Build reachable set by traversing dependencies from entry points
4. Filter for contexts not in reachable set and without stories
5. Return orphaned context list

**Test Assertions**:
- returns contexts with no stories
- excludes contexts that are dependencies of story-linked components
- includes transitively unreachable contexts
- returns empty list when all contexts are reachable

### get_component_impact/2

Analyzes the impact of modifying a component by tracing all dependents.

```elixir
@spec get_component_impact(Scope.t(), String.t()) :: %{
  component: Component.t(),
  direct_dependents: [Component.t()],
  transitive_dependents: [Component.t()],
  affected_contexts: [Component.t()]
}
```

**Process**:
1. Fetch target component by ID with dependents preloaded
2. Collect direct dependents
3. Recursively traverse to build transitive dependent set
4. Extract unique contexts from all affected components
5. Return impact analysis map

**Test Assertions**:
- returns the target component
- lists direct dependents
- includes transitive dependents through chain
- identifies all affected parent contexts
- handles component with no dependents

### generate_component_view/2

Generates a detailed markdown view of a component and its full dependency tree.

```elixir
@spec generate_component_view(Scope.t(), String.t() | [String.t()]) :: String.t()
```

**Process**:
1. Fetch component(s) by ID or module name
2. For each component, collect direct dependencies
3. Recursively descend to collect all transitive dependencies
4. Group dependencies by depth level in the tree
5. Format as markdown with component header, description, and nested dependency sections
6. Return formatted markdown string

**Test Assertions**:
- accepts single component ID or module name
- accepts list of component IDs or module names
- shows component name and description as header
- lists direct dependencies with descriptions
- lists transitive dependencies grouped by depth
- shows full module names for each dependency
- handles components with no dependencies
- handles deeply nested dependency chains
- deduplicates dependencies that appear through multiple paths

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.Architecture.OverviewProjector

Generates comprehensive markdown overviews of all components organized by context. Lists components with types, descriptions, and dependencies in a format optimized for AI agent consumption during design sessions.

### CodeMySpec.Architecture.MermaidProjector

Generates a simple Mermaid flowchart showing contexts and their dependency relationships.

### CodeMySpec.Architecture.NamespaceProjector

Generates hierarchical tree views of components organized by Elixir module namespace. Produces indented text trees showing the structural organization of the codebase by module path.
