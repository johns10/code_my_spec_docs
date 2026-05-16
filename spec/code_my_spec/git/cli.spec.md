# CodeMySpec.Git.Cli

Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library.

## Delegates

None - this module directly implements all its public functions.

## Dependencies

- CodeMySpec.Git.URLParser
- CodeMySpec.Integrations
- CodeMySpec.Users.Scope
- Git (external library)
