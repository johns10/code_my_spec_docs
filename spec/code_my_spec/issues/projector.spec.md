# CodeMySpec.Issues.Projector

## Type

module

Projects issues from the database to read-only markdown files in `.code_my_spec/issues/`. Each issue is written as a standalone markdown file in the appropriate status subdirectory (incoming/ or accepted/). Dismissed issues are not projected. The projection is idempotent — calling project_all will always produce the correct filesystem state regardless of what an agent may have done to the files.

## Dependencies

- CodeMySpec.Issues.Issue
- CodeMySpec.Environments
- CodeMySpec.Paths

## Functions

### project_issue/2

Projects a single issue to the appropriate filesystem location.

```elixir
@spec project_issue(Environments.Environment.t(), Issue.t()) :: :ok
```

**Process**:
1. Determine target directory based on status (:incoming → incoming/, :accepted or :resolved → accepted/)
2. Skip projection if status is :dismissed
3. Build filename from issue: `qa-{story_id}-{slug}.md` (or `braindump-{slug}.md` if no story_id)
4. Remove any existing file for this issue in other directories (handles status transitions)
5. Build markdown content with title, severity, scope, description, source sections
6. If resolved, append Resolution section
7. Write file via Environments.write_file

**Test Assertions**:
- writes incoming issue to incoming/ directory
- writes accepted issue to accepted/ directory
- writes resolved issue to accepted/ with Resolution section
- does not write dismissed issues
- removes stale file from old directory on status change
- generates correct filename slug from title
- uses braindump prefix when story_id is nil

### project_all/2

Re-projects all active issues for a project. Clears and rebuilds.

```elixir
@spec project_all(Environments.Environment.t(), [Issue.t()]) :: :ok
```

**Process**:
1. Clear incoming/ and accepted/ directories
2. Ensure directories exist
3. Project each issue with status in [:incoming, :accepted, :resolved]
4. Return :ok

**Test Assertions**:
- projects all active issues
- clears stale files from previous projections
- skips dismissed issues
- creates directories if missing
- is idempotent

### remove_projection/2

Removes any projected file for an issue from all directories.

```elixir
@spec remove_projection(Environments.Environment.t(), Issue.t()) :: :ok
```

**Process**:
1. Build the filename for this issue
2. Delete from incoming/ if exists
3. Delete from accepted/ if exists
4. Return :ok

**Test Assertions**:
- removes file from incoming directory
- removes file from accepted directory
- succeeds even if file doesn't exist

### build_filename/1

Generates the projection filename for an issue.

```elixir
@spec build_filename(Issue.t()) :: String.t()
```

**Process**:
1. Build slug from title: downcase, replace non-alphanumeric with underscore, trim, truncate to 40 chars
2. If story_id present: `qa-{story_id}-{slug}.md`
3. If no story_id: `braindump-{slug}.md`

**Test Assertions**:
- generates qa- prefix with story_id
- generates braindump- prefix without story_id
- slugifies title correctly
- truncates long titles

### build_content/1

Builds the markdown content for a projected issue file.

```elixir
@spec build_content(Issue.t()) :: String.t()
```

**Process**:
1. Build markdown with: `# {title}`, `## Severity`, `## Scope`, `## Description`, `## Source`
2. If resolved, append `## Resolution` section
3. Return content string

**Test Assertions**:
- includes all required sections
- appends Resolution section when status is :resolved
- omits Resolution section when not resolved
- formats source as story reference when story_id present
