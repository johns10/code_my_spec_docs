# CodeMySpec.Personas.PersonasRepository

Ecto queries for personas and persona_stories. All queries filter by `scope.active_account_id`. Cross-account operations are rejected.

## Type

repository

## Functions

### create_persona/2

Inserts a new persona scoped to the active account.

```elixir
@spec create_persona(Scope.t(), map()) :: {:ok, Persona.t()} | {:error, Ecto.Changeset.t()}
```

### list_personas/1

Returns all personas in the active account.

```elixir
@spec list_personas(Scope.t()) :: [Persona.t()]
```

### get_persona_by_slug/2

Fetches a persona by slug within the active account.

```elixir
@spec get_persona_by_slug(Scope.t(), String.t()) :: Persona.t() | nil
```

### link_persona_to_story/3

Inserts a persona_stories row after verifying both persona and story belong to the active account. Returns `{:error, :cross_account}` on mismatch.

```elixir
@spec link_persona_to_story(Scope.t(), integer(), integer()) ::
        {:ok, PersonaStory.t()} | {:error, :cross_account | Ecto.Changeset.t()}
```

### list_personas_for_story/2

Returns every persona linked to the given story within the active account.

```elixir
@spec list_personas_for_story(Scope.t(), integer()) :: [Persona.t()]
```

### list_personas_for_project/2

Returns every persona linked (via any story) to the given project within the active account. Used by `PersonasChecker` to enumerate personas for the `personas_complete` requirement.

```elixir
@spec list_personas_for_project(Scope.t(), integer()) :: [Persona.t()]
```

## Dependencies

- Ecto.Query
- CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory
- CodeMySpec.Repo
- CodeMySpec.Users.Scope
