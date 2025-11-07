# Code My Spec: AI-Driven Phoenix Context Architect
## Comprehensive System Architecture Analysis

---

## Executive Summary

**Code My Spec** is a sophisticated Phoenix application that orchestrates AI agents to automatically generate Phoenix contexts for new applications. The system coordinates two primary roles:

1. **Product Manager Part**: Manages user stories, requirements gathering, and acceptance criteria
2. **Architect Part**: Designs context architecture, generates component designs, and validates architectural consistency

The system creates a complete workflow from user story collection → context design → component design → architectural review → code generation, all facilitated through structured agent sessions and coordination workflows.

---

## 1. Agent Coordination Architecture

### 1.1 Agent Types System

The application defines 5 specialized agent types (`lib/code_my_spec/agents/agent_types.ex`):

```elixir
@type agent_type() :: 
  :unit_coder              # General coding assistance
  | :context_designer      # Phoenix context design expert
  | :context_reviewer      # Reviews context/component design for architectural consistency
  | :component_designer    # Designs individual components
  | :test_writer           # Writes tests and fixtures
```

**Key Architecture Decisions:**
- Agents are **ephemeral** (not persisted) - created on-demand for specific tasks
- Each agent type has a specialized prompt guiding its role and constraints
- Agent implementations are pluggable via application configuration
- ClaudeCodeAgent is the primary implementation using Claude Code CLI

### 1.2 Agent Type Specifications

#### Context Designer
```
Description: "Designs Phoenix contexts with proper architecture"
Focus Areas:
- Clean boundaries and responsibilities
- Well-defined components
- Proper schema relationships
- Public API design
- Testing strategies
```

#### Context Reviewer
```
Description: "Reviews Phoenix context designs for architectural consistency"
Focus Areas:
- Architectural consistency and Phoenix best practices
- Integration between context and child components
- Alignment with user stories and requirements
- Identifying and fixing design issues
```

#### Component Designer
```
Description: "Designs components of Phoenix contexts"
Focus Areas:
- Clarity of purpose and boundaries
- Testability
- Simplicity of design
- Only designing necessary functionality
```

### 1.3 MCP Servers: Agent-Tool Integration

The system exposes agent capabilities through **Model Context Protocol (MCP) servers**:

#### Stories MCP Server (`lib/code_my_spec/mcp_servers/stories_server.ex`)
Provides tools for the "Product Manager" agent role:
- `CreateStory` / `CreateStories` - Define requirements
- `UpdateStory` - Refine user stories
- `ListStories` - Review all requirements
- `StartStoryInterview` - Conduct requirement gathering
- `StartStoryReview` - Validate completeness

#### Components MCP Server (`lib/code_my_spec/mcp_servers/components_server.ex`)
Provides tools for the "Architect" agent role:
- `CreateComponent` / `CreateComponents` - Define contexts
- `CreateDependency` / `CreateDependencies` - Establish relationships
- `UpdateComponent` - Refine context design
- **`StartContextDesign`** - Architect initiates context design (Product Manager interaction!)
- **`ReviewContextDesign`** - Architect reviews current architecture
- `ShowArchitecture` - Display full system architecture
- `ArchitectureHealthSummary` - Validate architectural quality

### 1.4 Coordinator Pattern: Session Orchestration

All agent coordination happens through **Sessions** - persistent workflow records that track:

```elixir
%Session{
  type: session_type,              # Determines workflow steps
  agent: :claude_code,             # Which agent implementation
  environment: :local | :vscode,   # Execution environment
  execution_mode: :manual | :agentic, # How commands execute
  status: :active | :complete | :failed,
  state: %{},                      # Session-specific workflow state
  interactions: [                  # Command/result history
    %Interaction{
      command: %Command{},         # What to execute
      result: %Result{}            # What happened
    }
  ]
}
```

---

## 2. Product Manager Functionality

### 2.1 Product Manager Role Overview

The "Product Manager part" handles **user story management and requirements gathering**:

**Responsibilities:**
1. Define application vision through executive summary
2. Gather user stories through LLM-driven interviews
3. Manage and refine user stories
4. Define acceptance criteria
5. Track story satisfaction across components
6. Impact analysis when stories change

### 2.2 Stories Context (`lib/code_my_spec/stories.ex`)

