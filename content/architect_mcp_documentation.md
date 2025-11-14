# Architect MCP Server - Phoenix Context Design Assistant

## Overview

The Architect MCP Server (`components-server`) is CodeMySpec's Phoenix context architecture interface that enables Claude Code and Claude Desktop to create, manage, and analyze component definitions (Phoenix contexts) and their dependencies. This server implements the Model Context Protocol (MCP) to provide context mapping, dependency validation, and architectural health analysis.

## What It Does

The Architect Server manages Phoenix context architecture by:

1. **Creating and managing components** (contexts) with type classification
2. **Defining dependencies** between contexts with circular dependency detection
3. **Linking stories to components** that satisfy them
4. **Analyzing architecture health** against Phoenix best practices
5. **Validating context boundaries** (domain vs coordination separation)

Components represent Phoenix contexts and their constituent modules (schemas, repositories, LiveViews, etc.). The server maintains these as structured data enabling queries, validation, and traceability.

## Philosophy

Per the executive summary transcript, CodeMySpec enforces **systematic processes with clear component boundaries and traceability**. The Architect Server embodies this by:

- Maintaining explicit context boundaries and dependencies in the database
- Validating architectural patterns (flat structure, entity ownership, no circular dependencies)
- Providing traceability from user stories through contexts to implementation files
- Enabling automated health checks against Phoenix architectural standards

## How to Use It

### Prerequisites

1. Install the MCP server in Claude Desktop or Claude Code
2. Ensure you have an active project and account in CodeMySpec
3. Create user stories first (use Stories MCP Server)
4. The server automatically scopes all operations to your active account/project

### Typical Workflow

```
1. Create contexts → Define domain and coordination contexts
2. Link stories → Assign stories to implementing contexts
3. Define dependencies → Declare which contexts depend on others
4. Validate → Check for circular dependencies and architectural issues
5. Review → Analyze architecture health periodically
6. Refine → Update contexts as understanding evolves
```

## Available Tools

### Core Operations

#### create_component

**Purpose:** Creates a single component (context or module).

**Parameters:**
- `name` (string, required): Component name (e.g., "Stories", "ApiKeys")
- `component_type` (enum, required): Type of component (see Component Types below)
- `module_name` (string, optional): Full Elixir module path (e.g., "MyApp.Stories")
- `description` (string, optional): Component description

**Returns:** Created component with ID and metadata

**Example:**
```json
{
  "name": "Stories",
  "component_type": "context",
  "module_name": "CodeMySpec.Stories",
  "description": "Manages user story creation and lifecycle"
}
```

#### create_components

**Purpose:** Creates multiple components in batch.

**Parameters:**
- `components` (list of maps, required): Array of component objects with name, component_type, module_name, description

**Returns:** Successful creations and any validation errors

**Behavior:**
- Processes all components even if some fail
- Returns successes and failures separately
- Failures include index and error details

#### get_component

**Purpose:** Retrieves a single component by ID.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Component details including dependencies and assigned stories

#### list_components

**Purpose:** Lists all components in the current project.

**Parameters:**
- `component_type` (enum, optional): Filter by component type

**Returns:** Array of components with dependencies and story counts

#### update_component

**Purpose:** Updates an existing component.

**Parameters:**
- `id` (integer, required): Component ID
- `name` (string, optional): New name
- `component_type` (enum, optional): New type
- `module_name` (string, optional): New module path
- `description` (string, optional): New description

**Returns:** Updated component or validation errors

#### delete_component

**Purpose:** Deletes a component.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Success confirmation or error

**Behavior:**
- Removes all dependencies involving this component
- Unlinks any stories assigned to this component

### Dependency Management

#### create_dependency

**Purpose:** Creates a dependency relationship between two components.

**Parameters:**
- `source_component_id` (integer, required): Component that depends on another
- `target_component_id` (integer, required): Component being depended upon

**Returns:** Created dependency or validation error

**Validation:**
- Cannot create circular dependencies
- Both components must exist
- Cannot create duplicate dependencies

#### create_dependencies

**Purpose:** Creates multiple dependencies in batch.

**Parameters:**
- `dependencies` (list of maps, required): Array of {source_component_id, target_component_id}

**Returns:** Successful creations and validation errors

**Behavior:**
- Validates each dependency for circular references
- Processes all even if some fail
- Returns successes and failures separately

#### delete_dependency

**Purpose:** Removes a dependency relationship.

**Parameters:**
- `source_component_id` (integer, required): Source component
- `target_component_id` (integer, required): Target component

**Returns:** Success confirmation or error

### Story Integration

