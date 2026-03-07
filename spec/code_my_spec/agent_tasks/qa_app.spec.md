# CodeMySpec.AgentTasks.QaApp

## Type

module

Orchestrator task for browser-based QA of the running app. Analyzes the project's routes, stories, and BDD spec coverage, then delegates per-story QA testing to QaStory workers using story IDs. Provides two entry points: `command/3` builds the orchestration prompt with router content, stories, BDD coverage, and dispatch instructions; `evaluate/3` checks that QA results exist per story and validates the summary.

## Functions

### command/3

Generate the orchestration prompt for the QA session.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Derive app name from mix.exs
2. Read router file at `lib/{app_name}_web/router.ex`
3. Load stories via `Stories.list_stories/1` (preloads criteria and tags)
4. Format BDD coverage via `SpecProjector.format_coverage/2`
5. Format BDD summaries via `SpecProjector.project_summary_list/1`
6. List existing issues from `docs/issues/*.md`
7. Assemble prompt sections:
    - Header with project name and reference to `web-cli` knowledge article
    - Server section with project cwd and `mix phx.server` instructions
    - Router section (embedded source or fallback to `mix phx.routes`)
    - Stories section listing each story with criteria
    - BDD coverage and details sections
    - Existing issues section
    - Instructions: smoke-test routes, dispatch qa-story subagents by story ID, write summary

**Test Assertions**:
- returns ok tuple with prompt string
- includes project name in prompt
- references web-cli knowledge article
- includes router content when router exists
- handles missing router gracefully with mix phx.routes fallback
- includes server startup instructions
- instructs agent to dispatch qa-story subagent
- dispatches with story ID not slug
- instructs agent to write summary to docs/qa/summary.md
- lists existing issues to avoid duplicates
- includes BDD coverage section

### evaluate/3

Validate all per-story QA results are complete and summary exists.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Load stories from project
2. Check if QA summary exists at `docs/qa/summary.md`
3. If no stories and summary exists -> `{:ok, :valid}`
4. For each story, build child session with story ID and delegate to `QaStory.evaluate/3`
5. Return `{:ok, :valid}` if all pass, or `{:ok, :invalid, feedback}`

**Test Assertions**:
- returns {:ok, :valid} when no stories and summary exists
- returns {:ok, :invalid, feedback} when summary is missing

## Dependencies

- CodeMySpec.AgentTasks.QaStory
- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.SpecProjector
- CodeMySpec.Environments
- CodeMySpec.Stories
