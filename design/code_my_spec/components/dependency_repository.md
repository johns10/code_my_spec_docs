# Dependency Repository

## Purpose
Provides basic data access functions for Dependency entities with project scoping.

## Module Definition

```elixir
defmodule CodeMySpec.Components.DependencyRepository do
  @moduledoc """
  Repository for Dependency data access.
  """

  import Ecto.Query, warn: false
  alias CodeMySpec.Repo
  alias CodeMySpec.Components.{Dependency, Component}
  alias CodeMySpec.Users.Scope

  @doc """
  Returns the list of dependencies for components in the given scope.
  """
  def list_dependencies(%Scope{active_project_id: project_id}) do
    from(d in Dependency,
      join: sc in Component, on: d.source_component_id == sc.id,
      where: sc.project_id == ^project_id,
      preload: [:source_component, :target_component]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single dependency by ID within scope.
  """
  def get_dependency!(%Scope{active_project_id: project_id}, id) do
    from(d in Dependency,
      join: sc in Component, on: d.source_component_id == sc.id,
      where: d.id == ^id and sc.project_id == ^project_id,
      preload: [:source_component, :target_component]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a dependency.
  """
  def create_dependency(attrs) do
    %Dependency{}
    |> Dependency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a dependency.
  """
  def delete_dependency(%Dependency{} = dependency) do
    Repo.delete(dependency)
  end

  @doc """
  Simple circular dependency check - looks for direct cycles.
  """
  def validate_dependency_graph(%Scope{active_project_id: project_id}) do
    circular_deps = 
      from(d1 in Dependency,
        join: d2 in Dependency,
        on: d1.source_component_id == d2.target_component_id and
            d1.target_component_id == d2.source_component_id,
        join: sc in Component, on: d1.source_component_id == sc.id,
        where: sc.project_id == ^project_id,
        preload: [:source_component, :target_component]
      )
      |> Repo.all()

    case circular_deps do
      [] -> :ok
      cycles -> {:error, format_cycles(cycles)}
    end
  end

  @doc """
  Basic topological sort - components with no dependencies first.
  """
  def resolve_dependency_order(%Scope{active_project_id: project_id}) do
    # Get components with dependency counts
    components_with_deps = 
      from(c in Component,
        left_join: d in Dependency, on: d.source_component_id == c.id,
        where: c.project_id == ^project_id,
        group_by: c.id,
        select: {c, count(d.id)}
      )
      |> Repo.all()

    # Sort by dependency count (ascending)
    sorted = 
      components_with_deps
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.map(&elem(&1, 0))

    {:ok, sorted}
  end

  defp format_cycles(cycles) do
    Enum.map(cycles, fn dep ->
      %{
        components: [dep.source_component, dep.target_component],
        path: [dep.source_component.name, dep.target_component.name]
      }
    end)
  end
end
```

## Function Categories

### Basic CRUD Operations
- `list_dependencies/1` - List all dependencies in project
- `get_dependency!/2` - Get dependency by ID
- `create_dependency/1` - Create new dependency  
- `delete_dependency/1` - Delete dependency

### Simple Graph Analysis
- `validate_dependency_graph/1` - Check for direct circular dependencies
- `resolve_dependency_order/1` - Basic sort by dependency count

## Scope Integration

All functions ensure proper scoping by joining with source component and filtering by `project_id`.

## Error Handling

Functions ending with `!` raise `Ecto.NoResultsError` if not found.
Graph analysis returns `{:ok, result}` or `{:error, cycles}` tuples.