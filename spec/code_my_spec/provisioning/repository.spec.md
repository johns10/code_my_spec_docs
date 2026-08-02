# CodeMySpec.Provisioning.Repository

The project's Git remote, created or adopted through the user's own GitHub App installation. Repository selection is GitHub's installation screen rather than a picker we build, so access is scoped to the repositories the user ticked and is revocable per-repository from their side. Creates one private repository by default, named after the project unless overridden, under a personal account or an organisation. Not called done until a push actually succeeds — a repository that exists but rejects the push is not a remote.

## Type

module

## Dependencies

- CodeMySpec.Integrations
- CodeMySpec.GitHub
- CodeMySpec.Git
- CodeMySpec.Projects
