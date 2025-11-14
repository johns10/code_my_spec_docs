# Components Context

## Purpose
Manages component definitions, metadata, type classification, and inter-component dependencies for architectural design.

## Entity Ownership
- Component entity representing any Elixir code file (genserver, context, schema, repository, task, registry, etc.)
- Dependency entity tracking inter-component relationships and resolution ordering
- SimilarComponent entity tracking component similarity references for design context
- Component, Dependency, and SimilarComponent repositories for data access

### Access Patterns
- Components are filtered by user ownership through project association
- Project-scoped components ensure isolation between user projects
- Foreign key relationships: component -> project -> user

## Public API
```elixir
# Component Management
@spec list_components(Scope.t()) :: [Component.t()]
@spec get_component!(Scope.t(), id :: integer()) :: Component.t()
@spec create_component(Scope.t(), attrs :: map()) :: {:ok, Component.t()} | {:error, Changeset.t()}
@spec create_components(Scope.t(), [attrs :: map()]) :: {:ok, [Component.t()]} | {:error, Changeset.t()}
@spec update_component(Scope.t(), Component.t(), attrs :: map()) :: {:ok, Component.t()} | {:error, Changeset.t()}
@spec delete_component(Scope.t(), Component.t()) :: {:ok, Component.t()} | {:error, Changeset.t()}

# Architectural Views
@spec show_architecture(Scope.t()) :: [Component.t()]  # Returns components with stories and dependencies recursively preloaded


# Dependency Management
@spec list_dependencies(Scope.t()) :: [Dependency.t()]
@spec get_dependency!(Scope.t(), id :: integer()) :: Dependency.t()
@spec create_dependency(attrs :: map()) :: {:ok, Dependency.t()} | {:error, Changeset.t()}
@spec delete_dependency(Scope.t(), Dependency.t()) :: {:ok, Dependency.t()} | {:error, Changeset.t()}

# Dependency Analysis
@spec validate_dependency_graph(Scope.t()) :: :ok | {:error, [circular_dependency()]}
@spec resolve_dependency_order(Scope.t()) :: {:ok, [Component.t()]} | {:error, :circular_dependencies}

# Similar Component Management
@spec list_similar_components(Scope.t(), Component.t()) :: [Component.t()]
@spec add_similar_component(Scope.t(), Component.t(), Component.t()) :: {:ok, SimilarComponent.t()} | {:error, Changeset.t()}
@spec remove_similar_component(Scope.t(), Component.t(), Component.t()) :: {:ok, SimilarComponent.t()} | {:error, Changeset.t()}
@spec get_components_with_similar(Scope.t(), [Component.t()]) :: [Component.t()]  # Returns components with similar_components preloaded

@type component_type :: :genserver | :context | :coordination_context | :schema | :repository | :task | :registry | :other
@type dependency_type :: :require | :import | :alias | :use | :call | :other
@type circular_dependency :: %{components: [Component.t()], path: [String.t()]}
```

## State Management Strategy
### Persistence
- Component Ecto schema with user_id and project_id foreign keys
- Dependency Ecto schema as simple join table between components
- SimilarComponent Ecto schema as join table for component similarity relationships
- Component associations preload dependencies/dependents and similar components via Ecto associations
- Dependency relationships with source/target component references and scope validation
- SimilarComponent relationships ensure both components belong to same project

### Transactions
- Component and dependency operations within project transaction boundaries
- Dependency graph validation ensuring no circular references
- Atomic operations for component graph modifications with consistency guarantees

## Components

### CodeMySpec.Components.Component

| field | value  |
| ----- | ------ |
| type  | schema |

- Schema Module
- Type Validation
- Scope Filtering

### CodeMySpec.Components.Dependency

| field | value  |
| ----- | ------ |
| type  | schema |

- Schema Module
- Source/Target Component References
- Relationship Type Classification
- Scope Validation

### CodeMySpec.Components.SimilarComponent

| field | value  |
| ----- | ------ |
| type  | schema |

- Schema Module
- Join table for many-to-many self-referential relationship
- Component/Similar Component References
- Scope Validation
- Ensures both components belong to same project

### CodeMySpec.Components.ComponentRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

- Component Data Access
 
### CodeMySpec.Components.DependencyRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

- Dependency Data Access
- Circular Dependency Detection
- Topological Sort Algorithm
- Resolution Order Calculation

### CodeMySpec.Components.SimilarComponentRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

- SimilarComponent Data Access
- Query similar components for a given component
- Batch preload similar components for multiple components

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects
- Phoenix.PubSub
- Ecto

## Execution Flow
1. **Scope Validation**: Verify user has access to project and component operations
2. **Component Retrieval**: Query components filtered by user_id through project association
3. **Type Validation**: Component type validated through schema changeset
4. **Dependency Resolution**: Validate all component dependencies exist within scope
5. **Persistence**: Save component with proper scope foreign keys
6. **Notification**: Broadcast component changes via PubSub within project scope