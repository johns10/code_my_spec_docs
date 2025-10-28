# Components MCP Server - AI Software Architect

## Overview

The Components MCP Server (`components-server`) is CodeMySpec's AI software architect interface that enables Claude Code and Claude Desktop to design, manage, and analyze Phoenix application architecture. This server implements the Model Context Protocol (MCP) to provide component modeling, dependency management, and architectural health analysis capabilities.

## What It Does

The Components Server acts as your AI software architect, helping you:

1. **Design Phoenix contexts and modules** based on user stories
2. **Model component architecture** with proper type classification (context, schema, repository, etc.)
3. **Manage dependencies** between components with cycle detection
4. **Analyze architectural health** with coverage and quality metrics
5. **Link components to stories** to establish traceability
6. **Review and refine architecture** against best practices

Think of it as a conversational interface for transforming user stories into well-structured Phoenix application architecture with clear boundaries and dependencies.

## Philosophy

Building on the Stories Server foundation, the Components Server embodies the principle that **AI excels when guided by structured architectural patterns**:

- Guides AI through systematic Phoenix context design instead of generating ad-hoc module structures
- Enforces architectural boundaries (contexts own entities, dependencies are explicit)
- Maintains human oversight during design review (you approve architecture)
- Creates precise component specifications that drive test and code generation
- Establishes complete traceability from stories → components → tests → code

The result: Component designs become exact specifications that make test generation trivial because architectural decisions have been made deliberately.

## How to Use It

### Prerequisites

1. Install the MCP server in Claude Desktop or Claude Code
2. Have user stories created via the Stories MCP Server
3. Active project and account in CodeMySpec
4. Understanding of Phoenix contexts and application architecture

### Typical Workflow

```
1. Start Context Design → AI guides you through Phoenix architecture
2. Create components (contexts, schemas, repositories, etc.)
3. Define dependencies between components
4. Review architecture health and quality metrics
5. Link components to stories they satisfy
6. Iterate on design based on review feedback
```

## Available Tools

### Architecture Design Tools

#### 1. start_context_design

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
- Context responsibilities are clear and focused
- Flat context structure (no nested contexts)

**Example Usage:**
```
User: [Calls start_context_design]

AI: I see you have 3 unsatisfied stories related to API key management.
    Let me help design the context architecture.

    Based on the stories, I recommend:

    1. ApiKeys context (domain context)
       - Owns ApiKey entity
       - Handles key generation, revocation, rotation
       - Stories: "Create API key", "Revoke API key", "Rotate API key"

    2. Dependencies needed:
       - ApiKeys depends on Accounts (for account scoping)
       - ApiKeys depends on Notifications (for expiration alerts)

    Does this align with your architecture vision?
```

#### 2. review_context_design

**Purpose:** Reviews current context architecture against best practices.

**Parameters:** None

**What it does:**
- Shows complete architecture with dependencies
- Lists unsatisfied stories still needing component assignment
- Validates dependency graph for circular dependencies
- Provides AI with review criteria and questions

**Review Questions:**
1. Are context boundaries aligned with business capabilities?
2. Do any contexts have unclear or overlapping responsibilities?
3. Are there missing contexts needed to satisfy stories?
4. Are dependencies properly justified and non-circular?
5. Should any contexts be split or merged based on cohesion?

**Example Output:**
```
Current Architecture:
- 5 contexts defined
- 3 unsatisfied stories remaining
- No circular dependencies detected ✅

Issues:
- ApiKeys context has 8 stories (consider splitting into ApiKeys + ApiKeyPolicies)
- Authentication context has no dependencies (may be missing session storage)
- Story "User exports audit log" has no assigned component

Recommendations:
1. Create AuditLog context for export story
2. Split ApiKeys if key policies become complex
3. Add Authentication → Sessions dependency
```

#### 3. show_architecture

**Purpose:** Shows complete system architecture with comprehensive details.

**Parameters:** None