**Core Operations:**
```elixir
# Story lifecycle
create_story(scope, attrs)              # PM creates new story
list_stories(scope)                     # View all requirements
list_unsatisfied_stories(scope)         # Stories without implementation
list_project_stories(scope)             # Project-scoped requirements

# Story refinement
update_story(scope, story, attrs)       # PM edits stories
change_story(scope, story, attrs)       # Track changes

# Story satisfaction
set_story_component(scope, story, component_id)   # Mark as satisfied
clear_story_component(scope, story)              # Unassign component
list_component_stories(scope, component_id)     # Which stories does this satisfy?
```

### 2.3 MCP Tools for PM Workflow

**Story Interview Tool** (`StartStoryInterview`):
- Initiates guided conversation with Claude
- Claude asks clarifying questions about requirements
- Captures acceptance criteria
- Generates structured user story data

**Story Review Tool** (`StartStoryReview`):
- Analyzes stories for gaps and conflicts
- Checks for completeness and clarity
- Suggests refinements
- Prepares for architectural mapping

### 2.4 PM ↔ Architect Handoff

The Product Manager role hands off to the Architect through:

1. **Unsatisfied Stories List** - Stories awaiting context assignment
2. **Story Components Link** - When architect creates contexts, PM sees them mapped to stories
3. **Architecture Review** - Architect validates stories are satisfied by proposed architecture

---

## 3. Architect Functionality

### 3.1 Architect Role Overview

The "Architect part" handles **context design, validation, and architectural oversight**:

**Responsibilities:**
1. Map user stories to Phoenix contexts
2. Design context architecture respecting entity ownership
3. Generate comprehensive design documentation
4. Review component designs for consistency
5. Validate architectural quality and dependencies
6. Ensure Phoenix best practices

### 3.2 Components Context Architecture

**Key Domain Concepts:**
```elixir
%Component{
  name: "Users",
  type: :domain,              # :domain or :coordination
  description: "User management context",
  module_name: "MyApp.Users",
  
  # Relationships
  outgoing_dependencies: [%Dependency{target_component_id: ...}],
  incoming_dependencies: [%Dependency{source_component_id: ...}],
  
  # Story satisfaction
  stories: [%Story{}]
}
```

**Context Types:**
- **Domain Context**: Owns entities and business logic
- **Coordination Context**: Orchestrates workflows across domains

### 3.3 Architect Session Types

The system provides multiple session types orchestrating the architect workflow:

#### 3.3.1 ContextDesignSessions
**Purpose**: Design entire new application contexts from user stories

**Workflow Steps**:
1. **Initialize** - Set up git branch and environment
2. **Documentation Generation** - AI generates comprehensive context design
3. **Validation** - Check design against Phoenix patterns
4. **Component Creation** - Generate Phoenix scaffolding

#### 3.3.2 ComponentDesignSessions  
**Purpose**: Design individual components within a context (AI-driven, no scaffolding)

**Workflow Steps**:
1. **Initialize** - Setup environment
2. **Read Context Design** - Load parent context for reference
3. **GenerateComponentDesign** - AI generates component design
4. **Validate Design** - Check against rules
5. **Revise Design** - Loop until passing validation
6. **Finalize** - Complete session

#### 3.3.3 ContextComponentsDesignSessions (Key Architect Coordination)
**Purpose**: Coordinate design of ALL components in a context in parallel

**Workflow Steps**:
1. **Initialize** - Create git branch
2. **SpawnComponentDesignSessions** - Create child sessions for each component (PARALLEL!)
3. **SpawnReviewSession** - Create review session for consistency validation
4. **Finalize** - Create pull request with all designs

**This is the key architect coordination pattern:**
```
ContextComponentsDesignSessions (Parent)
├── ComponentDesignSession #1 (Product Component)
├── ComponentDesignSession #2 (Cart Component)
├── ComponentDesignSession #3 (Order Component)
└── ComponentDesignReviewSession (Validates consistency across all)
```

#### 3.3.4 ContextDesignReviewSessions
**Purpose**: Comprehensive architectural review of context + all component designs

**Workflow Steps**:
1. **ExecuteReview** - Claude reviews ALL designs holistically:
   - Context design document
   - All child component designs
   - User stories (for alignment)
   - Project executive summary
   - Validates consistency, integration points, architectural quality
2. **Finalize** - Mark complete and stage review file

### 3.4 MCP Tools for Architect Workflow

