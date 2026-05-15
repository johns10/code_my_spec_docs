# CodeMySpec.AgentTasks.TechnicalStrategy

## Type

skill

## Intent

Identify the technology decisions a project needs to make, document
each one as an ADR, and produce an index of all decisions. The task
auto-writes ADRs for the standard CodeMySpec stack (Elixir, Phoenix,
LiveView, Tailwind, DaisyUI, etc.) before prompting, so the agent
focuses on project-specific topics that the pre-made set doesn't
cover.

The output (`decisions/{topic}.md` files + a `decisions.md` index) is
the input for downstream `code_generation` (knows which generators to
run) and `architecture_designed` (uses the decisions when proposing
components).

## Done signal

`.code_my_spec/architecture/decisions.md` exists. The evaluator's
check is existence-only — the quality of individual ADRs is verified
downstream when consuming tasks act on them.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `technical_strategy` (id 2), gated by `stories_exist`
(id 15). The chain `code_generation` (id 3) → `qa_integration_plan`
(id 4) → `architecture_designed` (id 5) all depend on the decisions
this task produces.

## Out of scope

- The task does not do deep research. Use `research_topic` when a
  decision needs more than cursory investigation.
- The task does not install libraries or bootstrap the project.
  `code_generation` runs the generators; `start_implementation`
  drives component code.
- The task does not write component-level implementation choices
  (algorithm selection, data structures). Those live in component
  specs.
- The task does not validate ADR content quality. The index existing
  is the only gate.

## Failure modes the agent should avoid

- Re-deciding pre-made stack topics. The pre-made ADRs are written
  before the agent sees the prompt; revising them is only correct
  when the project genuinely needs to supersede a default.
- Writing ADRs without reading the project's stories and current
  dependencies. The decision context comes from the project, not
  generic best practices.
- Over-researching. Cursory hex.pm search + README skim is the bar;
  deep investigation belongs in `research_topic`.
- Forgetting to write the `decisions.md` index. Without it, the
  evaluator fails and downstream tasks can't enumerate decisions.

## Resources

Required input:
- The project record (`scope.active_project`) for the project name.
- `mix.exs` — embedded in the prompt's Current Dependencies section.
- Project stories — listed in the prompt's User Stories section.
- Component count — informs the Architecture Overview section.

Required reading:
- `priv/knowledge/technical_strategy/workflow.md` — the full
  procedure (pre-made decisions, identification, research, ADR
  format, index update).

Produced:
- `.code_my_spec/architecture/decisions/{topic}.md` — one ADR per
  decision, both pre-made (auto-written by the task) and
  project-specific (written by the agent).
- `.code_my_spec/architecture/decisions.md` — index of all
  decisions with status.

## Tools

No task-specific tools required. Built-ins (Read, Write, Bash,
WebSearch / WebFetch for hex.pm + library docs) handle the work.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Paths
- CodeMySpec.Stories

## Public functions worth knowing

- `premade_decisions/0` — returns the list of standard-stack
  decisions auto-written before prompting. Treated as data; revise
  here if a topic should be added to or dropped from the pre-made
  set across all CodeMySpec projects.
- `ensure_premade_decisions/1` — writes any missing pre-made ADRs
  to the environment. Called by `command/2` before rendering the
  prompt so the "Existing Decisions" section reflects post-write
  state.
