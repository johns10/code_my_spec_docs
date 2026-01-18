# CodeMySpec.Problems.ProblemRenderer

Utility module for rendering Problem structs into human and AI-readable formats. Transforms normalized problems from static analysis tools, compilers, and test failures into actionable feedback strings for Claude Code agent evaluation hooks.

## Dependencies

- CodeMySpec.Problems.Problem

## Functions

### render/2

Render a single problem to a formatted string.

```elixir
@spec render(Problem.t(), keyword()) :: String.t()
```

**Options**:
- `:format` - Output format: `:text` (default), `:compact`
- `:include_source` - Include source tool name (default: true)

**Process**:
1. Build location string from file_path and optional line number
2. Format severity indicator (error/warning/info)
3. Combine location, severity, source, and message into output string
4. For compact format, use single-line `file:line: [severity] message`
5. For text format, use multi-line with labeled fields

**Test Assertions**:
- renders problem with file path and line number
- renders problem without line number
- includes source tool name when include_source is true
- omits source tool name when include_source is false
- renders compact format as single line
- renders text format with labeled fields

### render_list/2

Render a list of problems to a formatted string.

```elixir
@spec render_list([Problem.t()], keyword()) :: String.t()
```

**Options**:
- `:format` - Output format: `:text` (default), `:compact`, `:grouped`
- `:group_by` - Grouping key for `:grouped` format: `:severity`, `:source`, `:file_path` (default: `:severity`)
- `:include_summary` - Include problem count summary (default: true)

**Process**:
1. Return empty string for empty list
2. Sort problems by severity (error first), then file_path, then line
3. For grouped format, partition problems by group_by key and render each group with header
4. Render each problem using render/2
5. Prepend summary line if include_summary is true

**Test Assertions**:
- returns empty string for empty list
- renders multiple problems separated by newlines
- sorts problems by severity with errors first
- groups problems by severity when group_by is :severity
- groups problems by source when group_by is :source
- groups problems by file_path when group_by is :file_path
- includes summary line with counts when include_summary is true
- omits summary line when include_summary is false

### render_summary/1

Render a summary of problem counts by severity.

```elixir
@spec render_summary([Problem.t()]) :: String.t()
```

**Process**:
1. Count problems by severity (error, warning, info)
2. Build summary string with non-zero counts
3. Return "No problems found" for empty list

**Test Assertions**:
- returns "No problems found" for empty list
- returns count string for single severity
- returns combined counts for multiple severities
- orders counts as errors, warnings, info

### render_summary_by_source/1

Render a summary of problem counts grouped by source tool, showing severity breakdown for each.

```elixir
@spec render_summary_by_source([Problem.t()]) :: String.t()
```

**Process**:
1. Return "No problems found" for empty list
2. Group problems by source (credo, dialyzer, boundary, sobelow, compiler, exunit, etc.)
3. For each source, count problems by severity
4. Format each source as a line with severity counts
5. Order sources alphabetically

**Test Assertions**:
- returns "No problems found" for empty list
- groups counts by source tool
- shows severity breakdown for each source
- orders sources alphabetically
- handles single source with multiple severities
- handles multiple sources with single severity each

### render_for_feedback/2

Render problems as actionable feedback for Claude Code agent evaluation.

```elixir
@spec render_for_feedback([Problem.t()], keyword()) :: String.t()
```

**Options**:
- `:max_problems` - Maximum number of problems to include (default: 10)
- `:context` - Context string to prepend (e.g., "Static analysis found issues:")

**Process**:
1. Return nil for empty list (indicates no problems)
2. Take at most max_problems from the list (prioritizing errors)
3. Render context header if provided
4. Render summary line
5. Render each problem in compact format
6. Append truncation notice if problems were limited
7. Append actionable instruction for Claude to fix issues

**Test Assertions**:
- returns nil for empty list
- includes context header when provided
- includes summary of problem counts
- limits output to max_problems
- prioritizes errors over warnings when truncating
- includes truncation notice when problems are limited
- ends with actionable instruction for Claude
