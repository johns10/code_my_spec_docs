# How to design architecture that keeps AI on track

> **Part of the [CodeMySpec Methodology](/methodology)** — This guide covers Phase 2: Architecture & Design, where user stories transform into well-defined system architecture. Learn the process for mapping requirements to architectural components so AI can generate maintainable code.

Your user stories define *what* your application does. Your architecture defines *how* it's organized. When working with AI to generate code, having well-defined architecture is the difference between a maintainable system and a pile of technical debt.

Some developers let AI generate code directly from requirements, skipping the architecture phase entirely. The AI makes architectural decisions on the fly, creating structure arbitrarily, scattering business logic, and within weeks you have a mess that even the AI can't navigate.

The solution: design your architecture deliberately, version control it, and use it as the foundation for all AI-generated code.

## My Architectural Approach: Vertical Slice

I use a **Vertical Slice architecture**, specifically for all my applications. Instead of organizing code by technical layers (controllers, services, repositories), vertical slice organizes by business capabilities. Each slice contains everything needed for a specific feature or domain—data access, business logic, and presentation.

This approach is particularly well-suited for AI-assisted development because:
- Each slice is self-contained and can be understood in isolation
- Dependencies between slices are explicit and minimal
- Business capabilities map directly to architectural components
- There are only two types of architectural artifacts to reason about

### Phoenix Contexts: My Implementation

I specifically use **Phoenix Contexts** as my implementation of Vertical Slice architecture. Phoenix contexts are a code organization pattern that groups related functionality around business domains rather than technical concerns.

For those unfamiliar: Phoenix contexts are self-contained modules with clear boundaries, consistent patterns rooted in domain-driven design, and built-in testability. A context like `Accounts` handles everything related to user management—authentication, profiles, permissions—in one cohesive module with a clear public API.

Why Phoenix contexts work so well with AI:
- **Self-contained modules** mean LLMs can reason about one domain at a time
- **Consistent patterns** across contexts mean LLMs can apply learned structures reliably
- **Clear boundaries** prevent LLMs from creating tangled dependencies
- **Built-in testability** means AI-generated code comes with verification

