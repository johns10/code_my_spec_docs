# CodeMySpec.ContentSync.MarkdownProcessor

Converts markdown content to HTML using the Earmark library. Populates the `processed_content` field with the rendered HTML output and catches parsing errors, returning them in a structured format within the `ProcessorResult` struct. Always returns `{:ok, result}` tuples with errors captured in the result structure rather than as error tuples.

## Dependencies

- Earmark
- CodeMySpec.ContentSync.ProcessorResult

## Functions

### process/1

Processes raw markdown content and converts it to HTML, returning a ProcessorResult struct.

```elixir
@spec process(raw_markdown :: String.t()) :: {:ok, ProcessorResult.t()}
```

**Process**:

1. Attempt to convert markdown to HTML using Earmark.as_html/1
2. On success: convert iodata to binary string, return ProcessorResult with parse_status :success and processed_content as HTML
3. On error from Earmark: build error map from error messages, return ProcessorResult with parse_status :error and parse_errors populated
4. On exception: rescue and capture exception details, return ProcessorResult with parse_status :error
5. Always return {:ok, result} tuple - errors are captured in the result, not as error tuples

**Test Assertions**:

- successfully processes simple heading to HTML with h1 tag
- returns ProcessorResult struct with all required fields (raw_content, processed_content, parse_status, parse_errors)
- converts simple paragraph to HTML with p tag
- preserves raw content exactly in result
- processes complete markdown document with multiple heading levels
- converts emphasis (bold/italic) to strong/em HTML tags
- converts inline links to anchor tags with href attributes
- converts mailto links correctly
- resolves reference-style links to anchor tags
- converts images to img tags with alt and src attributes
- preserves image alt text in output
- converts fenced code blocks to code elements
- converts inline code to code elements
- preserves code content in output
- converts blockquotes to blockquote elements
- handles nested blockquotes
- converts unordered lists to ul/li elements
- converts ordered lists to ol elements
- handles nested lists
- converts tables to table/thead/tbody/tr/th/td elements
- converts horizontal rules to hr elements
- converts all emphasis types (bold, italic, combined)
- processes embedded HTML, preserving tags and attributes
- processes task lists
- processes empty markdown successfully
- processes whitespace-only markdown successfully
- processes unicode characters (Chinese, accented, emojis, Cyrillic)
- preserves unicode in output
- processes special characters (ampersands, less than, greater than)
- processes very long markdown content
- processes escaped markdown characters
- processes HTML entities
- handles unmatched brackets gracefully
- handles incomplete code blocks
- handles unbalanced emphasis markers
- handles invalid tables gracefully
- captures error details when parsing fails (error_type, message in parse_errors)
- error result includes raw_content
- handles nested formatting combinations
- handles multiple consecutive blank lines
- handles mixed line endings
- handles very deep list nesting
- processing same markdown multiple times returns identical results
- success results have consistent structure (parse_status :success, binary content, nil errors)
- always returns ok tuple regardless of parse status
- generates well-formed HTML with matching open/close tags
- converts all six heading levels correctly
- processes typical blog post markdown with headings, code blocks, and links
- processes landing page content with emphasis, lists, and links
- processes documentation with code examples
- processes markdown with inline script tags safely (no execution)
- handles onclick attributes in HTML safely
- processes embedded code blocks without executing the code
