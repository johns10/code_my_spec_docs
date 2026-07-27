# CodeMySpec.Epics

Epics are named, user-managed collections that organize a project's user stories. A story belongs to at most one epic. Epics are purely organizational — they carry no execution semantics; releasing an epic's stories for development is a one-shot bulk edit of the stories themselves.

## Type

context

## Dependencies

- CodeMySpec.Epics.Epic
- CodeMySpec.Epics.EpicsRepository
- CodeMySpec.Projects
- CodeMySpec.Repo
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
- Phoenix.PubSub
