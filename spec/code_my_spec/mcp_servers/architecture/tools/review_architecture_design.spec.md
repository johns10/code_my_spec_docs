# CodeMySpec.McpServers.Architecture.Tools.ReviewArchitectureDesign

MCP tool that reviews current architecture design against best practices, providing feedback on surface-to-domain separation, dependency flow, component organization, and alignment with user stories.

This tool generates a comprehensive architecture review prompt that references architecture view files and includes metrics about component organization, story satisfaction, and dependency health. It helps AI agents and developers assess architectural quality and identify areas needing improvement.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the architecture review tool, generating a comprehensive review prompt with architecture metrics, unsatisfied stories, component organization, and dependency health.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope using Validators.validate_scope/1
2. Retrieve unsatisfied stories using Stories.list_unsatisfied_stories/1
3. Retrieve components with dependencies using Components.list_components_with_dependencies/1
4. Validate dependency graph using Components.validate_dependency_graph/1
5. Calculate architecture metrics by analyzing components and dependency validation results
6. Build review prompt with all gathered data
7. Return prompt response using ArchitectureMapper.prompt_response/1
8. If validation fails, return error using ArchitectureMapper.error/1

**Test Assertions**:
- returns review prompt with architecture metrics including total, surface, and domain component counts
- references architecture view files (overview.md, dependency_graph.mmd, namespace_hierarchy.md)
- shows unsatisfied stories count and lists up to 5 stories with titles
- handles case with no unsatisfied stories, showing success message
- shows component organization grouped by type in order (controller, liveview, cli, worker, coordinator, context, repository, schema)
- detects circular dependencies and displays count with error indicator
- shows healthy dependencies when no cycles exist with success indicator
- includes review questions about surface-to-domain separation
- includes review questions about dependency flow
- includes review questions about component responsibilities
- includes next steps for mapping unsatisfied stories to surface components
- counts surface vs domain components correctly based on component types
- detects orphaned components (no incoming/outgoing dependencies, not a context)
- handles empty architecture gracefully with guidance message
- truncates long lists to 5 items with indication of remaining count
- shows component dependency counts in organization section
- returns error for invalid scope

### build_review_prompt/3

Builds a comprehensive architecture review prompt with metrics, stories, components, and dependency health information.

```elixir
@spec build_review_prompt(list(CodeMySpec.Stories.Story.t()), list(CodeMySpec.Components.Component.t()), map()) :: String.t()
```

**Process**:
1. Format architecture views section with file references
2. Format architecture metrics using format_metrics/1
3. Format unsatisfied stories section using format_unsatisfied_stories/1
4. Format component organization using format_component_organization/1
5. Format dependency health using format_dependency_health/1
6. Include review questions for surface-to-domain separation, dependency flow, component responsibilities, story coverage, and architectural issues
7. Include next steps focusing on unsatisfied stories and dependency issues
8. Return formatted markdown prompt string

**Test Assertions**:
- includes section headers for Architecture Views, Architecture Metrics, Unsatisfied Stories, Component Organization, Dependency Health, Review Questions, and Next Steps
- references docs/architecture files (overview.md, dependency_graph.mmd, namespace_hierarchy.md)
- includes all review question categories
- mentions count of unsatisfied stories in next steps section

### calculate_architecture_metrics/2

Calculates architecture metrics including component counts by category, circular dependencies, and orphaned components.

```elixir
@spec calculate_architecture_metrics(list(CodeMySpec.Components.Component.t()), :ok | {:error, list(map())}) :: map()
```

**Process**:
1. Define surface types (controller, liveview, cli, worker)
2. Define domain types (context, schema, repository, coordinator)
3. Filter components into surface and domain categories
4. Count total components
5. Count surface and domain components
6. Count contexts specifically
7. Calculate circular dependencies using calculate_cycles/1
8. Count orphaned components using is_orphaned?/1
9. Return map with all metrics

**Test Assertions**:
- returns map with keys: total_components, surface_components, domain_components, contexts, circular_dependencies, orphaned_components
- correctly categorizes controllers, liveviews, CLI, and workers as surface components
- correctly categorizes contexts, schemas, repositories, and coordinators as domain components
- counts circular dependencies from validation result
- identifies orphaned components (no dependencies, not a context)

### calculate_cycles/1

Extracts the count of circular dependency cycles from validation result.

