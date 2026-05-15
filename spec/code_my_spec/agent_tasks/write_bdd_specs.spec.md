# CodeMySpec.AgentTasks.WriteBddSpecs

## Type

skill

## Intent

Generate BDD specification files for a story whose three-amigos session is
complete (rules + scenarios on the story) but whose specs haven't been
written yet. Produces one `*_spex.exs` file per acceptance criterion, each
under the project's `<App>Spex` namespace, driving the real interaction
surface from `given_` / `when_` / `then_` steps.

The agent reads **both** the framework BDD knowledge (Spex DSL, philosophy,
boundaries, environment, cassettes, shared givens — applies to any project
using CodeMySpec) and the **project** BDD knowledge (this codebase's four
interaction surfaces, canonical skeletons, cassette conventions). Project
rules override framework rules where they conflict.

## Done signal

For every acceptance criterion on the story:

- A spec file exists at the path returned by `BddSpecs.spec_file_path/2`
  (which encodes story_id and criterion_id).
- The file is parseable Elixir (passes `Code.string_to_quoted/2`).
- It `use`s a module ending in `Spex.Case` (the project's case template,
  not `<App>Web.ConnCase`).
- It parses as a valid Spex via `BddSpecs.Parser.parse/2`.
- It contains at least one scenario, and every scenario has at least one
  Given/When/Then step.

The evaluator returns `:invalid` with per-criterion feedback if any spec
fails these checks.

## Dispatch shape

`component_task` via the story graph — story_graph node `bdd_specs_exist`
(id 2) is satisfied by this task. The task takes a story_id (via the
component-dispatch routing through the requirement graph).

## Out of scope

- The task does not invent rules or scenarios. Three-amigos is the
  prerequisite (`three_amigos_complete`, story_graph id 5) — if rules or
  scenarios are missing, fix them upstream.
- The task does not fix failing specs. If specs exist but fail to pass,
  that's `fix_bdd_specs`'s job (story_graph id 3).
- The task does not write code to make specs pass. Specs are
  failure-first; the implementation flow handles the code.
- The task does not modify the framework knowledge or project knowledge
  at any path — it reads both.

## Failure modes the agent should avoid

- Calling context functions directly from `when_` / `then_` steps. The
  step blocks must drive the real interaction surface (LiveView, HTTP
  hook, MCP tool, filesystem). See project knowledge for the four
  surfaces.
- Reading the DB from `then_`. Outcomes must be observable through the
  same surface the action drove.
- Writing a spec that `use`s `<App>Web.ConnCase` directly. The project
  case template `<App>Spex.Case` wires up the SexySpex DSL, ConnTest,
  LiveViewTest, and the DB sandbox in one place.
- Returning a bare context map from a step. Wrap in `{:ok, map}` or use
  `:ok` for no-update.
- Inventing failure-path scenarios to satisfy a coverage template. If a
  rule's failure mode lives at a different layer, leave it out.
- Skipping the framework or project knowledge layer. Both are required
  reading.

## Resources

Required input:
- `task.story_id` (or `story_id` on the dispatched component task) — the
  story whose specs to write.
- The story record with acceptance criteria — `Stories.get_story/2`.
- The story's linked component — read from `story.component_id`;
  source file, moduledoc, and component type drive the prompt.
- Three-amigos artifacts on the story (rules, scenarios) — implicit
  prerequisite; the criteria carry the scenario data.

Required reading (framework BDD knowledge — `priv/knowledge/bdd/spex/`):
- `writing_a_spex.md` — file layout, module template, DSL syntax,
  step return-value conventions. Essential.
- `philosophy.md` — what Spex is for, how it differs from regular tests.
- `environment.md` — environment abstraction in steps.
- `boundaries.md` — what you can and can't do in `given_` / `when_` / `then_`.
- `shared_givens.md` — importing shared given blocks.
- `recording_cassettes.md` — when and how to record HTTP cassettes.

Required reading (project BDD knowledge — `.code_my_spec/knowledge/bdd/spex/`):
- `four_surfaces_quick_reference.md` — surface decision table + 30-second
  skeletons (MCP tool, HTTP, LiveView, filesystem).
- `surfaces.md` — canonical skeletons per surface.
- `cassettes.md` — project-specific cassette conventions.

Project rules override framework rules where they conflict.

Optional input:
- Sibling specs in the same story directory — read at least one
  end-to-end as a copy template (shared setup, fixture paths, case
  template, given usage).

Produced:
- `test/spex/<story_id>/<criterion_id>_spex.exs` — one per acceptance
  criterion.

## Tools

No task-specific tools required. Built-ins (Read, Write, Bash, Glob)
handle everything. Reading both knowledge layers via direct path Read.

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Stories
