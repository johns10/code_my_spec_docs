# CodeMySpec.Stories.Markdown

Handles parsing and formatting of user stories in markdown format for import/export functionality. Provides clean separation between markdown processing logic and story domain operations.

## Delegates

None

## Dependencies

None

## Functions

### validate_format/1

Validates that a markdown string has proper document structure for story parsing.

```elixir
@spec validate_format(binary()) :: {:ok, :valid} | {:error, format_error()}
@type format_error :: :invalid_structure | :missing_sections | :malformed_headers
```

**Process**:
1. Trim whitespace from input markdown string
2. Return `{:error, :empty_document}` if trimmed content is empty
3. Split content into lines and check for story section headers (lines starting with `## `)
4. Return `{:error, :missing_sections}` if no story headers found
5. Validate all headers have content after the `## ` prefix
6. Return `{:error, :malformed_headers}` if any header is empty
7. Return `{:ok, :valid}` if all validations pass

**Test Assertions**:
- validates valid markdown format with project header
- validates valid markdown format without project header
- returns error for empty document
- returns error for whitespace-only document
- returns error for missing story sections
- returns error for malformed headers (empty ## headers)

### parse_markdown/1

Parses a markdown document into a list of story attribute maps containing title, description, and acceptance criteria.

```elixir
@spec parse_markdown(binary()) :: {:ok, [story_attrs()]} | {:error, parse_error()}
@type story_attrs :: %{title: binary(), description: binary(), acceptance_criteria: [binary()]}
@type parse_error :: :invalid_format | :empty_document | :missing_story_data | :missing_sections
```

**Process**:
1. Validate format using `validate_format/1`
2. Split markdown into sections by `\n## ` delimiter
3. Detect if first section is a project header (does not start with `## `) and skip it
4. Parse each story section:
   - Extract title from `## ` header line
   - Extract description text between title and acceptance criteria section
   - Extract acceptance criteria bullet items after `**Acceptance Criteria**` marker
5. Return list of story maps in document order
6. Return error if any section is missing required title or description

**Test Assertions**:
- parses complete markdown document with single story
- parses markdown with multiple stories
- parses story without acceptance criteria (returns empty list)
- parses stories without project header
- returns error for invalid format (empty document)
- preserves order of stories as they appear in document

### format_stories/2

Formats a list of story attribute maps back into markdown document format.

```elixir
@spec format_stories([story_attrs()], binary() | nil) :: binary()
```

**Process**:
1. If project_name provided, prepend `# project_name\n\n` header
2. For each story map, format as:
   - `## title` header
   - Description text
   - `**Acceptance Criteria**` section with bullet list (if criteria exist)
3. Join all story sections with double newlines
4. Return empty string for empty story list

**Test Assertions**:
- formats single story to markdown with all sections
- formats multiple stories to markdown separated by blank lines
- formats story without acceptance criteria (omits criteria section)
- formats empty list to empty string
- includes project header when project_name provided
- omits project header when project_name is nil
- round-trip parsing and formatting preserves data
- handles complex multiline descriptions