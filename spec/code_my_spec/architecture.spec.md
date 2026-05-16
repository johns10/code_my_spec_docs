# CodeMySpec.Architecture

A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides projectors that create documentation artifacts (component hierarchies, namespace trees) written to the repository and synchronized with current project state during full syncs.

## Delegates

- generate_overview/1: CodeMySpec.Architecture.OverviewProjector.project/1
- generate_namespace_hierarchy/1: CodeMySpec.Architecture.NamespaceProjector.project/1

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Users.Scope
