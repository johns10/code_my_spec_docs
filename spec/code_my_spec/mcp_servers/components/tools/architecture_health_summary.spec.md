# CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary

MCP tool that provides a comprehensive health assessment of the system architecture. Analyzes story coverage (entry/dependency/orphaned components), context distribution patterns, dependency issues (missing references, high fan-out, circular dependencies), and calculates an overall health score with recommendations for improvement.

## Functions

### execute/2

Execute the architecture health analysis tool via the MCP protocol.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame using Validators.validate_scope/1
2. List all components with dependencies using Components.list_components_with_dependencies/1
3. Analyze health metrics by calling analyze_health/2
4. Build health response JSON and return tool reply
5. On validation error, return ComponentsMapper.error/1

**Test Assertions**:
- returns excellent health for empty architecture
- handles scope validation errors correctly
- returns tool response type with JSON content

### analyze_health/2

Compute comprehensive health analysis across all health dimensions.

```elixir
@spec analyze_health([Component.t()], Scope.t()) :: map()
```

**Process**:
1. Analyze story coverage by calling analyze_story_coverage/1
2. Analyze context distribution by calling analyze_context_distribution/1
3. Analyze dependency issues by calling analyze_dependency_issues/2
4. Calculate overall score by calling calculate_overall_score/2
5. Return map with all health metrics

**Test Assertions**:
- combines all health dimensions into single map
- passes scope to functions requiring it

### analyze_story_coverage/1

Categorize components as entry points, dependencies, or orphaned and calculate coverage percentages.

```elixir
@spec analyze_story_coverage([Component.t()]) :: map()
```

**Process**:
1. Count total components
2. Filter components with stories to get entry components
3. Recursively collect all dependency IDs using get_all_dependency_ids/3
4. Count dependency components (no stories but referenced by entry points)
5. Calculate orphaned components (neither entry nor dependency)
6. Calculate story coverage percentage (entry / (entry + orphaned) * 100)
7. Calculate orphaned percentage (orphaned / total * 100)
8. Determine health status using coverage_health_status_by_orphans/1
9. Return coverage metrics map

**Test Assertions**:
- correctly distinguishes entry, dependency, and orphaned components
- calculates story coverage percentage as entry / (entry + orphaned)
- calculates orphaned percentage correctly
- assigns health status based on orphaned percentage

### get_all_dependency_ids/3

Recursively collect all dependency component IDs for a given component.

```elixir
@spec get_all_dependency_ids(Component.t(), [Component.t()], MapSet.t()) :: [integer()]
```

**Process**:
1. Check if component ID already visited to prevent cycles
2. Add current component ID to visited set
3. Extract direct dependency IDs from outgoing_dependencies
4. Recursively collect indirect dependencies for each direct dependency
5. Return combined list of direct and indirect dependency IDs

**Test Assertions**:
- handles circular dependencies without infinite loops
- returns empty list for already visited components
- recursively collects transitive dependencies

### analyze_context_distribution/1

Analyze the distribution of stories across components and identify distribution patterns.

```elixir
@spec analyze_context_distribution([Component.t()]) :: map()
```

**Process**:
1. Get coverage analysis to obtain orphaned/dependency component counts
2. Calculate raw story count frequencies across all components
3. Convert frequency map to string-keyed map for JSON serialization
4. Count high-story components (7+ stories)
5. Determine distribution health using distribution_health_status/1
6. Return distribution metrics including raw counts

**Test Assertions**:
- produces story distribution histogram with string keys
- includes orphaned and dependency component counts
- assigns distribution health status based on high-story component count

### analyze_dependency_issues/2

Identify dependency problems including missing references, high fan-out, and circular dependencies.

```elixir
@spec analyze_dependency_issues([Component.t()], Scope.t()) :: map()
```

**Process**:
1. Create set of all valid component IDs
2. Find missing references by calling find_missing_references/2
3. Find high fan-out components by calling find_high_fan_out_components/1
4. Validate dependency graph using Components.validate_dependency_graph/1
5. Extract circular dependencies from validation result
6. Calculate dependency health using dependency_health_status/3
7. Return issues map with all dependency problems

**Test Assertions**:
- identifies missing component references
- detects high fan-out components (>5 dependencies)
- includes circular dependency information
- calculates dependency health status

### find_missing_references/2

Find all component dependencies that reference non-existent components.

```elixir
@spec find_missing_references([Component.t()], MapSet.t()) :: [map()]
```

