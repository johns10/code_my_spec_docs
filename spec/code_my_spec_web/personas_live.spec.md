# CodeMySpecWeb.PersonasLive

Live context grouping the server-side LiveViews and LiveComponents for the active project's persona library. PMs browse, create, view, and link personas here.

## Type

live_context

## Components

### CodeMySpecWeb.PersonasLive.FormComponent

Form for creating and editing personas. Handles validation of slug, name, and headline fields. Submits through `Personas.create_persona/2` or `Personas.update_persona/2`.

## Dependencies

- CodeMySpec.Personas
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
