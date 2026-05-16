# CodeMySpec.ContentSync.ProcessorResult

Shared result structure for all content processors in the sync pipeline.

Contains raw and processed content along with parsing status and error details.
Used by MarkdownProcessor and HtmlProcessor to return consistent results that
can be merged into content attributes by the Sync module.

## Fields

| Field             | Type         | Required | Description                                      | Constraints                           |
| ----------------- | ------------ | -------- | ------------------------------------------------ | ------------------------------------- |
| raw_content       | string       | Yes      | Original unprocessed content string              | Enforced key                          |
| processed_content | string       | No       | Processed content (HTML for markdown/html)       | Nil on error                          |
| parse_status      | atom         | Yes      | Processing result status                         | Values: :success, :error. Enforced key |
| parse_errors      | map          | No       | Error details when parse_status is :error        | Nil on success                        |

## Dependencies

None.
