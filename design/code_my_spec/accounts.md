# Accounts

## Purpose
Manages multi-tenant account structures and user membership relationships with role-based permissions.

## Entity Ownership
- Account entities (personal and team accounts)
- Account-User membership relationships with role-based permissions
- Account context management for users
- Members role validation and access control

## Public API

```elixir
# Account Management
@spec create_personal_account(user_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec create_team_account(attrs :: map(), creator_id :: integer()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec get_account(id :: integer()) :: Account.t() | nil
@spec get_account!(id :: integer()) :: Account.t()
@spec update_account(Account.t(), attrs :: map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
@spec delete_account(Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}

# Membership Management
@spec add_user_to_account(user_id :: integer(), account_id :: integer(), role :: account_role()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t() | :user_limit_exceeded}
@spec remove_user_from_account(user_id :: integer(), account_id :: integer()) :: {:ok, Member.t()} | {:error, :not_found}
@spec list_user_accounts(user_id :: integer()) :: [Account.t()]
@spec list_account_users(account_id :: integer()) :: [User.t()]
@spec get_user_role(user_id :: integer(), account_id :: integer()) :: account_role() | nil
@spec update_user_role(user_id :: integer(), account_id :: integer(), role :: account_role()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
@spec user_has_account_access?(user_id :: integer(), account_id :: integer()) :: boolean()
@spec can_add_user_to_account?(account_id :: integer()) :: boolean()
@spec count_account_users(account_id :: integer()) :: non_neg_integer()

# Account Context Management
@spec get_personal_account(user_id :: integer()) :: Account.t() | nil
@spec ensure_personal_account(user_id :: integer()) :: {:ok, Account.t()}

# Custom Types
@type account_role :: :owner | :admin | :member
@type account_type :: :personal | :team
```

## State Management Strategy

### Persistence
- Ecto schemas for accounts and members join table
- Personal accounts auto-created during user registration
- Cascade delete protection for accounts with active users

### Consistency
- Role validation at schema level with database constraints
- Owner role protection (cannot remove last owner from team accounts)
- Transaction boundaries around account creation with initial membership

### Performance
- Preloading strategies for account-user relationships
- Indexed queries on frequently accessed fields (user_id, account_id)
- Efficient role checking through database queries

## Component Diagram

```
Accounts
├── Account (name, type, slug)
├── Members (user_id, account_id, role, join table)
├── Accounts Repository
│   ├── CRUD Operations
│   ├── Personal Account Creation
│   └── Team Account Creation
└── Members Repository
    ├── User Addition/Removal
    ├── Role Management
    └── Access Control
```

## Dependencies
- **Users Context**: User entities for membership relationships and personal account creation
- **Billing Context**: Subscription and plan data for user limit validation (when implemented)

## Execution Flow

### Personal Account Creation Flow
1. **Trigger**: Called during user registration via Users context callback
2. **Account Creation**: Generate personal account with user's name
3. **Owner Assignment**: Add user as owner of their personal account
4. **Context Setup**: Personal account becomes default context for user

### Team Account Creation Flow
1. **Account Creation**: User creates team account with specified attributes
2. **Owner Assignment**: Creator automatically assigned as account owner
3. **Slug Generation**: Unique slug created for account routing
4. **Permission Setup**: Owner permissions established for creator

### Members Management Flow
1. **User Limit Check**: Verify account hasn't exceeded user limit (via Billing context when implemented)
2. **Access Validation**: Verify requesting user has permission to modify members
3. **Role Assignment**: Add user to account with specified role
4. **Constraint Checking**: Validate role hierarchy and account limits
5. **Relationship Creation**: Persist members in members join table

### Account Context Switching Flow
1. **Permission Validation**: Verify user has access to requested account
2. **Context Update**: Switch user's current account context
3. **Role Refresh**: Update session with user's role in new account context
