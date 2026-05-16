# CodeMySpec.StaticAnalysis.AnalyzerBehaviour

## Type

module

Behaviour defining the interface that all static analyzers must implement. Specifies callbacks for running analysis and checking availability. Each analyzer implements these callbacks to execute its specific tool (Credo, Boundary, Sobelow, or custom analyzers) and normalize results into Problem structs for consistent reporting. This behaviour enables pluggable static analysis with uniform error handling and result aggregation.

## Delegates

None - this module defines callbacks only.

## Dependencies

- CodeMySpec.Problems.Problem
- CodeMySpec.Users.Scope
