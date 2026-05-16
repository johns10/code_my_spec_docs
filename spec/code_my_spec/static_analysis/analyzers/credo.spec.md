# CodeMySpec.StaticAnalysis.Analyzers.Credo

## Type

module

Runs Credo static analysis for code consistency and style checks. Executes `mix credo suggest --format json --all --all-priorities`, captures stdout to a temporary file for reliable JSON parsing, then converts to Problems. Implements the AnalyzerBehaviour to provide pluggable static analysis capabilities with consistent error handling and result normalization.

## Delegates

None

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemConverter
