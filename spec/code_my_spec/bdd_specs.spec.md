# CodeMySpec.BddSpecs

## Type

context

Context for working with BDD specifications. Provides file-based discovery and coverage analysis of Spex DSL specs without database persistence. Maps specs to stories and acceptance criteria through file naming conventions, enabling traceability between requirements and executable specifications.

## Delegates

### Spex

Delegates to `CodeMySpec.BddSpecs.Spex` for executing BDD specifications.

## Components

### BddSpecs.Spec

Struct representing a parsed BDD specification. Contains spec name, file path, scenarios with step descriptions, and derived story_id/criterion_id from file path. No implementation code retained - just the structural summary.

### BddSpecs.Scenario

Struct representing a scenario within a spec. Contains scenario name and lists of given/when/then step descriptions as strings.

### BddSpecs.Step

Struct representing a Given/When/Then step. Contains step type (:given, :when, :then), description text, and source line number.

### BddSpecs.Parser

Parses Spex DSL files into Spec structs using Elixir AST analysis. Extracts spex, scenario, given_, when_, and then_ macro calls. Returns structured data without implementation code. Not exposed publicly - used internally by the context.

### BddSpecs.SpecProjector

Renders Spec structs into formatted output. Provides coverage reports and summary views. Not exposed publicly - used internally by the context for report generation.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Stories.Story
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Users.Scope
