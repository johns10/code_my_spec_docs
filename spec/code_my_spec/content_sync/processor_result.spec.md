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

## Functions

### success/2

Creates a ProcessorResult for successful processing.

```elixir
@spec success(raw_content :: String.t(), processed_content :: String.t()) :: t()
```

**Process**:
1. Build struct with raw_content and processed_content
2. Set parse_status to :success
3. Set parse_errors to nil

**Test Assertions**:
- returns ProcessorResult struct with parse_status :success
- sets raw_content to first argument
- sets processed_content to second argument
- sets parse_errors to nil
- returns correct struct type

### error/2

Creates a ProcessorResult for failed processing.

```elixir
@spec error(raw_content :: String.t(), parse_errors :: map()) :: t()
```

**Process**:
1. Build struct with raw_content
2. Set processed_content to nil
3. Set parse_status to :error
4. Set parse_errors to provided error map

**Test Assertions**:
- returns ProcessorResult struct with parse_status :error
- sets raw_content to first argument
- sets processed_content to nil
- sets parse_errors to second argument
- accepts error map with error_type and message keys
- accepts error map with optional violations list
- accepts error map with optional line number
- accepts error map with optional context
- accepts error map with optional details
- returns correct struct type
