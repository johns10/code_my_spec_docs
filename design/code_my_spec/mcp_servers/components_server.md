# ComponentsServer Design

## Overview

The ComponentsServer MCP server enables LLMs to manage Phoenix context architecture by providing tools for component CRUD operations, dependency management, and guided context design sessions. It focuses on mapping user stories to Phoenix contexts and managing inter-context dependencies.

## Primary Responsibilities

- Component (Phoenix context) CRUD operations
- Dependency relationship management between contexts
- Context design session orchestration
- Context architecture review and validation
- User story to context mapping facilitation

## Server Structure

### Main Server Module
`CodeMySpec.MCPServers.ComponentsServer`
- Uses Hermes.Server with capabilities: [:tools]
- Similar structure to StoriesServer

### Tool Components

#### CRUD Operations
- `CreateComponent` - Creates new Phoenix contexts with proper validation
- `UpdateComponent` - Updates existing context metadata and descriptions
- `DeleteComponent` - Removes contexts (with dependency validation)
- `GetComponent` - Retrieves single context with relationships
- `ListComponents` - Lists all contexts in project scope

#### Dependency Management
- `CreateDependency` - Creates dependency relationships between contexts
- `DeleteDependency` - Removes dependency relationships

#### Story Integration
- `ListUserStories` - Read-only access to user stories for context design
- `SetStoryComponent` - Specify that a story is satisfied by a component
- `ClearStoryComponent` - Remove the relationship from a story to a component

#### Conversation Starters
- `StartContextDesign` - Initiates context design session with user stories
- `ReviewContextDesign` - Reviews existing context architecture

#### Architectural Statistics

##### `ArchitectureHealthSummary`

- Story coverage: assigned/unassigned counts
- Context distribution: counts by story size (1, 2-6, 7+)
- Dependency issues: missing refs, high fan-out contexts
- Data quality: duplicate stories
- One comprehensive health overview

##### `ContextStatistics`

- Each context: story count, dependency in/out counts
- Sorted by story count or dependency count
- Raw numbers for LLM analysis

## Component Type Restrictions

Components created through this server should be restricted to architectural contexts only:
- `:context` (domain contexts)
- `:coordination_context` (workflow orchestrators)

Other component types (`:genserver`, `:schema`, `:repository`, etc.) are not relevant for high-level architectural design and should be filtered out or prevented.

## Tool Specifications

### CreateComponent
**Purpose**: Create new Phoenix context with proper scoping and validation

**Schema**:
```elixir
schema do
  field :name, :string, required: true
  field :type, :enum, values: [:context, :coordination_context], required: true  
  field :module_name, :string, required: true
  field :description, :string, required: false
end
```

**Validation**:
- Uses Components.create_component/2 with scope
- Validates unique context names within project
- Validates proper Elixir module naming

### CreateDependency
**Purpose**: Create dependency relationship between contexts with validation

**Schema**:
```elixir
schema do
  field :source_component_id, :integer, required: true
  field :target_component_id, :integer, required: true  
  field :type, :enum, values: [:require, :import, :alias, :use, :call, :other], required: true
end
```

**Internal Validation**:
- Runs circular dependency detection during creation
- Prevents self-dependencies

### StartContextDesign
**Purpose**: Initiate guided context design session

**Behavior**:
- Lists current user stories in project
- Lists existing components and dependencies
- Provides expert architect persona prompt
- Guides LLM to create components that satisfy user stories
- Encourages proper domain vs coordination context separation

**Prompt Structure**:
```
You are an expert Elixir architect specializing in Phoenix contexts.
Your job is to design a clean context architecture that satisfies the user stories.

**Current User Stories:**
[Formatted list of stories]

**Existing Components:**
[Current components and dependencies]

**Your Role:**
- Map user stories to Phoenix contexts based on entity ownership
- Use business capability grouping within entity boundaries  
- Ensure flat context structure (no nested contexts)
- Distinguish between domain contexts (own entities) and coordination contexts (orchestrate workflows)
- Create components and dependencies to represent the complete system
```

### ReviewContextDesign  
**Purpose**: Review and validate existing context architecture

**Behavior**:
- Lists all components and dependencies
- Provides architectural review criteria
- Analyzes context boundaries and responsibilities
- Validates story coverage and architectural principles

**Review Criteria**:
- Each user story maps to exactly one context
- Domain contexts own exactly at least entity type
- Coordination contexts don't always own entities
- Dependencies are explicit and justified
- No circular dependencies exist
- Context responsibilities are clear and focused

## Integration Points

### Components Context API
- All component operations go through `CodeMySpec.Components` API
- Leverages existing repository pattern
- Uses scope-based access control

### Stories Context (Read-Only)
- Accesses `CodeMySpec.Stories.list_project_stories/1`
- No story modification capabilities
- Stories formatted in prompts for context design

### Validation Integration
- Uses `Components.validate_dependency_graph/1` internally
- Runs validation on dependency creation
- Returns validation errors in tool responses

## Error Handling

Following StoriesServer patterns:
- Scope validation errors
- Component not found errors  
- Dependency validation failures
- Circular dependency detection
- Database constraint violations

## Response Format

Uses similar mapper pattern as StoriesServer:
- Success responses with created/updated entities
- Error responses with structured error information
- Prompt responses for conversation starters

## Security Considerations

- All operations scoped to user's active project
- No cross-project data access
- Validation prevents invalid architectural relationships
- Read-only access to user stories prevents accidental modification

## Future Considerations

- Story modification integration (when requirements change during design)
- Integration with demo generation (when re-enabled)
- Advanced architectural validation rules
- Context size and complexity metrics