**Process**:
1. Iterate through all components
2. Filter outgoing dependencies where target ID not in valid component set
3. Map each missing dependency to structured error map with source and target info
4. Flatten and return all missing references

**Test Assertions**:
- returns empty list when all references valid
- identifies components with missing target references
- includes source and target component details

### find_high_fan_out_components/1

Identify components with more than 5 outgoing dependencies.

```elixir
@spec find_high_fan_out_components([Component.t()]) :: [map()]
```

**Process**:
1. Filter components where outgoing_dependencies length > 5
2. Map each high fan-out component to structured map with ID, name, count
3. Include list of all dependency details
4. Return list of high fan-out components

**Test Assertions**:
- detects components with more than 5 dependencies
- includes dependency count and full dependency list
- returns empty list when no high fan-out components

### calculate_overall_score/2

Compute weighted overall health score from coverage and dependency metrics.

```elixir
@spec calculate_overall_score([Component.t()], Scope.t()) :: map()
```

**Process**:
1. Calculate coverage score using coverage_score/1
2. Calculate dependency score using dependency_score/2
3. Average the two scores and round to 1 decimal place
4. Convert score to health level using score_to_health_level/1
5. Return score breakdown with overall, coverage, dependency, and health level

**Test Assertions**:
- averages coverage and dependency scores equally
- converts numeric score to health level category
- returns all score components

### coverage_score/1

Calculate coverage score based on orphaned component percentage (inverted).

```elixir
@spec coverage_score([Component.t()]) :: float()
```

**Process**:
1. Analyze story coverage to get orphaned percentage
2. Return 100.0 minus orphaned percentage (fewer orphans = better score)

**Test Assertions**:
- returns 100.0 when no orphaned components
- inverts orphaned percentage for positive scoring

### dependency_score/2

Calculate dependency score by applying penalties for dependency issues.

```elixir
@spec dependency_score([Component.t()], Scope.t()) :: float()
```

**Process**:
1. Create set of all component IDs
2. Find missing references and apply 10 point penalty each
3. Find high fan-out components and apply 5 point penalty each
4. Validate dependency graph and apply 20 point penalty for circular dependencies
5. Calculate total penalty
6. Return max(0.0, 100.0 - penalty)

**Test Assertions**:
- penalizes missing references by 10 points each
- penalizes high fan-out by 5 points each
- penalizes circular dependencies by 20 points
- never returns negative scores

### coverage_health_status_by_orphans/1

Convert orphaned percentage to health status category.

```elixir
@spec coverage_health_status_by_orphans(float()) :: atom()
```

**Process**:
1. Return :excellent if orphaned_percentage == 0
2. Return :good if orphaned_percentage <= 10
3. Return :fair if orphaned_percentage <= 25
4. Return :poor otherwise

**Test Assertions**:
- returns :excellent for zero orphans
- returns :good for low orphan percentage
- returns :fair for moderate orphan percentage
- returns :poor for high orphan percentage

### distribution_health_status/1

Assess distribution health based on high-story component count.

```elixir
@spec distribution_health_status(integer()) :: atom()
```

**Process**:
1. Return :concerning if high_story_components > 3
2. Return :fair if high_story_components > 1
3. Return :good otherwise

**Test Assertions**:
- returns :concerning when many components have 7+ stories
- returns :fair for moderate high-story components
- returns :good when few high-story components

### dependency_health_status/3

Determine dependency health from issue counts.

```elixir
@spec dependency_health_status([map()], [map()], [any()]) :: atom()
```

**Process**:
1. Sum lengths of missing references, high fan-out, and circular dependency lists
2. Return :excellent if issues == 0
3. Return :good if issues <= 2
4. Return :fair if issues <= 5
5. Return :poor otherwise

**Test Assertions**:
- returns :excellent when no issues
- returns :good for minimal issues
- returns :fair for moderate issues
- returns :poor for many issues

### score_to_health_level/1

Map numeric score to categorical health level.

```elixir
@spec score_to_health_level(float()) :: atom()
```

**Process**:
1. Return :excellent if score >= 85
2. Return :good if score >= 70
3. Return :fair if score >= 50
4. Return :poor otherwise

**Test Assertions**:
- maps high scores to :excellent
- maps moderate scores to :good
- maps low scores to :fair
- maps very low scores to :poor

### health_response/1

Build Hermes tool response with health summary JSON.

```elixir
@spec health_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create new tool response using Hermes.Server.Response.tool/0
2. Add JSON content with architecture_health key containing summary
3. Return response struct

**Test Assertions**:
- returns Hermes tool response type
- includes architecture_health in JSON structure

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
