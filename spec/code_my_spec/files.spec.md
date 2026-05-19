# CodeMySpec.Files

Filesystem-to-DB projection of tracked project files. Stores path, role, mtime, fingerprint, validity, owning component. Drives auto-embedding (project_knowledge + hex_doc roles) so semantic_search reflects current disk state.

## Type

context

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Configurations
- CodeMySpec.Documents
- CodeMySpec.Embeddings
- CodeMySpec.Environments
- CodeMySpec.Git
- CodeMySpec.Paths
- CodeMySpec.Problems
- CodeMySpec.Projects
- CodeMySpec.Repo
- CodeMySpec.StaticAnalysis
- CodeMySpec.Stories
- CodeMySpec.Users

