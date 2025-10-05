# Integrations.Providers.GitHub

## Purpose

Implements the `Integrations.Providers.Behaviour` for GitHub OAuth integration, providing Assent strategy configuration with GitHub-specific client credentials and scopes, returning the `Assent.Strategy.Github` module, and normalizing GitHub's user data structure to the application's domain model for seamless integration storage.

## Public API

```elixir
@behaviour CodeMySpec.Integrations.Providers.Behaviour

# Provider Configuration
@spec config() :: Keyword.t()

# Strategy Selection
@spec strategy() :: module()

# User Data Normalization
@spec normalize_user(user_data :: map()) :: {:ok, map()} | {:error, term()}
```

## Execution Flow

### Configuration Retrieval

1. **Load Client Credentials**: Fetch `github_client_id` and `github_client_secret` from application config
2. **Build Redirect URI**: Construct OAuth callback URL using configured base URL
3. **Set Authorization Params**: Define GitHub-specific scopes (`user:email`, `repo`, `read:org`)
4. **Return Configuration**: Provide keyword list compatible with `Assent.Strategy.Github`

### Strategy Selection

1. **Return Strategy Module**: Return `Assent.Strategy.Github` for use by Assent OAuth flow

### User Data Normalization

1. **Extract OpenID Claims**: Receive user map from Assent with standardized OpenID Connect claims
2. **Map Provider Fields**: Transform GitHub-specific fields to application schema:
   - `sub` → `provider_user_id`
   - `email` → `email`
   - `name` → `name`
   - `preferred_username` → `username`
   - `picture` → `avatar_url`
3. **Validate Required Fields**: Ensure `provider_user_id` is present
4. **Return Normalized Map**: Provide domain model map for Integration persistence