**StartContextDesign**:
```
Architect's entry point for context mapping
- Displays unsatisfied user stories
- Shows existing components
- Instructs Claude to map stories to contexts
- Focus: entity ownership, business capability grouping
```

**ReviewContextDesign**:
```
Architect review of current state
- Shows architecture summary
- Lists unsatisfied stories (what's missing?)
- Checks dependency validation (circular deps?)
- Guides architect toward completion
```

**ShowArchitecture**:
```
Full architectural visualization
- Displays all components (contexts)
- Shows dependencies
- Indicates which stories are satisfied
- JSON output for programmatic access
```

### 3.5 Architecture Validation

The system validates architectural quality through:

**1. Dependency Graph Validation**
```elixir
Components.validate_dependency_graph(scope)
# Returns :ok or {:error, cycles}
# Detects circular dependencies
```

**2. Entity Ownership Rules**
- Each domain context owns exactly one entity type
- Coordination contexts orchestrate without owning entities
- Prevents responsibility blurring

**3. Story Satisfaction Coverage**
- Tracks unsatisfied stories
- Reports gaps in context coverage
- Ensures all requirements are mapped

---

## 4. Phoenix Context Generation Workflow

### 4.1 End-to-End Workflow

```
┌─────────────────────────────────────────────────────┐
│ Product Manager Phase: Requirements                 │
├─────────────────────────────────────────────────────┤
│ 1. Create user stories (via LLM interview)          │
│ 2. Refine and approve user stories                  │
│ 3. Review completeness                              │
│ 4. Identify unsatisfied requirements                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Architect Phase 1: Context Design                   │
├─────────────────────────────────────────────────────┤
│ 1. Map stories to contexts (StartContextDesign)    │
│ 2. Create component definitions                     │
│ 3. Establish dependencies                           │
│ 4. Validate architecture (ReviewContextDesign)      │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Architect Phase 2: Component Design (Parallel)      │
├─────────────────────────────────────────────────────┤
│ ContextComponentsDesignSessions                     │
│ ├── SpawnComponentDesignSessions (creates N child) │
│ │   ├── ComponentDesignSession #1 → Design         │
│ │   ├── ComponentDesignSession #2 → Design         │
│ │   └── ComponentDesignSession #N → Design         │
│ │       (all running in parallel via agentic mode) │
│ └── SpawnReviewSession → Review consistency        │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Architect Phase 3: Validation & Review              │
├─────────────────────────────────────────────────────┤
│ ContextDesignReviewSessions                         │
│ → Holistic review of all designs                    │
│ → ExecuteReview: Comprehensive validation           │
│ → Finalize: Mark approved, create PR                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Output: Phoenix Context Documentation               │
├─────────────────────────────────────────────────────┤
│ - Context design documents (1:1 to code files)      │
│ - Component design specifications                   │
│ - Architecture review findings                      │
│ - Ready for implementation                          │
└─────────────────────────────────────────────────────┘
```

### 4.2 Session Execution Modes

**Manual Mode** (Default):
- Commands execute in user's terminal
- User controls flow
- Good for exploration and learning

**Agentic Mode** (Parallel Coordination):
- Commands execute autonomously
- Client loops through workflow automatically
- Enables parallel child session execution
- External conversation ID tracks Claude SDK state

### 4.3 Session State Management

Each session maintains state through:

```elixir
%Session{
  state: %{
    # Context-specific workflow state
    parent_context_name: "Users",
    context_design_path: "path/to/design.md",
    validation_feedback: "...",
    revision_count: 1
  },
  
  # Interaction history (full audit trail)
  interactions: [
    %Interaction{
      command: %Command{module: Steps.Initialize, ...},
      result: %Result{status: :ok, output: "..."}
    },
    %Interaction{
      command: %Command{module: Steps.GenerateComponentDesign, ...},
      result: %Result{status: :ok, output: "Generated design"}
    }
  ]
}
```

**Key Principles:**
- All state persisted immediately after each step
- Interactions form complete audit trail
- Sessions recoverable from database
- No temporary state - everything reproducible

---

## 5. Key Modules and Responsibilities

### 5.1 Core Coordination

