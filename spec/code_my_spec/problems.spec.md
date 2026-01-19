# CodeMySpec.Problems

**Type**: context

The Problems context provides a unified abstraction for problems, warnings, and errors discovered across different analysis tools and validation processes. It normalizes heterogeneous tool outputs into a consistent data model that can be used both ephemerally (in-memory during sessions) and persistently (stored for project-level fitness tracking).

## Delegates

- list_project_problems/2: CodeMySpec.Problems.ProblemRepository.list_project_problems/2
- create_problems/2: CodeMySpec.Problems.ProblemRepository.create_problems/2
- replace_project_problems/2: CodeMySpec.Problems.ProblemRepository.replace_project_problems/2
- clear_project_problems/1: CodeMySpec.Problems.ProblemRepository.clear_project_problems/1
- from_credo/1: CodeMySpec.Problems.ProblemConverter.from_credo/1
- from_compiler/1: CodeMySpec.Problems.ProblemConverter.from_compiler/1
- from_test_failure/1: CodeMySpec.Problems.ProblemConverter.from_test_failure/1

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Repo
- Ecto.Schema
- Ecto.Changeset

## Components

### CodeMySpec.Problems.ProblemConverter

Utility module for transforming heterogeneous tool outputs (Credo, compiler warnings, test failures) into normalized Problem structs. Provides consistent data transformation regardless of source tool format.

### CodeMySpec.Problems.Problem

Schema representing a normalized problem from any analysis or testing tool. Supports both ephemeral (in-memory) usage during sessions and persistent storage for project-level fitness tracking.

### CodeMySpec.Problems.ProblemRepository

Repository module providing scoped data access operations for problems. Handles database queries with proper scope filtering and user/project isolation.
