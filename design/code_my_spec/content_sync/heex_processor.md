# HeexProcessor

## Purpose

Validates HEEx (HTML+EEx) template syntax without rendering by using `EEx.compile_string/1` with `Phoenix.LiveView.HTMLEngine`. Stores the raw HEEx template in `raw_content` and sets `processed_content` to `nil` after successful validation (HEEx templates are rendered at request time with assigns, not during sync). Returns success tuples with detailed syntax error information for invalid templates.

## Public API

```elixir
# Template Processing
@spec process(raw_heex :: String.t()) :: {:ok, ProcessorResult.t()}

# Uses shared result type
@type result :: ProcessorResult.t()
```

## Execution Flow

1. **Syntax Validation**: Attempt to compile HEEx template using `EEx.compile_string(raw_heex, engine: Phoenix.LiveView.HTMLEngine, file: "nofile", line: 1)`
2. **Success Path**: If compilation succeeds:
   - Return `{:ok, result}` with `parse_status: :success`
   - Set `raw_content` to the original HEEx string
   - Set `processed_content` to `nil` (templates rendered at request time with assigns)
   - Set `parse_errors` to `nil`
3. **Error Path**: If compilation raises an exception:
   - Catch `EEx.SyntaxError`, `Phoenix.LiveView.Tokenizer.ParseError`, or other compilation errors
   - Return `{:ok, result}` with `parse_status: :error`
   - Set `raw_content` to the original HEEx string
   - Set `processed_content` to `nil`
   - Set `parse_errors` to map containing:
     - `error_type`: String describing the error class (e.g., "EEx.SyntaxError", "Phoenix.LiveView.Tokenizer.ParseError")
     - `message`: Human-readable error message
     - `line`: Line number where error occurred (if available)
     - `column`: Column number where error occurred (if available)
4. **Result Return**: Always return `{:ok, ProcessorResult.t()}` (errors captured in result, not as error tuples)

## Implementation Notes

### HEEx vs EEx

HEEx is the modern Phoenix LiveView template format that includes:
- HTML-aware parsing and validation
- Component syntax (`<.component />`)
- Attribute validation
- Better error messages

This processor validates HEEx specifically, not plain EEx templates.

### Compilation Without Rendering

The processor validates syntax by compiling the template but never renders it:
- Compilation checks syntax correctness
- Rendering requires assigns (variables/data)
- Assigns are only available at request time
- `processed_content` is intentionally `nil`

### Error Handling

All errors are caught and embedded in the result:
```elixir
rescue
  e in EEx.SyntaxError ->
    {:ok, %ProcessorResult{
      raw_content: raw_heex,
      processed_content: nil,
      parse_status: :error,
      parse_errors: %{
        error_type: "EEx.SyntaxError",
        message: Exception.message(e),
        line: e.line,
        column: nil
      }
    }}

  e in Phoenix.LiveView.Tokenizer.ParseError ->
    {:ok, %ProcessorResult{
      raw_content: raw_heex,
      processed_content: nil,
      parse_status: :error,
      parse_errors: %{
        error_type: "Phoenix.LiveView.Tokenizer.ParseError",
        message: Exception.message(e),
        line: e.line,
        column: e.column
      }
    }}
end
```

### Integration with Sync

Sync calls HeexProcessor for `.heex` files:
1. Sync reads `.heex` file contents
2. Calls `HeexProcessor.process(content)`
3. Receives `{:ok, result}` with embedded status
4. Merges result with metadata into content attributes
5. Inserts content record (including errors)

### Request-Time Rendering

HEEx templates are rendered when requested by users:
- Template stored in `raw_content` field
- Rendering happens in controllers/LiveViews
- Assigns passed at render time
- `processed_content` remains nil in database