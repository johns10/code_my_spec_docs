---
type: "repository_design"
---

# Accounts Repository Design

## Purpose
Provides data access layer for account entities, handling personal and team account creation, basic account operations, and query building within the multi-tenant architecture.

## Core Operations/Public API

### Basic CRUD Operations
```elixir
@spec create_account(attrs :: account_attrs()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec get_account(id :: integer()) :: Account.t() | nil
@spec get_account!(id :: integer()) :: Account.t()
@spec update_account(Account.t(), attrs :: map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec delete_account(Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

### Account Type Management
```elixir
@spec create_personal_account(user_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec create_team_account(attrs :: map(), creator_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec get_personal_account(user_id :: integer()) :: Account.t() | nil
@spec ensure_personal_account(user_id :: integer()) :: {:ok, Account.t()}
```

### Query Builders
```elixir
@spec by_slug(slug :: String.t()) :: Ecto.Query.t()
@spec by_type(type :: account_type()) :: Ecto.Query.t()
@spec with_preloads(preloads :: [atom()]) :: Ecto.Query.t()
```

## Function Descriptions

### Account Creation Functions
- `create_personal_account/1` - Creates personal account with auto-generated slug from user name, coordinates with Members repository to assign owner
- `create_team_account/2` - Creates team account with specified attributes, validates unique slug, coordinates with Members repository to assign creator as owner
- `ensure_personal_account/1` - Gets existing personal account or creates new one, used during user registration

### Query Functions
- `by_slug/1` - Finds account by unique slug identifier for routing
- `by_type/1` - Returns query filtered by account type (personal/team)
- `with_preloads/1` - Adds preloads to query for related data

## Error Handling

### Validation Errors
- `{:error, changeset}` - Invalid account attributes, slug conflicts, validation failures

### Not Found Errors
- `{:error, :not_found}` - Account not found
- `nil` - Query functions return nil for missing entities

### Constraint Errors
- `{:error, :slug_taken}` - Account slug already exists

## Transaction Patterns

### Account Creation with Initial Membership
```elixir
Repo.transaction(fn ->
  with {:ok, account} <- create_account(attrs),
       {:ok, _} <- Members.add_user_to_account(user_id, account.id, :owner) do
    {:ok, account}
  else
    {:error, reason} -> Repo.rollback(reason)
  end
end)
```

## Usage Patterns

### Architecture Integration
Repository integrates with Accounts context as primary data access layer for account entities. Works alongside Members repository for complete account management functionality.

### Common Query Patterns
```elixir
# Get account by slug
Account
|> by_slug("my-team")
|> Repo.one()

# Get team accounts
Account
|> by_type(:team)
|> Repo.all()
```

### Performance Considerations
- Use `with_preloads/1` for efficient data loading
- Index on `accounts.slug` and `accounts.type` for fast queries
- Preload strategies prevent N+1 queries when accessing related data

## Dependencies
- **Ecto.Repo** - Database operations and transactions
- **Account schema** - Account entity structure and validations
- **Member schema** - Membership join table with role information
- **Members repository** - Membership management operations
- **Users schema** - User entity for account creation

## Type Definitions
```elixir
@type account_attrs :: %{
  name: String.t(),
  slug: String.t(),
  type: account_type()
}
@type account_type :: :personal | :team
```