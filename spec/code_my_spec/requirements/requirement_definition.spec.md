# CodeMySpec.Requirements.RequirementDefinition

## Type

schema

Immutable template defining what needs to be checked for a component. Maps to runtime Requirement instances which track satisfaction status. Enables artifact type categorization for UI grouping and clear separation between definition (what to check) and instance (whether satisfied).

## Fields

| Field         | Type          | Required | Description                                      | Constraints                     |
| ------------- | ------------- | -------- | ------------------------------------------------ | ------------------------------- |
| name          | atom          | Yes      | Requirement identifier                           | Must be unique per component    |
| checker       | module        | Yes      | Checker module that validates this requirement   | Must implement CheckerBehaviour |
| satisfied_by  | module \| nil | Yes      | Session module that can satisfy this requirement | Must be valid SessionType       |
| artifact_type | atom          | Yes      | Category for UI grouping                         | See artifact_type enum          |
| description   | string        | Yes      | Human-readable requirement description           |                                 |
| threshold     | float         | No       | Minimum score to consider requirement satisfied  | Range: 0.0-1.0, Default: 1.0    |
| config        | map           | No       | Checker-specific configuration                   | Default: %{}                    |

**artifact_type enum**:
- `:specification` - Spec files
- `:review` - Review files
- `:code` - Implementation files
- `:tests` - Test files, test status
- `:dependencies` - Dependency satisfaction checks
- `:hierarchy` - Child component checks

## Functions

### new/1

Creates a new requirement definition from attributes map with validation.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Extract required fields from attrs map
2. Default threshold to 1.0 if not provided
3. Validate threshold is between 0.0 and 1.0 if provided
4. Default config to empty map if not provided
5. Build and return RequirementDefinition embedded schema

**Test Assertions**:
- creates definition with all required fields
- returns error for invalid checker type
- returns error for invalid session type
- returns error for invalid artifact type
- defaults threshold to 1.0
- accepts valid threshold between 0.0 and 1.0
- returns error for threshold less than 0.0
- returns error for threshold greater than 1.0
- defaults config to empty map

## Dependencies

- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Sessions.SessionType