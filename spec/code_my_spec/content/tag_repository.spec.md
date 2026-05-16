# CodeMySpec.Content.TagRepository

Query builder module for tag upsert and lookup.

Handles tag normalization and conflict resolution on unique constraints.
Tags are single-tenant (no account_id/project_id scoping) and shared globally
across the deployed content system.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Content.Tag
