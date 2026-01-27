# CodeMySpec.Sessions.StepBehaviour

Defines the behaviour contract for workflow step modules in session orchestration. Each step module implements callbacks for command generation and result processing, enabling pluggable workflow steps that can be composed into session-specific execution sequences.

## Delegates

None - this module defines callbacks only.

## Functions

### get_command/3

Generate a command for execution based on the current session state. Step modules implement this callback to translate session context into executable commands.

```elixir
@callback get_command(scope :: Scope.t(), session :: Session.t(), opts :: keyword()) ::
  {:ok, Command.t()} | {:error, String.t()}
```

**Process**:
1. Receive the scope (user/project context), session, and optional keyword arguments
2. Analyze the session state, interactions, and related entities to determine command requirements
3. Build a Command struct with the step module reference, command string, and any required metadata
4. Return `{:ok, Command.t()}` on success or `{:error, reason}` for business logic errors

**Test Assertions**:
- returns `{:ok, Command.t()}` with valid scope and session
- returned Command has module field set to the implementing step module
- returned Command has command string appropriate for the step's responsibility
- returns `{:error, String.t()}` when session state is invalid for this step
- passes through opts to command metadata when provided

### handle_result/4

Process the result of command execution and determine session updates. Step modules implement this callback to interpret results and advance the workflow.

```elixir
@callback handle_result(
  scope :: Scope.t(),
  session :: Session.t(),
  result :: Result.t(),
  opts :: keyword()
) ::
  {:ok, session_updates :: map(), updated_result :: Result.t()} | {:error, String.t()}
```

**Process**:
1. Receive the scope, session, execution result, and optional keyword arguments
2. Parse and interpret the result data, stdout, stderr, and status fields
3. Build a map of session field updates (status, state, or other fields as needed)
4. Optionally transform the result to enrich or extract parsed data
5. Return `{:ok, session_attrs, final_result}` on success or `{:error, reason}` for errors

**Test Assertions**:
- returns `{:ok, map(), Result.t()}` with valid inputs
- session_updates map can include :status field to complete or fail the session
- session_updates map can include :state field to merge with existing session state
- returns empty map `%{}` when no session updates are needed
- returns the result unchanged when no transformation is required
- returns `{:error, String.t()}` when result indicates an unrecoverable error
- handles Result with :ok status and advances workflow appropriately
- handles Result with :error status and sets appropriate session failure state

## Dependencies

- CodeMySpec.Sessions.Command
- CodeMySpec.Sessions.Result
- CodeMySpec.Sessions.Session
- CodeMySpec.Users.Scope
