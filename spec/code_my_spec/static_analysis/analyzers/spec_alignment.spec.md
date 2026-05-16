# CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment

## Type

module

Custom analyzer that validates implementation matches specification definitions. Checks function signatures, type specs, and test assertions against spec documents. Reads spec files from the docs/spec directory, parses them using the Documents context, then compares parsed functions against actual implementation and test files to detect misalignment. Reports Problems for missing functions, mismatched specs, and missing or extra test assertions.

## Delegates

None - all functionality is implemented directly.

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Problems.Problem
- CodeMySpec.Documents
- CodeMySpec.Code.Elixir
- CodeMySpec.Utils.Paths
- File
- Path
