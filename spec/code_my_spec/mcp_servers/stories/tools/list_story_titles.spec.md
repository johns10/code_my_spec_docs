# CodeMySpec.McpServers.Stories.Tools.ListStoryTitles

Lists story titles in a project (lightweight).

Returns just ID, title, and component_id - no criteria or full descriptions. Use this for quick lookups, selection lists, or when you need to find a story ID.

This MCP tool is exposed via the Hermes server framework and provides a lightweight alternative to full story listing operations.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
