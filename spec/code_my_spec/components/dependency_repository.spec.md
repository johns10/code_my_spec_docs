# CodeMySpec.Components.DependencyRepository

Repository for managing component dependency relationships within a project scope. Provides CRUD operations for dependencies between components and graph analysis utilities for detecting circular dependencies and resolving dependency order.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Components.Dependency
- CodeMySpec.Components.Component
- CodeMySpec.Users.Scope

## Functions

### list_dependencies/1

Returns all dependencies for components in the given scope, with source and target components preloaded.

```elixir
@spec list_dependencies(Scope.t()) :: [Dependency.t()]
```

**Process**:
1. Query dependencies where source component belongs to scope's project
2. Preload source_component and target_component associations
3. Return list of dependencies

**Test Assertions**:

- returns all dependencies for components in scope project
- returns empty list when no dependencies exist in scope
- preloads source and target components
- excludes dependencies from other projects

### get_dependency!/2

Gets a single dependency by ID within the given scope. Raises if not found or not in scope.

```elixir
@spec get_dependency!(Scope.t(), non_neg_integer()) :: Dependency.t()
```

**Process**:
1. Query dependency by ID where source component belongs to scope's project
2. Preload source_component and target_component associations
3. Return dependency or raise Ecto.NoResultsError

**Test Assertions**:

- returns dependency with preloaded associations when exists in scope
- raises Ecto.NoResultsError when dependency not found
- raises Ecto.NoResultsError when dependency exists but not in scope

### create_dependency/2

Creates a new dependency between components.

```elixir
@spec create_dependency(Scope.t(), map()) :: {:ok, Dependency.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build new Dependency struct
2. Apply changeset with provided attributes
3. Insert into database

**Test Assertions**:

- creates dependency with valid attributes
- returns error changeset with missing required fields
- returns error changeset when source and target are the same
- returns error changeset with invalid foreign key
- returns error changeset for duplicate dependency

### delete_dependency/2

Deletes a dependency within scope.

```elixir
@spec delete_dependency(Scope.t(), Dependency.t()) :: {:ok, Dependency.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:

- deletes dependency successfully
- accepts scope parameter for API consistency

### delete_dependency/1

Deletes a dependency without scope validation.

```elixir
@spec delete_dependency(Dependency.t()) :: {:ok, Dependency.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:

- deletes dependency successfully
- raises Ecto.StaleEntryError for already deleted dependency

### validate_dependency_graph/1

Checks for direct circular dependencies in the project's dependency graph.

```elixir
@spec validate_dependency_graph(Scope.t()) :: :ok | {:error, list()}
```

**Process**:
1. Query for pairs of dependencies where A depends on B and B depends on A
2. Filter to dependencies within scope's project
3. Return :ok if no cycles found
4. Return {:error, cycles} with formatted cycle information if found

**Test Assertions**:

- returns :ok when no circular dependencies exist
- returns error with circular dependency details when cycle exists
- ignores circular dependencies from other projects
- returns both directions of circular dependency in error

### resolve_dependency_order/1

Returns components sorted by their dependency count (fewest dependencies first).

```elixir
@spec resolve_dependency_order(Scope.t()) :: {:ok, [Component.t()]}
```

**Process**:
1. Left join components with their outgoing dependencies
2. Group by component and count dependencies
3. Sort by dependency count ascending
4. Return {:ok, sorted_components}

**Test Assertions**:

- returns components ordered by dependency count
- returns all components in scope even with no dependencies
- only returns components from the scoped project
- components with no dependencies come first