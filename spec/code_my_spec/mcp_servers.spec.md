# CodeMySpec.McpServers

MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

This context serves as the namespace for MCP server implementations that expose CodeMySpec functionality to AI agents (Claude Code, Claude Desktop) via the Hermes MCP library. The actual protocol handling is delegated to Hermes.Server - this context organizes the server definitions, tools, and shared infrastructure.

## Type

context

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.Sessions
- Hermes.Server
- Ecto.Changeset
- Jason

## Components

### StoriesServer

Hermes MCP server exposing user story management tools to AI agents. Registers 13 tools for CRUD operations on stories and acceptance criteria, plus workflow tools for story interviews and reviews.

### ComponentsServer

Hermes MCP server exposing component architecture tools to AI agents. Registers 16 tools for component CRUD, dependency management, similar component tracking, and architecture analysis/design workflows.

### ArchitectureServer

Hermes MCP server exposing specification file management and architecture design tools to AI agents. Registers 9 tools for spec file CRUD, design workflow initiation, and dependency graph validation.

### AnalyticsAdminServer

Hermes MCP server exposing Google Analytics 4 administrative tools to AI agents. Registers 14 tools for managing custom dimensions, custom metrics, and key events.

### Validators

Validation utilities for MCP server requests ensuring proper scope (account and project) context.

### Formatters

Response formatting utilities for MCP servers providing hybrid human-readable + JSON responses with changeset error formatting and contextual guidance.

### Stories.StoriesMapper

Maps story domain entities to MCP response formats with hybrid text summaries and JSON data structures for both human and programmatic consumption.

### Stories.Tools.CreateStory

Tool for creating user stories with title, description, and acceptance criteria.

### Stories.Tools.CreateStories

Batch tool for creating multiple user stories in a single request.

### Stories.Tools.UpdateStory

Tool for updating existing user story fields.

### Stories.Tools.DeleteStory

Tool for removing user stories from the system.

### Stories.Tools.GetStory

Tool for retrieving detailed story information including criteria.

### Stories.Tools.ListStories

Tool for listing stories with pagination support.

### Stories.Tools.ListStoryTitles

Tool for retrieving story titles and IDs only (lightweight list).

### Stories.Tools.AddCriterion

Tool for adding acceptance criteria to existing stories.

### Stories.Tools.UpdateCriterion

Tool for modifying acceptance criterion text or verification status.

### Stories.Tools.DeleteCriterion

Tool for removing acceptance criteria from stories.

### Stories.Tools.SetStoryComponent

Tool for associating a story with a component.

### Stories.Tools.ClearStoryComponent

Tool for removing component association from a story.

### Stories.Tools.StartStoryInterview

Tool for initiating structured story refinement workflow sessions.

### Stories.Tools.StartStoryReview

Tool for initiating story validation and approval workflow sessions.

### Components.ComponentsMapper

Maps component domain entities to MCP response formats with JSON structures for AI agent consumption.

### Components.Tools.CreateComponent

Tool for creating architectural components (contexts, modules, schemas, etc.).

### Components.Tools.CreateComponents

Batch tool for creating multiple components with dependency relationships.

### Components.Tools.UpdateComponent

Tool for modifying component metadata and relationships.

### Components.Tools.DeleteComponent

Tool for removing components from the architecture.

### Components.Tools.GetComponent

Tool for retrieving detailed component information including dependencies.

### Components.Tools.ListComponents

Tool for listing all components in the project architecture.

### Components.Tools.CreateDependency

Tool for establishing dependency relationships between components.

### Components.Tools.CreateDependencies

Batch tool for establishing multiple dependency relationships.

### Components.Tools.DeleteDependency

Tool for removing dependency relationships between components.

### Components.Tools.AddSimilarComponent

Tool for marking components as architectural analogs for reference.

### Components.Tools.RemoveSimilarComponent

Tool for removing similar component relationships.

### Components.Tools.StartContextDesign

Tool for initiating structured context design workflow sessions.

### Components.Tools.ReviewContextDesign

Tool for initiating design review and validation workflow sessions.

### Components.Tools.ShowArchitecture

Tool for visualizing the component dependency graph and structure.

### Components.Tools.ArchitectureHealthSummary

Tool for analyzing architectural quality metrics and identifying issues.

### Components.Tools.ContextStatistics

Tool for computing metrics on context size, complexity, and dependencies.

### Components.Tools.OrphanedContexts

Tool for identifying components without parent relationships or stories.

### Architecture.ArchitectureMapper

Maps architecture domain entities and spec files to MCP response formats with JSON structures and validation results for AI agent consumption.

### Architecture.Tools.CreateSpec

Tool for creating specification files for components in the architecture.

### Architecture.Tools.UpdateSpecMetadata

Tool for updating metadata fields in existing specification files.

