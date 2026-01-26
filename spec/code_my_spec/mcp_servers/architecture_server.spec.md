# McpServers.ArchitectureServer

MCP server that exposes file-based architecture and spec management tools to AI agents via Hermes. Provides spec file creation/updates with automatic database synchronization, architecture analysis and impact tools, and guided design workflow tools that reference generated architecture views (overview, dependency graph, namespace hierarchy).

## Dependencies

- Hermes.Server
- CodeMySpec.Architecture
- CodeMySpec.Components
- CodeMySpec.Stories
- CodeMySpec.Documents
- CodeMySpec.ProjectSync
- CodeMySpec.McpServers.Architecture.Tools.CreateSpec
- CodeMySpec.McpServers.Architecture.Tools.UpdateSpecMetadata
- CodeMySpec.McpServers.Architecture.Tools.ListSpecs
- CodeMySpec.McpServers.Architecture.Tools.GetSpec
- CodeMySpec.McpServers.Architecture.Tools.DeleteSpec
- CodeMySpec.McpServers.Architecture.Tools.StartArchitectureDesign
- CodeMySpec.McpServers.Architecture.Tools.ReviewArchitectureDesign
- CodeMySpec.McpServers.Architecture.Tools.GetArchitectureSummary
- CodeMySpec.McpServers.Architecture.Tools.GetComponentImpact
- CodeMySpec.McpServers.Architecture.Tools.GetComponentView
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph

## Functions

### start_link/1

Starts the ArchitectureServer as a supervised process.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

**Process**:
1. Initialize Hermes.Server with name "architecture-server"
2. Set version to "1.0.0"
3. Enable tools capability
4. Register all architecture tool modules
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

### Spec File Management

The server exposes spec file operations with automatic DB sync:

- **CreateSpec**: Creates new spec file from template and syncs to DB
- **UpdateSpecMetadata**: Updates spec metadata sections and syncs to DB
- **ListSpecs**: Lists all specs in project with optional type filtering (queries DB)
- **GetSpec**: Retrieves spec by module name/ID with content and dependency info
- **DeleteSpec**: Deletes spec file and removes component from DB

### Design Workflow

The server exposes guided architecture design tools:

- **StartArchitectureDesign**: Initiates design session with story context and architecture view references
- **ReviewArchitectureDesign**: Reviews design with metrics, issues, and architecture view references

### Architecture Analysis

The server exposes analysis and validation tools:

- **GetArchitectureSummary**: Returns structured metrics (counts, depth, cycles)
- **GetComponentImpact**: Analyzes ripple effects of component changes
- **GetComponentView**: Generates detailed component dependency markdown
- **ValidateDependencyGraph**: Detects circular dependencies

## Architecture Views Integration

All design workflow tools reference architecture view files that are kept up-to-date via ProjectSync:
- `docs/architecture/overview.md` - Component overview with descriptions
- `docs/architecture/dependency_graph.mmd` - Mermaid dependency visualization
- `docs/architecture/namespace_hierarchy.md` - Namespace tree structure

These views are regenerated during sync operations and should always reflect current state.

## Sync-on-Write Pattern

When agents create or update specs via this server:
1. Spec file is written to `docs/spec/` directory
2. Component entry is immediately synced to database
3. Architecture views are regenerated via ProjectSync
4. Agents reference updated views for continued work

This ensures spec files remain the source of truth while maintaining fast DB queries for relationships and analysis.

## Authentication

All tools validate scope via OAuth2 access token in the frame context. Each tool uses `Validators.validate_scope/1` to ensure:
- Valid access token exists in frame
- User has access to the account
- Project is active in scope
- User has appropriate permissions

Invalid scope results in error responses without executing tool logic.

## Response Format

All tools return responses via mapper functions that format data according to MCP protocol standards:
- Success responses include structured data
- Error responses include error type and message
- All responses maintain JSON-serializable format for MCP transport
