# Components.SimilarComponentRepository

Repository for managing similar component relationships within a project scope. Similar components represent design inspiration and contextual references between components. Provides CRUD operations for bidirectional similarity lookups, bulk sync operations, and efficient batch preloading.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Components.SimilarComponent
- CodeMySpec.Components.Component
- CodeMySpec.Users.Scope

## Functions

### list_similar_components/2

Returns the list of components marked as similar to a given component within the project scope.

```elixir
@spec list_similar_components(Scope.t(), Component.t()) :: [Component.t()]
```

**Process**:
1. Join SimilarComponent with Component to validate project scope
2. Join with similar Component to get full component data
3. Filter by component_id and project_id from scope
4. Extract similar_component associations from results

**Test Assertions**:

- returns all similar components for given component
- returns empty list when no similar components exist
- excludes similar components from other projects
- returns Component structs, not SimilarComponent join records

### add_similar_component/3

Creates a similar component relationship between two components in the same project.

```elixir
@spec add_similar_component(Scope.t(), Component.t(), Component.t()) ::
        {:ok, SimilarComponent.t()} | {:error, Ecto.Changeset.t() | :components_not_in_same_project}
```

**Process**:
1. Validate both components belong to the same project as scope
2. Build SimilarComponent changeset with component IDs
3. Insert relationship into database

**Test Assertions**:

- creates relationship between two components in same project
- returns error when components are not in same project
- returns error when component references itself
- returns error for duplicate relationship
- returns error with invalid component IDs

### remove_similar_component/3

Removes a similar component relationship within the project scope.

```elixir
@spec remove_similar_component(Scope.t(), Component.t(), Component.t()) ::
        {:ok, SimilarComponent.t()} | {:error, :not_found | Ecto.Changeset.t()}
```

**Process**:
1. Query for SimilarComponent matching both component IDs within project scope
2. Return {:error, :not_found} if relationship doesn't exist
3. Delete relationship and return {:ok, deleted_record}

**Test Assertions**:

- removes existing similar component relationship
- returns {:error, :not_found} when relationship doesn't exist
- validates project scope when removing relationship
- returns deleted SimilarComponent on success

### sync_similar_components/3

Syncs similar components for a component to match the given list of IDs. Removes relationships not in the list and adds new ones.

```elixir
@spec sync_similar_components(Scope.t(), Component.t(), [Ecto.UUID.t()]) ::
        {:ok, Component.t()} | {:error, any()}
```

**Process**:
1. Fetch current similar component IDs using list_similar_components
2. Compute IDs to remove (current - new) using MapSet difference
3. Compute IDs to add (new - current) using MapSet difference
4. Remove old relationships by iterating to_remove set
5. Add new relationships by iterating to_add set
6. Return {:ok, component} if all additions succeed, or first error encountered

**Test Assertions**:

- adds new similar components not currently linked
- removes similar components no longer in the list
- keeps similar components that are in both current and new lists
- returns {:ok, component} when sync succeeds with no changes
- returns {:error, reason} when any addition fails
- handles empty similar_ids list by removing all relationships

### preload_similar_components/2

Preloads similar components for multiple components efficiently in a single query.

```elixir
@spec preload_similar_components(Scope.t(), [Component.t()]) :: [Component.t()]
```

**Process**:
1. Extract component IDs from input list
2. Query all SimilarComponent records for those IDs with similar_component preloaded
3. Group results by component_id into a lookup map
4. Map over input components, setting similar_components from lookup map

**Test Assertions**:

- returns components with similar_components association populated
- returns empty similar_components list for components with no relationships
- handles empty input list
- efficiently batches query for multiple components
- preserves original component order in result

### list_referenced_by/2

Gets components that reference the given component as similar (reverse lookup).

```elixir
@spec list_referenced_by(Scope.t(), Component.t()) :: [Component.t()]
```

**Process**:
1. Join SimilarComponent with Component on component_id (the referencing component)
2. Filter where similar_component_id matches given component and project scope
3. Preload component association
4. Extract and return referencing components

**Test Assertions**:

- returns components that consider this component similar
- returns empty list when no components reference this one
- excludes references from other projects
- returns Component structs, not SimilarComponent join records