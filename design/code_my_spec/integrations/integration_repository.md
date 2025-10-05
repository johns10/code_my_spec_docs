# IntegrationRepository

## Purpose

Provides data access functions for Integration entities with proper user scoping, encryption/decryption of OAuth tokens, and specialized queries for token retrieval and expiration checking. Ensures all operations are filtered by user_id to maintain security boundaries and prevent unauthorized access to OAuth credentials.

## Public API

```elixir
# Basic CRUD Operations
@spec get_integration(Scope.t(), provider :: provider()) :: {:ok, Integration.t()} | {:error, :not_found}
@spec list_integrations(Scope.t()) :: [Integration.t()]
@spec create_integration(Scope.t(), attrs :: integration_attrs()) :: {:ok, Integration.t()} | {:error, Changeset.t()}
@spec update_integration(Scope.t(), provider :: provider(), attrs :: integration_attrs()) :: {:ok, Integration.t()} | {:error, :not_found | Changeset.t()}
@spec delete_integration(Scope.t(), provider :: provider()) :: {:ok, Integration.t()} | {:error, :not_found}

# Query Builders
@spec by_provider(Scope.t(), provider :: provider()) :: {:ok, Integration.t()} | {:error, :not_found}
@spec with_expired_tokens(Scope.t()) :: [Integration.t()]

# Specialized Operations
@spec upsert_integration(Scope.t(), provider :: provider(), attrs :: integration_attrs()) :: {:ok, Integration.t()} | {:error, Changeset.t()}
@spec connected?(Scope.t(), provider :: provider()) :: boolean()
```

## Function Descriptions

### Basic CRUD Operations

**`get_integration/2`** - Retrieves a single integration for the scoped user and provider. Returns `{:error, :not_found}` if no integration exists.

**`list_integrations/1`** - Returns all integrations for the scoped user, ordered by most recently created.

**`create_integration/2`** - Creates a new integration with encrypted tokens. Validates provider is supported and enforces unique constraint on (user_id, provider).

**`update_integration/3`** - Updates an existing integration with new attributes. Commonly used for token refresh operations. Returns `{:error, :not_found}` if integration doesn't exist for scoped user.

**`delete_integration/2`** - Removes an integration and all associated encrypted tokens for the scoped user and provider.

### Query Builders

**`by_provider/2`** - Alias for `get_integration/2`, provides semantic clarity when querying by provider.

**`with_expired_tokens/1`** - Returns all integrations for the scoped user where expires_at is less than the current timestamp. Used to identify integrations requiring token refresh.

### Specialized Operations

**`upsert_integration/3`** - Creates or updates an integration based on unique constraint (user_id, provider). Used during OAuth callback to handle both first-time connections and reconnections.

**`connected?/2`** - Returns true if an integration exists for the scoped user and provider, false otherwise. Efficient check without loading full integration record.

## Error Handling

### Standard Error Patterns

- `{:error, :not_found}` - Integration doesn't exist for scoped user and provider
- `{:error, changeset}` - Validation failures (invalid provider, missing required fields, constraint violations)
- `{:error, :invalid_scope}` - Scope missing required user_id

### Validation Errors

Changesets may contain errors for:
- `provider` - Not in supported provider list
- `access_token` - Required field missing
- `user_id, provider` - Unique constraint violation (duplicate integration)

## Usage Patterns

### Architecture Integration

All repository functions accept a `Scope.t()` struct as the first parameter, extracting `user_id` to filter queries. This ensures users can only access their own integrations without explicit authorization checks at the context layer.

## Execution Flow

### Get Integration with Scope Filtering

1. **Extract User ID**: Retrieve user_id from scope.user.id
2. **Query Database**: Filter integrations where user_id = scope user AND provider = requested provider
3. **Return Result**: Return `{:ok, integration}` if found, `{:error, :not_found}` otherwise
4. **Decrypt Tokens**: Cloak automatically decrypts access_token and refresh_token fields when loading from database

### Upsert Integration

1. **Extract User ID**: Retrieve user_id from scope.user.id
2. **Build Changeset**: Merge attrs with user_id and validate required fields
3. **Encrypt Tokens**: Cloak encrypts access_token and refresh_token before persistence
4. **Execute Upsert**: Use `on_conflict: :replace_all` with conflict_target `[:user_id, :provider]`
5. **Return Result**: Return `{:ok, integration}` with decrypted tokens or `{:error, changeset}`

### Check Expiration

1. **Query with Timestamp**: Filter integrations where user_id = scope user AND expires_at < DateTime.utc_now()
2. **Return List**: Return all expired integrations without decrypting tokens (expires_at is unencrypted)
3. **Context Handles Refresh**: Context layer iterates results and calls refresh_token for each

## Dependencies

- CodeMySpec.Scope
- CodeMySpec.Integrations.Integration