---
glob: "**/code_my_spec/*.md"
priority: 0
---

# Phoenix Context Design Rules

## Overview
This document defines the standard structure and requirements for designing Phoenix contexts that serve as the public API for bounded contexts in our application architecture.

## Required Sections

### 1. Purpose
- **Single sentence** describing what the context manages
- Focus on the business domain, not technical implementation
- Should clearly indicate the bounded context boundaries

### 2. Entity Ownership
- List the primary entities this context owns and manages
- Include any orchestration responsibilities
- Keep it concise - bullet points acceptable here

### 3. Public API
- Complete function specifications using `@spec` notation
- Include all public functions the context exposes
- Define custom types using `@type` definitions
- Group related functions logically with comments
- Error tuples should be specific and meaningful

### 4. State Management Strategy
- Describe how data flows through the context
- Persistence patterns (Ecto schemas, external APIs, etc.)
- Caching strategies if applicable
- Transaction boundaries and consistency requirements

### 5. Component Diagram
- Text-based hierarchical structure showing internal organization
- Show relationships between schemas, modules, and behaviors
- Keep at architectural level - no implementation details
- Use consistent indentation and clear nesting

### 6. Dependencies
- External contexts this context depends on
- Third-party libraries or services
- Infrastructure requirements
- Keep descriptions brief but specific

### 7. Execution Flow
- Step-by-step walkthrough of primary operations
- Show how public API functions orchestrate internal components
- Include error handling and edge cases
- Number steps clearly for readability

## Design Principles

### API Design
- Functions should be self-documenting through clear naming
- Return consistent error tuples across the context
- Use specific error atoms rather than generic `:error`
- Group related operations logically

### State Management
- Be explicit about persistence strategies
- Clearly define transaction boundaries
- Explain any caching or performance considerations
- Document data flow patterns

### Component Organization
- Show clear separation of concerns
- Indicate behavior contracts where applicable
- Keep internal structure visible but not overwhelming
- Use consistent naming conventions

## What NOT to Include

### Implementation Details
- Specific Ecto query implementations
- Database schema migrations
- Detailed module internals
- Function implementations

### Technical Specifics
- Performance optimization details
- Error handling implementation
- Validation logic specifics
- Infrastructure configuration

### Business Logic
- Domain-specific rules and calculations
- Workflow implementations
- Integration patterns
- Data transformation logic

## Example Structure

```
# Context Name

## Purpose
[Single sentence describing the bounded context]

## Entity Ownership
- [Primary entities managed]
- [Orchestration responsibilities]

## Public API
```elixir
# [Logical grouping of functions]
@spec function_name(params) :: return_type
@type custom_type :: specific_definition
```

## State Management Strategy
### [Strategy Category]
- [Description of approach]

## Component Diagram
```
Context Name
├── [Primary components]
│   └── [Sub-components]
└── [Supporting modules]
```

## Dependencies
- **[Dependency Name]**: [Brief description]

## Execution Flow
1. **[Step Name]**: [Description]
2. **[Next Step]**: [Description]
```