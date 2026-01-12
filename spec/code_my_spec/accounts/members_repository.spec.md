# CodeMySpec.Accounts.MembersRepository

Provides data access layer for account membership relationships, handling user addition/removal, role management, and access control within the multi-tenant architecture.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.Member
- CodeMySpec.Users.User

## Functions

### add_user_to_account/3

Adds a user to an account with an optional role, defaulting to `:member`.

```elixir
@spec add_user_to_account(integer(), integer(), account_role()) ::
        {:ok, Member.t()} | {:error, Ecto.Changeset.t() | :user_limit_exceeded}
```

**Process**:
1. Check if user can be added to account via `can_add_user_to_account?/1`
2. If allowed, create a new Member changeset with user_id, account_id, and role
3. Insert the member record into the database
4. Return `{:ok, member}` on success or `{:error, changeset}` on failure

**Test Assertions**:
- adds user to account with default member role
- adds user to account with specified role
- returns error when user is already member of account
- returns error when user does not exist
- returns error when account does not exist

### remove_user_from_account/2

Removes a user from an account, with protection against removing the last owner.

```elixir
@spec remove_user_from_account(integer(), integer()) ::
        {:ok, Member.t()} | {:error, :not_found}
```

**Process**:
1. Look up the member record by user_id and account_id
2. If not found, return `{:error, :not_found}`
3. If member is an owner, count total owners for the account
4. If owner count > 1, delete the member; otherwise return `{:error, :last_owner}`
5. For non-owner roles, delete the member directly
6. Return `{:ok, deleted_member}` on successful deletion

**Test Assertions**:
- removes user from account successfully
- returns error when user is not member of account
- prevents removal of last owner
- allows removal of owner when multiple owners exist
- allows removal of admin or member regardless of count

### update_user_role/3

Updates a user's role within an account, with validation to ensure at least one owner remains.

```elixir
@spec update_user_role(integer(), integer(), account_role()) ::
        {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Look up the member record by user_id and account_id
2. If not found, return `{:error, :not_found}`
3. Create an update role changeset with the new role
4. Validate that the account will still have at least one owner after the change
5. If valid, update the member; otherwise return `{:error, changeset}`

**Test Assertions**:
- updates user role successfully
- returns error when user is not member of account
- prevents changing last owner role
- allows changing owner role when multiple owners exist
- allows promoting user to owner

### get_user_role/2

Retrieves a user's role within an account.

```elixir
@spec get_user_role(integer(), integer()) :: account_role() | nil
```

**Process**:
1. Look up the member record by user_id and account_id
2. If not found, return `nil`
3. Return the member's role

**Test Assertions**:
- returns user role when user is member of account
- returns nil when user is not member of account

### user_has_account_access?/2

Checks if a user has any membership in an account.

```elixir
@spec user_has_account_access?(integer(), integer()) :: boolean()
```

**Process**:
1. Query for existence of a member record matching user_id and account_id
2. Return true if exists, false otherwise

**Test Assertions**:
- returns true when user has access to account
- returns false when user does not have access to account

### can_add_user_to_account?/1

Checks if an account can accept additional users (placeholder for billing integration).

```elixir
@spec can_add_user_to_account?(integer()) :: true
```

**Process**:
1. Currently always returns true (TODO: Add billing logic)

**Test Assertions**:
- always returns true

### count_account_users/1

Counts the number of users in an account.

```elixir
@spec count_account_users(integer()) :: non_neg_integer()
```

**Process**:
1. Aggregate count of members where account_id matches
2. Return the count

**Test Assertions**:
- returns count of users in account
- returns 0 for account with no users

### list_user_accounts/1

Lists all accounts a user belongs to.

```elixir
@spec list_user_accounts(integer()) :: [Account.t()]
```

**Process**:
1. Query accounts joining with members on account_id
2. Filter where member's user_id matches the provided user_id
3. Return all matching accounts

**Test Assertions**:
- returns accounts for user
- returns empty list for user with no accounts

### list_account_users/1

Lists all users belonging to an account.

```elixir
@spec list_account_users(integer()) :: [User.t()]
```

**Process**:
1. Query users joining with members on user_id
2. Filter where member's account_id matches the provided account_id
3. Return all matching users

**Test Assertions**:
- returns users for account
- returns empty list for account with no users

### list_account_members/1

Lists all members of an account with user data preloaded.

```elixir
@spec list_account_members(integer()) :: [Member.t()]
```

**Process**:
1. Query members where account_id matches
2. Preload user associations
3. Return all matching members with users preloaded

**Test Assertions**:
- returns members for account with users preloaded
- returns empty list for account with no members

### list_accounts_with_role/2

Lists accounts where a user has a specific role.

```elixir
@spec list_accounts_with_role(integer(), account_role()) :: [Account.t()]
```

**Process**:
1. Query accounts joining with members on account_id
2. Filter where member's user_id matches and role matches the specified role
3. Return all matching accounts

**Test Assertions**:
- returns accounts where user has specific role
- returns empty list when user has no accounts with specified role

### by_user/1

Returns a composable query for filtering members by user_id.

```elixir
@spec by_user(integer()) :: Ecto.Query.t()
```

**Process**:
1. Build a query on Member filtered by user_id
2. Return the query for composition

**Test Assertions**:
- returns query for user's memberships

### by_account/1

Returns a composable query for filtering members by account_id.

```elixir
@spec by_account(integer()) :: Ecto.Query.t()
```

**Process**:
1. Build a query on Member filtered by account_id
2. Return the query for composition

**Test Assertions**:
- returns query for account's memberships

### by_role/1

Returns a composable query for filtering members by role.

```elixir
@spec by_role(account_role()) :: Ecto.Query.t()
```

**Process**:
1. Build a query on Member filtered by role
2. Return the query for composition

**Test Assertions**:
- returns query for memberships with specific role

### with_user_preloads/0

Returns a composable query with user associations preloaded.

```elixir
@spec with_user_preloads() :: Ecto.Query.t()
```

**Process**:
1. Build a query on Member with user preloaded
2. Return the query for composition

**Test Assertions**:
- returns query with user preloaded

### with_account_preloads/0

Returns a composable query with account associations preloaded.

```elixir
@spec with_account_preloads() :: Ecto.Query.t()
```

**Process**:
1. Build a query on Member with account preloaded
2. Return the query for composition

**Test Assertions**:
- returns query with account preloaded