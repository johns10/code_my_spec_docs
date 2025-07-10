---
type: "repository_design"
---

# Members Repository Design

## Purpose
Provides data access layer for account membership relationships, handling user addition/removal, role management, and access control within the multi-tenant architecture.

## Core Operations/Public API

### Membership Management
```elixir
@spec add_user_to_account(user_id :: integer(), account_id :: integer(), role :: account_role()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t() | :user_limit_exceeded}
@spec remove_user_from_account(user_id :: integer(), account_id :: integer()) :: {:ok, Member.t()} | {:error, :not_found}
@spec update_user_role(user_id :: integer(), account_id :: integer(), role :: account_role()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
@spec get_user_role(user_id :: integer(), account_id :: integer()) :: account_role() | nil
```

### Access Control
```elixir
@spec user_has_account_access?(user_id :: integer(), account_id :: integer()) :: boolean()
@spec can_add_user_to_account?(account_id :: integer()) :: boolean()
@spec count_account_users(account_id :: integer()) :: non_neg_integer()
```

### List Operations
```elixir
@spec list_user_accounts(user_id :: integer()) :: [Account.t()]
@spec list_account_users(account_id :: integer()) :: [User.t()]
@spec list_accounts_with_role(user_id :: integer(), role :: account_role()) :: [Account.t()]
```

### Query Builders
```elixir
@spec by_user(user_id :: integer()) :: Ecto.Query.t()
@spec by_account(account_id :: integer()) :: Ecto.Query.t()
@spec by_role(role :: account_role()) :: Ecto.Query.t()
@spec with_user_preloads() :: Ecto.Query.t()
@spec with_account_preloads() :: Ecto.Query.t()
```

## Function Descriptions

### Membership Functions
- `add_user_to_account/3` - Adds user to account with specified role, checks user limits and validates permissions
- `remove_user_from_account/2` - Removes user from account, prevents removal of last owner from team accounts
- `update_user_role/3` - Changes user's role in account, validates role hierarchy and permissions
- `get_user_role/2` - Returns user's role in specific account

### Access Control Functions
- `user_has_account_access?/2` - Checks if user has any role in account
- `can_add_user_to_account?/1` - Validates if account can accept new members based on limits
- `count_account_users/1` - Returns total member count for account

### List Functions
- `list_user_accounts/1` - Returns all accounts where user is a member
- `list_account_users/1` - Returns all users who are members of account
- `list_accounts_with_role/2` - Returns accounts where user has specific role

### Query Functions
- `by_user/1` - Filters memberships by user ID
- `by_account/1` - Filters memberships by account ID
- `by_role/1` - Filters memberships by role
- `with_user_preloads/0` - Preloads user data for membership queries
- `with_account_preloads/0` - Preloads account data for membership queries

## Error Handling

### Validation Errors
- `{:error, changeset}` - Invalid role assignment, validation failures
- `{:error, :user_limit_exceeded}` - Account has reached maximum user limit
- `{:error, :invalid_role}` - Invalid role assignment or hierarchy violation

### Not Found Errors
- `{:error, :not_found}` - User, account, or membership relationship not found
- `nil` - Query functions return nil for missing entities

### Constraint Errors
- `{:error, :last_owner}` - Cannot remove last owner from team account
- `{:error, :duplicate_membership}` - User already member of account

## Transaction Patterns

### Role Transfer
```elixir
Repo.transaction(fn ->
  with {:ok, _} <- update_user_role(old_owner_id, account_id, :admin),
       {:ok, _} <- update_user_role(new_owner_id, account_id, :owner) do
    :ok
  else
    {:error, reason} -> Repo.rollback(reason)
  end
end)
```

### Bulk Member Addition
```elixir
Repo.transaction(fn ->
  user_ids
  |> Enum.reduce_while({:ok, []}, fn user_id, {:ok, acc} ->
    case add_user_to_account(user_id, account_id, :member) do
      {:ok, membership} -> {:cont, {:ok, [membership | acc]}}
      {:error, reason} -> {:halt, {:error, reason}}
    end
  end)
  |> case do
    {:ok, memberships} -> {:ok, Enum.reverse(memberships)}
    {:error, reason} -> Repo.rollback(reason)
  end
end)
```

## Usage Patterns

### Architecture Integration
Repository integrates with Accounts context for membership management. Works alongside Accounts repository and coordinates with Users and Billing contexts for complete functionality.

### Common Query Patterns
```elixir
# Get user's accounts with roles
Member
|> by_user(user_id)
|> with_account_preloads()
|> Repo.all()

# Get team accounts where user is owner
Member
|> by_user(user_id)
|> by_role(:owner)
|> with_account_preloads()
|> where([m, a], a.type == :team)
|> Repo.all()

# Get account members with user data
Member
|> by_account(account_id)
|> with_user_preloads()
|> Repo.all()
```

### Performance Considerations
- Use `with_user_preloads/0` and `with_account_preloads/0` for efficient data loading
- Index on `members.user_id`, `members.account_id`, and `members.role` for fast queries
- Preload strategies prevent N+1 queries when accessing related data

## Dependencies
- **Ecto.Repo** - Database operations and transactions
- **Member schema** - Membership join table with role information
- **Account schema** - Account entity for membership relationships
- **Users schema** - User entity for membership relationships
- **Billing context** - User limit validation (when implemented)

## Type Definitions
```elixir
@type account_role :: :owner | :admin | :member
```