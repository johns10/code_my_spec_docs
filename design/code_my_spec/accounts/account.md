---
type: "schema_design"
---

# Account Schema Design

## Account Schema

The Account schema represents both personal and team accounts in a multi-tenant structure.

**Core Fields:**
- `name` - Display name for the account (required, 1-100 chars)
- `slug` - URL-friendly identifier (required, unique, 3-50 chars)
- `type` - Either `:personal` or `:team` (defaults to `:personal`)

**Relationships:**
- `has_many :members` - Join table for user memberships
- `has_many :users, through: [:members, :user]` - Associated users

**Validation Rules:**
- Name is required and must be 1-100 characters
- Slug must be unique, lowercase letters/numbers/hyphens only
- Slug cannot be reserved words (admin, api, www, help, support, docs, blog)
- Team account slugs must start with a letter
- Personal account slugs are auto-generated from name

**Example Schema:**
```elixir
schema "accounts" do
  field :name, :string
  field :slug, :string
  field :type, Ecto.Enum, values: [:personal, :team], default: :personal
  
  has_many :members, CodeMySpec.Accounts.Member, on_delete: :delete_all
  has_many :users, through: [:members, :user]
  
  timestamps()
end
```

## Database Design

**Indexes:**
- Unique index on `accounts.slug`
- Index on `accounts.type` for filtering

**Constraints:**
- Check constraint for valid account types (personal, team)
- Foreign key constraints with cascade delete