#### set_story_component

**Purpose:** Links a story to the component that satisfies it.

**Parameters:**
- `story_id` (integer, required): Story ID
- `component_id` (integer, required): Component ID

**Returns:** Updated story with component assignment

**Note:** This tool is available in both Stories and Architect servers for convenience.

#### list_stories

**Purpose:** Lists all stories in the current project.

**Parameters:**
- `status` (enum, optional): Filter by story status (in_progress, completed, dirty)
- `unsatisfied` (boolean, optional): If true, return only stories without assigned components

**Returns:** Array of stories with component assignments

### Design Session Tools

#### start_context_design

**Purpose:** Begins a guided architecture design session.

**Parameters:** None

**What it does:**
- Loads all unsatisfied stories (stories without assigned components)
- Loads existing components and dependencies
- Provides AI with architect persona and Phoenix design principles
- Generates structured prompt guiding context mapping discussion

**Architect Guidelines:**
- Use entity ownership to determine context boundaries
- Distinguish domain contexts (own entities) from coordination contexts (orchestrate workflows)
- Maintain flat structure (no nested contexts)
- Ensure single responsibility per context
- Identify and validate dependencies
- Map each story to exactly one responsible context

**Example Usage:**
```
User: Let's design the context architecture
AI: [Uses start_context_design]
AI: I see 12 unsatisfied stories covering authentication, API keys, and conversations.
    Let's map these to contexts. Should authentication and user management
    be one context or separate? Also, API keys might need rate limiting...
```

#### review_context_design

**Purpose:** Conducts comprehensive architecture quality review.

**Parameters:** None

**What it does:**
- Loads all components with dependencies and story assignments
- Evaluates against Phoenix context best practices
- Identifies architectural issues and risks

**Review Criteria:**
- Circular dependencies (error condition)
- Orphaned contexts (contexts with no assigned stories)
- Unsatisfied stories (stories without assigned contexts)
- Excessive dependencies (contexts depending on many others)
- Domain/coordination separation
- Entity ownership clarity
- Context size and complexity

**Example Output:**
```
## Architecture Review

**Current Architecture:**
- 12 domain contexts, 3 coordination contexts
- 45 stories satisfied, 3 unsatisfied
- 0 circular dependencies

**Findings:**
- ApiKeys context depends on 4 others - consider splitting
- 3 stories about "user preferences" unassigned
- RateLimiting context has no stories - is it necessary?

**Recommendations:**
1. Create UserPreferences context for unassigned stories
2. Review ApiKeys dependencies for coordination context extraction
```

### Analysis Tools

#### show_architecture

**Purpose:** Displays complete context architecture with dependency graph.

**Parameters:** None

**Returns:** Tree view of all contexts with dependencies, types, and story counts

**Format:**
```
Domain Contexts:
- Stories (5 stories)
  → depends on: Projects
- ApiKeys (3 stories)
  → depends on: Accounts, Projects

Coordination Contexts:
- DesignSessions (2 stories)
  → depends on: Stories, Documents, LLMs
```

#### architecture_health_summary

**Purpose:** Provides architectural metrics and warnings.

**Parameters:** None

**Returns:** JSON with:
- Total context count (domain vs coordination)
- Total story count (satisfied vs unsatisfied)
- Orphaned context count
- Circular dependency count
- Average dependencies per context
- Warnings list

#### context_statistics

**Purpose:** Returns quantitative architecture statistics.

**Parameters:** None

**Returns:** JSON with:
- Context counts by type
- Story satisfaction rate
- Dependency graph metrics
- Component type distribution

#### orphaned_contexts

**Purpose:** Finds contexts with no assigned stories.

**Parameters:** None

**Returns:** List of contexts without story assignments

**Use case:** Identify contexts that may not be necessary or need story assignment

## Component Types

Components are classified by Phoenix architectural pattern:

- **`context`**: Phoenix context (boundary module)
- **`schema`**: Ecto schema (database entity)
- **`repository`**: Data access layer module
- **`live_view`**: Phoenix LiveView module
- **`live_component`**: Phoenix LiveComponent module
- **`controller`**: Phoenix controller
- **`channel`**: Phoenix channel
- **`gen_server`**: OTP GenServer process
- **`supervisor`**: OTP Supervisor
- **`worker`**: Background job worker
- **`migration`**: Database migration
- **`test`**: Test module

Domain contexts typically contain: schemas, repositories, and context boundary modules.
Coordination contexts typically contain: workflows, GenServers, and process orchestration.

## Component Data Model

