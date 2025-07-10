---
type: "schema_design"
---

# Member Schema

The Member schema manages the many-to-many relationship between accounts and users with role-based permissions.

**Core Fields:**
- `user_id` - Reference to user (required)
- `account_id` - Reference to account (required)
- `role` - User's role in the account (`:owner`, `:admin`, or `:member`)

**Role Hierarchy:**
- `:owner` - Full control, can manage all aspects including deletion
- `:admin` - Can manage users and settings but cannot delete account
- `:member` - Basic access, cannot manage users or settings

**Business Rules:**
- Each account must have at least one owner
- Users can have different roles in different accounts
- Personal accounts always have the user as owner
- Users cannot have duplicate memberships in same account

**Example Schema:**
```elixir
schema "members" do
  field :role, Ecto.Enum, values: [:owner, :admin, :member], default: :member
  
  belongs_to :user, CodeMySpec.Users.User
  belongs_to :account, CodeMySpec.Accounts.Account
  
  timestamps()
end
```

## Database Design

**Indexes:**
- Unique index on `members.[user_id, account_id]`
- Indexes on `members.user_id`, `members.account_id`, `members.role`

**Constraints:**
- Check constraint for valid roles (owner, admin, member)
- Foreign key constraints with cascade delete
