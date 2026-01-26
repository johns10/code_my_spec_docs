# CodeMySpec.McpServers.Stories.Tools.UpdateCriterion

MCP tool for updating the description of existing acceptance criteria. Protects verified (locked) criteria from modification to maintain test integrity.

## Functions

### execute/2

Executes the update criterion tool operation, validating scope and verification status before updating.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Validate the current scope has active account and project via Validators.validate_scope/1
2. Retrieve the criterion by ID using AcceptanceCriteria.get_criterion/2
3. Check if criterion was found (return error if nil)
4. Verify criterion is not marked as verified using check_not_verified/1
5. Update the criterion description via AcceptanceCriteria.update_criterion/3
6. Map the updated criterion to a hybrid response (summary + JSON)
7. Handle errors for not found, verified status, validation, and general failures

**Test Assertions**:
- returns success response when updating unverified criterion with valid description
- returns criterion_not_found_error when criterion ID does not exist
- returns error when attempting to update verified criterion
- returns validation_error when description is invalid or missing
- returns error when scope validation fails (missing active account)
- returns error when scope validation fails (missing active project)
- broadcasts :updated event to acceptance_criteria pubsub topic on success

### check_not_verified/1

Private function that checks if a criterion is verified and prevents updates to locked criteria.

```elixir
@spec check_not_verified(CodeMySpec.AcceptanceCriteria.Criterion.t()) :: :ok | {:error, :criterion_verified}
```

**Process**:
1. Pattern match on criterion.verified field
2. Return {:error, :criterion_verified} if verified is true
3. Return :ok for all other cases (unverified criteria)

**Test Assertions**:
- returns :ok when criterion verified field is false
- returns :ok when criterion verified field is nil
- returns {:error, :criterion_verified} when criterion verified field is true

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response
- Hermes.Server.Frame
