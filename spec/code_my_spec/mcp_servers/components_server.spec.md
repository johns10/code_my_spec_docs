# McpServers.ComponentsServer

MCP (Model Context Protocol) server that exposes component management, dependency tracking, architecture analysis, and design workflow tools to AI agents via Hermes. Provides comprehensive CRUD operations for components, dependency graph manipulation, similar component tracking, context design workflows, and architecture health reporting.

## Dependencies

- Hermes.Server
- CodeMySpec.McpServers.Components.Tools.CreateComponent
- CodeMySpec.McpServers.Components.Tools.UpdateComponent
- CodeMySpec.McpServers.Components.Tools.DeleteComponent
- CodeMySpec.McpServers.Components.Tools.GetComponent
- CodeMySpec.McpServers.Components.Tools.ListComponents
- CodeMySpec.McpServers.Stories.Tools.ListStories
- CodeMySpec.McpServers.Components.Tools.CreateDependency
- CodeMySpec.McpServers.Components.Tools.DeleteDependency
- CodeMySpec.McpServers.Components.Tools.AddSimilarComponent
- CodeMySpec.McpServers.Components.Tools.RemoveSimilarComponent
- CodeMySpec.McpServers.Components.Tools.StartContextDesign
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture
- CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary
- CodeMySpec.McpServers.Components.Tools.ContextStatistics
- CodeMySpec.McpServers.Components.Tools.OrphanedContexts
- CodeMySpec.McpServers.Stories.Tools.SetStoryComponent

## Functions

### start_link/1

Starts the ComponentsServer as a supervised process.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Initialize Hermes.Server with name "components-server"
2. Set version to "1.0.0"
3. Enable tools capability
4. Register all component tool modules
5. Start server process under supervision

**Test Assertions**:
- starts server successfully with correct name
- registers server with version "1.0.0"
- enables tools capability
- all tool components are available after start
- server process is alive and supervised

### child_spec/1

Returns child specification for supervision tree.

```elixir
@spec child_spec(keyword()) :: Supervisor.child_spec()
```

**Process**:
1. Generate child_spec using Hermes.Server defaults
2. Set id to __MODULE__
3. Set start as {__MODULE__, :start_link, [opts]}

**Test Assertions**:
- returns valid child_spec map
- includes correct module id
- includes correct start tuple

## Tool Categories

### CRUD Operations

The server exposes the following component CRUD tools:

- **CreateComponent**: Creates new component with type, name, module_name
- **UpdateComponent**: Updates existing component attributes
- **DeleteComponent**: Removes component and cascades to dependencies
- **GetComponent**: Retrieves single component by ID with associations
- **ListComponents**: Returns all components in project scope

### Dependency Management

The server exposes dependency graph manipulation tools:

- **CreateDependency**: Creates dependency relationship between components
- **DeleteDependency**: Removes dependency relationship

### Similar Component Tracking

The server exposes tools for tracking similar components for reference:

- **AddSimilarComponent**: Links similar component for design reference
- **RemoveSimilarComponent**: Unlinks similar component reference

### Architecture Analysis

The server exposes architecture visualization and health tools:

- **ShowArchitecture**: Returns component dependency graph for components with stories
- **ArchitectureHealthSummary**: Provides health metrics and recommendations
- **ContextStatistics**: Returns statistics for context components
- **OrphanedContexts**: Identifies contexts not connected to story-driven components

### Design Workflows

The server exposes context design session tools:

- **StartContextDesign**: Initiates context design session for component and children
- **ReviewContextDesign**: Triggers review of context design for architectural issues

### Story Integration

The server exposes story-component linking tools:

- **ListStories**: Returns all stories in project scope
- **SetStoryComponent**: Links story to component for traceability

## Authentication

All tools validate scope via OAuth2 access token in the frame context. Each tool uses `Validators.validate_scope/1` to ensure:
- Valid access token exists in frame
- User has access to the account
- Project is active in scope
- User has appropriate permissions

Invalid scope results in error responses without executing tool logic.

## Response Format

All tools return responses via `ComponentsMapper` or equivalent mapper functions that format data according to MCP protocol standards:
- Success responses include structured data
- Error responses include error type and message
- All responses maintain JSON-serializable format for MCP transport