**Returns:** JSON with:
- Full dependency graph with relationships
- All stories associated with each component
- Architecture layers organized by dependency depth
- Detailed component information and metrics

**Architecture Layers:**
- **Depth 0**: Entry points (components with stories)
- **Depth 1+**: Dependency layers (ordered by dependency depth)

**Example Response Structure:**
```json
{
  "architecture": {
    "overview": {
      "total_components": 12,
      "components_with_stories": 5,
      "total_dependencies": 8,
      "architecture_layers": [...]
    },
    "components": [
      {
        "component": {
          "id": 1,
          "name": "ApiKeys",
          "type": "context",
          "module_name": "MyApp.ApiKeys",
          "stories": [...],
          "dependencies": [...],
          "metrics": {
            "story_count": 3,
            "dependency_count": 2
          }
        },
        "depth": 0,
        "layer": "Entry Points"
      }
    ],
    "dependency_graph": {...}
  }
}
```

#### 4. architecture_health_summary

**Purpose:** Provides comprehensive health overview of system architecture.

**Parameters:** None

**Health Metrics:**

**Story Coverage:**
- Entry components (components with stories)
- Dependency components (dependencies of entry points)
- Orphaned components (no stories, not dependencies)
- Story coverage percentage
- Health status: excellent/good/fair/poor

**Context Distribution:**
- Story count distribution across components
- High-story components (7+ stories = potential split candidates)
- Distribution health status

**Dependency Issues:**
- Missing references (broken dependency links)
- High fan-out components (5+ dependencies)
- Circular dependencies
- Dependency health status

**Overall Score:**
- Coverage score (0-100, based on orphaned component percentage)
- Dependency score (0-100, penalties for issues)
- Overall health score (average)
- Health level: excellent/good/fair/poor

**Example Output:**
```json
{
  "architecture_health": {
    "story_coverage": {
      "total_components": 15,
      "entry_components": 6,
      "dependency_components": 7,
      "orphaned_components": 2,
      "story_coverage_percentage": 75.0,
      "health_status": "good"
    },
    "dependency_issues": {
      "circular_dependencies": [],
      "high_fan_out_components": [
        {"name": "Accounts", "dependency_count": 6}
      ],
      "dependency_health": "good"
    },
    "overall_score": {
      "overall_score": 82.5,
      "health_level": "good"
    }
  }
}
```

### Component CRUD Operations

#### 5. create_component

**Purpose:** Creates a single component.

**Parameters:**
- `name` (string, required): Component name (e.g., "ApiKeys")
- `type` (enum, required): Component type
- `module_name` (string, required): Full Elixir module name (e.g., "MyApp.ApiKeys")
- `description` (string, optional): Component purpose and responsibilities
- `priority` (integer, optional): Implementation priority
- `parent_component_id` (integer, optional): Parent component ID for hierarchical structures

**Component Types:**
- `:context` - Domain context owning entities
- `:coordination_context` - Workflow orchestration context
- `:schema` - Ecto schema (database entity)
- `:repository` - Data access layer
- `:genserver` - GenServer process
- `:task` - Oban/Task background job
- `:registry` - Process registry or lookup service
- `:behaviour` - Elixir behaviour definition
- `:other` - Other component types

**Returns:** Created component with ID and metadata

**Example:**
```json
{
  "name": "ApiKeys",
  "type": "context",
  "module_name": "MyApp.ApiKeys",
  "description": "Manages API key generation, revocation, and rotation for external service authentication",
  "priority": 1
}
```

#### 6. create_components

**Purpose:** Creates multiple components in batch.

**Parameters:**
- `components` (list of maps, required): Array of component definitions

**Returns:** Successful creations and any validation errors

**Behavior:**
- Processes all components even if some fail
- Returns successes and failures separately
- Failures include index and error details

**Use case:** After design discussion, AI can create all designed components at once

#### 7. update_component

**Purpose:** Updates an existing component.

**Parameters:**
- `id` (integer, required): Component ID
- `name`, `type`, `module_name`, `description`, `priority`, `parent_component_id` (all optional)

