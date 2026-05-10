# Project Configuration — Rules

## Rule: All quality gate configuration is local to the engineer's machine

There's no server-side policy. The engineer decides what's required and
what blocks. This config lives in a local-only ProjectConfiguration schema
in the local SQLite DB. Not synced to the server.

One ProjectConfiguration per project.

## Rule: Configuration lives in a ProjectConfiguration schema

Not on the Project schema. require_specs and require_unit_tests are removed
from the server-side Project schema and replaced by fields on ProjectConfiguration.

## Rule: Requirement toggles control the requirements graph

Three separate booleans that determine what work is required for a component
to be considered done:
- require_specs (default: true)
- require_reviews (default: true)
- require_unit_tests (default: true)

These replace the bundled require_specs and require_unit_tests on Project.

## Rule: Compile always runs, warning blocking is configurable

Compiler errors always block (non-negotiable). Compiler warnings block by
default but the engineer can turn that off.

## Rule: Analyzers and validators are configurable with four modes

Each configurable source supports: off / block all / block changed / don't block.

| Source            | Default       |
|-------------------|---------------|
| compile_warnings  | block         |
| credo             | block changed |
| exunit            | block all     |
| spex              | off           |
| spec_validation   | block changed |
| qa_validation     | block changed |

spec_validation covers document schema validation and H1 title matching on
spec/review files. qa_validation covers qa brief/result schema checks. Both
are cheap (millisecond cost) but still configurable — their problems persist
across turns, so "always block on every matching problem in the DB" punishes
the engineer for prior stubs and unrelated work. `block_changed` scopes the
block to files the agent actually touched this turn.

## Rule: Credo's `:block_all` scans the whole project, not just changed files

In `:block_all`, the stop hook runs `mix credo` against the entire project
so the block decision reflects every file's current state. In `:block_changed`
and `:dont_block`, credo runs only on the files the agent touched this turn —
fast and scoped. `:off` skips credo entirely.

This rule is specific to credo because `lib/` and `test/` are large surface
areas where the per-file accumulation model takes too many turns to converge,
and silent gaps (an analyzer crash on one turn) can leave real violations
unblocked indefinitely. Spec and QA validation operate on tightly bounded
directories (`.code_my_spec/spec/**`, `.code_my_spec/qa/**`) where the per-file
model converges quickly enough, so they keep the changed-files-only scan in
every mode.

When credo runs project-wide, the pipeline clears all credo problems before
persisting the new scan results. When credo runs scoped, problems are cleared
per-file (the existing pattern).

## Rule: ProjectConfiguration is created with defaults on first use

When config is read for a project that doesn't have a ProjectConfiguration
record yet, one is created automatically with all defaults. The engineer
never has to visit the config screen to get the standard behavior.
