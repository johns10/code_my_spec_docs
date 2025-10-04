# Schema Component Design Document

## Purpose

Define the embedded schema and validation logic for schema component design specifications. Schema components represent Ecto schema entities that define data structures, relationships, and validation rules for persistence in the database.

## Field Documentation

| Field                | Type   | Required | Description                                                                     |
| -------------------- | ------ | -------- | ------------------------------------------------------------------------------- |
| purpose              | string | Yes      | High-level description of what the schema represents and its role in the domain |
| fields               | string | Yes      | List of schema fields with their types, requirements, and descriptions          |
| associations         | string | No       | Description of belongs_to, has_many, has_one, and many_to_many relationships    |
| validation_rules     | string | No       | Changeset validations and business logic constraints                            |
| database_constraints | string | No       | Unique constraints, indexes, and foreign key configurations                     |
| other_sections       | map    | No       | Additional documentation sections for flexibility                               |

## Associations

- No direct database associations (embedded schema)
- No embedded schemas (all fields are simple strings or maps)
- Implements `CodeMySpec.Documents.DocumentBehaviour`

## Validation Rules

### Core Fields
- **purpose**: Required, 1-5000 characters
- **fields**: Required, 1-10000 characters (longer to accommodate detailed field tables)

### Optional Fields
- **associations**: Optional, max 5000 characters
- **validation_rules**: Optional, max 5000 characters
- **database_constraints**: Optional, max 5000 characters
- All other top-level fields are optional to support incremental documentation
- String fields have maximum lengths to prevent abuse

## Database Constraints

This is an embedded schema with no direct database representation. However, it documents:

### Indexes
Documentation should specify recommended indexes for the schema being designed:
- Primary key indexes
- Foreign key indexes
- Unique constraint indexes
- Performance optimization indexes

### Unique Constraints
Documentation should describe unique constraints:
- Single-field uniqueness
- Composite uniqueness (multiple fields)
- Scoped uniqueness (e.g., unique per project_id)

### Foreign Keys
Documentation should specify foreign key relationships:
- Referenced table and column
- Cascade behavior (delete, update)
- Nullability

## Dependencies

- `CodeMySpec.Documents.FieldDescriptionRegistry`
- `CodeMySpec.Documents.DocumentBehaviour`

## Implementation Notes

### Design Decisions

1. **Free Text Fields** - All documentation fields are free text (string) rather than structured data to allow flexibility in documentation style and format.

2. **Required vs Optional Split** - Only `purpose` and `fields` are required to allow incremental documentation while ensuring minimum useful content.

3. **Flexible Other Sections** - The `other_sections` map allows capturing arbitrary documentation without schema changes, supporting evolving documentation needs.

4. **No Scope Validation** - Unlike ContextDesign, SchemaComponentDesign does not validate component existence since schemas are lower-level implementation details.

### Validation Philosophy

- Minimal validation on content to preserve flexibility in documentation format
- Required fields ensure baseline documentation quality
- String length limits prevent abuse while allowing detailed documentation
- No structural validation of table formats or markdown - parsers handle this separately
