# CodeMySpec.McpServers.Components.Tools.StartContextDesign

MCP tool that initiates guided context design sessions for AI agents. Generates a structured prompt containing unsatisfied user stories and existing components, then guides the agent through Phoenix context architecture design following entity ownership and business capability principles.

## Functions

### execute/2

Executes the tool to start a context design session.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) ::
        {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate that frame contains valid scope with active account and project
2. Retrieve unsatisfied stories from Stories context using scope
3. Retrieve components with dependencies from Components context using scope
4. Generate AI architect prompt with stories and components context
5. Format prompt with context design principles and instructions
6. Return prompt response via ComponentsMapper

**Test Assertions**:
- executes successfully with valid scope in frame
- returns tool response with isError false
- returns text content containing architect prompt
- prompt includes expert Elixir architect role description

### format_stories_context/1

Formats a list of stories into human-readable context for the AI prompt.

```elixir
@spec format_stories_context([CodeMySpec.Stories.Story.t()]) :: String.t()
```

**Process**:
1. Check if stories list is empty
2. If empty, return satisfied requirements message
3. Otherwise, map each story through format_story_summary/1
4. Join formatted summaries with double newlines

**Test Assertions**:
- returns satisfied message for empty list
- formats multiple stories with proper separation
- delegates to format_story_summary for individual stories

### format_story_summary/1

Formats a single story with title, description, and acceptance criteria.

```elixir
@spec format_story_summary(CodeMySpec.Stories.Story.t()) :: String.t()
```

**Process**:
1. Extract acceptance criteria from story
2. If criteria is empty, use "No acceptance criteria defined"
3. Otherwise, format each criterion as bulleted list item
4. Build formatted string with bold title, description, and criteria
5. Return formatted summary

**Test Assertions**:
- formats story with title and description
- handles empty acceptance criteria
- formats acceptance criteria as bulleted list
- includes all story information in output

### format_components_context/1

Formats a list of components into human-readable context for the AI prompt.

```elixir
@spec format_components_context([CodeMySpec.Components.Component.t()]) :: String.t()
```

**Process**:
1. Check if components list is empty
2. If empty, return "no components exist" message
3. Otherwise, map each component through format_component_summary/1
4. Join formatted summaries with double newlines

**Test Assertions**:
- returns no components message for empty list
- formats multiple components with proper separation
- delegates to format_component_summary for individual components

### format_component_summary/1

Formats a single component with name, type, module, description, and dependencies.

```elixir
@spec format_component_summary(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Format outgoing dependencies using format_dependencies/1
2. Build formatted string with bold name and type
3. Include module name
4. Add description if present, otherwise "No description"
5. Include formatted dependencies section
6. Return formatted summary

**Test Assertions**:
- formats component with name, type, and module
- handles missing description gracefully
- includes dependencies section
- formats component information for readability

### format_dependencies/1

Formats a list of dependencies as bulleted list of target component names.

```elixir
@spec format_dependencies([CodeMySpec.Components.Dependency.t()]) :: String.t()
```

**Process**:
1. Check if dependencies list is empty
2. If empty, return "None"
3. Otherwise, map each dependency to extract target component name
4. Format each name as bulleted list item
5. Join items with newlines

**Test Assertions**:
- returns "None" for empty list
- formats dependencies as bulleted list
- extracts target component names correctly
- joins multiple dependencies with newlines

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
