# CodeMySpec.McpServers.Stories.Tools.GetCriterion

MCP tool that reads one acceptance criterion by its number, active or retired, with the story it belongs to. Retired criteria are not listed by `get_story`; this is how they are read.

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Anubis.Server.Component
- Anubis.Server.Frame
- Anubis.Server.Response
