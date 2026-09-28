# CodeMySpec.McpServers.Stories.Tools.RetireStory

MCP tool that retires a user story. There is no delete: the story keeps its row and number, leaves the backlog and the graph, and its criteria retire with it. Linked issues keep their link.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Anubis.Server.Component
- Anubis.Server.Frame
- Anubis.Server.Response
- Ecto.Changeset
