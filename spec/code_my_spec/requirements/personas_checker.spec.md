# CodeMySpec.Requirements.PersonasChecker

Delegate checker for the `personas_complete` requirement node in `project_graph`. Iterates over personas linked to the active project and verifies each has a DB row, `summary.md`, and `sources.md`, and that `summary.md` validates against the `persona_summary` document type.

## Type

module

## Dependencies

- CodeMySpec.Documents
- CodeMySpec.Environments
- CodeMySpec.Personas
- CodeMySpec.Users.Scope
