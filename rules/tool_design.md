---
component_type: "mcp_tool"
session_type: "design"
---

# MCP Tool Design Rules

Follow these principles when designing MCP tools:

## Core Structure

### Module Pattern
- Use `Hermes.Server.Component` with `type: :tool`
- Include descriptive `@moduledoc` explaining the tool's purpose
- Alias necessary modules at the top (Stories, StoriesMapper, Validators)

### Schema Definition
- Define required and optional fields using `schema do` block
- Use appropriate field types (`:string`, `{:list, :string}`, `{:list, :map}`)
- Mark required fields explicitly with `required: true`

## Implementation Pattern

### Validation First
- Always validate scope using `Validators.validate_scope(frame)` as first step
- Use `with` pattern for chaining validations and operations
- Fail fast and let supervisors handle recovery

### Error Handling
- Pattern match on different error types in `else` clause
- Handle `%Ecto.Changeset{}` validation errors specifically when applicable
- Use a `Mapper` for consistent response formatting, which should be defined per context
- Map atom errors to user-friendly messages

### Response Formatting
- Always return `{:reply, response, frame}` tuple
- Use StoriesMapper functions for consistent response structure:
  - `x_response/1` for single operations
  - `x_batch_response/1` for successful batch operations
  - `validation_error/1` for changeset errors
  - `error/1` for general errors

## Specific Patterns

### Single Entity Operations (Create, Update, Delete)
```elixir
def execute(params, frame) do
  with {:ok, scope} <- Validators.validate_scope(frame),
       {:ok, entity} <- Context.operation(scope, params) do
    {:reply, Mapper.entity_response(entity), frame}
  else
    {:error, changeset = %Ecto.Changeset{}} ->
      {:reply, Mapper.validation_error(changeset), frame}
    
    {:error, atom} ->
      {:reply, Mapper.error(atom), frame}
  end
end
```

### Batch Operations
- Use `Enum.reduce/3` to accumulate successes and failures
- Track index for error reporting
- Return partial success with detailed failure information
- Reverse accumulated lists to maintain order

### Read Operations
- Use bang functions (`get_story!/2`) when entity must exist
- Let the function crash if entity not found (fail fast principle)

## Data Flow

### Input Processing
- Accept structured parameters through schema validation
- Transform data as needed before passing to context functions
- Use `Map.drop/2` to remove non-updatable fields (like `:id`)

### Output Processing  
- Always use mapper functions for response formatting
- Maintain consistent response structure across all tools
- Include relevant data and clear error messages

## Naming Conventions

### Module Names
- Follow pattern: `CodeMySpec.McpServers.{Domain}.Tools.{Action}{Entity}`
- Use descriptive action verbs (Create, Update, Delete, Start)
- Use singular entity names

### Function Names
- Use `execute/2` as the main entry point
- Use private helper functions for complex formatting
- Choose descriptive names that reveal intent

## Error Philosophy

### Clear Error Messages
- Provide actionable error information
- Use consistent error response format
- Map technical errors to user-friendly messages

## Long-Running Work

### Answer with what you already know

A tool returns as soon as it knows the outcome of the work it actually did. It
does not report "started" for work it has already finished, and never for work
it has already refused.

Split the operation at the point where the waiting becomes real:

- **Decided before the work** — validations, gates, precondition reads. These
  are milliseconds. They belong in the `with` chain and are answered to the
  caller. See "Validation First".
- **The work itself** — if it completes in seconds, do it and report the result.
- **A genuinely long tail** — dispatch it, and return a handle plus a way to
  check it. Say in the answer that it is still running, so the caller does not
  read the reply as a completed one.

Promotion is the worked example: it returns immediately, reporting whether the
merge succeeded and what changed, plus a task that resolves to the status of the
redeploy. The merge is fast and is reported; the redeploy is slow and is
dispatched and named.

### Why "started" is worse than an error

An async wrapper reports the outcome out of band — a message to an agent, a line
in a log. Every caller without that channel gets an optimistic acknowledgement
and nothing else, so a refusal becomes invisible and a false success takes its
place. The caller then waits for something that already decided not to happen,
and checking looks identical to a slow success.

Measured: `promote` wrapped everything in a task because "the sweep takes
minutes". The sweep had since moved out of the gate, so a full promotion ran in
0.3s, and every refusal — stale analyzers, uncommitted work, recorded problems —
was computed in milliseconds and then reported only to Alloy agents. A Claude
Code session was told "Promotion started." for a promotion refused half an hour
earlier.

### Check the reason is still true

Both halves of that bug were stale rationale, not a wrong decision at the time.
The comment explaining why the tool was async outlived the sweep it named. When
a doc or comment justifies a shape by how long something takes, re-measure
before trusting it.

### A surface a spec cannot assert on is a broken surface

If a tool answers nothing useful, tests reach for a sibling that does, and the
real door goes uncovered. Story 1046 had nineteen criteria on promotion and all
nineteen drove `promote_sync`, because the helper recorded that `promote`
"answers at once and messages the outcome back, which leaves a spec nothing in
the reply to assert on". They passed while the tool agents call was returning a
false success. Fix the surface rather than testing around it.

## Testing Considerations

- Design tools to be easily testable without mocks
- Make dependencies explicit through function parameters
- Use pure functions for data transformations
- Keep side effects isolated in context layer