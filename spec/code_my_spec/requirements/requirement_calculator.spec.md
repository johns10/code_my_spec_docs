# CodeMySpec.Requirements.RequirementCalculator

Computes requirement satisfaction from File records, Problems, and entity fields.

Dispatches on the `check_type` field of each RequirementDefinition rather than
pattern-matching on requirement names. Covers component, story, and project
requirements with a unified set of check types.

Check types:

- **`:file_exists`** — a File record with the configured role exists for the entity
- **`:file_valid`** — a File record with the configured role exists AND has `valid: true`
- **`:path_exists`** — a file at the configured path exists in the project file list
- **`:field_present`** — a field on the entity is not nil
- **`:no_problems`** — zero Problem records from the configured source
- **`:tests_passing`** — zero exunit Problem records for the entity
- **`:spex_passing`** — zero spex Problem records for the entity

Each check type reads its parameters from `definition.config`:
- `:file_exists` → `%{role: :spec}`, `%{role: :bdd_spec}`, etc.
- `:file_valid` → `%{role: :spec}`, `%{role: :test}`, etc.
- `:path_exists` → `%{path: ".code_my_spec/qa/journey_plan.md"}` or `%{path_prefix: ".code_my_spec/integrations/"}`
- `:field_present` → `%{field: :component_id}`
- `:no_problems` → `%{source: "credo"}`, `%{source: "sobelow"}`, etc.
- `:tests_passing` → no config needed (source is always "exunit")
- `:spex_passing` → no config needed (source is always "spex")

The old children aggregate checks (`context_specs`, `context_implementation`)
are removed — child dependencies are handled by the requirement graph edges,
not by the calculator.

Story and project checks are also handled here instead of in RequirementGraph.
The graph is responsible for topology (edges), the calculator for satisfaction
(nodes). `project_setup` remains a special case that delegates to
`ProjectSetup.evaluate`.

## Type

module

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Files.File
- CodeMySpec.Issues
- CodeMySpec.Problems.Problem
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Preloader
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
