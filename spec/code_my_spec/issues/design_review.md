# Design Review

## Overview

Reviewed the Issues context with 3 child components (Issue, IssuesRepository, Projector). The design implements a DB-backed issue tracking system where the database is the source of truth and markdown files are read-only projections for agent consumption. Issues track defects, improvements, and observations discovered during QA testing or captured from braindump files.

## Architecture

- **Separation of concerns**: Well-defined. Context handles coordination between repository (CRUD) and projector (filesystem). Repository owns all DB queries. Projector is a pure transformation module that writes markdown files.
- **Component types**: Appropriate. Issue is typed as `schema` (Ecto schema with changesets and validation). IssuesRepository is typed as `repository` (direct DB access with query composables). Projector is typed as `module` (pure functions, no state).
- **Dependency relationships**: Correct. Context depends on Issue, IssuesRepository, Projector, Documents (for QaIssue struct), Environments (for filesystem), and Users.Scope. Repository depends on Issue, Repo, and Scope. Projector depends on Issue, Environments, and Paths.
- **No circular dependencies**: Confirmed. Issues reads from Documents for QA result parsing but Documents has no awareness of Issues. Projector writes to filesystem but has no dependency on the repository.
- **Status lifecycle**: Issue schema enforces valid transitions via `@valid_transitions` map: incoming → accepted/dismissed, accepted → resolved. Dismissed and resolved are terminal states.
- **Severity ordering**: Repository uses a SQL CASE fragment for consistent ordering across all list queries.

## Integration

- **Context delegates reads to repository**: `list_issues/1`, `list_by_status/2`, `list_by_story/2`, `get_issue!/2` all delegate directly.
- **Write operations coordinate repo + projector**: `create_issue/2` inserts via repo then projects. Status transitions (`accept_issue/2`, `dismiss_issue/3`, `resolve_issue/3`) update via repo then project or remove projection.
- **QA result ingestion**: `create_from_qa_result/3` parses QaIssue structs from document sections, upserts each (deduplicating by title + story_id + project_id), and projects created issues.
- **Braindump ingestion**: `create_from_braindump/3` parses markdown H1 as title, body as description, defaults to accepted status and medium severity.
- **Idempotent projection**: `project_all/2` clears and rebuilds all projection directories, safe to call at any time to recover from agent interference.
- **Unique constraint handling**: Upsert uses `on_conflict: :nothing` with conflict target `[:title, :story_id, :project_id]`, then fetches existing on conflict.

## Conclusion

Ready for implementation. The architecture cleanly separates concerns between schema validation, database operations, and filesystem projection. The idempotent projection design addresses the core problem of agents deleting or modifying issue files — the system can always recover by re-projecting from the database source of truth.
