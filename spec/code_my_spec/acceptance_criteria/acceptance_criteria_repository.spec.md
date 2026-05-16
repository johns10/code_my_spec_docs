# CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository

Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filtering by story and verification status filtering. All operations respect project and account scoping. The context module delegates read operations directly to this repository and wraps write operations with PubSub broadcasting.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Users.Scope
- Ecto.Query
