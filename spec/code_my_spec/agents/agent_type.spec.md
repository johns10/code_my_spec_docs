# CodeMySpec.Agents.AgentType

Embedded schema representing an agent type configuration. Defines the structure for different types of AI agents including their prompts, descriptions, implementations, and tool configurations. Used as an embedded schema without a primary key for flexible agent type definitions within the system.

## Fields

| Field            | Type           | Required | Description                                      | Constraints      |
| ---------------- | -------------- | -------- | ------------------------------------------------ | ---------------- |
| name             | string         | Yes      | Unique identifier name for the agent type        |                  |
| prompt           | string         | Yes      | System prompt template for the agent             |                  |
| description      | string         | Yes      | Human-readable description of the agent's purpose |                  |
| implementation   | string         | No       | Module or implementation reference for the agent | Nullable         |
| config           | map            | No       | Additional configuration options for the agent   | Default: %{}     |
| additional_tools | array (string) | No       | List of extra tool identifiers available to agent | Default: []      |

## Functions

### changeset/2

Builds a changeset for creating or updating an AgentType struct with validation.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast the provided attributes to the schema fields: name, prompt, description, implementation, config, additional_tools
2. Validate that required fields (name, prompt, description) are present

**Test Assertions**:
- returns valid changeset when all required fields are provided
- returns invalid changeset when name is missing
- returns invalid changeset when prompt is missing
- returns invalid changeset when description is missing
- accepts nil for optional implementation field
- uses empty map as default for config when not provided
- uses empty list as default for additional_tools when not provided
- casts config as a map type
- casts additional_tools as an array of strings

## Dependencies

- Ecto.Schema
- Ecto.Changeset
