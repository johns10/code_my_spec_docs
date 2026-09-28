# CodeMySpec.McpServers.Stories.Tools.RestoreStory

MCP tool that brings a retired story back under its number, with the criteria that were retired with it. The story comes back parked; releasing it again is a separate decision. Refuses a story that is not retired.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Anubis.Server.Component
- Anubis.Server.Frame
- Anubis.Server.Response
- Ecto.Changeset
