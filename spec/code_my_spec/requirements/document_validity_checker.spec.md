# CodeMySpec.Requirements.DocumentValidityChecker

Validates that a document file contains valid content according to its document type definition.
Uses `CodeMySpec.Documents.create_dynamic_document/2` to validate the document structure.

Implements the `CodeMySpec.Requirements.CheckerBehaviour` behaviour.

## Delegates

None.

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Components.Registry
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Documents
- CodeMySpec.Utils
- CodeMySpec.Environments
- CodeMySpec.Users.Scope

## Functions

### check/4

Validates a component's spec document against its document type definition.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) :: map()
```

**Process**:
1. Extract the component type from the component struct
2. Look up the type definition from the Registry to get the document_type
3. Call validate_document/4 to read and validate the spec file
4. Return a requirement result map with name, artifact_type, description, checker_module, satisfied_by, satisfied boolean, score (1.0 or 0.0), checked_at timestamp, and details

**Test Assertions**:
- validates a valid context_spec document and returns satisfied: true with document_type "context_spec"
- validates a valid spec document and returns satisfied: true with document_type "spec"
- validates a valid schema document and returns satisfied: true with document_type "schema"
- returns error for document missing required sections with satisfied: false
- returns error for document with disallowed sections with satisfied: false
- returns error when spec file does not exist with reason "Failed to read spec file"
- returns error when component type is nil (no document_type specified)
- includes all required fields in result: name, artifact_type, description, checker_module, satisfied_by, satisfied, checked_at, details