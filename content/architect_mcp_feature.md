# Architect: AI-Guided Context Design

> **Have AI design your Phoenix context architecture through expert-guided conversations.** The Architect MCP Server turns architecture design into an iterative dialogue that maps user stories to well-defined contexts.

## What Architect Does

### 1. AI Guides You Through Context Design

Instead of designing architecture alone, **the AI becomes your architecture consultant and interviews you**:

```
You: I have these user stories ready. Let's design the contexts.

AI: [Calls start_context_design]
    [Loads unsatisfied stories and existing components]

    Looking at your stories, I see requirements for:
    - User authentication and management
    - API key creation and revocation
    - Conversation management with LLMs

    Let's map these to contexts. Should authentication
    and user management be one context or separate?

    Also, I notice API keys might need rate limiting.
    Should that be part of the ApiKeys context or
    a separate RateLimiting coordination context?
```

The AI uses Phoenix context design principles (entity ownership, flat structure, clear dependencies) to help you create clean architecture.

### 2. Components Become Structured Data, Not Diagrams

Components (contexts) live in your database with:
- Type (domain or coordination)
- Component ownership (what components belong to this context)
- Dependencies (which other contexts this depends on)
- Story assignments (traceability from requirements to implementation)
- Module names (actual code paths)
- Version history

This enables:
- Automatic architectural health checks
- Circular dependency detection
- Orphaned context identification
- Complete requirements traceability
- Query by type, dependencies, or stories
- Navigation from stories -> components -> code

### 3. Automatic Architecture Reviews

The AI can review your entire architecture against best practices:

```
AI: [Calls review_context_design]

## Architecture Review

**Current Architecture:**
- 12 domain contexts
- 3 coordination contexts
- 45 stories satisfied, 3 unsatisfied

**Findings:**

- No circular dependencies detected
- All contexts have clear entity ownership
- ApiKeys context depends on 4 other contexts - consider splitting
- 3 stories about "user preferences" aren't assigned to any context
- RateLimiting has no stories - is this context necessary?

**Recommendations:**
1. Create UserPreferences context for the 3 unassigned stories
2. Consider if rate limiting belongs in ApiKeys context instead
3. Review ApiKeys dependencies - might indicate coordination needed
```

Reviews catch architectural issues before you write code.

### 4. Direct Integration with Stories

When you start a context design session, AI automatically:
- Loads all unsatisfied stories (stories without assigned components)
- Shows existing components and their dependencies
- Helps you map stories to new or existing contexts
- Validates dependency relationships
- Links stories to components as you design

After design, you have complete traceability: Story 42 ("Admin creates API key") is satisfied by Component 15 (ApiKeys domain context), which has clear dependencies, entity ownership, and a path to implementation.

## How It Works

### Installation

Install the Architect MCP Server in Claude Code or Claude Desktop. The server exposes tools that Claude can call during conversations:

**Core Operations:**
- `create_component` / `create_components` - Add contexts to architecture
- `update_component` - Modify existing contexts
- `delete_component` - Remove contexts
- `get_component` - View single context details
- `list_components` - View all project contexts

**Dependency Management:**
- `create_dependency` / `create_dependencies` - Define context dependencies
- `delete_dependency` - Remove dependencies

**Design Sessions:**
- `start_context_design` - Begin guided architecture design
- `review_context_design` - Review architecture quality

**Analysis:**
- `show_architecture` - View complete context architecture with dependencies
- `architecture_health_summary` - Get architectural metrics and warnings
- `context_statistics` - View context counts and relationship stats
- `orphaned_contexts` - Find contexts with no stories assigned

**Story Integration:**
- `set_story_component` - Link story to implementing context
- `list_stories` - View all project stories

All operations are automatically scoped to your active account and project (multi-tenancy built-in).

### Typical Workflow

1. **Gather Requirements:** Use Stories MCP Server to create user stories first
2. **Design:** Start conversation, AI calls `start_context_design`, guides architecture discussion
3. **Create:** AI creates domain and coordination contexts with `create_components`
4. **Link:** Map each story to responsible context using `set_story_component`
5. **Define Dependencies:** Add dependencies between contexts with `create_dependencies`
6. **Review:** Periodically call `review_context_design` to evaluate architecture health
7. **Refine:** Update contexts as understanding evolves, check for circular dependencies
8. **Track:** Architecture health metrics show coverage, orphaned contexts, and issues