| Module                                         | Responsibility                                              |
| ---------------------------------------------- | ----------------------------------------------------------- |
| `Sessions.Orchestrator`                        | Main coordinator - routes to session-specific orchestrators |
| `ContextDesignSessions.Orchestrator`           | Manages context design workflow steps                       |
| `ContextComponentsDesignSessions.Orchestrator` | Coordinates parallel component design + review              |
| `ComponentDesignSessions.Orchestrator`         | Manages individual component design workflow                |
| `ContextDesignReviewSessions.Orchestrator`     | Manages architectural review workflow                       |

### 5.2 Session Step Modules

Each session type has step implementations following `StepBehaviour`:

```elixir
@callback get_command(Scope.t(), Session.t(), opts) :: {:ok, Command.t()} | {:error, term()}
@callback handle_result(Scope.t(), Session.t(), Result.t(), opts) :: {:ok, state, Result.t()} | {:error, term()}
```

**Example Steps:**
- `ContextComponentsDesignSessions.Steps.SpawnComponentDesignSessions` - Creates child sessions
- `ContextComponentsDesignSessions.Steps.SpawnReviewSession` - Creates review session
- `ComponentDesignSessions.Steps.GenerateComponentDesign` - AI design generation
- `ComponentDesignSessions.Steps.ValidateDesign` - Design validation
- `ComponentDesignSessions.Steps.ReviseDesign` - Iterative improvement

### 5.3 Agent & Execution

| Module                                       | Responsibility                           |
| -------------------------------------------- | ---------------------------------------- |
| `Agents.AgentTypes`                          | Registry of all agent types with prompts |
| `Agents.Implementations.ClaudeCodeAgent`     | Claude Code CLI execution                |
| `Environments.VSCode` / `Environments.Local` | Environment-specific execution           |

### 5.4 Domain: Stories (Product Manager)

| Module                       | Responsibility                                         |
| ---------------------------- | ------------------------------------------------------ |
| `Stories`                    | Story CRUD and satisfaction tracking                   |
| `Stories.Story`              | Story schema - title, description, acceptance criteria |
| `MCPServers.Stories.Tools.*` | Story operations exposed to LLM agents                 |
| `MCPServers.StoriesServer`   | MCP endpoint for story tools                           |

### 5.5 Domain: Components (Architect)

| Module                          | Responsibility                                   |
| ------------------------------- | ------------------------------------------------ |
| `Components`                    | Component CRUD and dependency management         |
| `Components.Component`          | Component schema - contexts and their properties |
| `Components.Dependency`         | Inter-component dependency relationships         |
| `MCPServers.Components.Tools.*` | Architecture operations exposed to architect     |
| `MCPServers.ComponentsServer`   | MCP endpoint for component tools                 |

### 5.6 Rules & Validation

| Module                             | Responsibility                         |
| ---------------------------------- | -------------------------------------- |
| `Rules.RulesRepository`            | Store and retrieve architectural rules |
| `Rules.RulesComposer`              | Combine rules for specific tasks       |
| Validation rules in `/docs/rules/` | Entity-specific design constraints     |

---

## 6. Data Flow: Product Manager ↔ Architect Coordination

### 6.1 Stories to Components Bridge

```
Product Manager Creates Stories
    ↓
Stories.list_unsatisfied_stories()
    ↓ [Displayed to Architect]
Architect Reviews in StartContextDesign Tool
    ↓
Architect Creates Components (Contexts)
    ↓ [Via CreateComponent Tool]
Stories.set_story_component()
    ↓ [PM can now see satisfaction]
Stories.list_satisfied_stories()
    ↓
PM validates all stories satisfied
```

### 6.2 Parallel Component Design Coordination

```
Architect Approves Component List
    ↓
ContextComponentsDesignSessions.Steps.SpawnComponentDesignSessions
    ↓ [Creates N child sessions in agentic mode]
    ├── ComponentDesignSession #1 (agentic: true)
    ├── ComponentDesignSession #2 (agentic: true)
    └── ComponentDesignSession #N (agentic: true)
    ↓ [All run in parallel - external_conversation_id tracks each]
Client monitors completion
    ↓
All child sessions complete
    ↓
SpawnReviewSession creates review session
    ↓
Review validates consistency across all
    ↓
ContextDesignReviewSessions.ExecuteReview
    ↓
Final architectural review document
```

### 6.3 Revision Loops in Component Design

```
ComponentDesignSessions.Steps.GenerateComponentDesign
    ↓ [AI generates design]
ComponentDesignSessions.Steps.ValidateDesign
    ↓
    ├─ PASS: → Finalize ✅
    └─ FAIL: → ReviseDesign
         ↓ [AI revises based on feedback]
         └─ Loop back to ValidateDesign
```

