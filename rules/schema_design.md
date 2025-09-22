---
component_type: "schema"
session_type: "design"
---

# Ecto Schema Design Rules

## Schema Structure
```elixir
defmodule App.Context.Schema do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "table_name" do
    # fields and associations
    timestamps()
  end
  
  def changeset(struct, attrs) do
    # validation logic
  end
end
```

- Write your design in plain english, some code samples are fine
- Include typespecs in schemas
- Include defaults for non-required fields: `default: value`
- Always specify enum defaults
- Include appropriate validations in changeset function
- Use `validate_required/2` for required fields
- Add length, format, and constraint validations as needed
- Create private validation functions for complex logic
- Use `belongs_to` and `has_many` for related data when coupling is desired
- Consider loose coupling with ID fields only when appropriate
- Document relationship patterns
- Comment field purposes and constraints
- Include usage examples
- Document state transitions for enums
- Note any special business rules