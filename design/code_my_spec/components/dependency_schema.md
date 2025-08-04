# Dependency Schema

## Purpose
Defines the Ecto schema for Dependency entities representing relationships between Elixir components within project architecture.

## Schema Definition

```elixir
defmodule CodeMySpec.Components.Dependency do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias CodeMySpec.Components.Component

  schema "dependencies" do
    belongs_to :source_component, Component
    belongs_to :target_component, Component

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dependency, attrs) do
    dependency
    |> cast(attrs, [:source_component_id, :target_component_id])
    |> validate_required([:source_component_id, :target_component_id])
    |> validate_no_self_dependency()
    |> unique_constraint([:source_component_id, :target_component_id])
    |> foreign_key_constraint(:source_component_id)
    |> foreign_key_constraint(:target_component_id)
  end

  defp validate_no_self_dependency(changeset) do
    source_id = get_field(changeset, :source_component_id)
    target_id = get_field(changeset, :target_component_id)
    
    if source_id && target_id && source_id == target_id do
      add_error(changeset, :target_component_id, "cannot depend on itself")
    else
      changeset
    end
  end
end
```

## Field Descriptions

### Required Fields
- **source_component_id**: Component that has the dependency
- **target_component_id**: Component being depended upon

### Associations
- **source_component**: Component that depends on another component
- **target_component**: Component being depended upon

## Validation Rules

### Type Validation
- Required, must be one of enum values: :require, :import, :alias, :use, :call, :other
- Enforced at database and changeset level

### Component Validation
- Both source_component_id and target_component_id are required
- Source and target cannot be the same component (no self-dependencies)

## Database Constraints

### Unique Constraints
- `unique_constraint([:source_component_id, :target_component_id])` - Prevents duplicate dependencies

### Foreign Key Constraints
- `source_component_id` references components.id (cascade delete)
- `target_component_id` references components.id (cascade delete)

## Migration Schema

```elixir
create table(:dependencies) do
  add :source_component_id, references(:components, on_delete: :delete_all), null: false
  add :target_component_id, references(:components, on_delete: :delete_all), null: false

  timestamps(type: :utc_datetime)
end

create unique_index(:dependencies, [:source_component_id, :target_component_id])
create index(:dependencies, [:source_component_id])
create index(:dependencies, [:target_component_id])
```