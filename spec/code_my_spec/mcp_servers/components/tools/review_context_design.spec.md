# CodeMySpec.McpServers.Components.Tools.ReviewContextDesign

MCP tool that reviews the current context design against best practices and provides architectural feedback. Analyzes system architecture, story assignments, and dependency relationships to help maintain clean architectural boundaries and ensure all stories are properly satisfied by components.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame

## Functions

### execute/2

Executes the context design review tool, generating a comprehensive architectural analysis prompt.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()} | {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that the frame contains a valid scope with active account and project
2. Retrieve list of unsatisfied stories from the Stories context
3. Execute ShowArchitecture tool to get current system architecture
4. Validate the dependency graph for circular dependencies
5. Format the architecture response from ShowArchitecture into readable text
6. Format unsatisfied stories list, showing first 5 with title and description preview
7. Format dependency analysis results showing if circular dependencies exist
8. Build comprehensive review prompt with sections:
   - Current Architecture (formatted component tree with stories and dependencies)
   - Unsatisfied Stories count and list
   - Dependency Analysis results
   - Review Questions covering context boundaries, responsibilities, missing contexts, dependency justification, and cohesion
   - Next Steps focusing on story assignment and dependency review
9. Return prompt response via ComponentsMapper
10. If validation fails, return error response via ComponentsMapper

**Test Assertions**:
- executes and returns prompt response with valid scope
- response type is tool
- response is not marked as error
- response content contains Context Design Review heading
- response content is text format
- handles missing active account error
- handles missing active project error

### format_unsatisfied_stories/1

Formats a list of unsatisfied stories for display in the review prompt.

```elixir
@spec format_unsatisfied_stories(list(CodeMySpec.Stories.Story.t())) :: String.t()
```

**Process**:
1. If stories list is empty, return success message
2. Take first 5 stories from the list
3. Map each story to formatted string with title and truncated description (100 chars)
4. Join formatted stories with newlines
5. If more than 5 stories exist, append count of remaining stories
6. Return formatted string

**Test Assertions**:
- returns success message for empty list
- formats single story with title and description
- truncates description to 100 characters
- limits display to first 5 stories
- shows count of remaining stories when more than 5 exist
- joins multiple stories with newlines

### format_dependency_analysis/1

Formats dependency validation results for display in the review prompt.

```elixir
@spec format_dependency_analysis(:ok | {:error, list()}) :: String.t()
```

**Process**:
1. If result is :ok, return success message indicating no circular dependencies
2. If result is error tuple with cycles list, return error message with cycle count
3. Return formatted string

**Test Assertions**:
- returns success message for valid dependency graph
- returns error message with count for circular dependencies
- includes checkmark emoji for success
- includes error emoji for failures

### format_architecture_from_response/1

Extracts and formats architecture data from ShowArchitecture response.

```elixir
@spec format_architecture_from_response(Hermes.Server.Response.t()) :: String.t()
```

**Process**:
1. Extract content array from response
2. Parse first content item as JSON text
3. If JSON parsing succeeds, delegate to format_architecture_json/1
4. If parsing fails, return error message
5. If content structure is unexpected, return error message

**Test Assertions**:
- parses valid JSON response and formats architecture
- returns error message for invalid JSON
- returns error message for unexpected response structure
- handles empty content array
- handles missing text field

### format_architecture_json/1

Formats parsed architecture JSON data into readable component tree structure.

```elixir
@spec format_architecture_json(map()) :: String.t()
```

**Process**:
1. Extract components list from architecture map
2. Filter components to find entry points (depth 0 with stories)
3. Remove duplicate components by ID
4. Map each entry point through format_component_tree/1
5. Join formatted trees with double newlines
6. Return formatted string

**Test Assertions**:
- formats components with stories at depth 0
- filters out components without stories
- removes duplicate components
- formats multiple entry points separately
- returns empty string for architecture without entry points
- joins multiple trees with double newlines

### format_component_tree/1

Formats a single component with its stories and dependencies.

```elixir
@spec format_component_tree(map()) :: String.t()
```

**Process**:
1. Extract component data from map
2. Format component header with name, type, and description
3. Format stories list via format_component_stories/1
4. Format dependencies list via format_component_dependencies/1
5. Build stories section if stories exist, otherwise show "No stories"
6. Build dependencies section if dependencies exist
7. Concatenate header, stories section, and dependencies section
8. Return formatted string

**Test Assertions**:
- formats component header with name, type, and description
- includes stories section when component has stories
- shows "No stories" message when component has no stories
- includes dependencies section when component has dependencies
- omits dependencies section when component has no dependencies
- properly indents nested sections

### format_component_stories/1

Formats a list of stories for a component with titles, descriptions, and acceptance criteria.

```elixir
@spec format_component_stories(list(map())) :: String.t()
```

**Process**:
1. Map each story to formatted string
2. Format story with title and description
3. If story has acceptance criteria, format criteria list with proper indentation
4. Join criteria items with newlines and 6-space indentation
5. Append criteria section to story string if criteria exist
6. Join all formatted stories with newlines
7. Return formatted string

**Test Assertions**:
- formats story with title and description
- includes acceptance criteria when present
- properly indents acceptance criteria items
- handles stories without acceptance criteria
- handles empty acceptance criteria array
- joins multiple stories with newlines
- uses 4-space indentation for stories
- uses 6-space indentation for criteria

### format_component_dependencies/1

Formats a list of component dependencies showing target component names and types.

```elixir
@spec format_component_dependencies(list(map())) :: String.t()
```

**Process**:
1. Map each dependency to formatted string
2. Extract target component name and type from dependency
3. Format as "- name (type)" with 4-space indentation
4. Join all formatted dependencies with newlines
5. Return formatted string

**Test Assertions**:
- formats dependency with target name and type
- uses 4-space indentation for dependencies
- joins multiple dependencies with newlines
- handles empty dependencies list
- extracts nested target component data correctly
