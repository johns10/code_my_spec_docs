# CodeMySpec.Issues.Projector

## Type

module

Projects issues from the database to read-only markdown files in `.code_my_spec/issues/`. Each issue is written as a standalone markdown file in the appropriate status subdirectory (incoming/ or accepted/). Dismissed issues are not projected. The projection is idempotent — calling project_all will always produce the correct filesystem state regardless of what an agent may have done to the files.

## Dependencies

- CodeMySpec.Issues.Issue
- CodeMySpec.Environments
- CodeMySpec.Paths
