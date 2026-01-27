# CodeMySpec.McpServers.Stories.StoriesMapper

Maps story data to MCP responses using a hybrid format that combines human-readable summaries with structured JSON data for programmatic access. This module handles all response formatting for story-related MCP tool operations, criterion operations, error responses, and resource responses.

## Dependencies

- CodeMySpec.McpServers.Formatters
- Hermes.Server.Response
- Jason
- Ecto

## Functions

### story_response/1

Creates a hybrid response for a newly created story.

```elixir
@spec story_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Generate human-readable summary with story title and ID
3. Combine summary and data into hybrid response format

**Test Assertions**:
- returns Response struct with success status
- includes story title and ID in summary text
- includes complete story data in JSON format
- properly formats story with all fields

### story_updated_response/1

Creates a hybrid response for an updated story.

```elixir
@spec story_updated_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Generate human-readable summary indicating update with story title and ID
3. Combine summary and data into hybrid response format

**Test Assertions**:
- returns Response struct with success status
- includes "updated" indicator in summary
- includes story title and ID in summary text
- includes complete story data in JSON format

### story_get_response/1

Creates a hybrid response for retrieving a single story with acceptance criteria statistics.

```elixir
@spec story_get_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Count total criteria and verified criteria
3. Generate formatted markdown summary with title, description, and criteria counts
4. Combine summary and data into hybrid response format

**Test Assertions**:
- returns Response struct with success status
- formats summary as markdown with H2 title
- includes criteria count statistics
- handles nil description gracefully
- handles nil or empty criteria list
- includes complete story data in JSON format

### story_deleted_response/1

Creates a simple text response for a deleted story.

```elixir
@spec story_deleted_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create tool response with simple text message
2. Include story title and ID in deletion confirmation

**Test Assertions**:
- returns Response struct with success status
- includes "deleted" indicator in text
- includes story title and ID

### story_component_set_response/1

Creates a hybrid response when a component is assigned to a story.

```elixir
@spec story_component_set_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Generate summary with story title, ID, and component ID
3. Combine summary and data into hybrid response format

**Test Assertions**:
- returns Response struct with success status
- includes component ID in summary
- includes story title and ID
- includes complete story data with component_id

### story_component_cleared_response/1

Creates a hybrid response when a component is cleared from a story.

```elixir
@spec story_component_cleared_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Generate summary indicating component clearance
3. Combine summary and data into hybrid response format

**Test Assertions**:
- returns Response struct with success status
- includes "cleared" indicator in summary
- includes story title and ID
- includes complete story data

### stories_list_response/4

Creates a paginated list response with pagination hints.

```elixir
@spec stories_list_response(list(map()), integer(), integer(), integer()) :: Hermes.Server.Response.t()
```

**Process**:
1. Count returned stories
2. Generate story summaries using story_summary/1
3. Handle empty results with appropriate message (consider offset)
4. Format non-empty results with story titles and IDs
5. Calculate pagination range (start, end)
6. Add pagination hint if more results available
7. Build data map with stories, total, limit, offset, and has_more flag
8. Combine summary text and data into hybrid response

**Test Assertions**:
- returns Response struct for empty list
- shows "No stories found" for empty list with zero offset
- shows appropriate message for empty list beyond available results
- formats story list with titles and IDs
- shows correct pagination range (e.g., "1-10 of 50")
- includes pagination hint when more results available
- does not include pagination hint when all results shown
- includes complete pagination metadata in data
- correctly calculates has_more flag

### story_titles_response/1

Creates a simple list response showing story titles and IDs.

