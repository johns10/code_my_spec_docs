# CodeMySpecWeb.PersonasLive

Live context grouping the server-side LiveViews and LiveComponents for the account persona library. PMs browse, create, view, and link personas here.

## Type

live_context

## LiveViews

### CodeMySpecWeb.PersonasLive.Index

- **Route:** `/personas`
- **Description:** Lists every persona in the active account with a link to create a new one. Each card shows name, headline, and a count of linked stories.

### CodeMySpecWeb.PersonasLive.Show

- **Route:** `/personas/:slug`
- **Description:** Displays a single persona — rendered `summary.md`, `sources.md` list, and linked stories. Offers an Edit action (opens FormComponent) and a Link-to-story action.

## Components

### CodeMySpecWeb.PersonasLive.FormComponent

Form for creating and editing personas. Handles validation of slug, name, and headline fields. Submits through `Personas.create_persona/2` or `Personas.update_persona/2`.

## Dependencies

- CodeMySpec.Personas
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
