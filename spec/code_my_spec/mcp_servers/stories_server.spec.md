# CodeMySpec.McpServers.StoriesServer

MCP server that exposes user story management tools to AI agents via the Hermes framework. Provides CRUD operations for stories, acceptance criteria management, and workflow initiation tools for story interviews and reviews.

## Functions

### server_capabilities/0

Returns the capabilities supported by this MCP server.

```elixir
@spec server_capabilities() :: map()
```

**Process**:
1. Return map of supported MCP capabilities defined in the server configuration
2. Includes tools capability for exposing story management operations

**Test Assertions**:
- returns map with tools capability
- capability map has tools key

### server_info/0

Returns metadata about the server including name and version.

```elixir
@spec server_info() :: map()
```

**Process**:
1. Return map with server name and version from configuration
2. Name is "stories-server", version is "1.0.0"

**Test Assertions**:
- returns map with name key set to "stories-server"
- returns map with version key set to "1.0.0"

### handle_request/2

Handles incoming MCP protocol requests by routing to appropriate component handlers.

```elixir
@spec handle_request(map(), map()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Receive MCP request and frame context
2. Route request to appropriate registered component based on request type
3. Execute component handler and return formatted response
4. Handle errors and return appropriate error responses

**Test Assertions**:
- routes tool calls to registered tool components
- returns properly formatted MCP responses
- handles unknown request types with errors

### supported_protocol_versions/0

Returns list of MCP protocol versions supported by this server.

```elixir
@spec supported_protocol_versions() :: list(String.t())
```

**Process**:
1. Return list of supported MCP protocol version strings
2. Includes protocol versions from 2024

**Test Assertions**:
- returns non-empty list of version strings
- includes protocol versions containing "2024"

### __components__/0

Returns all registered components (tools, resources, prompts) for this server.

```elixir
@spec __components__() :: list(map())
```

**Process**:
1. Return list of all components registered via component/1 macro
2. Includes tools, resources, and prompts

**Test Assertions**:
- returns non-empty list of components
- list includes all registered tool components

### __components__/1

Returns registered components filtered by type.

```elixir
@spec __components__(atom()) :: list(map())
```

**Process**:
1. Receive component type filter (e.g., :tool, :resource, :prompt)
2. Filter registered components by specified type
3. Return filtered list of matching components

**Test Assertions**:
- filters components by type correctly
- returns tools when type is :tool
- returned tools include create_story, update_story, delete_story, get_story, list_stories, list_story_titles
- returned tools include add_criterion, update_criterion, delete_criterion
- returned tools include start_story_interview, start_story_review
- tool components have valid input schemas
- tool components have descriptions
- resource components have valid URIs
- prompt components have descriptions

## Dependencies

- Hermes.Server
- CodeMySpec.McpServers.Stories.Tools.CreateStory
- CodeMySpec.McpServers.Stories.Tools.UpdateStory
- CodeMySpec.McpServers.Stories.Tools.DeleteStory
- CodeMySpec.McpServers.Stories.Tools.GetStory
- CodeMySpec.McpServers.Stories.Tools.ListStories
- CodeMySpec.McpServers.Stories.Tools.ListStoryTitles
- CodeMySpec.McpServers.Stories.Tools.AddCriterion
- CodeMySpec.McpServers.Stories.Tools.UpdateCriterion
- CodeMySpec.McpServers.Stories.Tools.DeleteCriterion
- CodeMySpec.McpServers.Stories.Tools.StartStoryInterview
- CodeMySpec.McpServers.Stories.Tools.StartStoryReview
