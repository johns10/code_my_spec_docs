# GetComponentView

MCP tool that generates detailed markdown views of components including metadata, dependency relationships, child components, related stories, and visual dependency trees for architectural understanding.

## Functions

### execute/2

Generates a comprehensive markdown view of a component and its full dependency tree for display to AI agents.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope from frame assigns using Validators.validate_scope/1
2. Find component by component_id or module_name using find_component/2
3. Load component with all associations using load_component_details/2
4. Build formatted markdown view using build_component_view/1
5. Return tool response with markdown content via ArchitectureMapper.component_view_response/1
6. On error, return error response via ArchitectureMapper.error/1

**Test Assertions**:
- retrieves component by module_name
- retrieves component by component_id
- shows component metadata including ID, type, parent, timestamps
- shows outgoing dependencies with names, types, and module names
- shows incoming dependents listing components that depend on this component
- shows child components with descriptions when present
- shows related stories with titles, descriptions, and acceptance criteria
- shows dependency tree with visual branch characters
- handles component with no dependencies showing leaf component message
- handles component with no child components
- handles component with no stories
- shows parent component information when exists
- shows top-level when no parent exists
- returns error when component not found by module_name
- returns error when component not found by component_id
- returns error when neither module_name nor component_id provided
- returns error for invalid scope
- shows dependency module names in formatted output
- includes component descriptions in child list

### find_component/2

Finds a component by either component_id or module_name from provided parameters.

```elixir
@spec find_component(CodeMySpec.Users.Scope.t(), map()) :: {:ok, CodeMySpec.Components.Component.t()} | {:error, String.t()}
```

**Process**:
1. Check if params contains component_id - if present, use Components.get_component/2
2. Otherwise check if params contains module_name - if present, use Components.get_component_by_module_name/2
3. Return error if component not found with specific identifier message
4. Return error if neither parameter provided

**Test Assertions**:
- finds component by component_id
- finds component by module_name
- returns error when component not found by id
- returns error when component not found by module_name
- returns error when neither parameter provided

### load_component_details/2

Loads component with all required associations for complete view generation.

```elixir
@spec load_component_details(CodeMySpec.Users.Scope.t(), String.t()) :: {:ok, CodeMySpec.Components.Component.t()} | {:error, String.t()}
```

**Process**:
1. Build Ecto query filtering by component_id and project_id from scope
2. Preload parent_component association
3. Preload child_components association
4. Preload stories association
5. Preload outgoing_dependencies with target_component
6. Preload incoming_dependencies with source_component
7. Execute query and return component or error if not found

**Test Assertions**:
- loads component with all associations
- returns error when component not found in project scope

### build_component_view/1

Generates formatted markdown document showing component details and relationships.

```elixir
@spec build_component_view(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Build header with component name, type, module_name, and description
2. Format metadata section with ID, type, parent, and timestamps
3. Format outgoing dependencies section
4. Format incoming dependents section
5. Format child components section
6. Format related stories section with acceptance criteria
7. Format dependency tree with visual branches
8. Concatenate all sections into single markdown string

**Test Assertions**:
- includes component name as header
- includes type and module name
- includes description when present
- formats metadata section
- formats dependencies and dependents
- formats child components
- formats stories with criteria
- formats dependency tree

### format_parent/1

Formats parent component information or top-level indicator.

```elixir
@spec format_parent(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Check if parent_component is NotLoaded or nil
2. Return "None (top-level)" if no parent
3. Otherwise format as "name (module_name)"

**Test Assertions**:
- returns top-level for nil parent
- returns top-level for NotLoaded parent
- formats parent name and module_name when present

### format_datetime/1

Formats DateTime as string or returns N/A for nil.

```elixir
@spec format_datetime(DateTime.t() | nil) :: String.t()
```

**Process**:
1. Return "N/A" if datetime is nil
2. Otherwise format using Calendar.strftime with pattern "%Y-%m-%d %H:%M:%S UTC"

**Test Assertions**:
- returns N/A for nil
- formats datetime in UTC format

### format_outgoing_dependencies/1

Formats list of outgoing dependencies as markdown list.

```elixir
@spec format_outgoing_dependencies(list()) :: String.t()
```

**Process**:
1. Return "None" message if empty list
2. Map each dependency to format "name (type) - module_name"
3. Join with newlines

**Test Assertions**:
- returns none message for empty list
- formats dependencies with names, types, and module names

### format_incoming_dependencies/1

Formats list of incoming dependencies as markdown list.

```elixir
@spec format_incoming_dependencies(list()) :: String.t()
```

**Process**:
1. Return "None" message if empty list
2. Map each dependency's source_component to format "name (type) - module_name"
3. Join with newlines

**Test Assertions**:
- returns none message for empty list
- formats dependents with names, types, and module names

### format_child_components/1

Formats list of child components as markdown list.

```elixir
@spec format_child_components(list() | Ecto.Association.NotLoaded.t()) :: String.t()
```

**Process**:
1. Return "Not loaded" if NotLoaded association
2. Return "No child components" message if empty list
3. Map each child to format "name (type) - module_name - description"
4. Join with newlines

**Test Assertions**:
- returns not loaded for NotLoaded association
- returns no children message for empty list
- formats children with descriptions when present

### format_stories/1

Formats list of related stories with acceptance criteria as markdown.

```elixir
@spec format_stories(list() | Ecto.Association.NotLoaded.t()) :: String.t()
```

**Process**:
1. Return "Not loaded" if NotLoaded association
2. Return "No related stories" message if empty list
3. Map each story to format with title, description, and acceptance criteria
4. Format acceptance criteria as nested bullet list
5. Join stories with double newlines

**Test Assertions**:
- returns not loaded for NotLoaded association
- returns no stories message for empty list
- formats stories with titles and descriptions
- includes acceptance criteria as nested list

### format_dependency_tree/1

Generates visual ASCII tree representation of component dependencies.

```elixir
@spec format_dependency_tree(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Return "not loaded" message if dependencies NotLoaded
2. Return "leaf component" message if empty dependencies
3. Build tree with component name as root
4. Format dependencies with visual branch characters using format_tree_dependencies/2
5. Wrap in code block with architectural guidance

**Test Assertions**:
- returns not loaded message for NotLoaded dependencies
- returns leaf message for no dependencies
- formats tree with branch characters
- includes architectural guidance

### format_tree_dependencies/2

Formats dependencies with appropriate ASCII tree branch characters.

```elixir
@spec format_tree_dependencies(list(), String.t()) :: String.t()
```

**Process**:
1. Return empty string if empty list
2. Map each dependency with index
3. Use "└─" for last item, "├─" for others
4. Format as "prefix + branch + name (type)"
5. Join with newlines

**Test Assertions**:
- returns empty string for empty list
- uses correct branch characters
- formats last item with end branch
- formats middle items with continuation branch

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- CodeMySpec.Repo
- Ecto.Query
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
