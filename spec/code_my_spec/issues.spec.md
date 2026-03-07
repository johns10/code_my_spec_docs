# CodeMySpec.Issues

## Type

context

Bounded context for managing QA issues and braindump items. Database is the source of truth; markdown files in `.code_my_spec/issues/` are read-only projections for agent consumption. Issues are created by evaluate hooks (from QA results and braindump triage), never by agents directly. Agent decisions (accept, dismiss, resolve) flow through structured result documents that the evaluate hook parses and applies.

## Functions

### create_issue/2

Creates a new issue within scope.

```elixir
@spec create_issue(Scope.t(), map()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build changeset with project_id and account_id from scope
2. Insert to database
3. Project issue to filesystem
4. Return result tuple

**Test Assertions**:
- creates issue with valid attributes
- sets project_id and account_id from scope
- projects issue file to `.code_my_spec/issues/incoming/`
- returns changeset error for invalid attributes
- validates required fields (title, severity, description)

### create_from_qa_result/3

Parses a validated QA result document and creates issues from it.

```elixir
@spec create_from_qa_result(Scope.t(), integer(), Documents.Document.t()) :: {:ok, [Issue.t()]}
```

**Process**:
1. Extract issues section from document.sections
2. Filter to fileable issues (valid severity)
3. For each issue, upsert by title + story_id (skip duplicates)
4. Set status to :incoming, source to QA result path
5. Project all created issues to filesystem
6. Return list of created issues

**Test Assertions**:
- creates issues from QA result document
- sets story_id from the story parameter
- skips duplicate issues (same title + story_id)
- sets status to :incoming
- sets source_path to the QA result file
- projects created issues to filesystem

### create_from_braindump/3

Creates an issue from a raw braindump markdown file, fleshing out the content.

```elixir
@spec create_from_braindump(Scope.t(), String.t(), map()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Parse braindump file content for title (H1), description (body)
2. Merge with provided attrs (severity, scope overrides)
3. Default severity to :medium, status to :accepted (braindumps are pre-triaged)
4. Insert to database
5. Project issue to filesystem
6. Return result tuple

**Test Assertions**:
- creates issue from braindump content
- defaults status to :accepted
- defaults severity to :medium
- merges explicit attrs over parsed content
- projects to accepted directory

### list_issues/1

Returns all issues for the active project in scope.

```elixir
@spec list_issues(Scope.t()) :: [Issue.t()]
```

**Process**:
1. Query issues filtered by project_id
2. Order by severity (critical first), then inserted_at
3. Return list

**Test Assertions**:
- returns all issues for the project
- returns empty list when no issues exist
- respects project scope
- orders by severity then creation date

### list_by_status/2

Returns issues filtered by status.

```elixir
@spec list_by_status(Scope.t(), atom()) :: [Issue.t()]
```

**Process**:
1. Query issues filtered by project_id and status
2. Order by severity (critical first), then inserted_at
3. Return list

**Test Assertions**:
- returns only issues with matching status
- returns empty list when no issues match
- respects project scope

### list_by_story/2

Returns issues associated with a specific story.

```elixir
@spec list_by_story(Scope.t(), integer()) :: [Issue.t()]
```

**Process**:
1. Query issues filtered by project_id and story_id
2. Order by severity then inserted_at
3. Return list

**Test Assertions**:
- returns issues for the given story
- returns empty list when story has no issues
- respects project scope

### get_issue!/2

Gets a single issue by ID within scope. Raises if not found.

```elixir
@spec get_issue!(Scope.t(), binary()) :: Issue.t()
```

**Process**:
1. Query by ID filtered by project_id
2. Return issue or raise Ecto.NoResultsError

**Test Assertions**:
- returns issue when it exists in project
- raises Ecto.NoResultsError when issue doesn't exist
- raises when issue exists but in different project

### accept_issue/2

Transitions an issue from :incoming to :accepted.

```elixir
@spec accept_issue(Scope.t(), Issue.t()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify issue belongs to scope's account
2. Update status to :accepted
3. Re-project issue (moves from incoming/ to accepted/)
4. Return result tuple

**Test Assertions**:
- transitions incoming issue to accepted
- re-projects file from incoming to accepted directory
- returns error when issue is not in :incoming status

### dismiss_issue/3

Transitions an issue from :incoming to :dismissed with a reason.

```elixir
@spec dismiss_issue(Scope.t(), Issue.t(), String.t()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify issue belongs to scope's account
2. Update status to :dismissed, set resolution to reason
3. Delete projected file (dismissed issues are not projected)
4. Return result tuple

**Test Assertions**:
- transitions incoming issue to dismissed
- stores dismissal reason in resolution field
- removes projected file
- returns error when issue is not in :incoming status

### resolve_issue/3

Marks an accepted issue as resolved with a resolution description.

```elixir
@spec resolve_issue(Scope.t(), Issue.t(), String.t()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify issue belongs to scope's account
2. Update status to :resolved, set resolution text
3. Re-project issue (adds Resolution section to projected file)
4. Return result tuple

**Test Assertions**:
- transitions accepted issue to resolved
- stores resolution text
- re-projects file with Resolution section appended
- returns error when issue is not in :accepted status

### project_all/2

Re-projects all active issues to filesystem. Idempotent — safe to call anytime.

```elixir
@spec project_all(Scope.t(), Environments.Environment.t()) :: :ok
```

**Process**:
1. Query all issues for project where status in [:incoming, :accepted, :resolved]
2. Clear existing projection directories
3. Project each issue to its status-appropriate directory
4. Return :ok

**Test Assertions**:
- projects incoming issues to incoming directory
- projects accepted issues to accepted directory
- projects resolved issues to accepted directory (with Resolution section)
- does not project dismissed issues
- is idempotent (same result on repeated calls)
- recovers from deleted files

### has_unresolved_issues?/2

Checks if there are accepted issues at or above a minimum severity.

```elixir
@spec has_unresolved_issues?(Scope.t(), atom()) :: boolean()
```

**Process**:
1. Query accepted issues with severity >= min_severity
2. Exclude issues with status :resolved
3. Return true if any exist

**Test Assertions**:
- returns true when unresolved issues exist at severity
- returns false when all issues are resolved
- respects minimum severity threshold
- ignores dismissed issues

### has_untriaged_issues?/2

Checks if there are incoming issues at or above a minimum severity.

```elixir
@spec has_untriaged_issues?(Scope.t(), atom()) :: boolean()
```

**Process**:
1. Query incoming issues with severity >= min_severity
2. Return true if any exist

**Test Assertions**:
- returns true when untriaged issues exist at severity
- returns false when no incoming issues exist
- respects minimum severity threshold

## Dependencies

- CodeMySpec.Issues.Issue
- CodeMySpec.Issues.IssuesRepository
- CodeMySpec.Issues.Projector
- CodeMySpec.Documents
- CodeMySpec.Environments
- CodeMySpec.Users.Scope

## Components

### Issues.Issue

Ecto schema representing a QA issue or braindump item. Fields: title, severity (critical/high/medium/low/info), scope (app/qa/docs), description, status (incoming/accepted/dismissed/resolved), resolution, story_id, source_path. Scoped by project_id and account_id. Uses UUID primary keys.

### Issues.IssuesRepository

Repository for issue CRUD operations with direct database access. Provides query composables for filtering by status, severity, story, and project. Includes severity ordering and upsert support for deduplication.

### Issues.Projector

Projects issues from the database to read-only markdown files in `.code_my_spec/issues/`. Each issue becomes a file in the status-appropriate subdirectory (incoming/, accepted/). File format matches the existing issue markdown convention. Handles cleanup of stale projections.
