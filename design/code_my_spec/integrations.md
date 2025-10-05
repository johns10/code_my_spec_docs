# Integrations Context

## Purpose
Manages OAuth integrations for external services, handling complete OAuth flows, secure token storage with automatic refresh, and providing authenticated tokens to other contexts for external API operations.

## Entity Ownership
- **Integration**: OAuth connection records linking users to external providers with encrypted tokens
- **OAuth Flow State**: CSRF-protected state management for authorization flows
- **Token Lifecycle**: Automatic token expiration detection and refresh on retrieval
- **Provider Registry**: OAuth configuration and capabilities per provider

## Public API

```elixir
# OAuth Flow Management
@spec authorize_url(scope :: Scope.t(), provider :: provider(), redirect_uri :: String.t()) :: {:ok, authorization_url :: String.t()} | {:error, :invalid_provider}
@spec handle_callback(scope :: Scope.t(), provider :: provider(), code :: String.t(), state :: String.t()) :: {:ok, Integration.t()} | {:error, :invalid_code | :state_mismatch | :exchange_failed}
@spec disconnect(scope :: Scope.t(), provider :: provider()) :: :ok | {:error, :not_found}

# Integration Management
@spec get_integration(scope :: Scope.t(), provider :: provider()) :: {:ok, Integration.t()} | {:error, :not_found}
@spec list_integrations(scope :: Scope.t()) :: [Integration.t()]
@spec connected?(scope :: Scope.t(), provider :: provider()) :: boolean()

# Token Operations
@spec get_token(scope :: Scope.t(), provider :: provider()) :: {:ok, token :: String.t()} | {:error, :not_connected | :refresh_failed}
@spec refresh_token(scope :: Scope.t(), provider :: provider()) :: {:ok, token :: String.t()} | {:error, :no_refresh_token | :refresh_failed}

# Custom Types
@type provider :: :github | :gitlab | :bitbucket
```

## Components

### Integrations.Integration

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema storing OAuth connection with encrypted access/refresh tokens, provider metadata, granted scopes, and token expiration timestamp. Scoped by user_id with unique constraint on (user_id, provider).

### Integrations.IntegrationRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Data access layer for Integration CRUD operations filtered by user_id with specialized queries for token retrieval and expiration checking.

### Integrations.Providers.GitHub

| field | value |
| ----- | ----- |
| type  | other |

GitHub provider implementation providing Assent strategy configuration, GitHub-specific OAuth scopes, and user data normalization to application domain model.

### Integrations.Providers.Behaviour

| field | value |
| ----- | ----- |
| type  | other |

Behaviour defining provider contract: configuration for Assent strategies, strategy module selection, and normalization of provider user data to application schema.

### Integrations.ProviderRegistry

| field | value    |
| ----- | -------- |
| type  | registry |

Registry mapping provider atoms to implementation modules and validating provider support at runtime.

## Dependencies
- Users

## Access Patterns
- Integrations scoped by user_id foreign key
- Unique constraint on (user_id, provider) ensures one integration per provider per user
- Queries filter by scope.user.id to ensure users only access their own tokens
- Token retrieval automatically checks expiration and refreshes if needed

## Execution Flow

### OAuth Authorization Flow
1. **Validate Provider**: Check provider exists in ProviderRegistry
2. **Get Provider Module**: Lookup implementation module (e.g., `Integrations.Providers.GitHub`)
3. **Get Configuration**: Call `provider.config()` to retrieve Assent strategy configuration
4. **Get Strategy**: Call `provider.strategy()` to get Assent strategy module
5. **Generate Authorization URL**: Call `strategy.authorize_url(config)` to generate URL and session_params
6. **Store Session Params**: Save session_params in user session for CSRF protection (5-minute expiration)
7. **Return URL**: Context returns authorization URL for redirect
8. **User Authorization**: User grants/denies permissions on provider's authorization page

