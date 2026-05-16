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
