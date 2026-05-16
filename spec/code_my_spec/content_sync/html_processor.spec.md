# CodeMySpec.ContentSync.HtmlProcessor

Validates HTML content structure and checks for disallowed JavaScript elements.

Parses HTML using Floki to ensure well-formed markup and scans for JavaScript content that violates content guidelines (script tags, inline event handlers, javascript: protocol). Copies validated HTML to `processed_content` field on success. Returns validation errors with violation details when HTML contains disallowed JavaScript.

## Dependencies

- Floki
- CodeMySpec.ContentSync.ProcessorResult
