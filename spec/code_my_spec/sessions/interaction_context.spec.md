# InteractionContext

Struct and preparation logic for session interaction execution contexts.

Contains all necessary information for command execution including the environment, command details, and execution options. This module bridges sessions with their execution environments by extracting the latest interaction and creating the appropriate environment context.

## Fields

| Field          | Type           | Required | Description                           | Constraints                    |
| -------------- | -------------- | -------- | ------------------------------------- | ------------------------------ |
| environment    | module()       | Yes      | Environment module for execution      | Created via Environments       |
| command        | struct()       | Yes      | Command to execute                    | From interaction               |
| execution_opts | keyword()      | Yes      | Options for command execution         | Includes session/interaction IDs |
| session        | Session.t()    | Yes      | Parent session                        | Must have interactions preloaded |
| interaction    | Interaction.t()| Yes      | Latest interaction from session       | First in preloaded list        |

## Delegates

None.

## Functions

### prepare/3

Prepares the execution context for an interaction by extracting the latest interaction from the session, creating an appropriate environment, and bundling execution options.

```elixir
@spec prepare(Scope.t(), Session.t(), keyword()) :: {:ok, t()} | {:error, term()}
```

**Process**:
1. Extract the latest interaction from the session's preloaded interactions list
2. Return `{:error, :no_interactions}` if session has no interactions
3. Create an execution environment using the session's environment type and working directory from state
4. Extract the command from the interaction
5. Build execution options by merging provided opts with session_id and interaction_id
6. Return `{:ok, %InteractionContext{}}` with all fields populated

**Test Assertions**:
- returns `{:ok, context}` when session has at least one interaction
- returns `{:error, :no_interactions}` when session has empty interactions list
- includes session_id in execution_opts
- includes interaction_id in execution_opts
- merges provided opts with generated execution opts
- uses session.environment type to create environment
- extracts working_dir from session.state when present
- uses first interaction from list as the latest interaction
- populates environment field with module from Environments.create/2
- populates command field from interaction.command

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Users.Scope
- CodeMySpec.Environments
