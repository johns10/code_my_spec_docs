# CodeMySpec.AgentTasks.TechnicalStrategy

## Type

module

Orchestrator task for identifying and resolving technology decisions. Analyzes the project's architecture, stories, and dependencies to identify topics needing technology decisions, then auto-writes pre-made ADRs for standard stack choices and guides the agent through cursory research and ADR creation for remaining topics. Focused purely on decisions — deep research is handled by ResearchTopics, bootstrap/implementation by ProjectBootstrap.

Two phases:
1. **Pre-made decisions** — auto-writes ADRs for standard stack choices before prompting
2. **Decision-making** — identifies new topics, does cursory research, writes ADRs, updates the decisions index

Artifacts produced:
- `.code_my_spec/architecture/decisions.md` — index of all decisions
- `.code_my_spec/architecture/decisions/{topic}.md` — individual decision records

## Functions

### premade_decisions/0

Returns the list of pre-made technology decisions that are part of the standard CodeMySpec stack.

```elixir
@spec premade_decisions() :: [%{topic: String.t(), title: String.t(), context: String.t(), decision: String.t()}]
```

**Process**:
1. Return the module attribute `@premade_decisions` containing standard stack decisions (elixir, phoenix, liveview, tailwind, daisyui, phx-gen-auth, exvcr, wallaby, bdd-testing, dotenvy)

**Test Assertions**:
- returns a non-empty list of decisions
- each decision has required fields (topic, title, context, decision)
- includes core stack decisions (elixir, phoenix, liveview, tailwind, daisyui, phx-gen-auth, exvcr, bdd-testing, dotenvy)
- does not include ngrok as a pre-made decision
- returns exactly 10 decisions

### command/3

Generate the orchestration prompt for the technical strategy session. Writes any missing pre-made decision ADRs directly to the environment, then reads architecture overview, project deps, existing decisions, and story titles to build a prompt for decision-making.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Write any missing pre-made decision ADR files via `ensure_premade_decisions/1`
2. Count components via `Components.count_components/1`
3. Read `mix.exs` from the environment (nil if not found)
4. List existing decision filenames from `decisions/` directory
5. List story titles via `Stories.list_story_titles/1`
6. Assemble prompt sections:
   - Header with project name and goal description
   - Architecture section with component count and file references (omitted if 0 components)
   - Dependencies section with mix.exs content (omitted if no mix.exs)
   - Existing decisions section listing already-decided topics (omitted if none)
   - Stories section listing story titles (omitted if none)
   - Instructions:
     1. **Identify topics** — analyze architecture, stories, and current deps for technology decisions needed; skip topics covered by existing decisions; common categories: testing, deployment, infrastructure, integrations
     2. **Research and decide each topic** — for each identified topic, do cursory research (search hex.pm, check docs), evaluate against project needs, write an ADR to `.code_my_spec/architecture/decisions/{topic}.md` with sections: Title, Status, Context, Options Considered (with pros/cons), Decision, Consequences
     3. **Update the index** — ensure `.code_my_spec/architecture/decisions.md` lists all decision records (pre-made and new) with status
     4. **Stop** — stop the session so validation can check the work

**Test Assertions**:
- returns ok tuple with non-empty prompt string
- includes project name in prompt
- includes deps context when mix.exs exists
- lists existing decisions in prompt
- instructs to research and write ADRs for identified topics
- writes missing pre-made decision ADR files to the environment
- does not overwrite pre-existing decision files
- does not include a "Pre-made Decisions to Write" section in prompt
- lists pre-made decisions as existing decisions after writing them
- does NOT include knowledge base building steps (handled by ResearchTopics)
- does NOT include bootstrap/library installation steps (handled by ProjectBootstrap)
- does NOT reference a specific subagent by name
- instructs to update the decisions index
- instructs to stop after completing the work
- omits architecture section when project has no components
- omits deps section when mix.exs is absent

### evaluate/3

Validate all pre-made decisions exist and the decisions index is complete.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Check if decisions index file exists
2. List existing decision filenames
3. Compute missing pre-made decisions (pre-made topics without ADR files)
4. If index exists and no missing pre-made decisions -> `{:ok, :valid}`
5. Otherwise build feedback listing missing items

**Test Assertions**:
- returns `{:ok, :valid}` when all pre-made decisions and index exist
- returns `{:ok, :invalid, feedback}` when pre-made decisions are missing
- returns `{:ok, :invalid, feedback}` when decisions index is missing
- feedback names the missing pre-made topic
- feedback references the expected index path when index is missing
- returns `{:ok, :invalid, feedback}` when both index and pre-made decisions are missing
- does NOT check for knowledge entries (handled by ResearchTopics)
- does NOT check for research prompt files

### ensure_premade_decisions/1

Write all missing pre-made decision ADR files to the environment.

```elixir
@spec ensure_premade_decisions(Environment.t()) :: non_neg_integer()
```

**Process**:
1. List existing decision filenames from the environment
2. Filter pre-made decisions to those whose topic is not in existing decisions
3. Write each missing decision as a markdown ADR file with Status (Accepted, pre-made), Context, Decision, and Consequences sections
4. Return the count of decisions written

*No direct tests — covered by command/3 test assertions: "writes missing pre-made decision ADR files to the environment" and "does not overwrite pre-existing decision files".*

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Paths
- CodeMySpec.Stories
