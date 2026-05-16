# CodeMySpec.McpServers.Personas.PersonasMapper

Maps persona data to MCP responses. Produces text-only responses (no structured_content) per project convention, embedding persona identifiers in a text footer so agents can reference them in follow-up calls.

## Dependencies

- CodeMySpec.McpServers.Formatters
- CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory
- Ecto.Changeset
