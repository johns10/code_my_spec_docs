# CodeMySpec.Events

Generic event log. One table (`events`) with two columns of interest: `event_type` (the discriminator) and `data` (a JSON blob whose shape is event-specific). Inserts are append-only.

## Type

infrastructure

## Dependencies

- CodeMySpec.Repo
