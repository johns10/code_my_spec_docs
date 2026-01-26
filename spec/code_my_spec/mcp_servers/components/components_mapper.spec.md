# ComponentsMapper

Maps component data to MCP responses in JSON format for programmatic access. This module handles all response formatting for component-related MCP tool operations, including single components, component lists, batch operations, dependencies, and error responses.

## Dependencies

- CodeMySpec.McpServers.Formatters
- Hermes.Server.Response
- Ecto.Association

## Functions

### component_response/1

Creates a JSON response for a single component with similar components included.

```elixir
@spec component_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract similar_components from component map or handle NotLoaded association
2. If similar_components is NotLoaded, use empty list
3. If similar_components is a list, map each to component_summary/1
4. Otherwise use empty list
5. Create tool response with JSON containing id, name, type, module_name, description, and similar_components

**Test Assertions**:
- returns Response struct with success status
- includes all component fields in JSON
- handles NotLoaded association for similar_components
- maps similar_components list to summaries
- includes empty list when similar_components is nil or other value
- properly serializes component data

### validation_error/1

Creates an error response from an Ecto changeset.

```elixir
@spec validation_error(Ecto.Changeset.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Format changeset errors using Formatters.format_changeset_errors/1
2. Create error response with formatted error message

**Test Assertions**:
- returns Response struct with error status
- includes formatted validation errors
- formats field names and messages clearly
- includes fix guidance when available

### error/1

Creates an error response from an atom or binary error message.

```elixir
@spec error(atom() | String.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. If error is an atom, convert to string and call error/1 recursively
2. If error is a binary, create error response with error message

**Test Assertions**:
- returns Response struct with error status
- handles atom error input
- handles string error input
- converts atom to string correctly

### components_list_response/1

Creates a JSON response for a list of components.

```elixir
@spec components_list_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Map components to summaries using component_summary/1
2. Create tool response with JSON containing components array

**Test Assertions**:
- returns Response struct with success status
- includes components array in JSON
- maps all components to summaries
- handles empty list
- properly serializes component summaries

### not_found_error/0

Creates a standard error response for resource not found.

```elixir
@spec not_found_error() :: Hermes.Server.Response.t()
```

**Process**:
1. Create error response with "Resource not found" message

**Test Assertions**:
- returns Response struct with error status
- includes generic not found message

### components_batch_response/1

Creates a JSON response for batch component creation showing count and summaries.

```elixir
@spec components_batch_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count created components
2. Map components to summaries using component_summary/1
3. Create tool response with JSON containing success flag, count, and components array

**Test Assertions**:
- returns Response struct with success status
- includes success: true in JSON
- includes count of created components
- includes all component summaries
- handles empty list with zero count

### dependencies_batch_response/1

Creates a JSON response for batch dependency creation showing count and summaries.

```elixir
@spec dependencies_batch_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count created dependencies
2. Map dependencies to summaries using dependency_summary/1
3. Create tool response with JSON containing success flag, count, and dependencies array

**Test Assertions**:
- returns Response struct with success status
- includes success: true in JSON
- includes count of created dependencies
- includes all dependency summaries with source and target components
- handles empty list with zero count

### batch_errors_response/2

Creates an error response for partial batch creation failures.

```elixir
@spec batch_errors_response(list(map()), list(tuple())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count successes and failures
2. Map successful components to summaries using component_summary/1
3. Map failures to error objects with index and formatted errors
4. Extract errors from changesets using Formatters.format_changeset_errors/1
5. Create tool response with JSON containing success: false, created_count, failed_count, created_components array, and errors array

**Test Assertions**:
- returns Response struct with success status (but data indicates failure)
- includes success: false in JSON
- includes created_count and failed_count
- includes created_components array with summaries
- includes errors array with index and error details
- properly formats changeset errors for each failure
- handles all successes scenario
- handles all failures scenario

### prompt_response/1

Creates a simple text response containing a prompt.

```elixir
@spec prompt_response(String.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create tool response with prompt text

**Test Assertions**:
- returns Response struct with success status
- includes exact prompt text in response
