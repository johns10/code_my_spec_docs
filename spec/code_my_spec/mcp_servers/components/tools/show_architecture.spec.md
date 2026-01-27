# CodeMySpec.McpServers.Components.Tools.ShowArchitecture

MCP tool that provides comprehensive system architecture visualization including dependency graphs, component relationships, architecture layers, and story associations. Exposes complete architectural context to LLM agents for understanding component organization, dependencies, and requirements.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame

## Functions

### execute/2

Executes the show architecture tool by validating scope and retrieving complete architecture data.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame contains valid scope with active account and project
2. Call Components.show_architecture/1 to retrieve architecture data
3. Build comprehensive architecture response with overview, components, and dependency graph
4. Return tool response with architecture JSON or error response if validation fails

**Test Assertions**:
- returns empty architecture when no components with stories exist
- returns components with stories and their dependencies
- shows components organized by dependency depth
- handles scope validation errors
- includes architecture overview with metrics
- builds complete dependency graph
- shows shared dependencies correctly

### architecture_response/1

Builds a Hermes tool response containing complete architecture data.

```elixir
@spec architecture_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Create a new tool response
2. Build architecture overview with metrics and layer information
3. Map architecture entries to detailed component information
4. Build dependency graph from all component relationships
5. Return response with JSON containing overview, components, and dependency_graph

**Test Assertions**:
- includes overview section with totals
- includes components array with detailed entries
- includes dependency_graph with relationships
- formats all data as valid JSON

### architecture_overview/1

Generates summary statistics and layer organization for the architecture.

```elixir
@spec architecture_overview(list(map())) :: map()
```

**Process**:
1. Count total components in architecture
2. Count components that have associated stories
3. Sum all outgoing dependencies across components
4. Group components by depth to create architecture layers
5. Return map with total_components, components_with_stories, total_dependencies, and architecture_layers

**Test Assertions**:
- calculates total component count correctly
- identifies components with stories
- sums dependency counts
- groups components by depth into layers
- returns complete overview map

### group_by_depth/1

Organizes architecture entries into layers based on dependency depth.

```elixir
@spec group_by_depth(list(map())) :: list(map())
```

**Process**:
1. Group architecture entries by their depth value
2. Map each depth group to a layer structure
3. Include depth, layer_name, component_count, and component_names
4. Sort layers by depth ascending
5. Return sorted list of layer maps

**Test Assertions**:
- groups components by depth correctly
- assigns appropriate layer names
- counts components per layer
- includes component names list
- sorts layers by depth

### layer_name_for_depth/1

Returns a descriptive name for an architecture layer based on depth.

```elixir
@spec layer_name_for_depth(non_neg_integer()) :: String.t()
```

**Process**:
1. If depth is 0, return "Entry Points (Components with Stories)"
2. Otherwise, return "Dependency Layer N" where N is the depth
3. Return the layer name string

**Test Assertions**:
- returns "Entry Points (Components with Stories)" for depth 0
- returns "Dependency Layer 1" for depth 1
- returns "Dependency Layer N" for depth N

### architecture_entry/1

Formats a single architecture entry with component details and layer information.

```elixir
@spec architecture_entry(map()) :: map()
```

**Process**:
1. Extract component and depth from the entry
2. Build detailed component info map
3. Include depth and layer name
4. Return formatted entry map

**Test Assertions**:
- includes detailed component information
- includes depth value
- includes layer name
- returns complete entry map

### detailed_component_info/1

Builds comprehensive component information including metadata, stories, dependencies, and metrics.

```elixir
@spec detailed_component_info(CodeMySpec.Components.Component.t()) :: map()
```

**Process**:
1. Extract core component fields (id, name, type, module_name, description, priority)
2. Format associated stories with format_stories/1
3. Format outgoing dependencies with format_dependencies/1
4. Calculate metrics (story_count, dependency_count, has_stories)
5. Return map with all component information

**Test Assertions**:
- includes all core component fields
- formats stories correctly
- formats dependencies correctly
- calculates metrics accurately
- handles missing stories and dependencies

### format_stories/1

Formats story associations for JSON response.

```elixir
@spec format_stories(list(CodeMySpec.Stories.Story.t())) :: list(map())
```

**Process**:
1. Map over each story in the list
2. Extract id, title, description, status, and acceptance_criteria
3. Return list of story maps

**Test Assertions**:
- formats story fields correctly
- handles empty story lists
- includes all story fields
- handles missing acceptance_criteria

### format_dependencies/1

Formats component dependencies for JSON response.

```elixir
@spec format_dependencies(list(CodeMySpec.Components.Dependency.t())) :: list(map())
```

**Process**:
1. Map over each dependency in the list
2. Extract dependency id
3. Extract target component information (id, name, module_name, type)
4. Return list of dependency maps with id and target

**Test Assertions**:
- formats dependency fields correctly
- handles empty dependency lists
- includes dependency id
- includes target component details

### build_dependency_graph/1

Constructs complete dependency graph with all relationships and summary.

```elixir
@spec build_dependency_graph(list(map())) :: map()
```

**Process**:
1. Flat map over architecture to extract all dependency relationships
2. For each component, map its outgoing dependencies to relationship maps
3. Each relationship includes from (source component), to (target component), and dependency_id
4. Build summary with total relationship count
5. Return map with relationships list and summary

**Test Assertions**:
- extracts all dependency relationships
- includes from component information
- includes to component information
- includes dependency id
- calculates total relationship count
- handles components with no dependencies
