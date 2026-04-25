# CodeMySpec.Personas.Persona

Ecto schema for account-scoped personas. Identity + metadata only; research text lives on disk at `.code_my_spec/personas/<slug>/`.

## Type

schema

## Fields

| Field       | Type         | Required   | Description                           | Constraints                      |
| ----------- | ------------ | ---------- | ------------------------------------- | -------------------------------- |
| id          | integer      | Yes (auto) | Primary key                           | Auto-generated                   |
| account_id  | integer      | Yes        | Owning account FK                     | References accounts.id           |
| slug        | string       | Yes        | URL-safe identifier                   | Unique per account, Max: 64      |
| name        | string       | Yes        | Display name                          | Max: 255                         |
| headline    | string       | No         | One-line summary for UI cards         | Max: 255                         |
| stories     | many_to_many Story | No  | Linked stories via persona_stories    | join_through: PersonaStory       |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp                    | Auto-generated                   |
| updated_at  | utc_datetime | Yes (auto) | Last update timestamp                 | Auto-generated                   |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Accounts.Account
- CodeMySpec.Personas.PersonaStory
- CodeMySpec.Stories.Story
