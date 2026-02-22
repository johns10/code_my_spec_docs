# CodeMySpec.McpServers.ArchitectureServer

MCP (Model Context Protocol) server that exposes architecture analysis tools to AI agents. Provides tools for validating dependency graphs and analyzing user stories. Integrates with the Hermes MCP framework to make CodeMySpec's architecture capabilities accessible to Claude Code and other MCP clients.

## Dependencies

- Hermes.Server
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph
- CodeMySpec.McpServers.Architecture.Tools.AnalyzeStories

## Functions

### server_info/0

Returns server metadata including name and version.

```elixir
@spec server_info() :: map()
```

**Process**:
1. Return map with server name "architecture-server"
2. Include version "1.0.0"

**Test Assertions**:
- returns name as "architecture-server"
- returns version as "1.0.0"

### server_capabilities/0

Returns server capabilities exposed to MCP clients.

```elixir
@spec server_capabilities() :: map()
```

**Process**:
1. Return map indicating tools capability is supported
2. Map contains "tools" key

**Test Assertions**:
- returns map with "tools" key
- indicates tools capability is available

### child_spec/1

Returns OTP child specification for supervision tree integration.

```elixir
@spec child_spec(keyword()) :: Supervisor.child_spec()
```

**Process**:
1. Build child spec with ArchitectureServer as id
2. Set start function to Hermes.Server.Supervisor.start_link with ArchitectureServer and options
3. Set type to :supervisor
4. Set restart to :permanent
5. Return child spec map

**Test Assertions**:
- returns child spec with correct id
- sets start function to Hermes.Server.Supervisor.start_link
- sets type to :supervisor
- sets restart to :permanent

### __components__/0

Returns list of registered tool components available through this server.

```elixir
@spec __components__() :: list(map())
```

**Process**:
1. Collect all registered components from component macro calls
2. Return list of component metadata maps
3. Each map includes component name and implementation module

**Test Assertions**:
- returns list of registered tools
- includes "validate_dependency_graph" tool
- includes "analyze_stories" tool
