# McpServers.Architecture.Tools.GetComponentView

MCP tool that generates a detailed markdown view of a component and its full dependency tree. Shows component metadata, description, dependencies (outgoing), dependents (incoming), child components, and related stories. Useful for understanding a component's place in the architecture and its relationships.

## Dependencies

- Hermes.Server.Component
- Ecto.Query
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- CodeMySpec.Repo

## Functions

### execute/2

Executes the MCP tool to retrieve and format component view information.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame using Validators.validate_scope/1
2. Find component by either component_id or module_name using find_component/2
3. Load full component details with all associations using load_component_details/2
4. Build markdown view using build_component_view/1
5. Return component view response via ArchitectureMapper.component_view_response/1
6. On error, return error response via ArchitectureMapper.error/1

**Test Assertions**:
- retrieves component by module_name
- retrieves component by component_id
- shows component metadata (ID, type, parent, timestamps)
- shows outgoing dependencies with names, types, and module names
- shows incoming dependents with names, types, and module names
- shows child components with names, types, module names, and descriptions
- shows related stories with titles, descriptions, and acceptance criteria
- shows dependency tree with visual formatting
- handles component with no dependencies
- handles component with no child components
- handles component with no stories
- shows parent component if exists
- shows 'top-level' when no parent
- returns error when component not found by module_name
- returns error when component not found by id
- returns error when neither module_name nor component_id provided
- returns error for invalid scope
- shows dependency module names in formatted output
- includes component descriptions in child list

### load_component_details/2

Loads a component with all needed associations for view generation.

```elixir
@spec load_component_details(CodeMySpec.Users.Scope.t(), Ecto.UUID.t()) :: {:ok, CodeMySpec.Components.Component.t()} | {:error, String.t()}
```

**Process**:
1. Build query for component by ID and project_id from scope
2. Preload parent_component, child_components, stories, outgoing_dependencies with target_component, and incoming_dependencies with source_component
3. Execute query using Repo.one/1
4. Return {:ok, component} if found, {:error, "Component not found"} if not found

**Test Assertions**:
- loads component with all associations preloaded
- returns error when component not found
- filters by project scope

### find_component/2

Finds a component by either component_id or module_name parameter.

```elixir
@spec find_component(CodeMySpec.Users.Scope.t(), map()) :: {:ok, CodeMySpec.Components.Component.t()} | {:error, String.t()}
```

**Process**:
1. If params contain component_id, call Components.get_component/2
2. If params contain module_name, call Components.get_component_by_module_name/2
3. If component found, return {:ok, component}
4. If component not found, return {:error, "Component not found with id/module_name: ..."}
5. If neither parameter provided, return {:error, "Must provide either component_id or module_name"}

**Test Assertions**:
- finds component by component_id
- finds component by module_name
- returns error when component not found by id
- returns error when component not found by module_name
- returns error when neither parameter provided

### build_component_view/1

Builds formatted markdown view of component with all details.

