# CodeMySpec.Accounts.Account

Ecto schema representing user accounts in the multi-tenant system. Accounts can be either personal (belonging to a single user) or team-based (shared among multiple members). Each account has a unique slug for URL-friendly identification.

## Fields

| Field       | Type                          | Required   | Description                              | Constraints                              |
| ----------- | ----------------------------- | ---------- | ---------------------------------------- | ---------------------------------------- |
| id          | integer                       | Yes (auto) | Primary key                              | Auto-generated                           |
| name        | string                        | Yes        | Display name of the account              | Min: 1, Max: 100                         |
| slug        | string                        | No         | URL-friendly identifier                  | Min: 3, Max: 50, lowercase alphanumeric with hyphens, unique, not reserved |
| type        | enum (:personal, :team)       | Yes        | Account type                             | Default: :personal                       |
| members     | has_many Member               | No         | Account membership associations          | on_delete: :delete_all                   |
| users       | has_many through members      | No         | Users associated via membership          | Through: [:members, :user]               |
| inserted_at | utc_datetime                  | Yes (auto) | Creation timestamp                       | Auto-generated                           |
| updated_at  | utc_datetime                  | Yes (auto) | Last update timestamp                    | Auto-generated                           |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Accounts.Member
- CodeMySpec.Users.User

## Functions

### changeset/2

Builds a changeset for updating an existing account with the given attributes.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast name, slug, and type attributes from the input map
2. Validate that name and type are required
3. Validate name length is between 1 and 100 characters
4. Apply slug validation rules (format, length, reserved words, team format)
5. Add unique constraint on slug field

**Test Assertions**:
- returns valid changeset when name and type are provided
- returns invalid changeset when name is missing
- returns invalid changeset when name exceeds 100 characters
- returns invalid changeset when name is empty
- validates slug contains only lowercase letters, numbers, and hyphens
- returns invalid changeset when slug is less than 3 characters
- returns invalid changeset when slug exceeds 50 characters
- returns invalid changeset for reserved slugs (admin, api, www, help, support, docs, blog)
- validates team account slugs must start with a letter
- allows personal account slugs to start with a number

### create_changeset/1

Builds a changeset for creating a new account with optional automatic slug generation.

```elixir
@spec create_changeset(map()) :: Ecto.Changeset.t()
```

**Process**:
1. Initialize a new Account struct
2. Apply standard changeset validations via changeset/2
3. For personal accounts without a slug, auto-generate slug from name

**Test Assertions**:
- creates valid changeset with name and type
- auto-generates slug from name for personal accounts when slug not provided
- does not auto-generate slug for team accounts
- preserves explicitly provided slug for personal accounts
- generates slug by downcasing name and replacing non-alphanumeric chars with hyphens
- collapses multiple consecutive hyphens into single hyphen in generated slug
- trims leading and trailing hyphens from generated slug