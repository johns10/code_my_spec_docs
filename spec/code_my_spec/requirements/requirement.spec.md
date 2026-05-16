# CodeMySpec.Requirements.Requirement

Embedded schema representing a component requirement instance with its satisfaction status. Created from RequirementDefinition templates and tracks runtime satisfaction state. Supports both boolean pass/fail via satisfied field and incremental quality scoring (0.0 to 1.0) for nuanced requirement assessment.

## Fields

| Field          | Type         | Required   | Description                                  | Constraints                      |
| -------------- | ------------ | ---------- | -------------------------------------------- | -------------------------------- |
| name           | string       | Yes        | Requirement identifier                       |                                  |
| artifact_type  | enum         | Yes        | Category for UI grouping                     | See artifact_type enum           |
| description    | string       | Yes        | Human-readable requirement description       |                                  |
| checker_module | CheckerType  | Yes        | Module that validates this requirement       |                                  |
| satisfied_by   | SessionType  | No         | Module that can satisfy this requirement     |                                  |
| satisfied      | boolean      | Yes        | Current satisfaction status                  | Determined by score >= threshold |
| score          | float        | No         | Quality score from 0.0 (fail) to 1.0 (pass)  | Range: 0.0-1.0                   |
| checked_at     | utc_datetime | No         | Timestamp of last requirement check          |                                  |
| details        | map          | Yes        | Additional contextual information from check | Default: %{}, includes errors    |
| component_id   | binary_id    | Yes        | Associated component                         | References components.id         |
| inserted_at    | utc_datetime | Yes (auto) | Creation timestamp                           | Auto-generated                   |
| updated_at     | utc_datetime | Yes (auto) | Last update timestamp                        | Auto-generated                   |

**artifact_type enum**:
- `:specification` - Spec files and validity
- `:review` - Review files
- `:code` - Implementation files
- `:tests` - Test files, test status
- `:dependencies` - Dependency satisfaction checks
- `:hierarchy` - Child component checks

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Components.Component
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.CheckerType
- CodeMySpec.Sessions.SessionType
- DateTime
