# ArchitectureMapper

Response formatter for architecture-related MCP server tools. Transforms component data, architecture summaries, validation results, and error states into standardized Hermes MCP Response structures for consumption by AI agents.

## Functions

### spec_created/2

Returns a success response for newly created spec files.

```elixir
@spec spec_created(Component.t(), String.t()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Build JSON payload with success status, message, component summary, and spec path
3. Return response with JSON content

**Test Assertions**:
- returns tool response with success true
- includes "Spec file created successfully" message
- contains component summary with module name
- includes provided spec path

### spec_updated/2

Returns a success response for updated spec metadata.

```elixir
@spec spec_updated(Component.t(), String.t()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Build JSON payload with success status, update message, component summary, and spec path
3. Return response with JSON content

**Test Assertions**:
- returns tool response with success true
- includes "Spec metadata updated successfully" message
- contains component summary
- includes spec path

### spec_response/3

Returns detailed component and spec content information.

```elixir
@spec spec_response(Component.t(), String.t(), String.t()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Build JSON payload with component detail (including dependencies), spec path, and spec content
3. Return response with JSON content

**Test Assertions**:
- returns tool response with component details
- includes spec path
- includes full spec content

### specs_list_response/1

Returns a list of all specs with their paths.

```elixir
@spec specs_list_response([Component.t()]) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Map components to spec summaries including generated spec paths
3. Return response with JSON array of specs

**Test Assertions**:
- returns tool response with specs array
- each spec includes module name and generated spec path
- handles multiple components correctly

### architecture_summary_response/1

Returns structured architecture metrics and summary data.

```elixir
@spec architecture_summary_response(map()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Pass through summary map directly as JSON payload
3. Return response with summary data

**Test Assertions**:
- returns tool response with summary data
- preserves all summary fields (context_count, component_count, etc.)
- maintains data types correctly

### component_impact_response/1

Returns component impact analysis showing direct and transitive dependencies.

```elixir
@spec component_impact_response(map()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Extract component, direct_dependents, transitive_dependents, and affected_contexts from impact map
3. Map each list to component summaries
4. Return response with formatted impact data

**Test Assertions**:
- returns tool response with component summary
- includes list of direct dependents as component summaries
- includes list of transitive dependents
- includes affected contexts

### component_view_response/1

Returns markdown-formatted component view.

```elixir
@spec component_view_response(String.t()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Set content as plain text with markdown string
3. Return response with text content

**Test Assertions**:
- returns tool response with text content
- preserves markdown formatting
- does not wrap in JSON

### validation_result_response/1

Returns validation results for dependency graph analysis.

```elixir
@spec validation_result_response(:ok | {:error, [map()]}) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. For :ok, return JSON with valid: true and success message
3. For {:error, cycles}, format cycle data with path and component details
4. Return response with validation status and optional cycle information

**Test Assertions**:
- returns valid: true for :ok input
- includes "No circular dependencies detected" message for success
- returns valid: false for error tuples
- includes "Circular dependencies detected" message for errors
- formats cycle paths and component lists correctly

### prompt_response/1

Returns a plain text prompt for agent consumption.

```elixir
@spec prompt_response(String.t()) :: Response.t()
```

**Process**:
1. Create a tool response structure
2. Set content as plain text with prompt string
3. Return response with text content

**Test Assertions**:
- returns tool response with text content
- preserves prompt text exactly
- does not wrap in JSON

### validation_error/1

Returns formatted validation errors from changeset.

```elixir
@spec validation_error(Ecto.Changeset.t()) :: Response.t()
```

**Process**:
1. Create a tool error response structure
2. Format changeset errors using Formatters module
3. Return error response with formatted error messages

**Test Assertions**:
- returns error response with isError: true
- formats changeset errors into readable messages

### error/1

Returns standardized error responses for various error types.

```elixir
@spec error(atom() | String.t() | Ecto.Changeset.t()) :: Response.t()
```

**Process**:
1. Pattern match on error type (atom, string, or changeset)
2. For atoms, convert to string and recurse
3. For strings, create tool error response with message
4. For changesets, delegate to validation_error/1
5. Return appropriate error response

**Test Assertions**:
- handles atom errors by converting to string
- handles string errors with error message
- delegates changeset errors to validation_error/1
- all variants return isError: true responses

### not_found_error/0

Returns a "Resource not found" error response.

```elixir
@spec not_found_error() :: Response.t()
```

**Process**:
1. Create a tool error response structure
2. Set error message to "Resource not found"
3. Return error response

**Test Assertions**:
- returns error response with isError: true
- includes "Resource not found" message

## Dependencies

- Hermes.Server.Response
- CodeMySpec.McpServers.Formatters
- CodeMySpec.Components.Component
