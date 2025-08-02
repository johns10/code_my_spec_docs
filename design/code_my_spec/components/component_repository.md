# Component Repository

## Purpose
Provides data access functions for Component entities with proper scope filtering and preloading.

## Function Categories

### Basic CRUD Operations
- `list_components/1` - List all components in project
- `get_component!/2` - Get component by ID (raises if not found)
- `get_component/2` - Get component by ID (returns nil if not found)
- `create_component/2` - Create new component
- `update_component/3` - Update existing component
- `delete_component/2` - Delete component

### Specialized Queries
- `list_components_with_dependencies/1` - List components with preloaded relationships
- `get_component_with_dependencies/2` - Get single component with relationships
- `get_component_by_module_name/2` - Find component by module name
- `list_components_by_type/2` - Filter components by type
- `search_components_by_name/2` - Search components by name pattern

## Scope Integration

All functions accept a `%CodeMySpec.Users.Scope{}` as the first parameter and automatically filter results by:
- `active_project_id` - Ensures components belong to the current project
- Implicit user access through project membership

## Query Patterns

### Project Scoping
All queries include `where: c.project_id == ^project_id` to ensure proper isolation.

## Error Handling

Functions ending with `!` will raise `Ecto.NoResultsError` if no results found.
Functions without `!` return `nil` for not found cases.
All database errors propagate as standard Ecto exceptions.