## Key Features

- **AI-Guided Design:** Structured architect persona asks questions you'd miss on your own
- **Structured Database:** Components are data, not diagrams - enables queries and validation
- **Architectural Reviews:** AI evaluates against Phoenix context best practices
- **Dependency Validation:** Automatic circular dependency detection
- **Story Traceability:** Direct links from stories to implementing contexts
- **Health Metrics:** Context count, dependency depth, story coverage, orphaned contexts
- **Batch Operations:** Create multiple contexts and dependencies efficiently
- **Version Control:** Full audit trail
- **Type System:** Domain vs coordination contexts with different validation rules

## Integration with CodeMySpec Workflow

Architect is the **second step** in the design-driven development process:

```
1. Stories -> Define requirements (Stories MCP Server)
2. Architect -> Design architecture (this feature - maps stories to contexts)
3. Design Sessions -> Generate detailed designs (uses context boundaries)
4. Test Sessions -> Generate tests (from acceptance criteria within contexts)
5. Coding Sessions -> Implement with TDD (organized by contexts)
```

Everything flows from architecture. When you generate designs, AI knows which context owns which entities. When you write tests, you know which context is responsible. When you implement code, you work within clear boundaries.

## Design Principles Enforced

**Domain vs Coordination:**
- Domain contexts own entities (database schemas)
- Coordination contexts orchestrate workflows across domains
- Clear separation validated by the system

**Flat Structure:**
- No nested contexts (Phoenix best practice)
- All contexts at same level
- Dependencies make relationships explicit

**Entity Ownership:**
- Each domain context owns specific entities
- Entities don't span contexts
- Clear responsibility boundaries

**Single Responsibility:**
- Each story maps to exactly one context
- Context satisfies all its assigned stories
- No overlapping responsibilities

**Explicit Dependencies:**
- Dependencies declared and validated
- Circular dependency detection
- Dependency graph visualization

## Tips for Best Results

**Start with stories, not architecture.** Don't design contexts in a vacuum. Let AI map your actual user stories to contexts.

**Coordination contexts have no entities.** DesignSessions orchestrates across Documents, Stories, Specs. It doesn't own data.

**Make dependencies explicit.** If DesignSessions uses Stories and Documents, declare those dependencies. Helps with implementation order.

**Review regularly.** Run `review_context_design` as you add stories to catch architectural drift.

**Name contexts for domain, not implementation.** "Stories" not "StoriesManager". "DesignSessions" not "DesignWorkflowCoordinator".

**Watch for circular dependencies.** System will catch them, but avoid by clarifying which context is responsible for what.

## Get Started

**Prerequisites:**
- CodeMySpec account and active project
- Stories created (use Stories MCP Server first)
- Claude Code or Claude Desktop with MCP support
- Architect MCP Server installed

**First conversation:**
```
You: I have 15 user stories ready. Let's design the context architecture.

AI: [Calls start_context_design]
    [Loads 15 unsatisfied stories]
    [Loads existing components if any]

    I see stories about authentication, API management,
    and conversation handling. Let me ask some questions
    to map these to contexts...
```

Then create contexts from the conversation, link stories to contexts, add dependencies, and review for architectural health.

## Example Architecture

Here's what a typical architecture looks like:

**Domain Contexts (Own Entities):**
- Projects -> Project entities
- Stories -> Story entities
- Documents -> Document entities
- Conversations -> Conversation entities
- Messages -> Message entities
- Tasks -> Task entities
- Agents -> Agent entities
- LLMs -> LLM entities
- Tests -> TestResult entities

**Coordination Contexts (Orchestrate Workflows):**
- DesignSessions -> Orchestrates Documents + Stories + LLMs
- CodeSessions -> Orchestrates Environments + Agents + Tasks + Tests
- UserConversation -> Orchestrates Conversations + Messages + LLMs + Tools

Dependencies flow from coordination to domain contexts, never the reverse.

---

**Previous:** [Stories MCP Server](/pages/stories-feature) - Gather requirements with AI interviews

**Next:** Design Sessions - Generate detailed designs from architecture

**Related:** [Managing Architecture](/pages/managing-architecture) - Manual process for context mapping

**Learn more:** [CodeMySpec Methodology](/methodology) - Full design-driven development process