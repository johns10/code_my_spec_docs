# CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph

MCP tool that validates the component dependency graph for circular dependencies. Returns validation result indicating success or detailed list of detected cycles. Circular dependencies violate clean architecture principles and make code harder to test and maintain.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
