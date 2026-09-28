# CodeMySpec.McpServers.Stories.Tools.RetireCriterion

MCP tool that retires an acceptance criterion by its number. There is no delete: a retired criterion keeps its row and number, drops out of its story's coverage, and can be restored. Refuses verified (locked) criteria.

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Anubis.Server.Component
- Anubis.Server.Frame
- Anubis.Server.Response
- Ecto.Changeset
