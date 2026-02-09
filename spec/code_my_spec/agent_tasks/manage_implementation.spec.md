# CodeMySpec.AgentTasks.ManageImplementation

Master agent task that orchestrates the full implementation lifecycle of a project. Provides the master prompt that drives the agent through an iterative loop:

1. **Write BDD specs** for the next incomplete story (via `/write-bdd-specs`)
2. **Develop context** to make failing BDD specs pass (via `/develop-context`)
3. Repeat until all stories are complete and all specs pass

This task sits at the **bottom of the session priority stack**. When the agent tries to stop, the stop hook evaluates all active sessions in priority order. Higher-priority sessions (e.g. WriteBddSpecs, DevelopContext) are evaluated first — they must be satisfied before ManageImplementation's evaluate is reached. This means the agent finishes its current task-level work before the project-level iteration logic runs.

The iteration loop lives in `evaluate/3`: run BDD specs, check for incomplete stories, and either allow the agent to stop (all done) or block with instructions for the next cycle.

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Spex
- CodeMySpec.Environments

## Functions

### command/3

Sync the project and generate the master prompt for the implementation loop.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:

1. Sync project state
2. Build the master prompt instructing the agent to alternate between writing BDD specs and developing contexts
3. Return the master prompt

**Test Assertions**:

- returns master prompt with instructions for the write-specs / implement cycle
- master prompt references `/write-bdd-specs` and `/develop-context` skills

### evaluate/3

Evaluate project state to decide whether the agent can stop or must continue.

Runs BDD specs and checks for incomplete stories. This is reached only after all higher-priority sessions in the stack have been satisfied.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) ::
  {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:

1. Run BDD specs against the working directory
2. If specs are failing, return `{:ok, :invalid, failure_feedback}` — agent must fix failures
3. If specs pass, check for the next incomplete story
4. If a story exists, return `{:ok, :invalid, next_story_prompt}` — agent should invoke `/write-bdd-specs`
5. If no incomplete stories remain, return `{:ok, :valid}` — agent may stop

**Test Assertions**:

- returns `{:ok, :invalid, feedback}` with failure details when BDD specs are failing
- returns `{:ok, :invalid, prompt}` directing agent to write BDD specs when next story exists
- returns `{:ok, :valid}` when all stories complete and specs pass
- handles BDD spec execution errors gracefully
