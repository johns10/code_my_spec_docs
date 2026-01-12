# CodeMySpec.Accounts.Member

Ecto schema managing the many-to-many relationship between accounts and users with role-based permissions. Supports a three-tier role hierarchy (owner, admin, member) with business rules ensuring each account maintains at least one owner.

## Fields

| Field       | Type        | Required   | Description                           | Constraints                                   |
| ----------- | ----------- | ---------- | ------------------------------------- | --------------------------------------------- |
| id          | integer     | Yes (auto) | Primary key                           | Auto-generated                                |
| role        | enum        | Yes        | User's role in the account            | Values: [:owner, :admin, :member], Default: :member |
| user_id     | integer     | Yes        | Foreign key to users table            | References users.id                           |
| account_id  | integer     | Yes        | Foreign key to accounts table         | References accounts.id                        |
| user        | association | No         | Associated User record                | belongs_to CodeMySpec.Users.User              |
| account     | association | No         | Associated Account record             | belongs_to CodeMySpec.Accounts.Account        |
| inserted_at | naive_datetime | Yes (auto) | Creation timestamp                 | Auto-generated                                |
| updated_at  | naive_datetime | Yes (auto) | Last modification timestamp        | Auto-generated                                |

## Functions

### changeset/2

Creates a changeset for creating a new member with role, user, and account associations.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the `:role`, `:user_id`, and `:account_id` fields from input attributes
2. Validate that `:role`, `:user_id`, and `:account_id` are required
3. Validate that `:role` is one of [:owner, :admin, :member]
4. Apply association constraint on `:user` to ensure user exists
5. Apply association constraint on `:account` to ensure account exists
6. Apply unique constraint on [:user_id, :account_id] using `members_user_id_account_id_index`

**Test Assertions**:
- returns valid changeset with valid role, user_id, and account_id
- returns invalid changeset when role is missing
- returns invalid changeset when user_id is missing
- returns invalid changeset when account_id is missing
- returns invalid changeset for invalid role values
- accepts :owner as valid role value
- accepts :admin as valid role value
- accepts :member as valid role value
- enforces unique constraint on user_id and account_id combination
- enforces association constraint on user
- enforces association constraint on account

### update_role_changeset/2

Creates a changeset for updating a member's role only.

```elixir
@spec update_role_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast only the `:role` field from input attributes
2. Validate that `:role` is required
3. Validate that `:role` is one of [:owner, :admin, :member]

**Test Assertions**:
- returns valid changeset with valid role
- returns invalid changeset when role is missing
- returns invalid changeset for invalid role values
- does not allow changing user_id
- does not allow changing account_id

### validate_owner_exists/2

Validates that an account maintains at least one owner when demoting the current owner.

```elixir
@spec validate_owner_exists(Ecto.Changeset.t(), module()) :: Ecto.Changeset.t()
```

**Process**:
1. If the new role is :owner, return changeset unchanged (promoting to owner is always valid)
2. Get user_id and account_id from changeset fields
3. If either is nil, return changeset unchanged
4. Query the repository to find the current member record
5. If current member is not an owner, return changeset unchanged
6. Count total owners for the account
7. If owner count is 1 or less, add error "account must have at least one owner"
8. Otherwise return changeset unchanged

**Test Assertions**:
- allows promoting any role to owner
- allows demoting owner when other owners exist
- prevents demoting the last owner to admin
- prevents demoting the last owner to member
- returns changeset unchanged when user_id is nil
- returns changeset unchanged when account_id is nil
- returns changeset unchanged when member is not currently an owner

### has_role?/2

Checks if a member has a specific role or higher in the role hierarchy.

```elixir
@spec has_role?(t(), :owner | :admin | :member) :: boolean()
```

**Process**:
1. Define role hierarchy: member=1, admin=2, owner=3
2. Compare member's role level with required role level
3. Return true if member's role level is greater than or equal to required level

**Test Assertions**:
- returns true when member has exactly the required role
- returns true when member has higher role than required
- returns false when member has lower role than required
- owner has all roles (member, admin, owner)
- admin has member and admin roles but not owner
- member only has member role

### owner?/1

Checks if a member is an owner of the account.

```elixir
@spec owner?(t()) :: boolean()
```

**Process**:
1. Return true if member's role equals :owner, false otherwise

**Test Assertions**:
- returns true for owner role
- returns false for admin role
- returns false for member role

### admin_or_owner?/1

Checks if a member is an admin or owner of the account.

```elixir
@spec admin_or_owner?(t()) :: boolean()
```

**Process**:
1. Return true if member's role is in [:admin, :owner], false otherwise

**Test Assertions**:
- returns true for owner role
- returns true for admin role
- returns false for member role

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Ecto.Query
- CodeMySpec.Users.User
- CodeMySpec.Accounts.Account