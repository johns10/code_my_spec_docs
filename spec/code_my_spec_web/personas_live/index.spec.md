# CodeMySpecWeb.PersonasLive.Index

Lists every persona in the active account. Each row shows name, slug, headline, and a "View" link. A prominent "New persona" action opens the FormComponent.

## Type

liveview

## Route

`/personas`

## Params

None

## User Interactions

- **phx-click="new"**: Opens the FormComponent in `:new` mode inside a modal or side panel.
- **phx-click="link_to_story"**: Sent from a persona row — opens the link-to-story flow (separate view or modal) for the selected persona.

## Components

- `CodeMySpecWeb.PersonasLive.FormComponent` — create form, shown in modal when `new` action is active.

## Design

Layout: centered single column with a persona grid.
Header:
  - Page title "Personas"
  - `.btn-primary` "New persona" button (right-aligned)
Main content:
  - If zero personas: empty-state card with a prompt to start persona research and a CTA to create a first persona.
  - Otherwise: responsive grid of `.card` elements (1 col mobile, 2 col tablet, 3 col desktop). Each card:
    - Persona name (h3)
    - Headline (muted)
    - Linked story count (badge)
    - `.btn-ghost` "View" linking to `/personas/:slug`
Components: `.card`, `.btn-primary`, `.btn-ghost`, `.badge`, `.modal`
Responsive: grid collapses to single column below `md`.

## Dependencies

- CodeMySpec.Personas
- CodeMySpec.Users.Scope
- CodeMySpecWeb.PersonasLive.FormComponent
