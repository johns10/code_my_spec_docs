# CodeMySpec.McpServers.Stories.Tools.DeleteCriterion

MCP tool that deletes an acceptance criterion from a story. Provides protection against deleting verified (locked) criteria to maintain data integrity.

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Anubis.Server.Component
- Anubis.Server.Frame
- Anubis.Server.Response
- Ecto.Changeset
