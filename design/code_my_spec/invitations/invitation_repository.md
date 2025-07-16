---
type: "repository_design"
---

# Invitations Repository Design

## Purpose
Provides data access layer for invitation entities, handling invitation creation, token management, status tracking, and scoped queries within the multi-tenant architecture.

## Core Operations/Public API

### Basic CRUD Operations
```elixir
@spec create_invitation(scope :: Scope.t(), attrs :: invitation_attrs()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
@spec get_invitation(scope :: Scope.t(), id :: integer()) :: Invitation.t() | nil
@spec get_invitation!(scope :: Scope.t(), id :: integer()) :: Invitation.t()
@spec update_invitation(scope :: Scope.t(), Invitation.t(), attrs :: map()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
@spec delete_invitation(scope :: Scope.t(), Invitation.t()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
```

### Token Operations
```elixir
@spec get_invitation_by_token(token :: String.t()) :: Invitation.t() | nil
@spec generate_invitation_token() :: String.t()
@spec validate_token_format(token :: String.t()) :: boolean()
@spec token_exists?(token :: String.t()) :: boolean()
```

### Status Management
```elixir
@spec mark_invitation_accepted(scope :: Scope.t(), Invitation.t()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
@spec mark_invitation_expired(scope :: Scope.t(), Invitation.t()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
@spec mark_invitation_cancelled(scope :: Scope.t(), Invitation.t()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
```

### Query Builders
```elixir
@spec by_email(email :: String.t()) :: Ecto.Query.t()
@spec by_status(status :: invitation_status()) :: Ecto.Query.t()
@spec by_account(account_id :: integer()) :: Ecto.Query.t()
@spec pending_and_not_expired() :: Ecto.Query.t()
@spec expired() :: Ecto.Query.t()
```

### Bulk Operations
```elixir
@spec mark_expired_invitations() :: {integer(), nil}
@spec cleanup_expired_invitations(days_old :: integer()) :: {integer(), nil}
@spec count_pending_invitations(scope :: Scope.t()) :: integer()
```

## Function Descriptions

### Invitation Creation Functions
- `create_invitation/2` - Creates invitation within account scope with auto-generated token and expiration, validates email uniqueness per account
- `generate_invitation_token/0` - Creates cryptographically secure 32-character token using Phoenix.Token patterns
- `validate_token_format/1` - Validates token is proper format and length before database queries

### Query Functions
- `get_invitation_by_token/1` - Token-based lookup for public invitation acceptance, no scoping required
- `by_email/1` - Finds invitations by email address within account scope
- `by_status/1` - Returns query filtered by invitation status (pending, accepted, expired, cancelled)
- `pending_and_not_expired/0` - Query for active invitations that can still be accepted
- `expired/0` - Query for invitations past expiration date for cleanup operations

### Status Management Functions
- `mark_invitation_accepted/2` - Updates status to accepted with timestamp, validates scope ownership
- `mark_invitation_expired/2` - Updates status to expired, used for manual expiration
- `mark_invitation_cancelled/2` - Updates status to cancelled, validates user permissions

## Error Handling

### Validation Errors
- `{:error, changeset}` - Invalid invitation attributes, email format errors, role validation failures
- `{:error, :user_already_member}` - Email already has account access
- `{:error, :duplicate_invitation}` - Pending invitation already exists for email/account combination

### Authorization Errors
- `{:error, :not_authorized}` - Invitation doesn't belong to scoped account
- `{:error, :insufficient_permissions}` - User lacks permission to manage invitations

### Token Errors
- `{:error, :invalid_token}` - Token doesn't exist or malformed
- `{:error, :expired_token}` - Token has passed expiration date

## Transaction Patterns

### Invitation Creation with Email Delivery
```elixir
Repo.transaction(fn ->
  with {:ok, invitation} <- create_invitation(scope, attrs),
       {:ok, _email} <- InvitationNotifier.deliver_invitation_email(invitation, url) do
    {:ok, invitation}
  else
    {:error, reason} -> Repo.rollback(reason)
  end
end)
```

### Invitation Acceptance with User Creation
```elixir
Repo.transaction(fn ->
  with {:ok, invitation} <- get_invitation_by_token(token),
       {:ok, user} <- Users.register_user(user_attrs),
       {:ok, _member} <- Accounts.add_user_to_account(user.id, invitation.account_id, invitation.role),
       {:ok, invitation} <- mark_invitation_accepted(scope, invitation) do
    {:ok, {user, invitation}}
  else
    {:error, reason} -> Repo.rollback(reason)
  end
end)
```

## Usage Patterns

### Architecture Integration
Repository integrates with Invitations context as primary data access layer for invitation entities. Uses Phoenix scopes for automatic account-based filtering and security boundaries.

### Common Query Patterns
```elixir
# Get pending invitations for account
Invitation
|> by_account(account_id)
|> by_status(:pending)
|> pending_and_not_expired()
|> Repo.all()

# Find user's invitations across accounts
Invitation
|> by_email("user@example.com")
|> by_status(:pending)
|> Repo.all()
```

### Performance Considerations
- Index on `invitations.token` for fast token lookups
- Composite index on `invitations.email, invitations.account_id` for duplicate prevention
- Index on `invitations.expires_at` for efficient cleanup operations
- Use bulk operations for system-wide maintenance tasks

## Dependencies
- **Ecto.Repo** - Database operations and transactions
- **Invitation schema** - Invitation entity structure and validations
- **Account schema** - Account entity for invitation association
- **User schema** - User entity for invitation creation tracking
- **UserSettings.Scope** - Account scoping and security boundaries
- **Phoenix.Token** - Secure token generation utilities

## Type Definitions
```elixir
@type invitation_attrs :: %{
  email: String.t(),
  role: account_role(),
  account_id: integer(),
  invited_by_id: integer()
}
@type invitation_status :: :pending | :accepted | :expired | :cancelled
@type account_role :: :owner | :admin | :member
```