**Returns:** Updated component or validation errors

#### 8. get_component

**Purpose:** Retrieves a single component by ID.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Component details with dependencies and stories

#### 9. list_components

**Purpose:** Lists all components in the current project.

**Parameters:** None

**Returns:** Array of components with full details

#### 10. delete_component

**Purpose:** Deletes a component.

**Parameters:**
- `id` (integer, required): Component ID

**Returns:** Success confirmation or error

**Note:** Cascade behavior depends on database constraints

### Dependency Management

#### 11. create_dependency

**Purpose:** Creates a dependency relationship between two components.

**Parameters:**
- `source_component_id` (integer, required): Component that depends on target
- `target_component_id` (integer, required): Component being depended upon

**Returns:** Created dependency or validation error

**Validation:**
- Prevents self-dependencies
- Detects circular dependencies
- Ensures both components exist

**Example:**
```json
{
  "source_component_id": 1,  // ApiKeys context
  "target_component_id": 5   // Accounts context
}
```

#### 12. create_dependencies

**Purpose:** Creates multiple dependencies in batch.

**Parameters:**
- `dependencies` (list of maps, required): Array of dependency definitions

**Returns:** Successful creations and any validation errors

**Use case:** After creating components, define all dependencies at once

#### 13. delete_dependency

**Purpose:** Removes a dependency relationship.

**Parameters:**
- `id` (integer, required): Dependency ID

**Returns:** Success confirmation or error

### Analysis and Statistics

#### 14. context_statistics

**Purpose:** Provides detailed statistics about contexts in the project.

**Parameters:** None (implementation depends on your codebase)

**Returns:** Context-specific metrics and analysis

#### 15. orphaned_contexts

**Purpose:** Lists contexts that have no stories and aren't dependencies.

**Parameters:** None (implementation depends on your codebase)

**Returns:** List of orphaned contexts that may need review or removal

**Use case:** Identifying components created but never linked to requirements

### Story Integration

#### 16. list_stories

**Purpose:** Lists all stories in the current project (shared from Stories Server).

**Parameters:** None

**Returns:** Array of stories with full details

**Use case:** Reference stories when designing components

#### 17. set_story_component

**Purpose:** Links a story to the component that satisfies it (shared from Stories Server).

**Parameters:**
- `story_id` (integer, required): Story ID
- `component_id` (integer, required): Component ID

**Returns:** Updated story or error

**Use case:** After creating components, assign them to the stories they implement

## Component Data Model

