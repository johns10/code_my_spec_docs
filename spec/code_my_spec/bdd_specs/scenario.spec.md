# CodeMySpec.BddSpecs.Scenario

## Type

schema (non-persisted)

Struct representing a single scenario within a BDD spec. Contains the scenario name and organized collections of step descriptions grouped by type (given, when, then). Scenarios are the executable units within a spec that verify specific behaviors.

## Fields

| Field       | Type         | Required | Description                                      | Constraints      |
| ----------- | ------------ | -------- | ------------------------------------------------ | ---------------- |
| name        | string       | Yes      | Human-readable scenario name                     | Min: 1, Max: 500 |
| given_steps | list(string) | No       | List of precondition step descriptions           | Default: []      |
| when_steps  | list(string) | No       | List of action/event step descriptions           | Default: []      |
| then_steps  | list(string) | No       | List of expected outcome step descriptions       | Default: []      |
| line_number | integer      | No       | Source line number where scenario is defined     | Positive integer |
| tags        | list(atom)   | No       | Optional tags for scenario categorization        | Default: []      |

## Functions

### new/1

Create a new Scenario struct with the given attributes.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Extract name from attributes map (required)
2. Extract given_steps, when_steps, then_steps (default to empty lists)
3. Extract optional line_number and tags
4. Build and return Scenario struct

**Test Assertions**:
- creates scenario with name only
- creates scenario with all step types populated
- defaults step lists to empty when not provided
- accepts line_number when provided
- accepts tags when provided
- preserves order of steps in each list

### changeset/2

Build a changeset for a Scenario struct with validation.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast attrs to name, given_steps, when_steps, then_steps, line_number, and tags
2. Validate that name is required
3. Validate name length is between 1 and 500 characters
4. Validate line_number is positive integer if provided

**Test Assertions**:
- returns valid changeset with all required fields
- returns invalid changeset when name is missing
- returns invalid changeset when name is empty string
- returns invalid changeset when name exceeds 500 characters
- returns invalid changeset when line_number is negative
- returns invalid changeset when line_number is zero
- accepts optional given_steps, when_steps, then_steps
- defaults step lists to empty arrays when not provided
- accepts optional tags list
- preserves step order in changeset

### add_given_step/2

Add a given step description to the scenario's given_steps list.

```elixir
@spec add_given_step(t(), String.t()) :: t()
```

**Process**:
1. Append the step description to the scenario's given_steps list
2. Return updated Scenario struct

**Test Assertions**:
- appends step to empty given_steps list
- appends step to existing given_steps list
- preserves existing steps when adding new step
- maintains step order

### add_when_step/2

Add a when step description to the scenario's when_steps list.

```elixir
@spec add_when_step(t(), String.t()) :: t()
```

**Process**:
1. Append the step description to the scenario's when_steps list
2. Return updated Scenario struct

**Test Assertions**:
- appends step to empty when_steps list
- appends step to existing when_steps list
- preserves existing steps when adding new step
- maintains step order

### add_then_step/2

Add a then step description to the scenario's then_steps list.

```elixir
@spec add_then_step(t(), String.t()) :: t()
```

**Process**:
1. Append the step description to the scenario's then_steps list
2. Return updated Scenario struct

**Test Assertions**:
- appends step to empty then_steps list
- appends step to existing then_steps list
- preserves existing steps when adding new step
- maintains step order

### step_count/1

Count the total number of steps across all step types in the scenario.

```elixir
@spec step_count(t()) :: non_neg_integer()
```

**Process**:
1. Sum the lengths of given_steps, when_steps, and then_steps lists
2. Return total count

**Test Assertions**:
- returns 0 for scenario with no steps
- returns correct count for scenario with only given steps
- returns correct count for scenario with only when steps
- returns correct count for scenario with only then steps
- returns correct count for scenario with all step types
- returns correct count for scenario with multiple steps per type

### has_steps?/1

Check if the scenario has any steps defined.

```elixir
@spec has_steps?(t()) :: boolean()
```

**Process**:
1. Check if any of given_steps, when_steps, or then_steps contain elements
2. Return true if any list is non-empty, false otherwise

**Test Assertions**:
- returns false for scenario with no steps
- returns true for scenario with only given steps
- returns true for scenario with only when steps
- returns true for scenario with only then steps
- returns true for scenario with steps in multiple types

### all_steps/1

Retrieve all steps from the scenario as a single flat list, preserving order (given, when, then).

```elixir
@spec all_steps(t()) :: list(String.t())
```

**Process**:
1. Concatenate given_steps, when_steps, and then_steps in order
2. Return combined list

**Test Assertions**:
- returns empty list for scenario with no steps
- returns only given steps when other types are empty
- returns only when steps when other types are empty
- returns only then steps when other types are empty
- returns all steps in correct order (given, then when, then then)
- preserves step order within each type

## Dependencies

- Ecto.Schema
- Ecto.Changeset
