# CodeMySpec.StaticAnalysis.Analyzers.Sobelow

## Type

module

Runs Sobelow security scanner for common Phoenix vulnerabilities. Executes `mix sobelow --format json --private`, captures stdout to a temporary file for reliable JSON parsing, then converts to Problems. Implements the AnalyzerBehaviour to provide consistent interface for static analysis execution.

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour
- System (for executing mix commands)
- File (for temporary file operations)
- Jason (for JSON parsing)