### OAuth Callback Flow
1. **Get Provider Module**: Lookup implementation for requested provider
2. **Get Configuration**: Call `provider.config()` and merge session_params from session
3. **Get Strategy**: Call `provider.strategy()` to get Assent strategy module
4. **Exchange Code**: Call `strategy.callback(config, params)` to exchange authorization code for tokens
5. **Normalize User Data**: Call `provider.normalize_user(assent_user)` to transform to application schema
6. **Encrypt Tokens**: Encrypt access_token and refresh_token using Cloak before storage
7. **Create/Update Integration**: Upsert Integration record with user_id, provider, encrypted tokens, normalized metadata
8. **Broadcast Event**: Publish integration connected event via PubSub for UI updates

### Token Retrieval with Auto-Refresh
1. **Scope Validation**: Extract user_id from scope
2. **Lookup Integration**: Query Integration by user_id and provider
3. **Check Connection**: Return `{:error, :not_connected}` if no integration exists
4. **Validate Expiration**: Compare expires_at timestamp with current time
5. **Refresh if Expired**: If expired, call `refresh_token/2` to get fresh token
6. **Decrypt Token**: Decrypt access_token from database using Cloak
7. **Return Token**: Provide decrypted token to calling context

### Token Refresh Flow
1. **Load Integration**: Fetch Integration record by user_id and provider
2. **Validate Refresh Token**: Verify refresh_token exists (some providers don't provide them)
3. **Get Provider Module**: Lookup implementation for provider
4. **Get Configuration**: Call `provider.config()` to retrieve Assent strategy configuration
5. **Get Strategy**: Call `provider.strategy()` to get Assent strategy module
6. **Decrypt Refresh Token**: Decrypt refresh_token from database using Cloak
7. **Request New Token**: Call `strategy.refresh_token(config, refresh_token)` via Assent
8. **Update Record**: Encrypt and store new access_token with updated expires_at timestamp
9. **Handle Failure**: Return error if refresh fails, requiring user re-authorization
10. **Return Token**: Provide fresh decrypted token to caller

### Disconnection Flow
1. **Load Integration**: Fetch Integration record by user_id and provider
2. **Delete Integration**: Remove Integration record from database
3. **Broadcast Event**: Publish disconnection event for UI updates

Note: Token revocation on the provider side is not implemented in the initial version. Deleted tokens will expire naturally per provider's token lifetime policy.

## State Management Strategy

### Persistence
- Single `integrations` table with user_id and provider columns (unique constraint)
- Cloak library encrypts access_token and refresh_token fields at rest
- expires_at timestamp enables expiration detection without decryption
- provider_metadata JSONB field stores normalized user data (provider_user_id, username, email, avatar_url, etc.)
- OAuth session_params stored in Phoenix session with 5-minute TTL for CSRF protection

### Token Security
- Access and refresh tokens encrypted using Cloak.Ecto.Binary with application vault
- Tokens never logged or exposed in error messages
- API calls use HTTPS with Authorization header
- Assent's session_params mechanism prevents CSRF attacks during OAuth flow
- Unique constraint on (user_id, provider) prevents duplicate integrations

### Token Refresh Strategy
- On-demand refresh when `get_token/2` detects expiration
- No background GenServer process monitoring expiration
- Refresh synchronously blocks retrieval to ensure valid token returned
- Failed refresh returns error requiring user re-authorization

### Provider Extensibility
- Provider implementations namespaced under `Integrations.Providers.*`
- Each provider implements `Integrations.Providers.Behaviour` with three callbacks:
  - `config/0` - Returns Assent strategy configuration (client_id, client_secret, redirect_uri, scopes)
  - `strategy/0` - Returns Assent strategy module (e.g., `Assent.Strategy.Github`)
  - `normalize_user/1` - Transforms provider user data to application domain model
- ProviderRegistry maps atoms to modules: `%{github: Integrations.Providers.GitHub}`
- Adding new provider requires: behaviour implementation, registry entry, environment configuration
- Leverages Assent's built-in strategies for OAuth mechanics (authorize_url, callback, refresh_token)
