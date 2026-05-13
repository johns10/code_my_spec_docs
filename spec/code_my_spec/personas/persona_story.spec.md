# CodeMySpec.Personas.PersonaStory

Join schema linking personas to stories. Both sides are project-scoped — cross-project links are rejected at the repository level by checking `persona.project_id == story.project_id`.

## Type

schema

## Fields

| Field       | Type         | Required   | Description                  | Constraints                     |
| ----------- | ------------ | ---------- | ---------------------------- | ------------------------------- |
| id          | integer      | Yes (auto) | Primary key                  | Auto-generated                  |
| persona_id  | integer      | Yes        | FK to personas               | References personas.id          |
| story_id    | integer      | Yes        | FK to stories                | References stories.id           |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp           | Auto-generated                  |
| updated_at  | utc_datetime | Yes (auto) | Last update timestamp        | Auto-generated                  |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Personas.Persona
- CodeMySpec.Stories.Story
