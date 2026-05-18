# Spec as Module Attribute: Kill `.code_my_spec/spec/` Entirely

## Problem

The `.code_my_spec/spec/` tree is a hand-edited shadow of the components table that drifts constantly:

- Spec files exist without impl (phantom contexts like `CodeMySpec.Quality`/`Code`/`TestContext`) — DB carries them as real components until someone notices and deletes the stub
- Impl files exist without spec — `Files.ComponentSync.parse_impl_file` invents a `nil` type, the upserter falls through to `"module"`, and the architecture proposal can't reference the module as a surface (e.g. `CodeMySpecLocalWeb.FilesLive` typed as `module` instead of `liveview`)
- Spec `## Dependencies` section drifts from what the impl actually calls
- Proposal validation enforces naming + type + namespace rules on the spec representation, even when the live DB already has the right linkages (e.g. story 717's real surface is `CodeMySpecLocalWeb.RequirementsLive`, but the validator rejects anything not starting with `CodeMySpecWeb.`)
- Architecture sessions require hand-editing `proposal.md` after every DB-side change to keep the projection in sync
- Module specs are being broadly demoted as a design discipline — keeping the file tree alive while demoting it is the worst of both worlds

The harness friction during architecture sessions traces back to this two-source split.

## Design

Move spec content into a `@component_spec` module attribute on the top-level module. The `.code_my_spec/spec/` tree is deleted. `ComponentSync` reads attributes via `Module.get_attribute/2` (or AST-walks the file for the attribute literal so it works without compiling) instead of `File.read!/1` on a spec path. The existing markdown parser is reused — the input is now an attribute string, not a file body.

```elixir
defmodule CodeMySpec.Issues do
  @component_spec """
  # CodeMySpec.Issues

  ## Type
  context

  ## Dependencies
  - CodeMySpec.Stories
  - CodeMySpec.Files
  """

  # ... rest of the module
end
```

### Why string-as-markdown over a structured map

- Migration is a paste-and-delete: existing spec file body → `@component_spec """..."""`, then `rm` the spec
- Existing parser (`extract_h1_module`, `extract_type_section`, `extract_dependencies`) reused wholesale
- Authors don't have to learn a new shape
- A parallel `@component_spec_structured` attribute can land later if validation pain shows up

### Why this beats the Boundary route

`use Boundary, deps: [...]` is the other obvious candidate for declaring deps. It loses to the attribute approach because:

- Two attributes (`@component_type` + `use Boundary`) vs one (`@component_spec`)
- Boundary brings semantics authors have to learn; module attributes are universal Elixir
- Boundary keeps its current role as a runtime enforcement layer if/when wanted — orthogonal, not coupled
- Migration is mechanical with the attribute; Boundary requires per-module thought about top-level membership

### Connection to "demoting module specs"

This isn't demoting specs further — it's deleting them as a *source of truth*. The information they encoded (type, description, deps) moves into the code. The proposal layer demotes from canonical to commentary (or dies entirely).

## What gets deleted

- `.code_my_spec/spec/` tree (every project)
- `Files.ComponentSync.parse_spec_file`, the spec/impl merge, `infrastructure_paths` consumer
- `Files.ComponentSync.parse_impl_file`'s `defmodule` regex moves into the attribute walker
- The spec file validator hooks in the validation pipeline (spec_valid, spec_file, etc. — they become "attribute present and parseable")
- Proposal's `## Dependencies` editing workflow — deps live in code now
- Phantom-context cleanup tasks (no spec file ⇒ no component, by construction)
- `Architecture.Proposal.check_naming_hierarchy` (already removed) and most of `check_orphan_components` (reframes to "module with `@component_spec` type=context not claimed by a story")

## Open questions

1. **Story links.** Stay DB-driven via `set_story_component` (current model) or move into the attribute as `Stories: [70, 76]`? Lean: stay DB-driven — story-component mapping is product-bound, not architecture-bound.
2. **Description duplication with `@moduledoc`.** Do we keep `## Description` inside `@component_spec` or read `@moduledoc` for it? Lean: keep inside `@component_spec` during migration (paste-and-delete trivially), revisit later.
3. **Pre-implementation design.** Today the proposal can sketch "context that doesn't exist yet." Code-first means scaffolding the module file before iterating. Either accept that workflow shift or keep a thin proposal layer for unplanted contexts.
4. **AST walk vs runtime introspection.** `Module.get_attribute/2` requires the module to be compiled. AST walking the .ex file works for any file on disk regardless of compile state, but reimplements some of `Code.string_to_quoted`. Probably AST walk for projection — matches how spec files work today (read disk, no compile dependency).

## Migration plan

One `mix cms.migrate_specs_to_attributes` task per project:

1. For each spec file under `.code_my_spec/spec/`, find the impl file by canonical path (or by `defmodule` matching the H1)
2. Inject `@component_spec """\n#{spec_body}\n"""` at the top of the module body (after `defmodule X do`)
3. Delete the spec file
4. Format the impl file with `mix format`
5. Commit

One PR per project. ComponentSync code change ships in the same PR for that project's harness.

## Friction this kills

- Phantom-context whack-a-mole during architecture sessions
- "Edit proposal.md after every set_story_component" loop
- `parse_impl_file` type misclassification (`module` for every un-spec'd LiveView/Controller)
- Validator rejection of valid surfaces (`CodeMySpecLocalWeb.*`)
- The `## Dependencies` section drift between spec and what the impl actually `alias`es
- Spec stub validation overhead on every stop hook for every untouched file

## Scope notes

- Single biggest behavior change in the harness's history; multi-day refactor across `Files.ComponentSync`, `Architecture.Proposal`, `Architecture.Proposal*Projector`, the proposal MCP tools, `Architecture.SpecStub`, and every existing spec file in every harness-managed project
- Land behind a feature flag (`spec_source: :attribute | :file`) or as a clean v2 of the projection layer that runs in parallel until verified
- Coordinated with the broader "demoting module specs" direction
