# CodeMySpec.McpServers.Personas.Tools.CreatePersona

MCP tool that creates an account-scoped persona. Invoked by the agent during persona research or by an engineer action through the persona library surface.

## Type

module

## Functions

### execute/2

Creates a persona in the active account using the provided attrs.

```elixir
@spec execute(map(), Anubis.Server.Frame.t()) ::
        {:reply, map(), Anubis.Server.Frame.t()}
```

**Process**:
1. Validate local scope from frame via `McpServers.Validators.validate_local_scope/1`
2. Call `CodeMySpec.Personas.create_persona/2` with the validated scope and attrs
3. On success, return a text response embedding the persona slug in the footer
4. On changeset error, return a text response summarizing the validation failures

## Dependencies

- Anubis.Server.Component
- CodeMySpec.McpServers.Validators
- CodeMySpec.Personas
