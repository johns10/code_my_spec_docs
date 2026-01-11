# CodeMySpec.ContentSync.HtmlProcessor

Validates HTML content structure and checks for disallowed JavaScript elements.

Parses HTML using Floki to ensure well-formed markup and scans for JavaScript content that violates content guidelines (script tags, inline event handlers, javascript: protocol). Copies validated HTML to `processed_content` field on success. Returns validation errors with violation details when HTML contains disallowed JavaScript.

## Dependencies

- Floki
- CodeMySpec.ContentSync.ProcessorResult

## Functions

### process/1

Processes raw HTML content and validates it for structure and security.

```elixir
@spec process(raw_html :: String.t()) :: {:ok, ProcessorResult.t()}
```

**Process**:
1. Parse HTML document using Floki.parse_document/1
2. If parsing fails, return error result with Floki.ParseError details including reason
3. Scan parsed document for `<script>` tags
4. Scan parsed document for inline event handlers (onclick, onload, onmouseover, onsubmit, onerror, etc.)
5. Scan parsed document for javascript: protocol in href/src attributes (case-insensitive, with whitespace trimming)
6. If violations found, return error result with DisallowedContent error and violation list
7. If no violations, return success result with raw HTML copied to processed_content

**Test Assertions**:
- successfully processes simple HTML paragraph
- returns ProcessorResult struct with all required fields
- successfully processes complete HTML document with doctype, head, body
- preserves HTML structure exactly in processed_content
- successfully processes HTML with valid attributes (class, id, href, src)
- allows safe inline styles
- allows data attributes
- successfully processes semantic HTML5 elements (article, header, section, footer)
- allows time elements with datetime attributes
- successfully processes table structures (table, thead, tbody)
- successfully processes form elements without JavaScript
- successfully processes deeply nested HTML
- returns error for HTML with script tag
- error includes violation details with error_type DisallowedContent
- detects script_tag violation type in violations array
- detects multiple script tags
- detects script tags with src attribute
- returns error for onclick attribute
- error includes violation details for onclick with element and attribute
- detects onload attribute
- detects onmouseover attribute
- detects onsubmit attribute
- detects onerror attribute
- detects multiple inline event handlers
- detects onchange, onfocus, onblur attributes
- returns error for javascript: in href
- error includes violation details for javascript_protocol type
- detects javascript: in src attribute
- detects javascript: with different casing (case-insensitive)
- detects javascript: with leading whitespace
- detects multiple types of violations simultaneously
- reports all violation types found (script_tag, event_handler, javascript_protocol)
- handles unclosed tags gracefully via Floki's lenient parsing
- handles mismatched tags
- handles invalid nesting
- successfully processes empty HTML string
- successfully processes whitespace-only HTML
- handles very long HTML content (1000+ elements)
- handles unicode characters in HTML
- handles HTML entities (&lt;, &gt;, etc.)
- handles HTML comments
- handles CDATA sections
- handles self-closing tags
- handles very deeply nested HTML (50+ levels)
- handles HTML with many attributes
- handles empty boolean attributes (disabled, readonly, required)
- allows safe anchor links (https://, relative, anchor, mailto:, tel:)
- allows image sources with valid protocols
- allows data URIs in images
- processing same HTML multiple times returns identical results
- success results have consistent structure (parse_status :success, parse_errors nil)
- error results have consistent structure (parse_status :error, processed_content nil)
- violation structures include type and element keys
- blocks potential XSS via script tags
- blocks potential XSS via onclick handlers
- blocks potential XSS via javascript: protocol
- does not execute JavaScript during validation
- safely handles HTML with special characters
- processes typical blog post HTML
- processes typical landing page HTML
- processes HTML with embedded media (video, audio)
