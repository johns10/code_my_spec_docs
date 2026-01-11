# Components.ComponentRepository

Repository for managing Component entities within a project scope. Provides CRUD operations, filtering by type and name, dependency preloading, architecture visualization, and requirement-based work tracking.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Components.Component
- CodeMySpec.Components.DependencyRepository
- CodeMySpec.Users.Scope

## Functions

### list_components/1

Returns all components for the scope's active project.

```elixir
@spec list_components(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query components where project_id matches scope's active_project_id
2. Return list of components

**Test Assertions**:

- returns all components for the project
- returns empty list when no components exist
- excludes components from other projects

### list_child_components/2

Returns child components of a parent component, ordered by priority descending then name ascending.

```elixir
@spec list_child_components(Scope.t(), integer()) :: [Component.t()]
```

**Process**:
1. Query components where parent_component_id matches and project_id matches scope
2. Order by priority descending, then name ascending
3. Return list of child components

**Test Assertions**:

- returns child components ordered by priority then name
- returns empty list when parent has no children

### get_component!/2

Gets a single component by ID within scope. Raises if not found or not in scope.

```elixir
@spec get_component!(Scope.t(), integer()) :: Component.t()
```

**Process**:
1. Query component by ID where project_id matches scope
2. Preload project and requirements associations
3. Return component or raise Ecto.NoResultsError

**Test Assertions**:

- returns component when it exists in project
- raises Ecto.NoResultsError when component doesn't exist
- raises Ecto.NoResultsError when component exists but belongs to different project

### get_component/2

Gets a single component by ID within scope. Returns nil if not found.

```elixir
@spec get_component(Scope.t(), integer()) :: Component.t() | nil
```

**Process**:
1. Query component by ID where project_id matches scope
2. Preload project and requirements associations
3. Return component or nil

**Test Assertions**:

- returns component when it exists in project
- returns nil when component doesn't exist
- returns nil when component exists but belongs to different project

### create_component/2

Creates a new component within scope.

```elixir
@spec create_component(Scope.t(), map()) :: {:ok, Component.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build new Component struct
2. Apply changeset with attributes and scope
3. Insert into database

**Test Assertions**:

- creates component with valid attributes
- returns error with invalid attributes (blank name/module_name)
- returns error with invalid module name format
- returns error when module_name already exists in project
- allows duplicate names across different projects

### upsert_component/2

Creates or updates a component based on module_name and project_id conflict.

```elixir
@spec upsert_component(Scope.t(), map()) :: Component.t()
```

**Process**:
1. Build new Component struct with changeset
2. Insert with on_conflict replacing all except id and inserted_at
3. Use module_name and project_id as conflict target
4. Return component or error

**Test Assertions**:

- creates new component when no conflict exists
- updates existing component when module_name conflicts
- preserves id and inserted_at on update

### update_component/4

Updates an existing component with optional persistence control.

```elixir
@spec update_component(Scope.t(), Component.t(), map(), list()) ::
        {:ok, Component.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset with attributes and scope
2. If persist option is true (default), persist to database
3. If persist option is false, apply changes without persisting
4. Return updated component or error changeset

**Test Assertions**:

- updates component with valid attributes
- returns error with invalid attributes
- persists changes when persist option is true
- applies changes without persisting when persist is false

### delete_component/2

Deletes a component within scope.

```elixir
@spec delete_component(Scope.t(), Component.t()) ::
        {:ok, Component.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delete the component from database
2. Return deleted component or error

**Test Assertions**:

- deletes component successfully
- cascade deletes dependencies when parent is deleted

### list_contexts/1

Returns all context and coordination_context type components for scope.

```elixir
@spec list_contexts(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query components where project_id matches scope
2. Filter where type is "context" or "coordination_context"
3. Return list of contexts

**Test Assertions**:

- returns only context and coordination_context type components
- excludes other component types

### list_contexts_with_dependencies/1

Returns all context components with their dependencies and associations preloaded.

```elixir
@spec list_contexts_with_dependencies(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query context and coordination_context type components in scope
2. Preload project, dependencies, dependents, outgoing_dependencies, incoming_dependencies, stories
3. Return list of contexts with preloaded associations

**Test Assertions**:

- returns contexts with all dependency associations preloaded
- includes stories association

### list_components_with_dependencies/1

Returns all components with their dependencies and associations preloaded.

```elixir
@spec list_components_with_dependencies(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query all components in scope
2. Preload project, dependencies, dependents, outgoing_dependencies, incoming_dependencies, stories
3. Return list of components with preloaded associations

**Test Assertions**:

- returns components with preloaded dependencies
- returns empty list when no components exist
- includes both incoming and outgoing dependency associations

### get_component_with_dependencies/2

Gets a single component with dependencies preloaded.

```elixir
@spec get_component_with_dependencies(Scope.t(), integer()) :: Component.t() | nil
```

**Process**:
1. Query component by ID within scope
2. Preload dependencies, dependents, outgoing_dependencies, incoming_dependencies
3. Return component or nil

**Test Assertions**:

- returns component with preloaded dependencies
- returns nil when component doesn't exist

### get_component_by_module_name/2

Gets a component by its module_name within scope.

```elixir
@spec get_component_by_module_name(Scope.t(), String.t()) :: Component.t() | nil
```

**Process**:
1. Query component where module_name matches and project_id matches scope
2. Return component or nil

**Test Assertions**:

- returns component when module name exists
- returns nil when module name doesn't exist
- returns nil when module name exists in different project

### list_components_by_type/2

Returns components filtered by type within scope.

```elixir
@spec list_components_by_type(Scope.t(), atom()) :: [Component.t()]
```

**Process**:
1. Query components where type matches and project_id matches scope
2. Return list of components

**Test Assertions**:

- returns components filtered by type
- returns empty list when no components of type exist

### search_components_by_name/2

Searches for components by name pattern (case-insensitive ILIKE).

```elixir
@spec search_components_by_name(Scope.t(), String.t()) :: [Component.t()]
```

**Process**:
1. Build search term with wildcards
2. Query components in scope where name matches pattern (ILIKE)
3. Return matching components

**Test Assertions**:

- returns components matching name pattern
- search is case insensitive
- returns empty list when no matches found
- handles partial matches

### search_components_by_module_name/2

Searches for components by module_name pattern (case-insensitive ILIKE).

```elixir
@spec search_components_by_module_name(Scope.t(), String.t()) :: [Component.t()]
```

**Process**:
1. Build search term with wildcards
2. Query components in scope where module_name matches pattern (ILIKE)
3. Return matching components

**Test Assertions**:

- returns components matching module_name pattern
- search is case insensitive
- handles partial matches

### show_architecture/1

Returns components that have stories attached, with deeply nested dependency preloading for architecture visualization.

```elixir
@spec show_architecture(Scope.t()) :: [%{component: Component.t(), depth: integer()}]
```

**Process**:
1. Query components in scope that have associated stories
2. Preload stories and outgoing_dependencies recursively (up to 8 levels deep)
3. Map results to include depth: 0 for root components
4. Return list of component/depth maps

**Test Assertions**:

- returns empty list when no components with stories exist
- returns only components with stories at depth 0
- includes dependencies in the architecture graph
- handles multiple root components with stories
- avoids infinite loops in circular dependencies
- excludes components from other projects
- preloads stories and dependencies on returned components

### list_orphaned_contexts/1

Returns context components that have no stories and are not dependencies of components with stories.

```elixir
@spec list_orphaned_contexts(Scope.t()) :: [Component.t()]
```

**Process**:
1. Get all components with dependencies preloaded
2. Find entry points (components with stories)
3. Recursively collect all dependency IDs from entry points
4. Filter for contexts with no stories that aren't in dependency set
5. Return orphaned contexts

**Test Assertions**:

- returns contexts with no stories and not referenced by story components
- excludes contexts that are dependencies of story components

### create_components_with_dependencies/3

Creates multiple components with their dependencies in a transaction.

```elixir
@spec create_components_with_dependencies(Scope.t(), [map()], [String.t()]) ::
        {:ok, [Component.t()]} | {:error, term()}
```

**Process**:
1. Start database transaction
2. Create all components, collecting results
3. If any creation fails, rollback transaction
4. Create dependencies for first component to target components by module_name
5. Skip missing dependency targets
6. Return created components or rollback on failure

**Test Assertions**:

- creates multiple components and their dependencies in a transaction
- rolls back all changes when component creation fails
- skips dependencies when target module doesn't exist
- handles empty component list
- handles empty dependency list
- creates multiple dependencies correctly
- returns error if component already exists with same module_name

### components_with_unsatisfied_requirements/1

Returns components that have at least one unsatisfied requirement.

```elixir
@spec components_with_unsatisfied_requirements(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query components in scope
2. Join with requirements where satisfied is false
3. Return distinct components with requirements preloaded

**Test Assertions**:

- returns components with unsatisfied requirements
- returns empty list when all requirements are satisfied
- includes components with mixed satisfied/unsatisfied requirements

### components_ready_for_work/1

Returns components that have no requirements or all requirements satisfied.

```elixir
@spec components_ready_for_work(Scope.t()) :: [Component.t()]
```

**Process**:
1. Query component IDs with unsatisfied requirements
2. Query all components not in that list
3. Preload requirements association
4. Return components ready for work

**Test Assertions**:

- returns components with all requirements satisfied or no requirements
- respects project scope
- excludes components with unsatisfied requirements