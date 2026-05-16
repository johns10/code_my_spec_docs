# CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary

MCP tool that provides a comprehensive health assessment of the system architecture. Analyzes story coverage (entry/dependency/orphaned components), context distribution patterns, dependency issues (missing references, high fan-out, circular dependencies), and calculates an overall health score with recommendations for improvement.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
