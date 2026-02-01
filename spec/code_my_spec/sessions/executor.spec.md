# CodeMySpec.Sessions.Executor

**Type**: logic

Executes commands based on their execution_strategy. Dispatches to appropriate execution pattern (sync, task, or async) based on Command.execution_strategy field.

## Functions

### execute/3

Execute a command according to its execution_strategy.

```elixir
@spec execute(Scope.t(), integer(), keyword()) :: {:ok, map()} | {:ok, pid()} | :ok | {:error, term()}
```

**Process**:
1. Get latest interaction from session
2. Extract command from interaction
3. Create execution environment based on session configuration
4. Pattern match on command.execution_strategy:
   - `:sync` - Execute synchronously, return `{:ok, result}`
   - `:task` - Spawn Task, return `{:ok, task_pid}`
   - `:async` - Execute externally, return `:ok`
5. Pass session_id and interaction_id to environment for context

**Test Assertions**:
- sync commands block and return `{:ok, result}`
- task commands spawn Task and return `{:ok, pid}`
- async commands return `:ok` immediately
- creates appropriate environment type from session
- passes session_id and interaction_id to environment
- returns error if no interactions exist
- returns error if environment creation fails
- handles execution failures gracefully

## Dependencies

- CodeMySpec.Sessions.Command
- CodeMySpec.Sessions.Session
- CodeMySpec.Environments
