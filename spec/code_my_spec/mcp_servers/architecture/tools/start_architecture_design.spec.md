# StartArchitectureDesign

MCP tool that initiates a guided architecture design session by generating a comprehensive prompt for AI agents. Maps user stories to application surface components (controllers, liveviews, CLI modules) rather than abstract bounded contexts. References architecture view files for system state context.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component

## Functions

### execute/2

Executes the MCP tool to generate an architecture design session prompt.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the frame has a valid scope (active account and project) using Validators.validate_scope/1
2. If validation fails, return error response via ArchitectureMapper.error/1
3. Retrieve all unsatisfied stories using Stories.list_unsatisfied_stories/1
4. Retrieve all components with their dependencies using Components.list_components_with_dependencies/1
5. Build comprehensive design prompt by calling build_design_prompt/2 with stories and components
6. Return prompt response via ArchitectureMapper.prompt_response/1

**Test Assertions**:
- returns prompt with unsatisfied stories when stories exist
- includes all unsatisfied stories in the prompt
- includes existing components in prompt with descriptions
- references architecture view files (overview.md, dependency_graph.mmd, namespace_hierarchy.md)
- includes surface-level mapping guidance (API endpoints, UI features, CLI commands)
- explains component types (liveview, controller, cli, context)
- includes design principles about dependency flow (surface → domain)
- handles case with no unsatisfied stories gracefully
- handles case with no existing components
- includes component dependencies in output
- returns error for invalid scope (missing active account or project)

### build_design_prompt/2

Constructs the architecture design prompt with unsatisfied stories and existing components context.

```elixir
@spec build_design_prompt(list(CodeMySpec.Stories.Story.t()), list(CodeMySpec.Components.Component.t())) :: String.t()
```

**Process**:
1. Start with expert architect role description and focus on unsatisfied stories
2. Format unsatisfied stories section using format_stories_context/1
3. Format existing components section using format_components_context/1
4. Include references to architecture view files (docs/architecture/overview.md, dependency_graph.mmd, namespace_hierarchy.md)
5. Provide role definition mapping stories to surface components by interface type
6. List design principles (start at surface, separate interface from logic, inward dependencies)
7. Document component types with descriptions
8. Provide step-by-step instructions for the design process
9. Return complete prompt as string

**Test Assertions**:
- generates prompt containing story titles and descriptions
- includes acceptance criteria for each story
- lists existing components with module names and types
- references all three architecture view files
- explains mapping between interface types and component types
- includes design principles about dependency direction
- provides clear instructions for using MCP tools

### format_stories_context/1

Formats a list of stories into readable context text for the prompt.

```elixir
@spec format_stories_context(list(CodeMySpec.Stories.Story.t())) :: String.t()
```

**Process**:
1. If stories list is empty, return message that all requirements are satisfied
2. Otherwise, map each story through format_story_summary/1
3. Join formatted stories with double newlines

**Test Assertions**:
- returns satisfied message for empty story list
- formats multiple stories with proper separation
- preserves all story information

### format_story_summary/1

Formats a single story with title, description, and acceptance criteria.

```elixir
@spec format_story_summary(CodeMySpec.Stories.Story.t()) :: String.t()
```

**Process**:
1. Extract story title, description, and acceptance_criteria
2. If acceptance_criteria is empty, use placeholder message
3. Otherwise, format each criterion as a bulleted list item
4. Combine title (bolded), description, and criteria into formatted string

**Test Assertions**:
- formats story with title in bold markdown
- includes description text
- formats acceptance criteria as bulleted list
- handles empty acceptance criteria with placeholder

### format_components_context/1

Formats a list of components into readable context text for the prompt.

```elixir
@spec format_components_context(list(CodeMySpec.Components.Component.t())) :: String.t()
```

**Process**:
1. If components list is empty, return message that no components exist
2. Otherwise, map each component through format_component_summary/1
3. Join formatted components with double newlines

**Test Assertions**:
- returns no components message for empty list
- formats multiple components with proper separation
- preserves component information and dependencies

### format_component_summary/1

Formats a single component with name, type, module, description, and dependencies.

```elixir
@spec format_component_summary(CodeMySpec.Components.Component.t()) :: String.t()
```

**Process**:
1. Extract component name, type, module_name, and description
2. Format dependencies using format_dependencies/1 with outgoing_dependencies
3. Combine name (bolded with type), module name, description (or placeholder), and dependencies into formatted string

**Test Assertions**:
- formats component with name and type in bold markdown
- includes module_name line
- shows description or placeholder text
- includes dependencies section

### format_dependencies/1

Formats a list of dependencies into readable text.

```elixir
@spec format_dependencies(list(CodeMySpec.Components.Dependency.t())) :: String.t()
```

**Process**:
1. If dependencies list is empty, return "None"
2. Otherwise, map each dependency to extract target_component.name
3. Format as bulleted list with dash prefix
4. Join with newlines

**Test Assertions**:
- returns "None" for empty dependency list
- formats single dependency as bulleted item
- formats multiple dependencies as bulleted list
- extracts correct target component names
