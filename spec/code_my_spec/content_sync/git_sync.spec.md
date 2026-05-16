# CodeMySpec.ContentSync.GitSync

Handles Git repository operations for content sync. Clones project's docs_repo to temporary directory for sync operations. Each sync creates a fresh clone - no persistent caching or pull operations.

## Delegates

None.

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Git
- CodeMySpec.Users.Scope