---

## 7. System Architecture Highlights

### 7.1 Separation of Concerns

**Product Manager Responsibilities:**
- User story collection and management
- Requirement clarification through LLM interview
- Tracking story satisfaction
- Impact analysis for changes

**Architect Responsibilities:**
- Context design and entity ownership
- Dependency management
- Architectural validation
- Design documentation
- Quality assurance

**Both roles use Claude via MCP tools** but with domain-specific prompts and operations.

### 7.2 Parallel Execution via Session Nesting

```elixir
# Parent session coordinates child sessions
parent_session = create_session(%{
  type: ContextComponentsDesignSessions,
  execution_mode: :agentic,
  component_id: context_component_id
})

# Step creates multiple child sessions (one per component)
child_sessions = create_child_sessions(parent_session, components)

# Client orchestrates parallel execution
Enum.each(child_session_ids, fn session_id ->
  execute_agentic_session(session_id)
end)

# Wait for all children, then review
wait_for_children(parent_session.child_sessions)
review_session = create_review_session(parent_session)
execute_agentic_session(review_session.id)
```

### 7.3 Validation-Driven Revision Loops

The system uses **explicit revision loops** for quality improvement:

```
Generate → Validate → (FAIL) → Revise → Validate → (PASS) → Finalize
```

Each iteration:
1. Validation provides specific feedback
2. Revision step processes feedback
3. Return to validation
4. Track iteration count to prevent infinite loops

### 7.4 Complete Audit Trail

Every session maintains full history:
- All commands executed
- All results returned
- All state transitions
- Complete timestamps

This enables:
- Perfect reproducibility
- Debugging failed sessions
- Learning from failures (postmortem analysis)
- Audit compliance

---

## 8. Technology Stack & Patterns

### 8.1 Core Technologies

| Layer           | Technology                                  |
| --------------- | ------------------------------------------- |
| Language        | Elixir/Phoenix                              |
| Database        | PostgreSQL (with JSON JSONB state field)    |
| LLM Integration | Claude API (via Claude Code CLI for agents) |
| Protocol        | Model Context Protocol (MCP) via Hermes     |
| Architecture    | Vertical Slice (Phoenix contexts)           |
| Persistence     | Ecto schemas and repositories               |

### 8.2 Design Patterns

**Pattern: Orchestrator**
- Stateless coordination
- Pure functions routing to steps
- Session state in database

**Pattern: Session + Interaction**
- Database-backed workflow state
- Each step is immutable command/result pair
- Enables replay and debugging

**Pattern: Step Behavior**
- Extensible interface for workflow steps
- `get_command/3` generates next action
- `handle_result/4` processes completion
- Can be implemented for any workflow type

**Pattern: MCP Tools**
- Domain operations exposed to LLMs
- Thin interface layer over business logic
- Protocol isolation from core domains

**Pattern: Agent Roles**
- Agent types with specialized prompts
- Behavior contracts for execution
- Environment-specific implementations

---

## 9. Key Gaps & Areas for Marketing Improvement

### 9.1 Gaps in System Documentation

1. **Missing: User Story → Context → Component Traceability**
   - System shows which stories satisfy which components
   - Missing: Which components implement which stories
   - Missing: How to trace user story through entire design

2. **Missing: Design Document Structure Specification**
   - System generates "design documents"
   - Unclear: What exactly is in a design document?
   - Missing: How do they map to Phoenix file structure?
   - Unclear: How detailed are component designs?

3. **Missing: Quality Metrics Definition**
   - System validates designs
   - Unclear: What are the validation criteria?
   - Missing: How are architectural quality rules defined?
   - Unclear: Can users customize rules?

4. **Missing: Revision Loop Failure Handling**
   - System retries revisions until validation passes
   - Unclear: What happens if revisions never converge?
   - Missing: Human escape hatch mechanism
   - Unclear: Retry limits and escalation strategy

5. **Missing: Multi-Context Orchestration**
   - System can design multiple components
   - Unclear: Can it design multiple full contexts in single workflow?
   - Missing: Cross-context dependency validation
   - Unclear: How are context boundaries determined?

### 9.2 Areas Needing Marketing Clarity

