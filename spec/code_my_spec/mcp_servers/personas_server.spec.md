# CodeMySpec.McpServers.PersonasServer

Anubis MCP server exposing persona operations as MCP tools. Registers the tools under the personas namespace.

## Type

module

## Functions

### start_link/1

Starts the MCP server process.

```elixir
@spec start_link(keyword()) :: GenServer.on_start()
```

## Dependencies

- Anubis.Server
- CodeMySpec.McpServers.Personas.Tools.CreatePersona
- CodeMySpec.McpServers.Personas.Tools.LinkPersonaToStory