For a deep dive into why Phoenix contexts are ideal for LLM-based code generation, see [Why Phoenix Contexts Are Perfect for LLM-Based Code Generation](#additional-resources).

### The Key Advantage: Two Architectural Artifacts

What makes this architecture particularly powerful for AI-assisted development is its simplicity: **there are only two types of architectural artifacts**—contexts and components.

**Contexts** are the Phoenix modules that organize your business logic. Each context represents a vertical slice of functionality.

**Components** are the generic code modules that belong to contexts (schemas, queries, business logic modules, etc.).

Within components, **entities** are the domain entities (typically stored in the database via schemas).

We will only be concerned with **Contexts** in this article—how to identify them, design them, and map requirements to them.

## The Problem

When you ask AI to "build a feature" without providing architectural context, it has to guess at, or research your structure in every conversation. It might:
- Create new contexts when it should use existing ones
- Put business logic in the wrong place
- Create circular dependencies between contexts
- Mix concerns that should be separated
- Generate code that conflicts with your existing patterns

Each conversation with AI starts from scratch unless you give it a well-defined architecture to work within.

Even on human teams, architecture tends to drift. Developers make expedient decisions, contexts accumulate responsibilities, and boundaries blur. With AI generating code at speed, the drift becomes chaos exponentially faster.

## My Solution: Well-Defined Architecture

I maintain a clear definition of my architecture: what each context does, what entities it owns, and how contexts connect together. This isn't theoretical architecture diagrams. It's a concrete, version-controlled document that maps directly to code.

The key insight: if you have well-defined architecture (using vertical slice), you can easily keep AI on track. The AI generates code that fits your design instead of inventing its own structure every conversation.

The question is: **how do you get from user stories to those well-defined contexts?**

## The Process: From User Stories to Architecture

Instead of designing architecture alone or letting AI improvise, I use a structured conversation process with AI to derive contexts from user stories.

Here's the actual process I use:

### Step 1: Start the Architecture Design Conversation

```
I have these user stories for [your application]. Help me design the architecture.

[Paste executive summary of your application here]

I use Vertical Slice architecture implemented via Phoenix Contexts.

Follow this process:
1. Identify all the bounded contexts mentioned or implied in the user stories
2. Propose domain contexts (one primary entity per context when possible)
3. Identify workflow orchestration needs
4. Propose coordination contexts (no entities, just orchestration)
5. Map each user story to exactly one context responsible for satisfying it
6. List dependencies for each context

Design principles:
- Domain contexts own entities and provide operations on them
- Coordination contexts orchestrate workflows across domain contexts
- Flat context structure (no nested contexts)
- Explicit dependencies between contexts
- Each requirement maps to one responsible context (for testing)

[Paste your user stories here]
```

### Step 2: Iterate on the Design

The AI will propose an initial architecture. This is where the real work happens. You'll iterate through questions like:

- **Is this really a separate context?**
- **Is this coordination or domain?**
- **Who orchestrates this workflow?**

Through these iterations, your architecture emerges. The AI helps you think through implications, catch conflicts, and refine boundaries.

### Step 3: Document the Final Architecture

Once the design stabilizes, document it:

```markdown
# My Project - Architecture

## Domain Contexts (Entity Owners)

### Stories Context
**Type**: Domain Context
**Entity**: `Story`
**Responsibilities**: User story CRUD, change tracking, impact analysis
**Dependencies**: None

### Documents Context
**Type**: Domain Context
**Entity**: `Document`
**Responsibilities**: Document storage, manual editing, approval tracking, version history
**Dependencies**: None

## Coordination Contexts (Workflow Orchestrators)

### DesignSessions Context
**Type**: Coordination Context
**Responsibilities**: Design workflow orchestration, LLM conversations, document generation, and all design-phase activities from executive summary to detailed documentation
**Dependencies**: Documents, Stories, Specs, LLMs, UserConversation

### CodeSessions Context
**Type**: Coordination Context
**Responsibilities**: Code work orchestration, integration workflows, retry management, and agent coordination for all code-related activities
**Dependencies**: Environments, Agents, Tasks, Tests

## Requirements Mapping

| Requirement                    | Context        |
| ------------------------------ | -------------- |
| 1.1 New Project Creation       | Projects       |
| 2.1 LLM-Driven Interview       | DesignSessions |
| 2.2 User Story Management      | Stories        |
| 3.1 Context Mapping            | DesignSessions |
| 6.1 Todo Generation            | Tasks          |
| 6.3 External Agent Integration | CodeSessions   |
```

This becomes your architectural source of truth. Version controlled, concrete, and directly referenced in AI conversations.

## Real Example: The Requirements Generator

Let me show you what this looks like with a real application. Here's an excerpt from my requirements generator architecture design conversation:

**Me**: "I have these user stories for a requirements generator. Help me design the architecture using Vertical Slice via Phoenix Contexts. Follow the process above. [pastes 30+ user stories]"

**AI**: "Let me analyze the components and propose contexts..."

```
2. Requirements Context (Domain Context)
Entity Ownership: User stories, requirements, and LLM interview data
Business Capabilities:
- LLM-driven requirement gathering
- User story CRUD operations
...
```

**Me**: "We should be more specific about Requirements. We'll need separate Conversations and Messages contexts. I don't like Architecture context - it's probably coordination. Documents should be its own context."

**AI**: "Good points. Let me revise..."

This goes back and forth - splitting contexts, merging contexts, clarifying boundaries - until we arrive at a clean, understandeable design.

## Key Design Principles

### Domain vs Coordination Contexts

This distinction is crucial and represents an alternative to traditional layered architecture that's much simpler:

**Domain contexts** own entities and provide operations on them:
- Stories owns Story entities
- Tasks owns Task entities
- Documents owns Document entities

**Coordination contexts** orchestrate workflows across domain contexts without owning entities:
- DesignSessions orchestrates Documents + Stories + Specs + LLMs for design workflows
- CodeSessions orchestrates Environments + Agents + Tasks + Tests for code workflows
- UserConversation orchestrates Conversations + Messages + LLMs + Tools for conversation flow

Instead of layers (presentation → business logic → data access), you have domains (entity ownership) and coordinators (workflow orchestration). This keeps your application flat, understandable, and maintainable.

This is an alternative to layered architecture that's dramatically simpler. No services layer, no repositories pattern, no dependency injection containers. Just two concepts: contexts and components.

### Single Responsibility Mapping

Each user story maps to exactly one context responsible for satisfying that requirement. It's a one to many relationship from contexts to to stories.

```
2.1 LLM-Driven Interview → DesignSessions
2.2 User Story Management → Stories
3.1 Context Mapping → DesignSessions
```

Not "Stories *supports* 2.1" — DesignSessions *satisfies* 2.1.

This makes testing straightforward: to test requirement 2.1, you test DesignSessions. To verify the system meets requirement 2.2, you test Stories.

It also prevents the "whose job is this?" problem. Every requirement has one clear owner.

### Explicit Dependencies

Every coordination context declares its dependencies:

```markdown
### DesignSessions Context
**Dependencies**: Documents, Stories, Specs, LLMs, UserConversation

### CodeSessions Context
**Dependencies**: Environments, Agents, Tasks, Tests
```

This prevents circular dependencies and makes integration order obvious. If Context A depends on Context B, you implement and test B before A. It also makes it trivial to verify your design after coding.

## How to Use Your Architecture

Once you have well-defined architecture, here's how to use it with AI:

**1. When asking AI to implement a requirement, provide the context definition and relevant user stories.**

"Here are the context definitions [paste relevant contexts]. Implement requirement 2.2 (User Story Management) in the Stories context."

The AI knows what the context is responsible for, what it depends on, and what components it owns.

**2. Design first, code second.**

Never let AI generate code without understanding your architecture. Do the architecture design conversation first, document the results, commit to version control, *then* generate code.

**3. Update architecture as it evolves.**

When you discover the design was wrong, update the context definitions immediately. Don't let the document diverge from reality. Git history shows how your architecture evolved.

**4. Reference architecture to catch conflicts.**

Adding a new feature? Check your context definitions first. Does an existing context handle this? Do you need a new context? How will it integrate?

**5. Project management.**

If you design and maintain your architecture in this way, it becomes your todo list. Development is no longer an interminable list of abstract tasks. Either the context is done and passes the acceptance criteria, or it doesn't. The application is done when all the contexts are done.

## Common Patterns and Decisions

### The "Is This A Context?" Test

When you're not sure if something deserves its own context:

**Does it own a primary entity?** → Probably a domain context
**Does it orchestrate workflows across contexts?** → Probably a coordination context
**Is it just a field on another entity?** → Not a context
**Is it just a type/variant of an existing pattern?** → Not a context

Example from my design: "Is Integration a context?"
Answer: No. Integration is a type of CodeSession. CodeSessions creates different work session types: `task_implementation`, `component_integration`, `context_integration`, `bdd_integration`.

### The "Where Does This Logic Go?" Test

**Operations on an entity** → Domain context that owns that entity
**Workflow across multiple contexts** → Coordination context
**Business logic specific to one entity** → Domain context that owns it
**Business logic spanning entities** → Coordination context

### The "Should This Be Separate?" Test

**Same entity, different aspects** → Probably same context
**Different entities, similar domain** → Probably separate contexts
**Supporting data** → Usually same context as the primary entity

Example from my design: "Should Agents and LLMs be separate?"
Answer: Yes. Agents are external autonomous tools with CLI interactions. LLMs are internal API calls with managed conversations. Different usage patterns, different contexts.

## The Evolution Process

Your architecture will change as you learn more about your domain. That's expected and healthy.

Version control will keep track of the evolution.

Each refinement makes the architecture clearer and better aligned with your actual domain.

## The Document Structure

Keep your architecture in `docs/context_mapping.md` or similar. Structure it like this:

```markdown
# [Project Name] - Architecture

## Domain Contexts (Entity Owners)

### [Context Name] Context
**Type**: Domain Context
**Entity**: `EntityName`
**Responsibilities**: [What this context does]
**Dependencies**: [Other contexts this depends on, or None]

[Repeat for each domain context]

## Coordination Contexts (Workflow Orchestrators)

### [Context Name] Context
**Type**: Coordination Context
**Responsibilities**: [What workflows this orchestrates]
**Dependencies**: [Contexts it coordinates across]

[Repeat for each coordination context]

## Requirements Mapping

| Requirement                 | Context     |
| --------------------------- | ----------- |
| 1.1 Requirement Description | ContextName |
| 2.1 Another Requirement     | ContextName |
```

This gives you everything you need in one place: context definitions, responsibilities, dependencies, and requirements traceability.

## Making It Work

**Start simple.** Don't try to design the perfect architecture upfront. Start with obvious contexts, iterate as you learn.

**Use git.** Commit architectural changes separately from code changes. The git history becomes a record of how your understanding evolved.

**Design through conversation.** Use the structured conversation process above. AI is good at asking architectural questions you haven't considered.

**Keep architecture updated.** When the implementation reveals the design was wrong, update the context definitions immediately.

**Reference architecture constantly.** Before every significant AI coding session, include relevant context definitions.
 
**Update architecture with new stories.** If you add or modify stories, have a fresh conversation with the LLM about it.

## The Result: Control at Speed

Well-defined architecture gives you architectural control while working at AI speed.

Without defined architecture, AI makes up structure as it goes. With defined architecture, AI generates code that fits a coherent design.

Your user stories define *what* the application does. Your architecture defines *how* it's organized. Together, they give AI everything needed to generate maintainable code.

The process:
1. Write user stories (requirements phase)
2. Design architecture through structured AI conversation
3. Document context definitions, responsibilities, dependencies
4. Version control the architecture
5. Use context definitions in all code generation conversations

Your architecture emerges through iteration with AI, and you maintain a living document that keeps all generated code consistent and maintainable.

This is how you get from user stories to well-defined architecture that keeps AI on track.

## Additional Resources

For a deep dive into why Phoenix contexts are ideal for LLM-based code generation, including their self-contained nature, domain-driven design principles, and built-in testability, see:

- [Why Phoenix Contexts Are Perfect for LLM-Based Code Generation](#) - Comprehensive guide to Phoenix contexts and their advantages for AI-assisted development
- [Phoenix Official Documentation](https://hexdocs.pm/phoenix/contexts.html) - Introduction to contexts
- [Building Beautiful Systems with Phoenix Contexts and DDD](https://speakerdeck.com/andrewhao/building-beautiful-systems-with-phoenix-contexts-and-ddd) - Andrew Hao's influential talk on contexts and domain-driven design