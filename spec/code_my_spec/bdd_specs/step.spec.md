# CodeMySpec.BddSpecs.Step

**Type**: schema (non-persisted)

Struct representing a single Given/When/Then step within a scenario. Contains the step type, human-readable description, and source line number for traceability back to the original spec file.

## Fields

| Field       | Type    | Required | Description                                      | Constraints                          |
| ----------- | ------- | -------- | ------------------------------------------------ | ------------------------------------ |
| type        | atom    | Yes      | Step type indicator                              | Values: :given, :when, :then         |
| description | string  | Yes      | Human-readable description of the step           | -                                    |
| line        | integer | No       | Source line number in the spec file              | Used for error reporting and tracing |

## Functions

### new/3

Creates a new Step struct with the given type, description, and optional line number.

```elixir
@spec new(atom(), String.t(), keyword()) :: t()
```

**Process**:
1. Build a Step struct with the provided type and description
2. Extract line number from opts, defaulting to nil if not provided
3. Return the Step struct

**Test Assertions**:
- creates step with :given type
- creates step with :when type
- creates step with :then type
- stores description string
- stores line number when provided
- defaults line to nil when not provided
- validates type is one of :given, :when, :then

### new/2

Creates a new Step struct with the given type and description.

```elixir
@spec new(atom(), String.t()) :: t()
```

**Process**:
1. Call new/3 with empty opts
2. Return the Step struct

**Test Assertions**:
- creates step without line number
- delegates to new/3 with empty opts

### given/2

Creates a new Given step with the given description and optional line number.

```elixir
@spec given(String.t(), keyword()) :: t()
```

**Process**:
1. Call new/3 with type :given, the description, and opts
2. Return the Step struct

**Test Assertions**:
- creates step with :given type
- stores description
- passes line number through to new/3

### when_step/2

Creates a new When step with the given description and optional line number.

```elixir
@spec when_step(String.t(), keyword()) :: t()
```

**Process**:
1. Call new/3 with type :when, the description, and opts
2. Return the Step struct

**Test Assertions**:
- creates step with :when type
- stores description
- passes line number through to new/3

### then_step/2

Creates a new Then step with the given description and optional line number.

```elixir
@spec then_step(String.t(), keyword()) :: t()
```

**Process**:
1. Call new/3 with type :then, the description, and opts
2. Return the Step struct

**Test Assertions**:
- creates step with :then type
- stores description
- passes line number through to new/3

### to_string/1

Converts a Step struct to a human-readable string format.

```elixir
@spec to_string(t()) :: String.t()
```

**Process**:
1. Pattern match on step type
2. Format as "Given <description>", "When <description>", or "Then <description>"
3. Return formatted string

**Test Assertions**:
- formats :given step as "Given <description>"
- formats :when step as "When <description>"
- formats :then step as "Then <description>"
- capitalizes step type keyword

### type_valid?/1

Validates that a step type is one of the allowed values.

```elixir
@spec type_valid?(atom()) :: boolean()
```

**Process**:
1. Check if type is in [:given, :when, :then]
2. Return boolean result

**Test Assertions**:
- returns true for :given
- returns true for :when
- returns true for :then
- returns false for invalid types
- returns false for nil

## Dependencies

- Ecto.Schema
