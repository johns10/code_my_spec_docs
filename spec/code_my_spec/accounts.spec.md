# CodeMySpec.Accounts

The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

## Dependencies

- CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.MembersRepository
- CodeMySpec.Authorization
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Functions

### subscribe_account/1

Subscribes to scoped notifications about account changes for the user.

```elixir
@spec subscribe_account(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract user ID from scope
2. Subscribe to Phoenix.PubSub topic "user:#{user_id}:account"

**Test Assertions**:
- returns :ok when subscription succeeds
- user receives {:created, account} broadcast when account created
- user receives {:updated, account} broadcast when account updated
- user receives {:deleted, account} broadcast when account deleted

### subscribe_member/1

Subscribes to scoped notifications about member changes for the user.

```elixir
@spec subscribe_member(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract user ID from scope
2. Subscribe to Phoenix.PubSub topic "user:#{user_id}:member"

**Test Assertions**:
- returns :ok when subscription succeeds
- user receives {:created, member} broadcast when member added
- user receives {:updated, member} broadcast when member role updated
- user receives {:deleted, member} broadcast when member removed

### list_accounts/1

Returns the list of accounts the user is a member of.

```elixir
@spec list_accounts(Scope.t()) :: [Account.t()]
```

**Process**:
1. Extract user ID from scope
2. Delegate to MembersRepository.list_user_accounts/1
3. Return list of accounts with user membership

**Test Assertions**:
- returns user's accounts when they have memberships
- returns empty list when user has no accounts
- only returns accounts where user is a member

### get_account/2

Gets a single account if the user has access.

```elixir
@spec get_account(Scope.t(), integer()) :: Account.t() | nil
```

**Process**:
1. Retrieve account from AccountsRepository.get_account/1
2. Return nil if account doesn't exist
3. Check authorization with Authorization.authorize/3 for :read_account
4. Return account if authorized, nil otherwise

**Test Assertions**:
- returns account when user has access
- returns nil when account doesn't exist
- returns nil when user lacks access permission

### get_account!/2

Gets a single account if the user has access, raises otherwise.

```elixir
@spec get_account!(Scope.t(), integer()) :: Account.t()
```

**Process**:
1. Retrieve account from AccountsRepository.get_account!/1
2. Verify authorization with Authorization.authorize!/3 for :read_account
3. Return account if authorized

**Test Assertions**:
- returns account when user has access
- raises Ecto.NoResultsError when account doesn't exist
- raises error when user lacks access permission

### create_account/2

Creates an account with the provided attributes.

```elixir
@spec create_account(Scope.t(), map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delegate to AccountsRepository.create_account/1
2. Broadcast {:created, account} message on success
3. Return result tuple

**Test Assertions**:
- creates account with valid attributes
- broadcasts {:created, account} message to subscribers
- returns error changeset with invalid attributes
- validates required fields

### create_personal_account/1

Creates a personal account for the user.

```elixir
@spec create_personal_account(Scope.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Extract user ID from scope
2. Delegate to AccountsRepository.create_personal_account/1
3. Broadcast {:created, account} message on success
4. Return result tuple

**Test Assertions**:
- creates personal account for user
- account type is :personal
- user is automatically set as owner
- broadcasts {:created, account} message to subscribers

### create_team_account/2

Creates a team account with the user as owner.

```elixir
@spec create_team_account(Scope.t(), map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Extract user ID from scope
2. Delegate to AccountsRepository.create_team_account/2
3. Broadcast {:created, account} message on success
4. Return result tuple

**Test Assertions**:
- creates team account with valid attributes
- account type is :team
- user is automatically set as owner
- broadcasts {:created, account} message to subscribers
- validates slug format for team accounts

### update_account/3

Updates an account if the user has management permissions.

```elixir
@spec update_account(Scope.t(), Account.t(), map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_account
2. Delegate to AccountsRepository.update_account/2
3. Broadcast {:updated, account} message on success
4. Return result tuple

**Test Assertions**:
- updates account with valid attributes
- broadcasts {:updated, account} message to subscribers
- returns error changeset with invalid attributes
- raises when user lacks management permission
- validates changed fields

### delete_account/2

Deletes an account if the user has management permissions.

```elixir
@spec delete_account(Scope.t(), Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_account
2. Delegate to AccountsRepository.delete_account/1
3. Broadcast {:deleted, account} message on success
4. Return result tuple

**Test Assertions**:
- deletes account when user has permission
- broadcasts {:deleted, account} message to subscribers
- raises when user lacks management permission
- cascades deletion to associated members

### change_account/3

Returns a changeset for tracking account changes.

```elixir
@spec change_account(Scope.t(), Account.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_account
2. Call Account.changeset/2 with account and attributes
3. Return changeset

**Test Assertions**:
- returns changeset for account
- includes changes when attributes provided
- raises when user lacks management permission
- changeset tracks field changes

### get_personal_account/1

Gets the user's personal account.

```elixir
@spec get_personal_account(Scope.t()) :: Account.t() | nil
```

**Process**:
1. Extract user ID from scope
2. Delegate to AccountsRepository.get_personal_account/1
3. Return account or nil

**Test Assertions**:
- returns personal account for user
- returns nil when user has no personal account
- only returns personal type account

### ensure_personal_account/1

Ensures the user has a personal account, creating one if needed.

```elixir
@spec ensure_personal_account(Scope.t()) :: Account.t()
```

**Process**:
1. Extract user ID from scope
2. Delegate to AccountsRepository.ensure_personal_account/1
3. Return existing or newly created account

**Test Assertions**:
- returns existing personal account when present
- creates new personal account when none exists
- idempotent operation returns same account

### list_account_members/2

Lists all members of an account if the user has read access.

```elixir
@spec list_account_members(Scope.t(), integer()) :: [Member.t()]
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :read_account
2. Delegate to MembersRepository.list_account_members/1
3. Return list of members with preloaded users

**Test Assertions**:
- returns account members when user has access
- preloads user associations
- raises when user lacks read permission
- returns empty list for account with no members

### add_user_to_account/4

Adds a user to an account with specified role (defaults to :member).

```elixir
@spec add_user_to_account(Scope.t(), integer(), integer(), atom()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_account
2. Delegate to MembersRepository.add_user_to_account/3
3. Broadcast {:created, member} message on success
4. Return result tuple

**Test Assertions**:
- adds user to account with default :member role
- adds user with specified role when provided
- broadcasts {:created, member} message to subscribers
- raises when user lacks management permission
- validates role is valid enum value
- prevents duplicate memberships

### remove_user_from_account/3

Removes a user from an account.

```elixir
@spec remove_user_from_account(Scope.t(), integer(), integer()) :: {:ok, Member.t()} | {:error, term()}
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_members
2. Delegate to MembersRepository.remove_user_from_account/2
3. Broadcast {:deleted, member} message on success
4. Return result tuple

**Test Assertions**:
- removes user from account when permitted
- broadcasts {:deleted, member} message to subscribers
- raises when user lacks member management permission
- prevents removal of last owner
- returns error when member not found

### update_user_role/4

Updates a user's role in an account.

```elixir
@spec update_user_role(Scope.t(), integer(), integer(), atom()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :manage_members
2. Delegate to MembersRepository.update_user_role/3
3. Broadcast {:updated, member} message on success
4. Return result tuple

**Test Assertions**:
- updates user role when permitted
- broadcasts {:updated, member} message to subscribers
- raises when user lacks member management permission
- prevents downgrading last owner
- validates role is valid enum value

### get_user_role/3

Gets a user's role in an account.

```elixir
@spec get_user_role(Scope.t(), integer(), integer()) :: atom() | nil
```

**Process**:
1. Verify authorization with Authorization.authorize!/3 for :read_account
2. Delegate to MembersRepository.get_user_role/2
3. Return role atom or nil

**Test Assertions**:
- returns user role when user is member
- returns nil when user has no role in account
- raises when user lacks read permission
- returns correct role enum value

### user_has_account_access?/2

Checks if a user has access to an account.

```elixir
@spec user_has_account_access?(Scope.t(), integer()) :: boolean()
```

**Process**:
1. Extract user ID from scope
2. Delegate to MembersRepository.user_has_account_access?/2
3. Return boolean result

**Test Assertions**:
- returns true when user is member of account
- returns false when user has no membership
- works for all role types

## Components

### CodeMySpec.Accounts.Account

Ecto schema for account entities with personal and team types, slug generation, and membership associations.

### CodeMySpec.Accounts.AccountsRepository

Data access layer for account entities, handling personal and team account creation, basic CRUD operations, and query building within the multi-tenant architecture.

### CodeMySpec.Accounts.Member

Ecto schema managing many-to-many relationship between accounts and users with role-based permissions (owner, admin, member) and business rule validation.

### CodeMySpec.Accounts.MembersRepository

Data access layer for account membership relationships, handling user addition/removal, role management, and access control queries within the multi-tenant architecture.