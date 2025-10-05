# Integrations.Integration

## Purpose

Represents OAuth integration connections between users and external service providers (GitHub, GitLab, Bitbucket), storing encrypted access and refresh tokens with automatic expiration tracking. Each integration maintains provider-specific metadata and granted scopes while ensuring one connection per provider per user.

## Fields

| Field             | Type             | Required | Description                   | Constraints                                                               |
| ----------------- | ---------------- | -------- | ----------------------------- | ------------------------------------------------------------------------- |
| id                | binary_id        | Yes      | Primary key                   | UUID, auto-generated                                                      |
| user_id           | binary_id        | Yes      | Foreign key to users table    | References users.id                                                       |
| provider          | enum             | Yes      | OAuth provider identifier     | One of: :github, :gitlab, :bitbucket                                      |
| access_token      | binary           | Yes      | Encrypted OAuth access token  | Encrypted via Cloak.Ecto.Binary                                           |
| refresh_token     | binary           | No       | Encrypted OAuth refresh token | Encrypted via Cloak.Ecto.Binary, may be nil for providers without refresh |
| expires_at        | utc_datetime     | Yes      | Token expiration timestamp    | UTC datetime for expiration checking                                      |
| granted_scopes    | array of strings | No       | List of OAuth scopes granted  | Array of scope strings (e.g., ["repo", "user:email"])                     |
| provider_metadata | map              | No       | Provider-specific user data   | JSONB field storing provider user_id, username, avatar_url, etc.          |
| inserted_at       | utc_datetime     | Yes      | Record creation timestamp     | UTC datetime, auto-generated                                              |
| updated_at        | utc_datetime     | Yes      | Record last update timestamp  | UTC datetime, auto-updated                                                |

## Associations

### belongs_to
- **user** - References users.id with on_delete: :delete_all to cascade integration deletion when user is removed

## Validation Rules

### User and Provider
- user_id required
- provider required
- provider must be one of the supported providers (:github)

### Token Fields
- access_token required (encrypted before storage)
- refresh_token optional (some providers may not issue refresh tokens)
- expires_at required to enable automatic refresh detection

### Scopes and Metadata
- granted_scopes optional array
- provider_metadata optional map with provider-specific validation

### Composite Uniqueness
- Unique constraint on (user_id, provider) ensures single integration per provider per user

## Database Constraints

### Indexes
- Primary key on id (UUID)
- Index on user_id for fast integration lookups by user
- Composite unique index on (user_id, provider) for scoped provider uniqueness

### Unique Constraints
- Unique constraint on (user_id, provider) prevents duplicate integrations

### Foreign Keys
- user_id references users.id, on_delete: :delete_all cascades deletion when user removed

## Security Considerations

### Token Encryption
- access_token and refresh_token fields use Cloak.Ecto.Binary for at-rest encryption
- Tokens automatically encrypted on write and decrypted on read via Ecto
- Application vault key required for encryption/decryption operations
- Tokens never exposed in logs or error messages

### Token Refresh Strategy
- expires_at timestamp enables expiration detection without decrypting tokens
- On-demand synchronous refresh when get_token/2 detects expiration
- No background processes monitoring expiration to reduce complexity
- Failed refresh requires user re-authorization through OAuth flow

## State Transitions

### Provider Field Values
- **:github** - GitHub OAuth integration
- **:gitlab** - GitLab OAuth integration
- **:bitbucket** - Bitbucket OAuth integration

New providers added by extending the enum and implementing the Providers.Behaviour

## Business Rules

### One Integration Per Provider
- Unique constraint (user_id, provider) ensures users can only have one active connection per provider
- Reconnecting to same provider updates existing integration record via upsert

### Automatic Token Refresh
- Token retrieval checks expires_at against current time
- Expired tokens trigger synchronous refresh using refresh_token
- Refresh updates access_token and expires_at in single transaction
- Missing or invalid refresh_token returns error requiring re-authorization

### Provider Metadata Storage
- provider_metadata JSONB field stores flexible provider-specific data
- Typical fields: provider_user_id, username, avatar_url, email
- Structure varies by provider implementation
- Used for display and provider-specific operations

### Scope Management
- granted_scopes stored as array of strings
- Reflects actual scopes granted by user (may differ from requested)
- Used to determine integration capabilities
- Changing scopes requires full re-authorization flow