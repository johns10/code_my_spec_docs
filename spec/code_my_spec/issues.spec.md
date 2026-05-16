# CodeMySpec.Issues

## Type

context

Bounded context for managing QA issues and braindump items. Database is the source of truth; markdown files in `.code_my_spec/issues/` are read-only projections for agent consumption. Issues are created by evaluate hooks (from QA results and braindump triage), never by agents directly. Agent decisions (accept, dismiss, resolve) flow through structured result documents that the evaluate hook parses and applies.

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
