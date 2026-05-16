# CodeMySpec.ContentAdmin.ContentAdminRepository

Provides multi-tenant data access for ContentAdmin entities with account and project scoping. Handles retrieval of content admin records for validation and preview workflows, applying strict multi-tenant filtering via Scope.

Note: This repository applies account_id and project_id filtering for administrative access. ContentRepository handles published content access without multi-tenant filtering.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.ContentAdmin.ContentAdmin
- CodeMySpec.Users.Scope
