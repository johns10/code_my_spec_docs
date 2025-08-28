# Requirements Repository

## Purpose
Manages persisted component requirement satisfaction status for UI display and workflow queries. Requirements are recreated fresh on each ProjectCoordinator run - persistence enables efficient queries and UI state display.

## Core Operations/Public API

### Basic CRUD
```elixir
@spec create_requirement(Scope.t(), Component.t(), requirement_attrs()) :: {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
@spec get_requirement(Scope.t(), integer()) :: Requirement.t() | nil
@spec update_requirement(Scope.t(), Requirement.t(), requirement_attrs()) :: {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
@spec delete_requirement(Scope.t(), Requirement.t()) :: {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
```

### Query Builders
```elixir
@spec list_requirements_for_component(Scope.t(), integer()) :: [Requirement.t()]
@spec by_satisfied_status(Ecto.Query.t(), boolean()) :: Ecto.Query.t()
@spec by_requirement_name(Ecto.Query.t(), atom()) :: Ecto.Query.t()
```

### Bulk Operations
```elixir
@spec recreate_component_requirements(Scope.t(), Component.t(), [Requirement.t()]) :: {:ok, [Requirement.t()]}
@spec clear_project_requirements(Scope.t()) :: :ok
```

### Specialized Operations
```elixir
@spec components_with_unsatisfied_requirements(Scope.t()) :: [Component.t()]
@spec components_ready_for_work(Scope.t()) :: [Component.t()]
```

## Function Descriptions

- **recreate_component_requirements/3**: Deletes existing requirements for component and creates fresh ones from current Registry specs
- **clear_project_requirements/1**: Wipes all requirement records for project - used before full rebuild
- **components_with_unsatisfied_requirements/1**: Returns components that have at least one unsatisfied requirement - core function for workflow queries
- **components_ready_for_work/1**: Returns components with no unsatisfied dependencies, ready to be worked on

## Error Handling

- **Validation errors**: `{:error, changeset}` for invalid requirement data
- **Not found**: `nil` for missing requirements (no exceptions)
- **Constraint violations**: `{:error, changeset}` for duplicate requirements per component

## Usage Patterns

### NextActionEngine Integration
```elixir
# Fast workflow queries without Registry checking
components_ready = RequirementsRepository.components_ready_for_work(scope)
next_actions = build_context_actions(components_ready)
```

### ProjectCoordinator Rebuild Pattern
```elixir
# Full requirement rebuild on coordinator run
RequirementsRepository.clear_project_requirements(scope)
Components.list_components(scope)
|> Enum.each(&recreate_component_requirements(scope, &1, compute_requirements(&1)))
```

### Component Completion Check
```elixir
# Fast completion check without Registry computation
unsatisfied_count = 
  RequirementsRepository.list_requirements_for_component(scope, component_id)
  |> RequirementsRepository.by_satisfied_status(false)
  |> Repo.aggregate(:count)

complete? = unsatisfied_count == 0
```