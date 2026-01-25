# CodeMySpec.Architecture.OverviewProjector

**Type**: module

Generates comprehensive markdown overviews of all components organized by context. Lists components with types, descriptions, and dependencies in a format optimized for AI agent consumption during design sessions.

## Delegates

None

## Functions

### project/1

Generates a comprehensive markdown overview of all components organized by their parent contexts.

```elixir
@spec project([Component.t()]) :: String.t()
```

**Process**:
1. Group components by parent context using parent_component_id
2. Build markdown document starting with a title header
3. For each context in the grouped results:
   - Add H2 header with context name
   - Include context type and description if available
   - List all child components under the context
4. For each component, format entry with:
   - H3 header with component name
   - Type badge in bold
   - Description on new line if present
   - Dependencies section listing module names
5. Handle components with no parent (root level) in separate section
6. Return complete markdown string

**Test Assertions**:
- generates markdown with title header
- groups components by parent context
- creates H2 sections for each context
- includes context descriptions
- lists components with H3 headers under their contexts
- includes component type in bold
- includes component descriptions when present
- lists dependencies with module names
- handles components with no parent in root section
- handles contexts with no child components
- handles empty component list returning minimal markdown
- handles components with no dependencies
- sorts contexts alphabetically by name
- sorts components within contexts by priority then name
- handles nil descriptions gracefully
- preserves component attributes

### project/2

Generates a comprehensive markdown overview with configurable options for filtering and formatting.

```elixir
@spec project([Component.t()], keyword()) :: String.t()
```

**Process**:
1. Extract options (include_descriptions, include_dependencies, context_filter)
2. Filter components by context_filter option if provided
3. Group components by parent context
4. Build markdown document with conditional sections based on options:
   - Skip descriptions if include_descriptions: false
   - Skip dependencies if include_dependencies: false
5. Format each context and component according to options
6. Return complete markdown string

**Test Assertions**:
- includes descriptions when include_descriptions: true (default)
- excludes descriptions when include_descriptions: false
- includes dependencies when include_dependencies: true (default)
- excludes dependencies when include_dependencies: false
- filters to specific contexts when context_filter option provided
- combines multiple options correctly
- handles empty options list with default behavior
- validates context_filter as list of context module names
- handles context_filter matching no components

## Dependencies

- CodeMySpec.Components.Component
