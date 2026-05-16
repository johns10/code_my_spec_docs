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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
