# CodeMySpec.AgentTasks.Init.Auth

## Type

module

Init step: confirms the CLI has an authenticated CodeMySpec session by calling `CodeMySpec.Auth.OAuthClient.authenticated?/0`. Cannot be auto-completed — `command/2` instructs the user to sign in via the web app or CLI auth flow, then resume by calling `get_next_requirement`.

## Dependencies

- CodeMySpec.Auth