```elixir
@spec calculate_cycles(:ok | {:error, list(map())}) :: integer()
```

**Process**:
1. If validation result is :ok, return 0
2. If validation result is {:error, cycles}, return length of cycles list

**Test Assertions**:
- returns 0 when validation result is :ok
- returns count of cycles when validation result is {:error, cycles}

### is_orphaned?/1

Determines if a component is orphaned (has no incoming or outgoing dependencies and is not a root context).

```elixir
@spec is_orphaned?(CodeMySpec.Components.Component.t()) :: boolean()
```

**Process**:
1. Retrieve incoming_dependencies list (default to empty if nil)
2. Retrieve outgoing_dependencies list (default to empty if nil)
3. Check if both lists are empty
4. Check if component type is not "context"
5. Return true if both dependencies are empty and type is not context, false otherwise

**Test Assertions**:
- returns true for components with no incoming or outgoing dependencies that are not contexts
- returns false for components with incoming dependencies
- returns false for components with outgoing dependencies
- returns false for context type components even with no dependencies

### format_metrics/1

Formats architecture metrics into markdown text with emoji indicators.

```elixir
@spec format_metrics(map()) :: String.t()
```

**Process**:
1. Format total components count
2. Format surface components count with types list
3. Format domain components count with types list
4. Format contexts count
5. Format circular dependencies with checkmark if 0, X if greater than 0
6. Format orphaned components with checkmark if 0, warning if greater than 0
7. Return formatted markdown string

**Test Assertions**:
- includes all metric categories in output
- shows checkmark emoji for 0 circular dependencies
- shows X emoji for non-zero circular dependencies
- shows checkmark emoji for 0 orphaned components
- shows warning emoji for non-zero orphaned components

### format_unsatisfied_stories/1

Formats unsatisfied stories list, showing up to 5 stories with truncation indicator.

```elixir
@spec format_unsatisfied_stories(list(CodeMySpec.Stories.Story.t())) :: String.t()
```

**Process**:
1. If stories list is empty, return success message
2. Take first 5 stories from list
3. Format each story as bullet point with title and truncated description
4. If more than 5 stories exist, append "and N more" message
5. Return formatted string

**Test Assertions**:
- returns success message for empty list
- shows up to 5 stories with title and description
- truncates descriptions to 100 characters
- appends "and N more" message when more than 5 stories exist

### format_component_organization/1

Formats components grouped by type with dependency counts, showing up to 5 components per type.

```elixir
@spec format_component_organization(list(CodeMySpec.Components.Component.t())) :: String.t()
```

**Process**:
1. If components list is empty, return guidance message to start with surface components
2. Group components by type
3. Sort groups by component_type_order/1
4. For each group, format type header with count
5. For each component (up to 5), format name, module_name, and dependency count
6. If more than 5 components in group, append "and N more" message
7. Return formatted markdown string

**Test Assertions**:
- returns guidance message for empty list
- groups components by type
- sorts types in architectural order (surface before domain)
- shows component name, module_name, and dependency count
- limits each type group to 5 components with truncation message
- handles NotLoaded dependency associations gracefully

### component_type_order/1

Returns sort order priority for component types to display surface components before domain components.

```elixir
@spec component_type_order(String.t()) :: integer()
```

**Process**:
1. Match component type string
2. Return integer priority: controller=1, liveview=2, cli=3, worker=4, coordinator=5, context=6, repository=7, schema=8
3. Return 99 for unknown types

**Test Assertions**:
- returns 1 for controller
- returns 2 for liveview
- returns 3 for cli
- returns 4 for worker
- returns 5 for coordinator
- returns 6 for context
- returns 7 for repository
- returns 8 for schema
- returns 99 for unknown types

### format_dependency_health/1

Formats dependency health status with guidance based on circular dependency presence.

```elixir
@spec format_dependency_health(map()) :: String.t()
```

**Process**:
1. Check circular_dependencies count in metrics map
2. If count is 0, return success message about healthy graph
3. If count is greater than 0, return error message with guidance to use ValidateDependencyGraph tool
4. Return formatted markdown string

**Test Assertions**:
- returns success message with checkmark for 0 circular dependencies
- returns error message with count for non-zero circular dependencies
- mentions ValidateDependencyGraph tool in error message
- explains impact of circular dependencies on testing and maintenance
