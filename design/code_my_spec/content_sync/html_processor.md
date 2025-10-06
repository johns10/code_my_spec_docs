# HtmlProcessor

## Purpose

Validates HTML content structure and checks for disallowed elements (script tags, inline event handlers). Parses HTML using Floki to ensure well-formed markup and scans for JavaScript content that violates content guidelines. Copies validated HTML to `processed_content` field on success. Returns validation errors with details for `parse_errors` field when HTML is malformed or contains disallowed JavaScript.

## Public API

```elixir
# HTML Processing
@spec process(raw_html :: String.t()) :: {:ok, ProcessorResult.t()}

# Uses shared result type
@type result :: ProcessorResult.t()
```

## Execution Flow

1. **HTML Parsing**: Attempt to parse HTML using `Floki.parse_document(raw_html)`
2. **Structure Validation**: If parsing fails:
   - Return `{:ok, result}` with `parse_status: :error`
   - Set `raw_content` to the original HTML string
   - Set `processed_content` to `nil`
   - Set `parse_errors` to map containing:
     - `error_type`: "Floki.ParseError" or similar
     - `message`: Human-readable error message about malformed HTML
     - `line`: Line number where parsing failed (if available from Floki)
3. **JavaScript Detection**: Search parsed HTML tree for disallowed JavaScript:
   - `<script>` tags using `Floki.find(document, "script")`
   - Inline event handlers (onclick, onload, etc.) by checking attributes on all elements
   - `javascript:` protocol in href/src attributes
4. **JavaScript Found Path**: If any JavaScript detected:
   - Return `{:ok, result}` with `parse_status: :error`
   - Set `raw_content` to the original HTML string
   - Set `processed_content` to `nil`
   - Set `parse_errors` to map containing:
     - `error_type`: "DisallowedContent"
     - `message`: "HTML contains disallowed JavaScript content"
     - `violations`: List of specific violations found, each with:
       - `type`: "script_tag", "event_handler", or "javascript_protocol"
       - `element`: Tag name where violation occurred
       - `attribute`: Attribute name (for event handlers and protocols)
       - `line`: Approximate line number (if determinable)
5. **Success Path**: If HTML is well-formed and contains no JavaScript:
   - Return `{:ok, result}` with `parse_status: :success`
   - Set `raw_content` to the original HTML string
   - Set `processed_content` to the original HTML string (unchanged)
   - Set `parse_errors` to `nil`
6. **Result Return**: Always return `{:ok, result}` tuple (errors captured in result map, not as error tuples)