```elixir
%Component{
  id: integer
  name: string
  component_type: enum  # See Component Types above
  module_name: string | nil
  description: string | nil
  project_id: integer
  account_id: integer
  parent_component_id: integer | nil  # For nested components within contexts
  inserted_at: datetime
  updated_at: datetime

  # Associations
  dependencies: list of Component  # Components this depends on
  dependent_components: list of Component  # Components depending on this
  stories: list of Story  # Stories satisfied by this component
}
```

## Dependency Data Model

```elixir
%Dependency{
  id: integer
  source_component_id: integer  # Component that depends
  target_component_id: integer  # Component being depended upon
  project_id: integer
  account_id: integer
  inserted_at: datetime
}
```

**Validation Rules:**
- Cannot create circular dependencies (A → B → A)
- Cannot create duplicate dependencies
- Both components must belong to same project
- Deleting a component deletes its dependencies

## Design Principles Enforced

### Domain vs Coordination

- **Domain contexts**: Own database schemas and implement business logic for specific entities
- **Coordination contexts**: Orchestrate workflows across domain contexts without owning entities
- System validates separation (coordination contexts should not have schema components)

### Flat Structure

- All contexts exist at the same level (no nested contexts)
- Phoenix best practice: avoid hierarchical context structures
- Dependencies make relationships explicit rather than using nesting

### Entity Ownership

- Each entity (schema) belongs to exactly one domain context
- Entities don't span context boundaries
- Clear ownership enables independent evolution

### Single Responsibility

- Each story maps to exactly one context
- A context satisfies all its assigned stories
- No overlapping responsibilities between contexts

### Explicit Dependencies

- All context relationships declared as dependencies
- Circular dependencies detected and prevented
- Dependency direction matters: coordination → domain (never reverse)

## Security & Multi-Tenancy

All operations are automatically scoped to the active account and project:
- Components cannot be accessed across accounts
- All queries filter by `account_id` and `project_id`
- MCP frame contains scope information passed to all tools
- Story-to-component links validated within project boundaries

## Integration with Workflow

The Architect Server is the **second step** in CodeMySpec's structured development process:

```
1. Stories → Define requirements (Stories MCP Server)
2. Architect (this server) → Design architecture, map stories to contexts
3. Design Sessions → Generate detailed component specs within contexts
4. Test Sessions → Create tests for components based on stories
5. Coding Sessions → Implement components within architectural boundaries
```

Components defined here drive:
- Design session scope (which context to design)
- Test generation targets (which component to test)
- Implementation boundaries (which files to create)
- Traceability (which stories justify each component)

## Tips for Effective Use

1. **Start with stories, not architecture**: Don't design contexts in a vacuum - map actual user stories first
2. **Domain contexts own entities**: Each schema belongs to exactly one domain context
3. **Coordination contexts orchestrate**: Use coordination contexts for cross-context workflows
4. **Make dependencies explicit**: Declare all dependencies even if they seem obvious
5. **Review regularly**: Use `review_context_design` as stories evolve to catch drift
6. **Watch dependency direction**: Coordination → domain is correct; domain → coordination indicates design issue
7. **Name for domain, not implementation**: "Stories" not "StoriesManager", "ApiKeys" not "ApiKeyService"
8. **Check for orphans**: Periodically run `orphaned_contexts` to find unused contexts
9.  **One story, one context**: Each story should map to exactly one implementing context

## Common Patterns

### Typical Domain Context Structure
```
Stories (context)
  ├─ Story (schema)
  ├─ StoriesRepository (repository)
  └─ Stories (boundary module - same as context)
```

### Typical Coordination Context Structure
```
DesignSessions (context)
  ├─ DesignSessions.Orchestrator (GenServer)
  ├─ DesignSessions.Workflow (pure functions)
  └─ DesignSessions (boundary module)

Dependencies: Stories, Documents, LLMs
```

### Dependency Flow Example
```
DesignSessions (coordination)
  → depends on Stories (domain)
  → depends on Documents (domain)
  → depends on LLMs (domain)

Stories (domain)
  → depends on Projects (domain)
  → no dependencies on coordination contexts
```

## Error Handling

**Circular Dependency Errors:**
- Returned when creating a dependency that would form a cycle
- Error includes the cycle path (A → B → C → A)
- Resolution: Identify which context should depend on the other

**Validation Errors:**
- Missing required fields (name, component_type)
- Invalid component type
- Non-existent component IDs in dependencies
- Duplicate dependencies

**Not Found Errors:**
- Component ID doesn't exist
- Component doesn't belong to active project
- Story ID not found when linking

All errors return descriptive messages with resolution guidance.