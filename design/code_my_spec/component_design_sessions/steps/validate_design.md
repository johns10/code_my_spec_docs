# ValidateDesign Step

## Purpose
Validates the generated component design documentation by parsing it through the Documents context to ensure it contains all required fields and follows the correct structure according to the component type.

## Public API

```elixir
# Step behavior implementation
@spec get_command(scope, session) :: {:ok, %Command{}} | {:error, term()}
@spec handle_result(scope, session, interaction) :: {:ok, %Session{}} | {:error, term()}
```

### get_command/2
- **Parameters**: `scope` (user scope), `session` (current session with component_design in state)
- **Returns**: `{:ok, %Command{}}` with no-op command (validation happens in handle_result)
- **Purpose**: Creates a command for the validation step (typically a no-op since validation is internal)

### handle_result/3
- **Parameters**: `scope`, `session`, `interaction` (with command result)
- **Returns**:
  - `{:ok, %Session{}}` if component design validates successfully
  - `{:error, %Result{status: :error, stderr: validation_errors}}` if validation fails
- **Purpose**: Validates component_design from session state using Documents context
- **Side Effects**: May update interaction result with validation error details

## Execution Flow
1. Retrieves the component design content from the session state (stored by ReadComponentDesign step)
2. Uses the Documents context to create a document from the design markdown
3. Validates the document structure based on the component type
4. Returns success if validation passes, error with details if validation fails

## Validation Logic
- Uses `Documents.create_component_document/3` to parse and validate the component design
- Document type is determined by the component type
- If document creation succeeds, the design is considered valid
- If document creation fails, the changeset errors are captured for revision feedback

## Success Path
- Document validates successfully � proceed to Finalize step
- Session state remains unchanged

## Error Path
- Document validation fails � place an error on the `CodeMySpec.Sessions.Result`
- THe Orchestrator will pick it up on the next command

## Dependencies
- Documents
- Sessions
- Component