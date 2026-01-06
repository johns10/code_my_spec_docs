# CodeMySpec.Requirements.DocumentValidityChecker

**Type**: logic

Validates component specification documents against their type-specific schemas. Reads document_type from component type definition to determine which validation rules apply. Returns quality score based on completeness and structural correctness.

## Delegates

None

## Functions

### check/3

Validates document content against component type-specific schema.

```elixir
@spec check(RequirementDefinition.t(), Component.t(), keyword()) :: CheckResult.t()
```

**Process**:
1. Get component type definition from Registry.get_type(component.type)
2. Extract document_type from component type definition
3. Get spec file path from component
4. Read document content from file
5. Get document definition for document_type from Documents.Registry
6. Validate document has all required sections
7. Calculate score based on section completeness (present sections / total required)
8. Build errors list for missing sections
9. Return check result with score, satisfied (score >= threshold), and details

**Test Assertions**:
- returns satisfied true with score 1.0 when all sections present
- returns satisfied false with score < 1.0 when sections missing
- reads document_type from component type definition
- uses document_type to look up validation rules
- returns score 0.0 when document file missing
- returns score 0.0 when document_type not specified in type definition
- returns score based on section ratio (e.g., 3/4 sections = 0.75)
- includes missing sections in error details
- includes document_type in result details
- handles file read errors gracefully
- handles missing component type definition gracefully

## Dependencies

- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.CheckResult
- CodeMySpec.Components.Component
- CodeMySpec.Components.Registry
- CodeMySpec.Documents.Registry
