# CodeMySpecWeb.PersonasLive.FormComponent

Form LiveComponent for creating and editing personas. Validates slug, name, and headline via the Persona changeset. On save, calls the Personas context and notifies the parent LiveView.

## Type

liveview_component

## Assigns

| Assign    | Type           | Required | Description                                          |
| --------- | -------------- | -------- | ---------------------------------------------------- |
| id        | any            | Yes      | Component instance identifier                        |
| action    | :new \| :edit  | Yes      | Whether the form creates or updates a persona        |
| persona   | Persona.t()    | Yes      | Persona struct (empty for :new, loaded for :edit)    |
| scope     | Scope.t()      | Yes      | Active scope for calling the Personas context        |
| on_save   | fun/1          | No       | Optional callback the parent provides to receive the saved persona |

## Events

- **phx-change="validate"**: Rebuilds the changeset with current params and updates `:changeset` in assigns so validation errors render live.
- **phx-submit="save"**: Submits the form — calls `Personas.create_persona/2` or `Personas.update_persona/2` based on `:action`. On success, notifies the parent via `send(self(), {:persona_saved, persona})` and closes the modal. On error, shows the errored changeset.

## Design

Layout: vertical form stack inside a modal card.
Fields:
  - Name (`.input`) — required
  - Slug (`.input`) — required, auto-derived from name on blur if empty, shows "URL-safe identifier" hint
  - Headline (`.input`) — optional, max 255
Footer:
  - `.btn-ghost` "Cancel" (closes modal)
  - `.btn-primary` "Save" (disabled while changeset is invalid)
Components: `.form-control`, `.input`, `.label`, `.btn-primary`, `.btn-ghost`, `.modal-action`
Responsive: form fields stack full-width on all breakpoints; modal width caps at `md`.

## Dependencies

- CodeMySpec.Personas
- CodeMySpec.Personas.Persona
- CodeMySpec.Users.Scope
