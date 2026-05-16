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
