---
glob: "**/code_my_spec/*.md"
priority: 0
---

# Phoenix Context Design Rules

## Overview
This document defines the standard structure and requirements for designing Phoenix contexts that serve as the public API for bounded contexts in our application architecture, following Phoenix scope patterns for secure data access.

## Required Sections

### 1. Purpose
- **Single sentence** describing what the context manages
- Focus on the business domain, not technical implementation
- Should clearly indicate the bounded context boundaries

### 2. Entity Ownership
- List the primary entities this context owns and manages
- Include any orchestration responsibilities
- Keep it concise - bullet points acceptable here

### 3. Scope Integration
- Check the existing scope file so you're on the right page
- Specify scope access patterns (user-scoped, organization-scoped, etc.)
- Document scope filtering behavior for all public functions

### 4. Public API
- Complete function specifications using `@spec` notation with scope as first parameter
- All data access functions must accept a scope struct as the first argument
- Include all public functions the context exposes
- Define custom types using `@type` definitions
- Group related functions logically with comments
- Error tuples should be specific and meaningful

### 5. State Management Strategy
- Describe how data flows through the context with scope constraints
- Persistence patterns (Ecto schemas with scope foreign keys)
- Transaction boundaries and consistency requirements within scope

### 6. Component Diagram
- Text-based hierarchical structure showing internal organization
- Show relationships between schemas, modules, behaviors, and scope filtering
- Keep at architectural level - no implementation details
- Use consistent indentation and clear nesting
- Use markdown syntax (`- `) for nested lists

### 7. Dependencies
- External contexts this context depends on
- Scope modules and their configuration
- Third-party libraries or services
- Infrastructure requirements
- Keep descriptions brief but specific

### 8. Execution Flow
- Step-by-step walkthrough of primary operations with scope validation
- Show how public API functions orchestrate internal components
- Include scope-based access control and filtering
- Include error handling and edge cases
- Number steps clearly for readability

## Design Principles

### Scope-First Security
- All public functions must accept a scope struct as the first parameter
- Database queries must filter by scope foreign keys (user_id, org_id, etc.)
- Use Phoenix generators with configured scopes for automatic security
- Implement proper scope validation and access control

### API Design
- Functions should be self-documenting through clear naming
- Return consistent error tuples across the context
- Use specific error atoms rather than generic `:error`
- Group related operations logically
- Maintain scope parameter consistency across all functions

### State Management
- Be explicit about persistence strategies with scope constraints
- Clearly define transaction boundaries within scope
- Explain any caching or performance considerations that respect scope
- Document data flow patterns with scope filtering

### Component Organization
- Show clear separation of concerns with scope integration
- Indicate behavior contracts where applicable
- Keep internal structure visible but not overwhelming
- Use consistent naming conventions
- Document scope configuration for generators

## Scope Configuration Requirements

### Generator Integration
- Define scope configuration in `config/config.exs`
- Specify default scope for automatic generator usage
- Include all required scope options: module, assign_key, access_path, schema_key, etc.
- Document test fixtures and helpers for scoped testing

### Security Implementation
- All Ecto queries must include scope filtering
- Use proper foreign key relationships for scope entities
- Implement scope validation in all public functions
- Ensure PubSub subscriptions are scoped appropriately

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

## Scope Integration
### Accepted Scopes
- **Primary Scope**: [Scope module and configuration]
- **Secondary Scopes**: [Additional scopes if applicable]

### Scope Configuration
```elixir
config :my_app, :scopes,
  user: [
    default: true,
    module: MyApp.Accounts.Scope,
    # ... other configuration
  ]
```

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
```
Context Name
├── [Primary components with scope integration]
│   └── [Sub-components]
└── [Supporting modules]
    └── Scope filtering logic
```

## Dependencies
- **[Scope Module]**: [Configuration and usage]
- **[Dependency Name]**: [Brief description]

## Execution Flow
1. **[Scope Validation]**: [Verify scope and access permissions]
2. **[Step Name]**: [Description with scope filtering]
3. **[Next Step]**: [Description]
```