### Architecture.Tools.GetSpec

Tool for retrieving specification file content for a component.

### Architecture.Tools.ListSpecs

Tool for listing all specification files in the project.

### Architecture.Tools.DeleteSpec

Tool for removing specification files from the system.

### Architecture.Tools.GetComponentView

Tool for generating detailed component view with dependencies and relationships.

### Architecture.Tools.ValidateDependencyGraph

Tool for detecting circular dependencies in the component architecture.

### AnalyticsAdmin.Tools.ListCustomDimensions

Tool for listing Google Analytics 4 custom dimensions.

### AnalyticsAdmin.Tools.GetCustomDimension

Tool for retrieving detailed custom dimension configuration.

### AnalyticsAdmin.Tools.CreateCustomDimension

Tool for registering new custom dimensions in GA4.

### AnalyticsAdmin.Tools.UpdateCustomDimension

Tool for modifying custom dimension metadata.

### AnalyticsAdmin.Tools.ArchiveCustomDimension

Tool for archiving custom dimensions (soft delete).

### AnalyticsAdmin.Tools.ListCustomMetrics

Tool for listing Google Analytics 4 custom metrics.

### AnalyticsAdmin.Tools.GetCustomMetric

Tool for retrieving detailed custom metric configuration.

### AnalyticsAdmin.Tools.CreateCustomMetric

Tool for registering new custom metrics in GA4.

### AnalyticsAdmin.Tools.UpdateCustomMetric

Tool for modifying custom metric metadata.

### AnalyticsAdmin.Tools.ArchiveCustomMetric

Tool for archiving custom metrics (soft delete).

### AnalyticsAdmin.Tools.ListKeyEvents

Tool for listing Google Analytics 4 key events.

### AnalyticsAdmin.Tools.CreateKeyEvent

Tool for registering new key events in GA4.

### AnalyticsAdmin.Tools.UpdateKeyEvent

Tool for modifying key event configuration.

### AnalyticsAdmin.Tools.DeleteKeyEvent

Tool for removing key events from GA4.

## Functions

### validate_scope/1

Validates that the MCP request frame contains both an active account and active project in the current scope.

```elixir
@spec validate_scope(Hermes.Server.Frame.t()) :: {:ok, CodeMySpec.Scope.t()} | {:error, atom()}
```

**Process**:
1. Extract current_scope from frame assigns
2. Validate active account exists in scope
3. Validate active project exists in scope
4. Return scope struct or appropriate error atom

**Test Assertions**:
- returns {:ok, scope} when account and project are set
- returns {:error, :missing_active_account} when account is nil
- returns {:error, :missing_active_project} when project is nil
- returns {:error, :missing_active_account} when scope is nil

### require_active_account/1

Validates that the current scope has an active account set.

```elixir
@spec require_active_account(Hermes.Server.Frame.t()) :: {:ok, Hermes.Server.Frame.t()} | {:error, :missing_active_account}
```

**Process**:
1. Extract current_scope from frame assigns
2. Check if scope exists and has active_account
3. Return frame unchanged if valid, error atom if invalid

**Test Assertions**:
- returns {:ok, frame} when account is present
- returns {:error, :missing_active_account} when account is nil
- returns {:error, :missing_active_account} when scope is nil

### require_active_project/1

Validates that the current scope has an active project set.

```elixir
@spec require_active_project(Hermes.Server.Frame.t()) :: {:ok, Hermes.Server.Frame.t()} | {:error, :missing_active_project}
```

**Process**:
1. Extract current_scope from frame assigns
2. Check if scope exists and has active_project
3. Return frame unchanged if valid, error atom if invalid

**Test Assertions**:
- returns {:ok, frame} when project is present
- returns {:error, :missing_active_project} when project is nil
- returns {:error, :missing_active_project} when scope is nil

### format_changeset_errors/1

Formats Ecto changeset errors as human-readable markdown with contextual guidance.

```elixir
@spec format_changeset_errors(Ecto.Changeset.t()) :: String.t()
```

**Process**:
1. Extract errors from changeset with interpolated values
2. Format each field's errors as markdown list items
3. Generate contextual fix guidance hints
4. Combine into markdown document with "Validation Error" header

**Test Assertions**:
- returns formatted markdown string
- includes field names in bold
- includes all error messages
- includes fix guidance when hints are available
- handles empty error list

### extract_errors/1

Extracts changeset errors as a map structure for programmatic access.

```elixir
@spec extract_errors(Ecto.Changeset.t()) :: %{atom() => [String.t()]}
```

**Process**:
1. Traverse changeset errors
2. Interpolate error message variables with keyword option values
3. Return map of field atoms to lists of error strings

**Test Assertions**:
- returns map with field keys and error string values
- interpolates variables like %{count} from opts
- handles nested changesets
- handles multiple errors per field
