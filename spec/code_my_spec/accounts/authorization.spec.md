# CodeMySpec.Accounts.Authorization

Role-based authorization checks against account membership: whether a scope's user may read, manage or delete an account, answered from `MembersRepository` roles. Part of the Accounts context — it lived as its own top-level `CodeMySpec.Authorization` until 2026-09-27, when that made Accounts and it depend on each other.

## Dependencies

- CodeMySpec.Accounts.MembersRepository
- CodeMySpec.Users.Scope
