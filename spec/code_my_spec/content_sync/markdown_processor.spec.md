# CodeMySpec.ContentSync.MarkdownProcessor

Converts markdown content to HTML using the Earmark library. Populates the `processed_content` field with the rendered HTML output and catches parsing errors, returning them in a structured format within the `ProcessorResult` struct. Always returns `{:ok, result}` tuples with errors captured in the result structure rather than as error tuples.

## Dependencies

- Earmark
- CodeMySpec.ContentSync.ProcessorResult