```elixir
@spec build_component_view(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Format header with component name
2. Add type and module metadata lines
3. Add description if present
4. Add Metadata section with ID, type, parent, created, and updated timestamps
5. Add Dependencies (Outgoing) section using format_outgoing_dependencies/1
6. Add Dependents (Incoming) section using format_incoming_dependencies/1
7. Add Child Components section using format_child_components/1
8. Add Related Stories section using format_stories/1
9. Add Dependency Tree section using format_dependency_tree/1
10. Return complete markdown string

**Test Assertions**:
- includes component name as header
- includes type and module name
- includes description when present
- includes metadata section with all fields
- includes dependencies section
- includes dependents section
- includes child components section
- includes stories section
- includes dependency tree section

### format_parent/1

Formats the parent component information for display.

```elixir
@spec format_parent(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Check if parent_component is NotLoaded or nil
2. If no parent, return "None (top-level)"
3. If parent exists, return "#{parent.name} (#{parent.module_name})"

**Test Assertions**:
- returns "None (top-level)" when no parent
- returns parent name and module when parent exists

### format_datetime/1

Formats datetime for display or returns "N/A" for nil.

```elixir
@spec format_datetime(DateTime.t() | nil) :: String.t()
```

**Process**:
1. If datetime is nil, return "N/A"
2. Otherwise, format using Calendar.strftime/2 with "%Y-%m-%d %H:%M:%S UTC" format

**Test Assertions**:
- returns "N/A" for nil
- formats datetime with correct pattern

### format_outgoing_dependencies/1

Formats list of outgoing dependencies as markdown.

```elixir
@spec format_outgoing_dependencies([CodeMySpec.Components.Dependency.t()]) :: String.t()
```

**Process**:
1. If empty list, return "_This component depends on: None_"
2. Map each dependency to "- **#{target.name}** (#{target.type}) - `#{target.module_name}`"
3. Join with newlines

**Test Assertions**:
- returns none message for empty list
- formats dependencies with name, type, and module name

### format_incoming_dependencies/1

Formats list of incoming dependencies (dependents) as markdown.

```elixir
@spec format_incoming_dependencies([CodeMySpec.Components.Dependency.t()]) :: String.t()
```

**Process**:
1. If empty list, return "_Components that depend on this: None_"
2. Map each dependency to "- **#{source.name}** (#{source.type}) - `#{source.module_name}`"
3. Join with newlines

**Test Assertions**:
- returns none message for empty list
- formats dependents with name, type, and module name

### format_child_components/1

Formats list of child components as markdown.

```elixir
@spec format_child_components([CodeMySpec.Components.Component.t()] | Ecto.Association.NotLoaded.t()) :: String.t()
```

**Process**:
1. If NotLoaded, return "Not loaded"
2. If empty list, return "_No child components_"
3. Map each child to "- **#{child.name}** (#{child.type}) - `#{child.module_name}`" with optional description
4. Join with newlines

**Test Assertions**:
- returns "Not loaded" for NotLoaded association
- returns no children message for empty list
- formats children with name, type, module name, and description when present

### format_stories/1

Formats list of related stories as markdown.

```elixir
@spec format_stories([CodeMySpec.Stories.Story.t()] | Ecto.Association.NotLoaded.t()) :: String.t()
```

**Process**:
1. If NotLoaded, return "Not loaded"
2. If empty list, return "_No related stories_"
3. For each story, format title, description, and acceptance criteria
4. Format acceptance criteria as indented bullet list
5. Join stories with double newlines

**Test Assertions**:
- returns "Not loaded" for NotLoaded association
- returns no stories message for empty list
- formats stories with title and description
- includes acceptance criteria as bullet list

### format_dependency_tree/1

Formats dependency tree with visual tree structure.

```elixir
@spec format_dependency_tree(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. If outgoing_dependencies is NotLoaded, return "_Dependency tree not loaded_"
2. If empty list, return "_No dependencies - this is a leaf component_"
3. Build tree visualization with component name at root
4. Format dependencies using format_tree_dependencies/2
5. Include usage note about surface-to-domain dependency flow
6. Return formatted tree in code block

**Test Assertions**:
- returns not loaded message when dependencies not loaded
- returns leaf component message for no dependencies
- formats tree with visual branches
- includes usage note

### format_tree_dependencies/2

Formats list of dependencies with tree branch characters.

```elixir
@spec format_tree_dependencies([CodeMySpec.Components.Dependency.t()], String.t()) :: String.t()
```

**Process**:
1. If empty list, return empty string
2. Enumerate dependencies with index
3. For each dependency, determine if last item
4. Use "└─" for last item, "├─" for others
5. Format as "#{prefix}#{branch} #{target.name} (#{target.type})"
6. Join with newlines

**Test Assertions**:
- returns empty string for empty list
- uses ├─ for non-last items
- uses └─ for last item
- includes target name and type
