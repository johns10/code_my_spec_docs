# MarkdownProcessor

## Purpose

Converts markdown content to HTML using the Earmark library. Populates the `processed_content` field with the rendered HTML output. Catches parsing errors and returns error tuples with detailed information for the `parse_errors` field, ensuring malformed markdown is gracefully handled within the content sync pipeline.

## Public API

```elixir
# Markdown Processing
@spec process(raw_markdown :: String.t()) :: {:ok, ProcessorResult.t()}

# Uses shared result type
@type result :: ProcessorResult.t()
```

## Execution Flow

1. **Markdown Parsing**: Attempt to convert markdown to HTML using `Earmark.as_html(raw_markdown)`
2. **Success Path**: If conversion succeeds:
   - Return `{:ok, result}` with `parse_status: :success`
   - Set `raw_content` to the original markdown string
   - Set `processed_content` to the generated HTML string
   - Set `parse_errors` to `nil`
3. **Error Path**: If conversion fails:
   - Catch `Earmark.Error` or other parsing exceptions
   - Return `{:ok, result}` with `parse_status: :error`
   - Set `raw_content` to the original markdown string
   - Set `processed_content` to `nil`
   - Set `parse_errors` to map containing:
     - `error_type`: String describing the error class (e.g., "Earmark.Error", "ArgumentError")
     - `message`: Human-readable error message
     - `line`: Line number where error occurred (if available from Earmark)
     - `context`: Additional context about the parsing failure (if available)
4. **Result Return**: Always return `{:ok, result}` tuple (errors captured in result map, not as error tuples)