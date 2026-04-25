# CodeMySpec.AgentTasks.PersonaResearch

Agent task for running the persona research process. `command/2` builds a prompt referencing the knowledge playbook and expected output paths. `evaluate/2` delegates to `PersonasChecker.complete?/1`.

## Type

module

## Functions

### command/2

Builds the task prompt for the agent. Names the playbook files under `priv/knowledge/persona_research/` (overview.md, pm_intake.md, primary_research.md, README.md) and the expected output paths `.code_my_spec/personas/<slug>/summary.md` + `sources.md`. Instructs the agent to run the PM intake conversation first, then research via web + knowledge MCP, then write artifacts.

```elixir
@spec command(Scope.t(), map()) :: {:ok, String.t()} | {:error, term()}
```

### evaluate/2

Evaluates the persona research task by delegating to `PersonasChecker.complete?/1` and formatting the result as the standard task evaluation tuple.

```elixir
@spec evaluate(Scope.t(), map()) ::
        {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

### analyzers/0

Returns the list of analyzers to run on the task (none for persona research — the checker is authoritative).

```elixir
@spec analyzers() :: [atom()]
```

## Dependencies

- CodeMySpec.Personas
- CodeMySpec.Requirements.PersonasChecker
- CodeMySpec.Users.Scope
