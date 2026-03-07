# CodeMySpec.Documents.Function

## Type

schema

Embedded schema representing a function from a spec document. Used by the document parsing system to store structured function documentation including name, description, type specification, process steps, and test assertions.

## Fields

| Field           | Type     | Required | Description                                      | Constraints      |
| --------------- | -------- | -------- | ------------------------------------------------ | ---------------- |
| name            | string   | Yes      | Function name with arity (e.g. build/1)          | Min: 1, Max: 255 |
| description     | string   | No       | What the function does                           |                  |
| spec            | string   | No       | Elixir @spec type specification                  |                  |
| process         | string   | No       | Step-by-step process description                 |                  |
| test_assertions | [string] | No       | List of test assertions for the function         | Default: []      |

## Functions

### changeset/2

Validates and casts function attributes for embedded schema operations.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the `:name`, `:description`, `:spec`, `:process`, and `:test_assertions` fields from input attributes
2. Validate that `:name` is present (required field)
3. Validate `:name` length is between 1 and 255 characters

**Test Assertions**:
- returns valid changeset with valid name
- returns valid changeset with all fields populated
- returns invalid changeset when name is missing
- returns invalid changeset when name is empty string
- returns invalid changeset when name exceeds 255 characters
- accepts empty list for test_assertions
- accepts list of strings for test_assertions
- allows nil for optional fields (description, spec, process)

## Dependencies

- Ecto.Schema
- Ecto.Changeset