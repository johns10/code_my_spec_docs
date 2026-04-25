# CodeMySpecWeb.PersonasLive.Show

Displays a single persona — rendered `summary.md`, the sources list, and linked stories. Provides edit and link-to-story actions.

## Type

liveview

## Route

`/personas/:slug`

## Params

- `slug` - string, persona slug within the active account

## User Interactions

- **phx-click="edit"**: Opens the FormComponent in `:edit` mode pre-filled with this persona's fields.
- **phx-click="link_to_story"**: Opens the link-to-story modal with a searchable list of account stories; selecting one calls `Personas.link_persona_to_story/3`.
- **phx-click="unlink_story"**: Unlinks the given story from this persona after a confirmation.

## Components

- `CodeMySpecWeb.PersonasLive.FormComponent` — edit form, shown in modal when `edit` action is active.

## Design

Layout: two-column wide view on desktop, single column on mobile.
Header:
  - Persona name (h1)
  - Headline (muted, large)
  - `.btn-primary` "Edit" + `.btn-secondary` "Link to story"
Left column (summary + sources):
  - `.card` rendering `summary.md` as markdown (Role, Goals, Pain Points, Context, Decision Drivers, Evidence sections as visible subheaders).
  - `.card` for Sources — list of URLs with titles and access dates from `sources.md`.
Right column (linked stories):
  - `.card` listing every linked story — title, status badge, unlink action.
Components: `.card`, `.btn-primary`, `.btn-secondary`, `.badge`, `.modal`, markdown renderer (MDEx).
Responsive: columns stack below `lg`.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Personas
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
- CodeMySpecWeb.PersonasLive.FormComponent
- MDEx