```elixir
%Component{
  id: integer
  name: string
  type: :context | :coordination_context | :schema | :repository | :genserver | :task | :registry | :behaviour | :other
  module_name: string  # Full Elixir module name
  description: string | nil
  priority: integer | nil
  project_id: integer
  account_id: integer
  parent_component_id: integer | nil

  # Associations
  stories: [Story]
  outgoing_dependencies: [Dependency]  # Components this depends on
  incoming_dependencies: [Dependency]  # Components that depend on this
  requirements: [Requirement]  # Implementation requirements
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

## Phoenix Architecture Patterns

### Domain Context
**Purpose:** Owns and manages one or more entity types
**Example:** `Accounts`, `ApiKeys`, `Projects`
**Characteristics:**
- Has Ecto schemas
- Has business logic
- May have repository pattern
- Entry point for domain operations

### Coordination Context
**Purpose:** Orchestrates workflows across multiple domain contexts
**Example:** `ProjectCoordinator`, `CheckoutWorkflow`
**Characteristics:**
- No owned entities
- Calls multiple domain contexts
- Implements complex workflows
- May use Sagas or Process Managers

### Component Types

| Type | Purpose | Example |
|------|---------|---------|
| `:context` | Domain context owning entities | `MyApp.Accounts` |
| `:coordination_context` | Workflow orchestration | `MyApp.ProjectCoordinator` |
| `:schema` | Database entity | `MyApp.Accounts.User` |
| `:repository` | Data access layer | `MyApp.Accounts.UserRepository` |
| `:genserver` | Stateful process | `MyApp.Cache.Server` |
| `:task` | Background job | `MyApp.Workers.EmailSender` |
| `:registry` | Process lookup | `MyApp.SessionRegistry` |
| `:behaviour` | Interface definition | `MyApp.PaymentGateway` |
| `:other` | Other components | Custom types |

## Security & Multi-Tenancy

All operations are automatically scoped:
- Components cannot be accessed across accounts
- All queries filter by `account_id`
- Project context determines which components are visible
- MCP frame contains scope information

## Integration with Workflow

The Components Server is the **second step** in CodeMySpec's structured AI development process:

```
1. Stories → Define requirements (Stories Server)
2. Components → Plan architecture (this server)
3. Component Design Sessions → Generate detailed designs
4. Component Test Sessions → Generate tests
5. Component Coding Sessions → Implement with TDD
```

Components created here drive:
- Test generation (what to test)
- Implementation order (dependency resolution)
- File creation (module names and types)
- Traceability (which component satisfies which story)

## Tips for Effective Use

### Design Process
1. **Start with interview**: Use `start_context_design` before creating components
2. **Map stories to contexts**: Each story should have one primary context
3. **Define boundaries first**: Establish what each context owns before implementation
4. **Create components in batch**: Use `create_components` after design discussion
5. **Add dependencies after**: Create all components, then define relationships
6. **Review regularly**: Use `review_context_design` and `architecture_health_summary` to validate

### Architecture Quality
1. **Keep contexts focused**: 1-6 stories per context is healthy, 7+ may need splitting
2. **Make dependencies explicit**: Don't hide context coupling
3. **Avoid circular dependencies**: Use coordination contexts to break cycles
4. **Name modules precisely**: `module_name` drives file generation
5. **Use proper types**: Type classification affects test generation
6. **Document responsibilities**: `description` helps future design decisions

### Health Monitoring
1. **Watch orphaned components**: Components with no stories and no dependents may be unnecessary
2. **Monitor fan-out**: Contexts with 5+ dependencies may be doing too much
3. **Aim for 100% story coverage**: All components should trace to stories or be dependencies
4. **Review distribution**: Many contexts with 7+ stories suggests over-loading

## Example Session

```
User: I have 5 stories about API key management. Help me design the architecture.

User: [Calls start_context_design]

AI: I can see the following unsatisfied stories:
    1. Account admin creates API key
    2. Account admin revokes API key
    3. Account admin rotates API key
    4. System sends expiration notifications
    5. API authenticates requests with keys

    Based on these, I recommend:

    **ApiKeys Context** (domain context)
    - Owns: ApiKey entity
    - Stories: 1, 2, 3
    - Responsibilities: Key lifecycle management
    - Module: MyApp.ApiKeys

    **ApiAuthentication Context** (coordination context)
    - Owns: No entities
    - Stories: 5
    - Responsibilities: Validates keys, enforces rate limits
    - Module: MyApp.ApiAuthentication

    **Dependencies:**
    - ApiKeys → Accounts (scope keys to accounts)
    - ApiKeys → Notifications (expiration alerts)
    - ApiAuthentication → ApiKeys (validate keys)

    Questions:
    1. Do keys need scopes/permissions?
    2. Should we track key usage/analytics?
    3. Any rate limiting requirements?

User: No scopes for v1. Yes to usage tracking. Rate limiting per account.

AI: Got it. Adding:

    **ApiUsage Context** (domain context)
    - Owns: ApiRequest entity
    - Stories: (new story needed: "Track API usage")
    - Module: MyApp.ApiUsage

    Updated dependencies:
    - ApiAuthentication → ApiUsage (log requests)
    - ApiAuthentication → RateLimiter (enforce limits)

    Shall I create these components?

User: Yes, create them.

AI: [Calls create_components with 4 contexts]
    [Calls create_dependencies with relationships]
    [Calls set_story_component for stories 1-5]

    Created 4 components with dependencies.
    Would you like me to review the architecture health?

