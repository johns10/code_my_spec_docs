# CodeMySpec.StaticAnalysis

## Type

context

Executes optional code quality and correctness tools against a project codebase. Provides a unified interface for running Credo (style/consistency), Boundary (module dependency enforcement), Sobelow (security), and custom static analyzers. Each tool writes output to temporary JSON files for reliable parsing, then normalizes results into Problems for consistent reporting and tracking. Separate from compilation and testing, which remain distinct concepts.

## Delegates

- run_all/2: CodeMySpec.StaticAnalysis.Runner.run_all/2
- run/3: CodeMySpec.StaticAnalysis.Runner.run/3
- list_analyzers/0: CodeMySpec.StaticAnalysis.Runner.list_analyzers/0

## Functions

## Dependencies

- CodeMySpec.Problems
- CodeMySpec.Projects
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.StaticAnalysis.AnalyzerBehaviour

Behaviour defining the interface that all static analyzers must implement. Specifies callbacks for running analysis and checking availability.

### CodeMySpec.StaticAnalysis.Runner

Orchestrates execution of static analyzers against a project. Handles parallel execution, error isolation, and result aggregation.

### CodeMySpec.StaticAnalysis.Analyzers.Credo

Runs Credo static analysis for code consistency and style checks. Executes `mix credo --format json` with file output for reliable JSON parsing, then converts to Problems.

### CodeMySpec.StaticAnalysis.Analyzers.Sobelow

Runs Sobelow security scanner for common Phoenix vulnerabilities. Executes `mix sobelow --format json` with file output for reliable JSON parsing, then converts to Problems.

### CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment

Custom analyzer that validates implementation matches specification definitions. Checks function signatures, type specs, and test assertions against spec documents.