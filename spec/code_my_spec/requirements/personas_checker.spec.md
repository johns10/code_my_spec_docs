# CodeMySpec.Requirements.PersonasChecker

Delegate checker for the `personas_complete` requirement node in `project_graph`. Iterates over personas linked to the active project and verifies each has a DB row, `summary.md`, and `sources.md`, and that `summary.md` validates against the `persona_summary` document type.

## Type

module

## Functions

### complete?/1

Runs the completeness check. Returns `:ok` when every persona is complete, otherwise `{:invalid, detail}` with a markdown-formatted per-persona per-artifact breakdown flowing through the stop hook.

```elixir
@spec complete?(Scope.t()) :: :ok | {:invalid, String.t()}
```

**Process**:
1. List personas linked to the active project via `Personas.list_personas_for_project/2`
2. For each persona: verify DB row exists, then check `.code_my_spec/personas/<slug>/summary.md` and `.code_my_spec/personas/<slug>/sources.md` via `Environments.file_exists?/2`
3. For each present `summary.md`, run `Documents.create_dynamic_document/2` against the `persona_summary` type to validate required sections
4. Zero personas or any gap returns `{:invalid, markdown_detail}` listing each failing persona with its specific missing artifact or section name

## Dependencies

- CodeMySpec.Documents
- CodeMySpec.Environments
- CodeMySpec.Personas
- CodeMySpec.Users.Scope
