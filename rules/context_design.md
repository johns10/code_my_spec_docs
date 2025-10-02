---
component_type: "context"
session_type: "design"
---

# Phoenix Context Design Rules

## Overview
This document defines the standard structure and requirements for designing Phoenix contexts that serve as the public API for bounded contexts in our application architecture, following Phoenix scope patterns for secure data access.

## Design Principles

### Scope-First Security
- All public functions must accept a scope struct as the first parameter
- Database queries must filter by scope foreign keys (user_id, org_id, etc.)

### API Design
- Functions should be self-documenting through clear naming
- Return consistent error tuples across the context
- Group related operations logically
- Maintain scope parameter consistency across all functions

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
