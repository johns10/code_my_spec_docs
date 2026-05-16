# CodeMySpec.Content.ContentRepository

Provides data access functions for published Content entities. Handles content retrieval with optional scope filtering - passing a Scope allows access to protected content for authenticated users, while nil scope only returns public content. Does NOT apply multi-tenant filtering by account_id/project_id.

Note: This repository is for published content access only. ContentAdminRepository handles validation/preview with multi-tenant scoping.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Content.Content
- CodeMySpec.Users.Scope
