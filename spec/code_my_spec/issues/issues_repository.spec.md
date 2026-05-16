# CodeMySpec.Issues.IssuesRepository

## Type

repository

Repository for issue CRUD operations with direct database access. Provides query composables for filtering by status, severity, story, and project. Includes severity ordering and upsert support for deduplication when creating issues from QA results.

## Dependencies

- Ecto.Query
- CodeMySpec.Repo
- CodeMySpec.Issues.Issue
- CodeMySpec.Users.Scope
