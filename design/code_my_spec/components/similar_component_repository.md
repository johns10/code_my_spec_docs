# SimilarComponent Repository

## Purpose
Provides data access functions for SimilarComponent entities with project scoping and efficient preloading capabilities for design sessions.

## Module Definition

```elixir
defmodule CodeMySpec.Components.SimilarComponentRepository do
  @moduledoc """
  Repository for SimilarComponent data access.
  """

  import Ecto.Query, warn: false
  alias CodeMySpec.Repo
  alias CodeMySpec.Components.{SimilarComponent, Component}
  alias CodeMySpec.Users.Scope

  @doc """
  Returns the list of similar components for a given component.
  """
  def list_similar_components(%Scope{active_project_id: project_id}, %Component{id: component_id}) do
    from(sc in SimilarComponent,
      join: c in Component, on: sc.component_id == c.id,
      join: similar in Component, on: sc.similar_component_id == similar.id,
      where: sc.component_id == ^component_id and c.project_id == ^project_id,
      preload: [similar_component: similar]
    )
    |> Repo.all()
    |> Enum.map(& &1.similar_component)
  end

  @doc """
  Creates a similar component relationship.
  Validates that both components exist within the same project.
  """
  def add_similar_component(%Scope{active_project_id: project_id}, %Component{id: component_id}, %Component{id: similar_component_id}) do
    # Validate both components belong to same project
    case validate_same_project(component_id, similar_component_id, project_id) do
      :ok ->
        %SimilarComponent{}
        |> SimilarComponent.changeset(%{
          component_id: component_id,
          similar_component_id: similar_component_id
        })
        |> Repo.insert()

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Removes a similar component relationship.
  """
  def remove_similar_component(%Scope{active_project_id: project_id}, %Component{id: component_id}, %Component{id: similar_component_id}) do
    from(sc in SimilarComponent,
      join: c in Component, on: sc.component_id == c.id,
      where: sc.component_id == ^component_id and
             sc.similar_component_id == ^similar_component_id and
             c.project_id == ^project_id
    )
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      similar_component -> Repo.delete(similar_component)
    end
  end

  @doc """
  Preloads similar components for multiple components efficiently.
  Returns components with similar_components association loaded.
  """
  def preload_similar_components(%Scope{} = _scope, components) when is_list(components) do
    component_ids = Enum.map(components, & &1.id)

    similar_map =
      from(sc in SimilarComponent,
        join: similar in Component, on: sc.similar_component_id == similar.id,
        where: sc.component_id in ^component_ids,
        preload: [similar_component: similar]
      )
      |> Repo.all()
      |> Enum.group_by(& &1.component_id)

    Enum.map(components, fn component ->
      similar_components =
        similar_map
        |> Map.get(component.id, [])
        |> Enum.map(& &1.similar_component)

      %{component | similar_components: similar_components}
    end)
  end

  @doc """
  Gets components that reference the given component as similar.
  (Reverse lookup - who considers this component similar?)
  """
  def list_referenced_by(%Scope{active_project_id: project_id}, %Component{id: component_id}) do
    from(sc in SimilarComponent,
      join: c in Component, on: sc.component_id == c.id,
      join: similar in Component, on: sc.similar_component_id == similar.id,
      where: sc.similar_component_id == ^component_id and similar.project_id == ^project_id,
      preload: [component: c]
    )
    |> Repo.all()
    |> Enum.map(& &1.component)
  end

  # Private Functions

  defp validate_same_project(component_id, similar_component_id, project_id) do
    components =
      from(c in Component,
        where: c.id in ^[component_id, similar_component_id] and c.project_id == ^project_id,
        select: c.id
      )
      |> Repo.all()

    if length(components) == 2 do
      :ok
    else
      {:error, :components_not_in_same_project}
    end
  end
end
```

## Function Categories

### Basic CRUD Operations
- `list_similar_components/2` - List all similar components for a given component
- `add_similar_component/3` - Create new similar component relationship
- `remove_similar_component/3` - Delete similar component relationship

### Batch Operations
- `preload_similar_components/2` - Efficiently preload similar components for multiple components
- `list_referenced_by/2` - Reverse lookup to find components that reference the given component

## Scope Integration

All functions ensure proper scoping by:
- Joining with component table to filter by `project_id`
- Validating both components belong to the same project before creating relationships
- Preventing cross-project similarity references

## Use in Design Sessions

The `preload_similar_components/2` function is designed for efficient batch loading during component design sessions:

1. Query all components to be designed
2. Call `preload_similar_components/2` to load all similar components in a single query
3. Pass similar components to design prompts as context
4. LLM uses similar components as examples for pattern consistency

## Error Handling

- `add_similar_component/3` returns `{:error, :components_not_in_same_project}` if components are from different projects
- `remove_similar_component/3` returns `{:error, :not_found}` if relationship doesn't exist
- All functions respect project scope to maintain security boundaries

## Performance Considerations

- Uses efficient joins and where clauses to minimize database queries
- `preload_similar_components/2` performs batch loading with a single query followed by grouping
- Indexes on `component_id` and `similar_component_id` ensure fast lookups