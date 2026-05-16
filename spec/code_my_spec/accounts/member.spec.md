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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- Ecto.Query
- CodeMySpec.Users.User
- CodeMySpec.Accounts.Account
