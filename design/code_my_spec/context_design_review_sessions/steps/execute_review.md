## Purpose

Orchestrates the execution of an architectural review by composing a comprehensive prompt with file paths to context designs, child component designs, user stories, and project summaries, then coordinates with Claude via MCP to perform holistic validation and write structured findings to a designated review file.

## Public API

```elixir
@type review_input :: %{
  context_design_path: String.t(),
  child_component_paths: [String.t()],
  user_story_paths: [String.t()],
  executive_summary_path: String.t(),
  review_output_path: String.t()
}

@type review_result :: %{
  review_file_path: String.t(),
  issues_found: non_neg_integer(),
  warnings_found: non_neg_integer(),
  execution_time_ms: non_neg_integer()
}

# Execute architectural review
@spec execute_review(Scope.t(), review_input()) ::
  {:ok, review_result()} |
  {:error, :invalid_paths} |
  {:error, :file_not_found, String.t()} |
  {:error, :path_traversal_attempt} |
  {:error, :mcp_unavailable} |
  {:error, :review_failed, String.t()}

# Validate review input paths
@spec validate_input_paths(Scope.t(), review_input()) ::
  {:ok, review_input()} |
  {:error, :invalid_paths | :file_not_found | :path_traversal_attempt, String.t()}

# Compose review prompt
@spec compose_review_prompt(review_input()) :: String.t()

# Parse review results
@spec parse_review_output(String.t()) ::
  {:ok, %{issues: non_neg_integer(), warnings: non_neg_integer()}} |
  {:error, :invalid_format}
```

## Execution Flow

### Execute Review

1. **Input Validation**
   - Verify all required paths are present in `review_input`
   - Ensure paths are absolute and within allowed project directories
   - Detect and reject path traversal attempts (../, ~/, etc.)
   - Return `{:error, :invalid_paths}` for malformed input

2. **File Existence Check**
   - Verify each input file exists and is readable
   - Check that files belong to the current scope's project
   - Return `{:error, :file_not_found, path}` for missing files
   - Collect file sizes for logging purposes

3. **Review Output Path Setup**
   - Ensure review output directory exists (create if needed)
   - Verify write permissions to output location
   - Check that output path is within project's review directory
   - Generate fallback path if provided path is invalid

4. **Prompt Composition**
   - Build comprehensive review instruction header
   - Include context design file path with description
   - List all child component design paths with component names
   - Reference user story paths for requirement traceability
   - Add executive summary path for project context
   - Specify review output path and expected format
   - Include validation criteria:
     - Architectural compatibility between context and components
     - Dependency coherence across components
     - Alignment with user stories and requirements
     - Phoenix/Elixir best practices compliance
     - Potential integration issues or conflicts

5. **MCP Communication**
   - Verify MCP server availability
   - Send composed prompt via MCP protocol
   - Include timeout configuration (default: 5 minutes)
   - Monitor for Claude's progress/status updates
   - Return `{:error, :mcp_unavailable}` if server is down
   - Return `{:error, :review_failed, reason}` on execution failure

6. **Review Output Verification**
   - Wait for Claude to complete writing review file
   - Verify review file was created at expected path
   - Validate review file is not empty
   - Check file format and structure

7. **Result Parsing**
   - Read generated review file
   - Parse structured findings (issues, warnings, recommendations)
   - Extract metadata (issue counts, severity levels)
   - Calculate execution duration

8. **Result Return**
   - Return `{:ok, review_result()}` with:
     - Path to completed review file
     - Count of issues found
     - Count of warnings found
     - Total execution time in milliseconds

### Validate Input Paths

1. **Path Format Validation**
   - Check all paths are non-empty strings
   - Verify paths are absolute (start with `/`)
   - Ensure no nil or missing required paths

2. **Security Validation**
   - Detect path traversal attempts: `../`, `~/`, symbolic links
   - Verify paths don't reference system directories
   - Check paths are within project workspace

3. **Scope Validation**
   - Extract project identifier from scope
   - Verify all paths belong to scope's project directory
   - Ensure user has read access to referenced files

4. **Existence Validation**
   - Check each input file exists on filesystem
   - Verify files are readable
   - Return first missing file in error message

5. **Result Return**
   - Return `{:ok, review_input()}` if all validations pass
   - Return specific error tuple for first validation failure

### Compose Review Prompt

1. **Header Construction**
   - Add review instruction title
   - State primary objectives: holistic validation, architectural compatibility
   - Define expected output format and structure

2. **Context Section**
   - Add "Context Design" section header
   - Include absolute path to context design file
   - Add instruction to analyze architectural decisions

3. **Components Section**
   - Add "Child Components" section header
   - List each component design path with component name
   - Instruct to validate component integration patterns

4. **Requirements Section**
   - Add "User Stories" section header
   - List all user story file paths
   - Instruct to verify requirement coverage

5. **Project Context Section**
   - Add "Executive Summary" section header
   - Include executive summary file path
   - Instruct to validate alignment with project goals

6. **Review Criteria**
   - List specific validation points:
     - Context boundary coherence
     - Component dependency resolution
     - Data flow patterns
     - Error handling consistency
     - Test coverage feasibility
     - Phoenix best practices

7. **Output Instructions**
   - Specify review file path for writing results
   - Define structured format with sections:
     - Executive Summary
     - Issues (blocking problems)
     - Warnings (concerns/suggestions)
     - Recommendations (improvements)
   - Request issue/warning counts at end

8. **Result Return**
   - Return complete prompt as single string
   - Include proper formatting and line breaks

### Parse Review Output

1. **File Reading**
   - Read review file contents
   - Handle file read errors gracefully

2. **Format Detection**
   - Check for expected section headers
   - Verify structure matches prompt instructions

3. **Metadata Extraction**
   - Search for "Issues Found:" pattern
   - Search for "Warnings Found:" pattern
   - Extract numeric counts

4. **Validation**
   - Ensure counts are non-negative integers
   - Verify at least executive summary section exists

5. **Result Return**
   - Return `{:ok, %{issues: n, warnings: m}}` on success
   - Return `{:error, :invalid_format}` if parsing fails
