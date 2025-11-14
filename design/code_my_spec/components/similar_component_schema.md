# SimilarComponent Schema

## Purpose
Defines the Ecto schema for SimilarComponent entities representing similarity relationships between components. Similar components serve as design inspiration and context when creating or modifying components, allowing the LLM to follow existing patterns and maintain architectural consistency.

## Schema Definition

```elixir
defmodule CodeMySpec.Components.SimilarComponent do
  use Ecto.Schema
  import Ecto.Changeset

  alias CodeMySpec.Components.Component

  schema "similar_components" do
    belongs_to :component, Component
    belongs_to :similar_component, Component

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(similar_component, attrs) do
    similar_component
    |> cast(attrs, [:component_id, :similar_component_id])
    |> validate_required([:component_id, :similar_component_id])
    |> validate_no_self_similarity()
    |> validate_same_project()
    |> unique_constraint([:component_id, :similar_component_id])
    |> foreign_key_constraint(:component_id)
    |> foreign_key_constraint(:similar_component_id)
  end

  defp validate_no_self_similarity(changeset) do
    component_id = get_field(changeset, :component_id)
    similar_id = get_field(changeset, :similar_component_id)

    if component_id && similar_id && component_id == similar_id do
      add_error(changeset, :similar_component_id, "cannot be similar to itself")
    else
      changeset
    end
  end

  defp validate_same_project(changeset) do
    # This validation requires preloading components
    # Implementation will query both components and validate project_id match
    changeset
  end
end
```

## Field Descriptions

### Required Fields
- **component_id**: Component that references another as similar
- **similar_component_id**: Component being referenced as similar

### Associations
- **component**: Component that has the similarity reference
- **similar_component**: Component being referenced as similar

## Validation Rules

### Component Validation
- Both component_id and similar_component_id are required
- Component and similar_component cannot be the same (no self-similarity)
- Both components must belong to the same project (cross-project similarities not allowed)

### Project Scope Validation
- Ensures both components exist within the same project
- Prevents referencing components from other users' projects
- Maintains project isolation and security boundaries

## Database Constraints

### Unique Constraints
- `unique_constraint([:component_id, :similar_component_id])` - Prevents duplicate similarity references

### Foreign Key Constraints
- `component_id` references components.id (cascade delete)
- `similar_component_id` references components.id (cascade delete)

## Migration Schema

```elixir
create table(:similar_components) do
  add :component_id, references(:components, on_delete: :delete_all), null: false
  add :similar_component_id, references(:components, on_delete: :delete_all), null: false

  timestamps(type: :utc_datetime)
end

create unique_index(:similar_components, [:component_id, :similar_component_id])
create index(:similar_components, [:component_id])
create index(:similar_components, [:similar_component_id])
```

## Use Cases

### Pattern Replication
Reference components with similar structure to maintain consistency (e.g., all repositories follow similar patterns).

### Architectural Consistency
Link components that should maintain similar design approaches across the codebase.

### Design Context
Provide examples to the LLM during component design sessions, allowing it to learn from existing implementations.

### Learning from Examples
New components can reference well-designed similar components to follow established patterns.

## Integration with Design Sessions

When spawning component design sessions, similar components are:
1. Queried from the database for the component being designed
2. Loaded with their full implementation code
3. Passed to the design prompt as context
4. Used by the LLM to understand patterns and maintain consistency

This creates a knowledge transfer mechanism where good design patterns naturally propagate through the codebase.