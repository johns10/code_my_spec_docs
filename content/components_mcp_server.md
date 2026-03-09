# Components MCP Server - Technical Reference

## Overview

The Components MCP Server (`components-server`) is CodeMySpec's web-accessible MCP server for designing, managing, and analyzing Phoenix application architecture. It exposes 17 tools for component CRUD, dependency management, similar component tracking, architecture design sessions, and health analysis.

**Endpoint:** `/mcp/components` (web)
**Transport:** Streamable HTTP via Hermes MCP
**Auth:** OAuth2 token required, ProjectScopeOverride plug

## What It Does

The Components Server acts as your AI software architect, helping you:

1. **Design Phoenix contexts and modules** based on user stories
2. **Model component architecture** with proper type classification
3. **Manage dependencies** between components with cycle detection
4. **Track similar components** to identify potential consolidation opportunities
5. **Analyze architectural health** with coverage and quality metrics
6. **Link components to stories** to establish traceability
7. **Review and refine architecture** against best practices

## Available Tools (17)

### Core CRUD (5 tools)

#### create_component

**Purpose:** Creates a single component.

**Parameters:**
- `name` (string, required): Component name (e.g., "ApiKeys")
- `type` (string, required): Component type - must be "context" or "coordination_context"
- `module_name` (string, required): Full Elixir module name (e.g., "MyApp.ApiKeys")
- `description` (string, optional): Component purpose and responsibilities
- `parent_component_id` (integer, optional): Parent component ID for hierarchical structures

**Returns:** Created component with ID and metadata

**Example:**
```json
{
  "name": "ApiKeys",
  "type": "context",
  "module_name": "MyApp.ApiKeys",
  "description": "Manages API key generation, revocation, and rotation"
}
```

#### update_component

**Purpose:** Updates an existing component.

**Parameters:**
- `id` (integer, required): Component ID
- `name`, `type`, `module_name`, `description`, `parent_component_id` (all optional)

**Returns:** Updated component or validation errors

#### delete_component

**Purpose:** Deletes a component.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Success confirmation or error

#### get_component

**Purpose:** Retrieves a single component by ID.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Component details with dependencies, stories, and requirements

#### list_components

**Purpose:** Lists all components in the current project.

**Parameters:** None

**Returns:** Array of components with full details

### Dependency Management (2 tools)

#### create_dependency

**Purpose:** Creates a dependency relationship between two components.

**Parameters:**
- `source_component_id` (integer, required): Component that depends on target
- `target_component_id` (integer, required): Component being depended upon

**Returns:** Created dependency or validation error

**Validation:**
- Prevents self-dependencies
- Detects circular dependencies
- Ensures both components exist

#### delete_dependency

**Purpose:** Removes a dependency relationship.

**Parameters:**
- `id` (string, required): Dependency ID

**Returns:** Deleted dependency details with source and target component summaries

### Similar Components (2 tools)

#### add_similar_component

**Purpose:** Creates a similar-component relationship between two components.

**Parameters:**
- `component_id` (integer, required): First component
- `similar_component_id` (integer, required): Component similar to the first

**Returns:** Both component summaries with success confirmation

**Use case:** Mark components that have overlapping responsibilities to flag potential consolidation during architecture review.

#### remove_similar_component

**Purpose:** Removes a similar-component relationship.

**Parameters:**
- `component_id` (integer, required): First component
- `similar_component_id` (integer, required): Component to unlink

**Returns:** Both component summaries with deletion confirmation

### Architecture & Design (6 tools)

#### start_context_design

**Purpose:** Initiates a guided Phoenix context design session with an AI architect.

**Parameters:** None

**What it does:**
- Loads unsatisfied user stories (stories without assigned components)
- Loads existing components and dependencies
- Provides AI with Phoenix architecture expert persona
- Generates structured prompt for context design discussion

**Architecture Principles:**
- Each user story maps to exactly one context
- Domain contexts own at least one entity type
- Coordination contexts orchestrate workflows across domains
- Dependencies are explicit and justified
- No circular dependencies
- Flat context structure (no nested contexts)

#### review_context_design

**Purpose:** Reviews current context architecture against best practices.

**Parameters:** None

**What it does:**
- Shows complete architecture with dependencies
- Lists unsatisfied stories still needing component assignment
- Validates dependency graph for circular dependencies
- Provides AI with review criteria and questions

**Review criteria:**
- Context boundaries aligned with business capabilities
- No unclear or overlapping responsibilities
- No missing contexts needed to satisfy stories
- Dependencies properly justified and non-circular
- Contexts appropriately sized (1-6 stories healthy, 7+ may need splitting)

#### show_architecture

**Purpose:** Shows complete system architecture with comprehensive details.

**Parameters:** None

**Returns:** JSON with:
- Full dependency graph with relationships
- All stories associated with each component
- Architecture layers organized by dependency depth
- Detailed component information and metrics

#### architecture_health_summary

**Purpose:** Provides comprehensive health overview of system architecture.

**Parameters:** None

**Health metrics:**
- **Story coverage:** Entry components, dependency components, orphaned components, coverage percentage
- **Context distribution:** Story count distribution, high-story components (7+ = split candidates)
- **Dependency issues:** Missing references, high fan-out (5+ deps), circular dependencies
- **Overall score:** Coverage score + dependency score averaged, health level (excellent/good/fair/poor)

#### context_statistics

**Purpose:** Provides detailed statistics about contexts in the project.

**Parameters:** None

**Returns:** Context-specific metrics and analysis

#### orphaned_contexts

**Purpose:** Lists contexts that have no stories and are not dependencies of other components.

**Parameters:** None

**Returns:** List of orphaned contexts that may need review or removal

### Story Linkage (1 tool)