1. **The "Product Manager Part" Label**
   - Reality: Stories context + MCP tools for story management
   - Marketing Gap: Sounds like a different product, but it's integrated
   - Suggestion: Call it "Requirements Management" or "Story Coordination"

2. **The "Architect Part" Label**
   - Reality: Component context + session workflows + design generation
   - Marketing Gap: Suggests manual architectural work, but it's mostly AI-driven
   - Suggestion: "Automated Architectural Design" or "Context Design Engine"

3. **Phoenix LiveView Specificity**
   - Claim: "Targets Phoenix LiveView applications specifically"
   - Reality: Focuses on context/schema design, not LiveView-specific
   - Missing: Why LiveView focus? (web interface requirement? LiveView patterns?)
   - Unclear: Would this work for API-only Phoenix apps?

4. **Parallel Component Design (Major Feature!)**
   - This is powerful: Design N components simultaneously
   - Completely missing from documentation/marketing
   - Suggestion: Highlight this as major acceleration feature

5. **Architectural Review Loop**
   - System does holistic review after all components designed
   - Missing: Completely absent from current marketing materials
   - Suggestion: Emphasize quality assurance through review

### 9.3 Implementation Insights Worth Highlighting

1. **Complete Audit Trail**
   - Every design decision tracked
   - Full conversation history preserved
   - Perfect reproducibility
   - Great for compliance and learning

2. **Validation-Driven Iteration**
   - Automatic revision loops
   - Design improves until validation passes
   - Reduces need for manual fixes

3. **Agentic Parallel Execution**
   - Multiple components design simultaneously
   - Automatic coordination and sequencing
   - Massive time savings vs serial design

4. **Fail-Safe Architecture**
   - Failed sessions preserved for analysis
   - Postmortem analysis extracts lessons
   - Designs improve incrementally

---

## 10. Summary: How It All Works

### Product Manager Workflow
1. **Stories MCP Server** enables PM to:
   - Create user stories through LLM interview
   - Refine and manage requirements
   - Track which stories are satisfied by components
   - Review architecture impacts

### Architect Workflow
1. **Components MCP Server** enables Architect to:
   - Create contexts (components)
   - Establish dependencies
   - Map stories to contexts
   - Review architecture health

### Design Generation Workflow
1. **ContextComponentsDesignSessions** orchestrates:
   - Initialization
   - **Spawning parallel ComponentDesignSessions** (one per component)
   - Each child session generates design with revision loops
   - **Spawning review session** for consistency validation
   - Creating PR with all designs

### Session Execution
- **Manual Mode**: User executes commands in terminal, controls flow
- **Agentic Mode**: System executes autonomously via Claude SDK
- **Hybrid**: Mix of both modes in single workflow

### Coordination Points
- Stories inform context design
- Contexts track story satisfaction
- Components spawn parallel design sessions
- Review sessions validate across all designs
- Complete audit trail enables learning

The system essentially implements a **"Design Automation Pipeline"** where:
- PM defines requirements (stories)
- Architect defines scope (contexts)
- System automatically designs all components in parallel
- System automatically validates designs
- Human approves final result
- Code generation follows from design

This is fundamentally different from typical architecture tools that are reactive dashboards - this is **proactive design automation**.

---

## File Structure Reference

Key files for understanding the system:

```
lib/code_my_spec/
├── agents/
│   ├── agent_types.ex                    # Agent type definitions
│   └── implementations/claude_code.ex    # Claude Code execution
│
├── sessions/
│   ├── session.ex                        # Session schema
│   ├── session_type.ex                   # Valid session types
│   └── orchestrator.ex                   # Main coordinator
│
├── stories.ex                             # Product Manager domain
├── components/                            # Architect domain
│   ├── component.ex
│   └── dependency.ex
│
├── context_design_sessions.ex             # Context design workflow
├── component_design_sessions.ex           # Component design workflow
├── context_components_design_sessions.ex  # Parallel component coordination
├── context_design_review_sessions.ex      # Review workflow
│
└── mcp_servers/
    ├── stories_server.ex                  # Product Manager tools
    └── components_server.ex               # Architect tools

docs/
├── user_stories.md                        # System requirements
├── context_mapping.md                     # Architecture overview
├── design/code_my_spec/
│   ├── agents.md
│   ├── sessions.md
│   ├── component_design_sessions.md
│   ├── context_components_design_sessions.md
│   └── context_design_review_sessions.md
└── rules/                                 # Architecture validation rules
```

