# How to design architecture that keeps AI on track

> **Part of the [CodeMySpec Methodology](/methodology)** — Phase 2: Architecture & Design.

Without architecture, AI makes it up. Every conversation. Different structure each time. Within weeks you have a codebase that even the AI can't navigate.

Sound familiar?

I've been there. The fix is simple: design your architecture deliberately, version control it, and feed it to every AI conversation.

## Vertical Slice + Phoenix Contexts

I organize by business capability, not technical layers. Each "slice" is a Phoenix context that owns everything for a domain -- data access, logic, presentation.

Why this works with AI:

- Self-contained modules. The AI reasons about one domain at a time.
- Consistent patterns. What works in one context works in all of them.
- Clear boundaries. No tangled dependencies.
- Two artifacts. Contexts and components. That's it.

**Contexts** are the modules organizing your business logic. **Components** are the code files inside them -- schemas, repositories, GenServers, LiveViews, whatever.

No services layer. No abstract factories. No dependency injection containers. Just contexts and components.

### 14 Component Types

CodeMySpec tracks 14 component types: context, coordination_context, schema, repository, genserver, task, registry, controller, json, liveview, liveview_component, live_context, behaviour, and other. Contexts contain child components in a hierarchy. The dependency graph catches circular dependencies before they become problems.

## The Problem

When you ask AI to "build a feature" without architectural context, it guesses. Every time. It creates new contexts when it should use existing ones. It puts logic in the wrong place. It invents circular dependencies.

Each conversation starts from scratch unless you give it structure to work within.

With AI generating code at speed, architectural drift becomes chaos exponentially faster.

## The Process: Stories to Architecture

Instead of designing alone or letting AI improvise, I use a structured conversation to derive contexts from user stories.

### Step 1: Start the Design Conversation

```
I have these user stories for [your application]. Help me design the architecture.

[Paste executive summary]

I use Vertical Slice architecture via Phoenix Contexts.

Follow this process:
1. Identify bounded contexts mentioned or implied in the stories
2. Propose domain contexts (one primary entity per context)
3. Identify workflow orchestration needs
4. Propose coordination contexts (no entities, just orchestration)
5. Map each story to exactly one responsible context
6. List dependencies for each context

Design principles:
- Domain contexts own entities and provide operations
- Coordination contexts orchestrate workflows across domain contexts
- Flat context structure (no nesting)
- Explicit dependencies
- Each requirement maps to one responsible context

[Paste your user stories]
```

### Step 2: Iterate

The AI proposes an initial architecture. Then the real work starts. You push back:

- "Is this really a separate context?"
- "Is this coordination or domain?"
- "Who orchestrates this workflow?"

Back and forth until the design clicks.

### Step 3: Document It

```markdown
# My Project - Architecture

## Domain Contexts (Entity Owners)

### Stories Context
**Type**: Domain Context
**Entity**: `Story`
**Responsibilities**: User story CRUD, change tracking, impact analysis
**Dependencies**: None

## Coordination Contexts (Workflow Orchestrators)

### DesignSessions Context
**Type**: Coordination Context
**Responsibilities**: Design workflow orchestration, LLM conversations, document generation
**Dependencies**: Documents, Stories, Specs, LLMs

## Requirements Mapping

| Requirement                    | Context        |
| ------------------------------ | -------------- |
| 2.1 LLM-Driven Interview       | DesignSessions |
| 2.2 User Story Management      | Stories        |
```

Version controlled. Concrete. Referenced in every AI conversation.

## How CodeMySpec Does This

CodeMySpec automates this process with two MCP servers:

**Components MCP Server** -- 17 tools for component CRUD, dependency management, and design sessions.

**Architecture Server** -- `validate_dependency_graph` and `analyze_stories`. Runs locally, catches problems before they ship.

Architecture lives in `.code_my_spec/architecture/overview.md`. ADRs go in `.code_my_spec/architecture/decisions/`. Spec files sync from `.spec.md` files in `.code_my_spec/spec/`.

At compile time, `use Boundary` enforces dependency rules. If something violates the graph, it won't compile.

## Domain vs Coordination Contexts

This distinction replaces traditional layered architecture.

**Domain contexts** own entities:
- Stories owns Story entities
- Documents owns Document entities

**Coordination contexts** orchestrate workflows without owning entities:
- DesignSessions orchestrates Documents + Stories + Specs + LLMs
- CodeSessions orchestrates Environments + Agents + Tasks + Tests

Instead of layers (presentation -> business logic -> data access), you have domains and coordinators. Flat. Understandable.

## Single Responsibility Mapping

Each user story maps to exactly one context. One to many, contexts to stories.

```
2.1 LLM-Driven Interview → DesignSessions
2.2 User Story Management → Stories
```

Not "Stories *supports* 2.1" -- DesignSessions *satisfies* 2.1.

This makes testing straightforward: test the owning context, verify the requirement. Every requirement has one clear owner.

## Quick Tests

**Is this a context?**
- Does it own a primary entity? Probably domain context.
- Does it orchestrate across contexts? Probably coordination context.
- Is it just a field on another entity? Not a context.

**Where does this logic go?**
- Operations on an entity -> domain context that owns it
- Workflow across contexts -> coordination context

**Should this be separate?**
- Same entity, different aspects -> same context
- Different entities, similar domain -> separate contexts

## Making It Work

**Start simple.** Don't design the perfect architecture upfront. Start with obvious contexts, iterate.

**Design through conversation.** AI asks architectural questions you haven't considered.

**Keep it updated.** When implementation reveals the design was wrong, update immediately. Don't let docs diverge from code.

**Reference it constantly.** Before every coding session, include relevant context definitions.

## The Result

Without defined architecture, AI makes up structure as it goes. With defined architecture, AI generates code that fits a coherent design.

Your stories define *what*. Your architecture defines *how*. Together, they give AI everything needed to generate maintainable code.

## Additional Resources

- [Why Phoenix Contexts Are Perfect for LLM-Based Code Generation](#) - Deep dive on contexts and AI
- [Phoenix Official Documentation](https://hexdocs.pm/phoenix/contexts.html)
- [Building Beautiful Systems with Phoenix Contexts and DDD](https://speakerdeck.com/andrewhao/building-beautiful-systems-with-phoenix-contexts-and-ddd) - Andrew Hao's talk on contexts and DDD
