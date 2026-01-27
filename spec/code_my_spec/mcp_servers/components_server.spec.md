# CodeMySpec.McpServers.ComponentsServer

MCP (Model Context Protocol) server that exposes component management, dependency tracking, architecture analysis, and design workflow tools to AI agents via Hermes. Provides comprehensive CRUD operations for components, dependency graph manipulation, similar component tracking, context design workflows, and architecture health reporting. This server enables AI agents like Claude Code to interact with the CodeMySpec component system through standardized MCP tool calls.

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

This module uses the Hermes.Server behavior which provides the MCP server implementation. The module declaration includes configuration via the `use Hermes.Server` macro and registers tool components that handle specific MCP operations.

### Server Configuration

The server is configured with the following attributes via `use Hermes.Server`:

- **name**: "components-server"
- **version**: "1.0.0"
- **capabilities**: [:tools]

### Tool Registration

Tools are registered using the `component/1` macro. Each registered tool module handles a specific MCP tool call and follows the Hermes.Server.Component behavior pattern.

**Core CRUD Operations:**

- **CreateComponent**: Creates a new component with name, type, module_name, description, and optional parent_component_id. Validates type enum (context, coordination_context) and delegates to Components.create_component/2.

- **UpdateComponent**: Updates an existing component's attributes. Validates scope ownership and delegates to Components.update_component/3.

- **DeleteComponent**: Removes a component from the system with cascading dependency cleanup. Delegates to Components.delete_component/2.

- **GetComponent**: Retrieves a single component by ID with similar components preloaded. Delegates to Components.get_component!/2 and loads similar components via Components.list_similar_components/2.

- **ListComponents**: Lists all components in the current project scope without filters. Delegates to Components.list_components/1.

**Dependency Management:**

- **CreateDependency**: Creates a dependency relationship between source_component_id and target_component_id. Validates for circular dependencies via Components.validate_dependency_graph/1 before committing. Returns structured dependency response with both component summaries.

- **DeleteDependency**: Removes a dependency relationship between components. Delegates to Components.delete_dependency/2.

**Similar Component Management:**

- **AddSimilarComponent**: Establishes a similar component relationship between component_id and similar_component_id for design reference purposes. Delegates to Components.add_similar_component/3.

- **RemoveSimilarComponent**: Removes a similar component relationship. Delegates to Components.remove_similar_component/3.

**Architecture and Design Tools:**

- **StartContextDesign**: Initiates a guided context design session by generating a comprehensive prompt including all unsatisfied stories (from Stories.list_unsatisfied_stories/1) and existing components with dependencies (from Components.list_components_with_dependencies/1). Returns formatted prompt as text response.

- **ReviewContextDesign**: Reviews proposed context designs for architectural compliance and best practices alignment.

- **ShowArchitecture**: Displays complete system architecture with dependency graphs organized by depth layers, story associations, and detailed component metrics. Returns architecture overview, components array, and dependency_graph with relationships. Delegates to Components.show_architecture/1.

- **ArchitectureHealthSummary**: Provides comprehensive health analysis including story_coverage (entry/dependency/orphaned components), context_distribution (story count patterns), dependency_issues (missing references, high fan-out, circular dependencies), and overall_score (coverage + dependency health). Uses sophisticated recursive analysis to identify all transitive dependencies and calculate orphaned components.

- **ContextStatistics**: Returns statistical analysis of context component usage patterns and distribution metrics.

- **OrphanedContexts**: Lists components that are not connected to stories or referenced in dependency chains. Delegates to Components.list_orphaned_contexts/1.

**Story Integration:**

- **ListStories**: Lists user stories with pagination support (limit, offset, search filters). Delegates to Stories.list_project_stories_paginated/2. Default limit is 20, max limit is 100.

- **SetStoryComponent**: Associates a story with a component that satisfies its requirements. Delegates to Stories.set_story_component/3 for linking.

**Process**:

1. Server initialization via `use Hermes.Server` macro establishes MCP server configuration with name, version, and capabilities
2. Tool components are registered using `component/1` macro calls during module compilation
3. When an AI agent makes an MCP tool call, the Hermes framework routes the request to the appropriate tool component's execute/2 function
4. Each tool component validates the request scope via Validators.validate_scope/1 to ensure active account and project exist
5. Tool executes its specific business logic by delegating to the Components or Stories context functions
6. Results are formatted using ComponentsMapper or StoriesMapper helper functions and wrapped in Hermes.Server.Response structs
7. Errors are caught and returned as structured error responses with appropriate error messages via mapper functions
8. Response is returned to the AI agent in MCP protocol format

**Test Assertions**:

- Server initialization creates a valid MCP server with name "components-server" and version "1.0.0"
- Server capabilities include :tools capability
- All registered tool components are available for MCP tool calls and route correctly
- Tool routing correctly maps tool names to their respective component modules
- Scope validation rejects requests without active account with :missing_active_account error
- Scope validation rejects requests without active project with :missing_active_project error
- CreateComponent validates type enum and returns validation error for invalid types
- CreateComponent delegates to Components.create_component/2 with scope and params
- GetComponent loads similar components via Components.list_similar_components/2
- CreateDependency validates for circular dependencies before committing changes
- CreateDependency returns circular_dependency_error with cycle descriptions when validation fails
- DeleteDependency removes dependency relationships via Components.delete_dependency/2
- ShowArchitecture returns architecture with overview, components array, and dependency_graph
- ShowArchitecture organizes components by depth layers starting from story entry points
- ArchitectureHealthSummary calculates accurate story_coverage metrics including orphaned_percentage
- ArchitectureHealthSummary identifies missing references, high fan-out components, and circular dependencies
- ArchitectureHealthSummary calculates overall_score from coverage_score and dependency_score
- StartContextDesign formats unsatisfied stories with acceptance criteria in prompt
- StartContextDesign includes existing components with dependencies in prompt
- ListStories respects limit parameter with max of 100 and default of 20
- ListStories supports pagination via offset parameter
- ListStories supports search filtering via search parameter
- SetStoryComponent links story to component via Stories.set_story_component/3
- All error responses provide clear, actionable error messages via mapper error functions
- Validation errors format Ecto.Changeset errors via Formatters.format_changeset_errors/1
- Similar component operations maintain relationships via Components context
- Response formatting uses ComponentsMapper for consistent JSON structure
- All tool responses are JSON-serializable for MCP transport
