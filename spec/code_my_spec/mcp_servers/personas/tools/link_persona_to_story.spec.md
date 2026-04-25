# CodeMySpec.McpServers.Personas.Tools.LinkPersonaToStory

MCP tool that links an existing persona to a story via the persona_stories join. Rejects cross-account attempts at the repository layer.

## Type

module

## Functions

### execute/2

Creates a persona_stories row referencing the active-account persona and story.

```elixir
@spec execute(map(), Anubis.Server.Frame.t()) ::
        {:reply, map(), Anubis.Server.Frame.t()}
```

**Process**:
1. Validate local scope from frame
2. Call `CodeMySpec.Personas.link_persona_to_story/3` with scope, persona_id, story_id
3. On `{:error, :cross_account}`, return a text response explaining the rejection
4. On success, return a text response naming the linked persona and story

## Dependencies

- Anubis.Server.Component
- CodeMySpec.McpServers.Validators
- CodeMySpec.Personas
