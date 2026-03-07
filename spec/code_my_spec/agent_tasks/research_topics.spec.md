# CodeMySpec.AgentTasks.ResearchTopics

## Type

module

Container task for ensuring all decided technology topics have adequate research coverage. Identifies which topics need research (decided minus pre-made minus framework-covered), generates an orchestration prompt with dispatch instructions, and delegates per-topic validation to ResearchTopic.

Follows the same pattern as ContextComponentSpecs — `command/3` returns the instructional prompt, `evaluate/3` checks children via ResearchTopic.evaluate/3.

Prerequisite: `technical_strategy` must be satisfied (all ADRs and index exist).

## Functions

### command/3

Generate the orchestration prompt listing topics that need research and dispatch instructions.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. List decided topics from `.code_my_spec/architecture/decisions/*.md`
2. Get pre-made topics from `TechnicalStrategy.premade_decisions/0`
3. List framework-covered topics from `.code_my_spec/framework/`
4. Compute topics needing research (decided minus pre-made minus framework-covered)
5. For each topic needing research, read the ADR content for context
6. Return prompt with:
   - Header explaining the research phase
   - List of topics needing research with ADR context
   - Subagent dispatch instructions (no specific subagent named)
   - Skip list explaining why pre-made and framework-covered topics don't need research
   - Stop instruction

**Test Assertions**:
- returns ok tuple with non-empty prompt string
- excludes pre-made decision topics from research list
- excludes topics covered by framework directory
- includes ADR content for topics needing research
- instructs to dispatch subagents (does NOT name a specific subagent)
- lists skipped topics with reason
- returns prompt noting no research needed when all topics are covered

### evaluate/3

Check whether all qualifying topics have completed ResearchTopic validation.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. List decided topics from decision record files
2. Get pre-made topics from `TechnicalStrategy.premade_decisions/0`
3. List framework-covered topics from `.code_my_spec/framework/`
4. Compute qualifying topics (decided minus pre-made minus framework-covered)
5. If no qualifying topics, return `{:ok, :valid}`
6. For each qualifying topic, build a child session with `state: %{"topic" => topic}` and delegate to `ResearchTopic.evaluate/3`
7. If all pass, return `{:ok, :valid}`
8. Otherwise collect incomplete topic names and return `{:ok, :invalid, feedback}`

**Test Assertions**:
- returns `{:ok, :valid}` when no topics need research (all pre-made or framework-covered)
- returns `{:ok, :valid}` when all qualifying topics pass ResearchTopic.evaluate/3
- returns `{:ok, :invalid, feedback}` when qualifying topics fail ResearchTopic.evaluate/3
- reports multiple incomplete topics in feedback
- does not check pre-made decision topics
- does not check framework-covered topics
- returns `{:ok, :valid}` when there are no decided topics at all
- qualifying topic covered by framework directory as a sub-directory is skipped

## Dependencies

- CodeMySpec.AgentTasks.ResearchTopic
- CodeMySpec.AgentTasks.TechnicalStrategy
- CodeMySpec.Environments
- CodeMySpec.Paths
