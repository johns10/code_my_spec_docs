---
component_type: "context"
session_type: "design"
---

# Phoenix Context Design Rules

## Overview
This document defines the standard structure and requirements for designing Phoenix contexts that serve as the public API for bounded contexts in our application architecture, following Phoenix scope patterns for secure data access.

## Required Sections

### 1. Purpose
- **Single paragraph** describing what the context manages
- Focus on the business domain, not technical implementation
- Should clearly indicate the bounded context boundaries

### 2. Entity Ownership
- List the primary entities this context owns and manages
- Keep it concise - bullet points acceptable here

### 3. Access Patterns
- Document how data access is controlled via scope
- Review scope/scopes files to understand access control patterns

### 4. Public API
- Complete function specifications using `@spec` notation
- All data access functions must accept a `Scope` struct as the first argument
- Include all public functions the context exposes
- Group related functions logically with comments
- Error tuples should be specific and meaningful

### 5. State Management Strategy
- Describe how data flows through the context
- Persistence patterns (Ecto schemas with scope foreign keys)

### 6. Components

**Structure**: Use H3 headers for each component module, followed by description text and optional tables.

**Requirements**:
- Each component must start with H3 header (`###`)
- Module names must be valid Elixir modules (PascalCase)
- Include brief description after each table
- Tables are required to provide the type of the module
- Focus on architectural relationships, not implementation details

### 7. Dependencies

**Format**: Simple bullet list of module names only.

**Requirements**:
- Use markdown bullet points (`-` or `*`)
- Each item must be a valid Elixir module name (PascalCase)
- No descriptions or explanations - just the module names
- Only include contexts found inside this application
- Keep the list focused and concise

### 8. Execution Flow
- Step-by-step walkthrough of primary operation
- Show how public API functions orchestrate internal components
- Number steps clearly for readability

## Design Principles

### Scope-First Security
- All public functions must accept a scope struct as the first parameter
- Database queries must filter by scope foreign keys (user_id, org_id, etc.)

### API Design
- Functions should be self-documenting through clear naming
- Return consistent error tuples across the context
- Group related operations logically
- Maintain scope parameter consistency across all functions

### State Management
- Be explicit about persistence strategies
- Explain any caching or performance considerations
- Document data flow patterns

### Component Organization
- Show clear separation of concerns
- Indicate behavior contracts where applicable
- Keep internal structure visible but not overwhelming
- Use consistent naming conventions

## What NOT to Include

### Implementation Details
- Specific Ecto query implementations (but document scope filtering requirements)
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

### Access Patterns
- [Description of how scope filtering works]
- [Foreign key relationships]

## Public API
```elixir
# [Logical grouping of functions]
@spec function_name(scope :: Scope.t(), params) :: return_type
@type custom_type :: specific_definition

# All functions must accept scope as first parameter
@spec list_entities(Scope.t()) :: [Entity.t()]
@spec get_entity!(Scope.t(), id :: integer()) :: Entity.t()
@spec create_entity(Scope.t(), attrs :: map()) :: {:ok, Entity.t()} | {:error, Changeset.t()}
```

## State Management Strategy
### [Strategy Category]
- [Description of approach with scope constraints]

## Component Diagram
### ModuleName

| field | value                                                                        |
| ----- | ---------------------------------------------------------------------------- |
| type  | genserver/context/coordination_context/schema/repository/task/registry/other |

Brief description of the component's responsibility.

## Dependencies
- ExternalContext.ModuleName
- OtherExternalContext.ModuleName

## Execution Flow
1. **[Scope Validation]**: [Verify scope and access permissions]
2. **[Step Name]**: [Description with scope filtering]
3. **[Next Step]**: [Description]
```