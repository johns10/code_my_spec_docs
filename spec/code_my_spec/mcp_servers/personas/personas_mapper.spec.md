# CodeMySpec.McpServers.Personas.PersonasMapper

Maps persona data to MCP responses. Produces text-only responses (no structured_content) per project convention, embedding persona identifiers in a text footer so agents can reference them in follow-up calls.

## Functions

### persona_response/1

Creates a text response for a newly created or fetched persona.

```elixir
@spec persona_response(Persona.t()) :: map()
```

### persona_link_response/1

Creates a text response for a successful persona-to-story link.

```elixir
@spec persona_link_response(PersonaStory.t()) :: map()
```

### cross_account_error_response/0

Creates a text response explaining a cross-account link rejection.

```elixir
@spec cross_account_error_response() :: map()
```

### changeset_error_response/1

Creates a text response summarizing changeset validation failures.

```elixir
@spec changeset_error_response(Ecto.Changeset.t()) :: map()
```

## Dependencies

- CodeMySpec.McpServers.Formatters
- CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory
- Ecto.Changeset
