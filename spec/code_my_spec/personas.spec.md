# CodeMySpec.Personas

Account-scoped persona library. Personas represent product users — role, goals, pain points, context, decision drivers — with identity + metadata in the DB and research text on disk under `.code_my_spec/personas/<slug>/`.

## Type

context

## Delegates

- create_persona/2: CodeMySpec.Personas.PersonasRepository.create_persona/2
- update_persona/3: CodeMySpec.Personas.PersonasRepository.update_persona/3
- list_personas/1: CodeMySpec.Personas.PersonasRepository.list_personas/1
- get_persona/2: CodeMySpec.Personas.PersonasRepository.get_persona/2
- get_persona_by_slug/2: CodeMySpec.Personas.PersonasRepository.get_persona_by_slug/2
- link_persona_to_story/3: CodeMySpec.Personas.PersonasRepository.link_persona_to_story/3
- unlink_persona_from_story/3: CodeMySpec.Personas.PersonasRepository.unlink_persona_from_story/3
- list_personas_for_story/2: CodeMySpec.Personas.PersonasRepository.list_personas_for_story/2
- list_personas_for_project/2: CodeMySpec.Personas.PersonasRepository.list_personas_for_project/2

## Dependencies

- CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory
- CodeMySpec.Personas.PersonasRepository
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.Personas.Persona

Ecto schema for account-scoped personas.

### CodeMySpec.Personas.PersonaStory

Join schema linking personas to stories (many-to-many, account-scoped).

### CodeMySpec.Personas.PersonasRepository

Ecto queries for personas and persona_stories. All queries filter by `scope.active_account_id`.