User: Yes

AI: [Calls architecture_health_summary]

    Architecture Health: EXCELLENT (Score: 95/100)
    - 4 components, 5 stories satisfied
    - 0 orphaned components ✅
    - 0 circular dependencies ✅
    - Average 1.25 stories per context ✅

    One note: You mentioned tracking API usage.
    Should I create that story or add it to the backlog?
```

## Advanced Features

### Dependency Graph Validation

The server automatically validates:
- **Circular dependencies**: Detects cycles in dependency graph
- **Missing references**: Identifies broken dependency links
- **Self-dependencies**: Prevents components depending on themselves

### Architecture Layers

Components are organized by dependency depth:
- **Depth 0**: Entry points with user stories
- **Depth 1**: Direct dependencies of entry points
- **Depth 2+**: Transitive dependencies

This layering helps with:
- Implementation order (bottom-up from highest depth)
- Understanding system structure
- Identifying architectural boundaries

### Health Scoring

**Coverage Score (0-100):**
```
100 - orphaned_percentage
```
- Penalizes components that don't trace to stories or dependencies

**Dependency Score (0-100):**
```
100 - (missing_refs * 10) - (high_fan_out * 5) - (circular_deps * 20)
```
- Penalizes broken references, high coupling, and cycles

**Overall Score:**
```
(coverage_score + dependency_score) / 2
```

**Health Levels:**
- 85-100: Excellent
- 70-84: Good
- 50-69: Fair
- 0-49: Poor

## Technical Implementation

**Framework:** Hermes MCP Server
**Exposed as:** `components-server` v1.0.0
**Capabilities:** Tools only (no resources or prompts)
**Language:** Elixir
**Location:** `lib/code_my_spec/mcp_servers/components_server.ex`

**Tool Components:**
```elixir
# Core CRUD
component(CodeMySpec.MCPServers.Components.Tools.CreateComponent)
component(CodeMySpec.MCPServers.Components.Tools.UpdateComponent)
component(CodeMySpec.MCPServers.Components.Tools.DeleteComponent)
component(CodeMySpec.MCPServers.Components.Tools.GetComponent)
component(CodeMySpec.MCPServers.Components.Tools.ListComponents)

# Batch operations
component(CodeMySpec.MCPServers.Components.Tools.CreateComponents)
component(CodeMySpec.MCPServers.Components.Tools.CreateDependencies)

# Dependency management
component(CodeMySpec.MCPServers.Components.Tools.CreateDependency)
component(CodeMySpec.MCPServers.Components.Tools.DeleteDependency)

# Architecture and design
component(CodeMySpec.MCPServers.Components.Tools.StartContextDesign)
component(CodeMySpec.MCPServers.Components.Tools.ReviewContextDesign)
component(CodeMySpec.MCPServers.Components.Tools.ShowArchitecture)
component(CodeMySpec.MCPServers.Components.Tools.ArchitectureHealthSummary)
component(CodeMySpec.MCPServers.Components.Tools.ContextStatistics)
component(CodeMySpec.MCPServers.Components.Tools.OrphanedContexts)

# Story integration (from Stories Server)
component(CodeMySpec.MCPServers.Stories.Tools.ListStories)
component(CodeMySpec.MCPServers.Stories.Tools.SetStoryComponent)
```

## Related Documentation

- **Stories MCP Server**: First step - define requirements
- **Executive Summary**: Project philosophy and approach
- **Session Orchestration**: How components drive design and test sessions
- **Component Design Sessions**: Detailed component design generation
- **Component Test Sessions**: Test generation from components

## Conclusion

The Components MCP Server transforms architectural design from "LLM generates random module structure" into a structured, human-guided conversation that produces precise Phoenix application architecture. By enforcing Phoenix patterns (contexts, dependencies, types) and maintaining human oversight during design review, you create the foundation where test and code generation become trivial because the architectural thinking has been done deliberately with AI as your expert advisor, not your autopilot.
