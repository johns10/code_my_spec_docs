# Requirements.Requirement

The Requirement Schema. Represents a component or context requirement with its satisfaction status. Maps to requirement specs but includes computed satisfaction state.

## Fields

| Field        | Type         | Required   | Description                       | Constraints              |
| ------------ | ------------ | ---------- | --------------------------------- | ------------------------ |
| id           | integer      | Yes (auto) | Primary key                       | Auto-generated           |
| name         | string       | Yes        | Requirement name                  |                          |
| checker_type | module       | Yes        | Module that checks requirement    | RequirementCheckerType   |
| description  | string       | Yes        | Human-readable description        |                          |
| satisfied_by | module       | No         | Session type that satisfies this  | SessionType              |
| satisfied    | boolean      | Yes        | Whether requirement is satisfied  | Default: false           |
| checked_at   | utc_datetime | No         | When requirement was last checked |                          |
| details      | map          | Yes        | Additional details about check    | Default: %{}             |
| component_id | integer      | Yes        | Associated component              | References components.id |
| component    | Component    | No         | Component association             |                          |
| inserted_at  | utc_datetime | Yes (auto) | Creation timestamp                | Auto-generated           |
| updated_at   | utc_datetime | Yes (auto) | Last update timestamp             | Auto-generated           |

## Functions

### changeset/2

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

Creates a changeset for creating a new requirement.

Validation rules:
- Casts: name, checker_type, description, satisfied_by, satisfied, checked_at, details, component_id
- Validates required: name, checker_type, description, satisfied

### update_changeset/2

```elixir
@spec update_changeset(t(), map()) :: Ecto.Changeset.t()
```

Creates a changeset for updating requirement satisfaction status.

Validation rules:
- Casts: satisfied, checked_at, details
- Validates required: satisfied

### from_spec/2

```elixir
@spec from_spec(requirement_spec :: map(), component_status :: struct()) :: t()
```

Creates a requirement from a requirement spec with computed satisfaction status.

**Process**:
1. Calls checker module from requirement spec
2. Computes satisfaction status
3. Stores checker module in checker_type field
4. Generates description from requirement name
5. Returns requirement struct with computed values

### name_atom/1

```elixir
@spec name_atom(t()) :: atom()
```

Returns the requirement name as an atom for pattern matching.

### checker_type/1

```elixir
@spec checker_type(t()) :: module()
```

Returns the checker module for requirement validation.