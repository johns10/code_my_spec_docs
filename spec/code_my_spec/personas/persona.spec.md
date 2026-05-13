# CodeMySpec.Personas.Persona

Ecto schema for project-scoped personas. Identity + metadata only; research text lives on disk at `.code_my_spec/personas/<slug>/`.

## Type

schema

## Fields

| Field       | Type         | Required   | Description                           | Constraints                      |
| ----------- | ------------ | ---------- | ------------------------------------- | -------------------------------- |
| id          | binary_id    | Yes (auto) | Primary key                           | Auto-generated                   |
| project_id  | binary_id    | Yes        | Owning project FK                     | References projects.id           |
| slug        | string       | Yes        | URL-safe identifier                   | Unique per project, Max: 64      |
| name        | string       | Yes        | Display name                          | Max: 255                         |
| headline    | string       | No         | One-line summary for UI cards         | Max: 255                         |
| persona_type| Ecto.Enum    | Yes        | Evidence tier                         | proto \| qualitative \| statistical |
| stories     | many_to_many Story | No  | Linked stories via persona_stories    | join_through: PersonaStory       |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp                    | Auto-generated                   |
| updated_at  | utc_datetime | Yes (auto) | Last update timestamp                 | Auto-generated                   |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Projects.Project
- CodeMySpec.Personas.PersonaStory
- CodeMySpec.Stories.Story