```elixir
@spec story_titles_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count stories
2. Handle empty list with "No stories found" message
3. Format non-empty list with bullet points of titles and IDs
4. Build data map with stories array and count
5. Combine summary and data into hybrid response

**Test Assertions**:
- returns Response struct for empty list
- shows "No stories found" for empty list
- formats stories as bullet list
- includes count in summary
- includes stories and count in data

### stories_batch_response/1

Creates a response for batch story creation showing up to 5 stories.

```elixir
@spec stories_batch_response(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count created stories
2. Generate summaries for all stories using story_summary/1
3. Take first 5 stories for display
4. Format story titles and IDs as bullet list
5. Add "and X more" indicator if count exceeds 5
6. Build data map with success flag, count, and all story summaries
7. Combine summary and data into hybrid response

**Test Assertions**:
- returns Response struct with success status
- shows all stories when 5 or fewer
- shows first 5 stories when more than 5
- includes "and X more" indicator when more than 5
- includes success: true in data
- includes count in data
- includes all story summaries in data

### batch_errors_response/2

Creates an error response for partial batch creation failures.

```elixir
@spec batch_errors_response(list(map()), list(tuple())) :: Hermes.Server.Response.t()
```

**Process**:
1. Count successes and failures
2. Format up to 3 successful stories with "and X more" if needed
3. Extract errors from changesets using Formatters.extract_errors/1
4. Format up to 3 failures with error messages
5. Add "and X more failures" if needed
6. Build markdown summary with creation and failure sections
7. Build data map with success: false, counts, created stories, and error details
8. Create error response with summary and JSON-encoded data

**Test Assertions**:
- returns Response struct with error status
- shows success count and list
- shows failure count and error messages
- limits success display to 3 stories
- limits failure display to 3 stories
- includes "and X more" indicators when applicable
- includes complete error details in data
- sets success: false in data
- includes created_stories array in data
- includes errors array with index and error details

### prompt_response/1

Creates a simple text response containing a prompt.

```elixir
@spec prompt_response(String.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create tool response with prompt text

**Test Assertions**:
- returns Response struct with success status
- includes exact prompt text in response

### criterion_added_response/2

Creates a hybrid response for a newly added criterion.

```elixir
@spec criterion_added_response(map(), map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract criterion data using criterion_data/1
2. Generate summary with story title, criterion ID, and description
3. Combine summary and data into hybrid response

**Test Assertions**:
- returns Response struct with success status
- includes story title in summary
- includes criterion ID in summary
- includes criterion description in summary
- includes complete criterion data

### criterion_updated_response/1

Creates a hybrid response for an updated criterion.

```elixir
@spec criterion_updated_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract criterion data using criterion_data/1
2. Generate summary with criterion ID and description
3. Combine summary and data into hybrid response

**Test Assertions**:
- returns Response struct with success status
- includes "updated" indicator in summary
- includes criterion ID in summary
- includes criterion description in summary
- includes complete criterion data

### criterion_deleted_response/1

Creates a simple text response for a deleted criterion.

```elixir
@spec criterion_deleted_response(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Create tool response with deletion message
2. Include criterion ID and description

**Test Assertions**:
- returns Response struct with success status
- includes "deleted" indicator in text
- includes criterion ID
- includes criterion description

### criterion_not_found_error/0

Creates a standard error response for criterion not found.

```elixir
@spec criterion_not_found_error() :: Hermes.Server.Response.t()
```

**Process**:
1. Create error response with helpful message
2. Include guidance to use get_story to see criteria IDs

**Test Assertions**:
- returns Response struct with error status
- includes helpful error message
- suggests using get_story tool

### validation_error/1

Creates an error response from an Ecto changeset.

```elixir
@spec validation_error(Ecto.Changeset.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Format changeset errors using Formatters.format_changeset_errors/1
2. Create error response with formatted error message

**Test Assertions**:
- returns Response struct with error status
- includes formatted validation errors
- formats field names and messages clearly
- includes fix guidance when available

### error/1

Creates an error response from an atom or binary error message.

```elixir
@spec error(atom() | String.t()) :: Hermes.Server.Response.t()
```

**Process**:
1. Convert atom to string if needed
2. Create error response with error message

**Test Assertions**:
- returns Response struct with error status
- handles atom error input
- handles string error input
- converts atom to string correctly

### not_found_error/0

Creates a standard error response for story not found.

```elixir
@spec not_found_error() :: Hermes.Server.Response.t()
```

**Process**:
1. Create error response with helpful message
2. Include guidance to use list_stories to verify IDs

**Test Assertions**:
- returns Response struct with error status
- includes helpful error message
- suggests using list_stories tool

### story_resource/1

Creates a JSON resource response for a story.

```elixir
@spec story_resource(map()) :: Hermes.Server.Response.t()
```

**Process**:
1. Extract story data using story_data/1
2. Create resource response with JSON data

**Test Assertions**:
- returns Response struct with resource type
- includes complete story data as JSON
- properly serializes all story fields

### stories_list_resource/1

Creates a JSON resource response for a list of stories.

```elixir
@spec stories_list_resource(list(map())) :: Hermes.Server.Response.t()
```

**Process**:
1. Map stories to summaries using story_summary/1
2. Create resource response with stories array

**Test Assertions**:
- returns Response struct with resource type
- includes stories array as JSON
- properly serializes all stories
- handles empty list
