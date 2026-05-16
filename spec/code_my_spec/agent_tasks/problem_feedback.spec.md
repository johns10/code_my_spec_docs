# CodeMySpec.AgentTasks.ProblemFeedback

## Type

module

Shared problem feedback for agent task evaluation. Queries persisted problems for component files and formats actionable feedback for the model. Each agent task type (code, test, spec) has different rules for which problems to include — code tasks include all problems, test tasks filter out test failures (TDD mode), and spec tasks check only the spec file.

## Dependencies

- CodeMySpec.Problems
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Utils
