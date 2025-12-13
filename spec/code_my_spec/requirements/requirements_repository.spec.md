# Requirements.RequirementsRepository

Manages persisted component requirement satisfaction status for UI display and workflow queries. Requirements are recreated fresh on each sync operation - persistence enables efficient queries and UI state display.

## Functions

### create_requirement/4

```elixir
@spec create_requirement(Scope.t(), Component.t(), requirement_attrs(), opts :: keyword()) :: {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
```

Creates a requirement for a component.

**Options**:
- `:persist` - Whether to persist to database (default: true)

**Test Assertions**:

- create_requirement/4 creates requirement with valid attributes
- create_requirement/4 returns error with invalid attributes
- create_requirement/4 associates requirement with component
- create_requirement/4 skips persistence when persist: false
- create_requirement/4 persists to database when persist: true

### update_requirement/3

```elixir
@spec update_requirement(Scope.t(), Requirement.t(), requirement_attrs()) :: {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
```

Updates an existing requirement's satisfaction status.

**Test Assertions**:

- update_requirement/3 updates requirement with valid attributes
- update_requirement/3 returns error with invalid attributes
- update_requirement/3 updates checked_at timestamp

### clear_requirements/3

```elixir
@spec clear_requirements(Scope.t(), Component.t(), opts :: keyword()) :: Component.t()
```

Clears requirements for a component.

**Options**:
- `:persist` - Whether to delete from database (default: false)

**Process**:
1. Optionally deletes all requirement records for component from database
2. Clears dependency associations from component struct
3. Returns updated component

**Test Assertions**:

- clear_requirements/3 deletes requirements from database when persist: true
- clear_requirements/3 skips database deletion when persist: false
- clear_requirements/3 clears dependency associations from struct
- clear_requirements/3 returns component

### list_requirements_for_component/2

```elixir
@spec list_requirements_for_component(Scope.t(), component_id :: integer()) :: [Requirement.t()]
```

Lists all requirements for a specific component.

**Test Assertions**:

- list_requirements_for_component/2 returns all requirements for component
- list_requirements_for_component/2 returns empty list when no requirements
- list_requirements_for_component/2 respects scope boundaries

### by_satisfied_status/2

```elixir
@spec by_satisfied_status(Ecto.Query.t(), satisfied :: boolean()) :: Ecto.Query.t()
```

Query builder to filter requirements by satisfaction status.

**Test Assertions**:

- by_satisfied_status/2 filters to satisfied requirements when true
- by_satisfied_status/2 filters to unsatisfied requirements when false
- by_satisfied_status/2 returns queryable