#### set_story_component

**Purpose:** Links a story to the component that satisfies it (shared from Stories Server).

**Parameters:**
- `story_id` (integer, required): Story ID
- `component_id` (integer, required): Component ID

**Returns:** Updated story with component assignment

**Note:** Also includes `list_stories` from the Stories Server for reference during design.

## Component Types

Components are classified by Phoenix architectural pattern. The full set of types in the system:

| Type                    | Purpose                                  |
| ----------------------- | ---------------------------------------- |
| `context`               | Domain context owning entities           |
| `coordination_context`  | Workflow orchestration context           |
| `schema`                | Ecto schema (database entity)            |
| `repository`            | Data access layer                        |
| `genserver`             | Stateful GenServer process               |
| `task`                  | Background job or one-time operation     |
| `registry`              | Process registry for dynamic lookup      |
| `controller`            | Phoenix controller handling HTTP/JSON    |
| `json`                  | Phoenix JSON view for controller         |
| `liveview`              | Phoenix LiveView page                    |
| `liveview_component`    | Reusable Phoenix LiveView component      |
| `live_context`          | UI grouping of related LiveViews         |
| `behaviour`             | Elixir behaviour definition              |
| `other`                 | Custom component type                    |

**Note:** The `create_component` tool currently restricts `type` to "context" and "coordination_context". Child components (schemas, repositories, etc.) are created as children of contexts via `parent_component_id`.

## Component Data Model

```elixir
%Component{
  id: uuid_v5           # Deterministic UUID based on module_name
  name: string
  type: string          # See Component Types above
  module_name: string   # Full Elixir module name
  description: string | nil
  parent_component_id: integer | nil
  project_id: integer
  account_id: integer

  # Associations
  stories: [Story]
  outgoing_dependencies: [Dependency]   # Components this depends on
  incoming_dependencies: [Dependency]   # Components that depend on this
  requirements: [Requirement]           # Implementation requirements
  component_status: ComponentStatus | nil

  inserted_at: datetime
  updated_at: datetime
}
```

```elixir
%Dependency{
  id: integer
  source_component_id: integer  # Component that depends
  target_component_id: integer  # Component being depended on
  source_component: Component
  target_component: Component
  inserted_at: datetime
  updated_at: datetime
}
```

## Component Hierarchy

Components follow a parent-child hierarchy based on module namespace:
- A context like `MyApp.Accounts` is the parent
- Its schemas (`MyApp.Accounts.User`), repositories (`MyApp.Accounts.UserRepository`), etc. are children
- Children reference their parent via `parent_component_id`
- Dependencies are between contexts, not between child components

Components are synced with spec files on the filesystem, enabling both database and file-based workflows.

## Security & Multi-Tenancy

All operations are automatically scoped:
- Components cannot be accessed across accounts
- All queries filter by `account_id` and `project_id`
- MCP frame contains scope information from OAuth2 token
- Story-to-component links validated within project boundaries

## Integration with Workflow

The Components Server is the **second step** in CodeMySpec's structured AI development process:

```
1. Stories Server       -> Define requirements
2. Components Server    -> Plan architecture (this server)
3. Design Sessions      -> Generate detailed component specs
4. Test Sessions        -> Generate tests from specs
5. Coding Sessions      -> Implement with TDD
```

Components created here drive:
- Test generation (what to test)
- Implementation order (dependency resolution)
- File creation (module names and types)
- Traceability (which component satisfies which story)
- Requirement tracking (spec files, reviews, implementations, tests)

## Technical Implementation

**Framework:** Hermes MCP Server
**Server name:** `components-server` v1.0.0
**Capabilities:** Tools only (no resources or prompts)
**Location:** `lib/code_my_spec/mcp_servers/components_server.ex`

**Tool modules:**
```elixir
# Core CRUD
component(CodeMySpec.McpServers.Components.Tools.CreateComponent)
component(CodeMySpec.McpServers.Components.Tools.UpdateComponent)
component(CodeMySpec.McpServers.Components.Tools.DeleteComponent)
component(CodeMySpec.McpServers.Components.Tools.GetComponent)
component(CodeMySpec.McpServers.Components.Tools.ListComponents)

# Dependency management
component(CodeMySpec.McpServers.Components.Tools.CreateDependency)
component(CodeMySpec.McpServers.Components.Tools.DeleteDependency)

# Similar components
component(CodeMySpec.McpServers.Components.Tools.AddSimilarComponent)
component(CodeMySpec.McpServers.Components.Tools.RemoveSimilarComponent)

# Architecture and design
component(CodeMySpec.McpServers.Components.Tools.StartContextDesign)
component(CodeMySpec.McpServers.Components.Tools.ReviewContextDesign)
component(CodeMySpec.McpServers.Components.Tools.ShowArchitecture)
component(CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary)
component(CodeMySpec.McpServers.Components.Tools.ContextStatistics)
component(CodeMySpec.McpServers.Components.Tools.OrphanedContexts)

# Story integration (from Stories Server)
component(CodeMySpec.McpServers.Stories.Tools.SetStoryComponent)
```

**Note:** `ListStories` and `SetStoryComponent` from the Stories Server are also registered, bringing the active tool count to 17 (5 CRUD + 2 dependency + 2 similar + 6 architecture + 2 story integration = 17).

## Error Handling

**Validation errors:**
- Missing required fields (name, type, module_name)
- Invalid component type
- Circular dependency detection
- Self-dependency prevention
- Duplicate dependencies

**Not found errors:**
- Component ID does not exist
- Component does not belong to active project
- Dependency ID not found

**Permission errors:**
- Component belongs to different account
- Invalid OAuth2 token

All errors return descriptive messages with field-level details for validation failures.
