# CodeMySpec.McpServers.Stories.Tools.DeleteCriterion

MCP tool that deletes an acceptance criterion from a story. Provides protection against deleting verified (locked) criteria to maintain data integrity.

## Functions

### execute/2

Executes the delete criterion tool with validation and protection checks.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate scope has active account and project using Validators.validate_scope/1
2. Fetch criterion by ID using AcceptanceCriteria.get_criterion/2
3. Check criterion exists, return error if nil
4. Verify criterion is not marked as verified using check_not_verified/1
5. Delete criterion using AcceptanceCriteria.delete_criterion/2
6. Map deleted criterion to response using StoriesMapper.criterion_deleted_response/1
7. Handle errors: criterion not found, verification protection, validation errors, or general errors
8. Return reply tuple with response and frame

**Test Assertions**:
- successfully deletes an unverified criterion
- returns criterion_not_found_error when criterion does not exist
- returns error when attempting to delete verified criterion
- returns error message explaining verified criteria are locked
- returns validation_error for Ecto.Changeset errors
- returns generic error for atom errors
- validates scope before executing
- returns proper MCP response format

### check_not_verified/1

Private function that checks if a criterion is verified and prevents deletion if it is.

```elixir
@spec check_not_verified(map()) :: :ok | {:error, :criterion_verified}
```

**Process**:
1. Pattern match on criterion with verified: true, return {:error, :criterion_verified}
2. For all other cases, return :ok

**Test Assertions**:
- returns error tuple for verified criteria
- returns ok for unverified criteria
- returns ok for criteria without verified field

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Frame
- Hermes.Server.Response
- Ecto.Changeset
