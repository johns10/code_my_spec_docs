# CodeMySpec.Git

Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations for cloning and pulling repositories using OAuth tokens from the Integrations context.

## Type

context

## Delegates

- clone/3: CodeMySpec.Git.CLI.clone/3
- pull/2: CodeMySpec.Git.CLI.pull/2

## Dependencies

- CodeMySpec.Git.CLI
- CodeMySpec.Git.URLParser
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.Git.CLI

Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library. Handles credential cleanup and URL restoration.

### CodeMySpec.Git.URLParser

Parses HTTPS git repository URLs to extract provider information and construct authenticated URLs with injected access tokens. Supports GitHub and GitLab providers. Validates URL format and normalizes host names.
