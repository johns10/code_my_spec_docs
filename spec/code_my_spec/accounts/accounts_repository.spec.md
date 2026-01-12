# CodeMySpec.Accounts.AccountsRepository

Data access layer for account entities, handling personal and team account creation, basic account operations, and query building within the multi-tenant architecture.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.Member
- CodeMySpec.Users.User
- Ecto.Query

## Functions

### create_account/1

Creates a new account with the provided attributes.

```elixir
@spec create_account(attrs :: account_attrs()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Create a new Account struct
2. Apply the changeset with provided attributes
3. Insert into the database via Repo

**Test Assertions**:
- creates an account with valid attributes
- returns error with invalid attributes (nil name)
- returns error with duplicate slug
- returns error with reserved slug

### get_account/1

Retrieves an account by its ID.

```elixir
@spec get_account(id :: integer()) :: Account.t() | nil
```

**Process**:
1. Query the database for an account with the given ID
2. Return the account or nil if not found

**Test Assertions**:
- returns account when it exists
- returns nil when account doesn't exist

### get_account!/1

Retrieves an account by its ID, raising if not found.

```elixir
@spec get_account!(id :: integer()) :: Account.t()
```

**Process**:
1. Query the database for an account with the given ID
2. Return the account or raise Ecto.NoResultsError if not found

**Test Assertions**:
- returns account when it exists
- raises when account doesn't exist

### update_account/2

Updates an existing account with the provided attributes.

```elixir
@spec update_account(Account.t(), attrs :: map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply the changeset to the existing account with new attributes
2. Update the record in the database via Repo

**Test Assertions**:
- updates account with valid attributes
- returns error with invalid attributes (empty name)
- returns error with duplicate slug

### delete_account/1

Deletes an existing account.

```elixir
@spec delete_account(Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delete the account record from the database via Repo
2. Associated members are deleted via cascade

**Test Assertions**:
- deletes account
- deletes account with associated members (cascade)

### create_personal_account/1

Creates a personal account for a user, extracting the account name from their email.

```elixir
@spec create_personal_account(user_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Fetch the user by ID (raises if not found)
2. Extract the name from the user's email (part before @)
3. Generate a slug by lowercasing and replacing non-alphanumeric characters with hyphens
4. Begin a database transaction
5. Create the account with type :personal
6. Create a member record linking the user as owner
7. Return the created account or rollback on error

**Test Assertions**:
- creates personal account for user
- extracts name from email
- returns error when user doesn't exist (raises Ecto.NoResultsError)

### create_team_account/2

Creates a team account with the provided attributes and assigns the creator as owner.

```elixir
@spec create_team_account(attrs :: map(), creator_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Begin a database transaction
2. Create the account with type :team and provided attributes
3. Create a member record linking the creator as owner
4. Return the created account or rollback on error

**Test Assertions**:
- creates team account with creator as owner
- returns error with invalid attributes

### get_personal_account/1

Retrieves the personal account for a given user.

```elixir
@spec get_personal_account(user_id :: integer()) :: Account.t() | nil
```

**Process**:
1. Build a query joining accounts with members
2. Filter by user_id and account type :personal
3. Return the single matching account or nil

**Test Assertions**:
- returns personal account for user
- returns nil when user only has team accounts
- returns nil when user has no accounts

### ensure_personal_account/1

Gets or creates a personal account for the user.

```elixir
@spec ensure_personal_account(user_id :: integer()) :: Account.t()
```

**Process**:
1. Attempt to get the user's personal account
2. If none exists, create a new personal account
3. Return the existing or newly created account

**Test Assertions**:
- returns existing personal account
- creates new personal account when none exists

### by_slug/1

Returns a query for accounts matching the given slug.

```elixir
@spec by_slug(slug :: String.t()) :: Ecto.Query.t()
```

**Process**:
1. Build an Ecto query filtering accounts by slug

**Test Assertions**:
- returns query for accounts with matching slug
- returns empty result for non-existent slug

### by_type/1

Returns a query for accounts matching the given type.

```elixir
@spec by_type(type :: account_type()) :: Ecto.Query.t()
```

**Process**:
1. Build an Ecto query filtering accounts by type (:personal or :team)

**Test Assertions**:
- returns query for accounts with matching type

### with_preloads/1

Returns a query with the specified associations preloaded.

```elixir
@spec with_preloads(preloads :: [atom()]) :: Ecto.Query.t()
```

**Process**:
1. Build an Ecto query with the specified preloads

**Test Assertions**:
- returns query with specified preloads
- handles multiple preloads