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

## Dependencies

- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Sessions.SessionType
