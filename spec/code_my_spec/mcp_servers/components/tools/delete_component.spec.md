# CodeMySpec.McpServers.Components.Tools.DeleteComponent

MCP tool that deletes a component from the system. Validates scope (active account and project), retrieves the component, deletes it from the database, and broadcasts the deletion event. Implements the Hermes MCP tool protocol for integration with AI agents via Claude Code/Desktop.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
