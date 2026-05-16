# CodeMySpec.Personas.PersonasRepository

Ecto queries for personas and persona_stories. All queries filter by `scope.active_project_id`. Cross-project operations are rejected.

## Type

repository

## Dependencies

- Ecto.Query
- CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory
- CodeMySpec.Repo
- CodeMySpec.Users.Scope
