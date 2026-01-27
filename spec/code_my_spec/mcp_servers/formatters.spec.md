# CodeMySpec.McpServers.Formatters

Formats responses and errors for MCP servers in a hybrid format combining human-readable summaries with structured data for programmatic access. This module provides consistent error formatting across MCP server tools.

## Functions

### format_changeset_errors/1

Formats changeset errors as human-readable text with contextual guidance for fixing validation issues.

```elixir
@spec format_changeset_errors(Ecto.Changeset.t()) :: String.t()
```

**Process**:
1. Extract errors from changeset using extract_errors/1
2. Map each field-messages pair to formatted markdown lines with field name bolded
3. Join all error lines with newlines
4. Generate fix guidance hints based on field types and error messages
5. Combine error lines and guidance into markdown-formatted string with "Validation Error" header
6. Trim whitespace and return formatted string

**Test Assertions**:
- returns formatted markdown string for changeset with single field error
- returns formatted markdown string for changeset with multiple field errors
- includes field names in bold markdown format
- includes "Validation Error" header in output
- includes fix guidance section when applicable hints exist
- omits fix guidance section when no hints are available
- handles empty changeset errors gracefully
- interpolates error message variables from opts

### extract_errors/1

Extracts errors from changeset as a map for programmatic use, with interpolated error messages.

```elixir
@spec extract_errors(Ecto.Changeset.t()) :: %{atom() => [String.t()]}
```

**Process**:
1. Traverse changeset errors using Ecto.Changeset.traverse_errors/2
2. For each error tuple (message, opts), interpolate variables in format %{key}
3. Replace variable placeholders with corresponding values from opts keyword list
4. Convert interpolated values to strings
5. Return map of field names to lists of interpolated error messages

**Test Assertions**:
- returns empty map for changeset with no errors
- returns map with field names as keys and error lists as values
- interpolates single variable in error message
- interpolates multiple variables in error message
- handles missing variable keys by keeping placeholder
- converts numeric option values to strings
- preserves multiple error messages for same field

## Dependencies

- Ecto.Changeset
