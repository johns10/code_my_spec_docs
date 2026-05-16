# CodeMySpec.Accounts

The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

## Type

context

## Dependencies

- CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.MembersRepository
- CodeMySpec.Authorization
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Components

### CodeMySpec.Accounts.Account

Ecto schema for account entities with personal and team types, slug generation, and membership associations.

### CodeMySpec.Accounts.AccountsRepository

Data access layer for account entities, handling personal and team account creation, basic CRUD operations, and query building within the multi-tenant architecture.

### CodeMySpec.Accounts.Member

Ecto schema managing many-to-many relationship between accounts and users with role-based permissions (owner, admin, member) and business rule validation.

### CodeMySpec.Accounts.MembersRepository

Data access layer for account membership relationships, handling user addition/removal, role management, and access control queries within the multi-tenant architecture.
