# Architect: AI-Guided Application Architecture

> **Turn architecture design into a conversation with an expert architect.** Instead of staring at blank diagrams, let AI interview you about your requirements and map them to clean, well-bounded components.

## The Problem

Designing application architecture is hard. Most developers either create god modules that own everything, or over-fragment their apps into dozens of tiny pieces. You need to understand entity ownership, dependency flow, and domain boundaries -- all before writing a single line of code.

## What Architect Does

Architect transforms architecture design from a solo planning exercise into a guided dialogue. The AI acts as your architecture consultant, asking clarifying questions, proposing component boundaries, and validating your decisions against best practices.

Your architecture lives as structured data in your database. Every component knows which stories it satisfies, which entities it owns, and which other components it depends on. The system tracks all 14 component types -- from contexts and schemas to LiveViews and controllers -- each with their own requirement definitions and validation rules. This enables automatic health checks, circular dependency detection, and complete traceability from requirements to implementation.

## How It Works

**1. Start the conversation**
Tell the AI you're ready to design architecture. It automatically loads all your unsatisfied user stories and any existing component definitions.

**2. AI analyzes and proposes structure**
The AI identifies natural groupings in your stories and asks targeted questions: "Should authentication and user management be one context or separate? Should rate limiting be part of the ApiKeys context or its own coordination context?" It then drafts an architecture proposal mapping stories to surface components and defining domain contexts.

**3. Map stories to components together**
Based on the conversation, create domain contexts (that own entities), coordination contexts (that orchestrate workflows), and surface components (LiveViews, controllers). The AI helps you assign stories to surface components -- domain context involvement is derived through the dependency graph.

**4. Define dependencies**
Declare which components depend on which. The system validates there are no circular dependencies and that domain boundaries stay clean.

**5. Review architecture health**
At any time, get an architecture health summary. The AI evaluates your component structure and flags potential issues: components depending on too many others, stories without assigned components, orphaned contexts with no stories, or contexts with no children.

## Key Capabilities

- **Guided design conversations** -- AI interviews you to discover the right component boundaries
- **Architecture proposals** -- Structured documents mapping stories to contexts and surface components with dependency declarations
- **14 component types** -- context, coordination_context, schema, repository, genserver, task, registry, behaviour, controller, json, live_context, liveview, liveview_component, and other
- **Hierarchical component tree** -- Parent-child relationships via module namespace (e.g., Accounts owns Accounts.User)
- **Circular dependency detection** -- Catch architectural problems before implementation
- **Architecture health summary** -- Statistics, orphan detection, and dependency graph validation on demand
- **Complete traceability** -- Navigate from user story to implementing component to actual code
- **Design sessions** -- Start and review context designs within well-defined boundaries
- **Component requirements** -- Each component type has specific requirements that must be satisfied before it's considered complete

## Integration with Your Workflow

Architect is the **second step** in the CodeMySpec process:

```
1. Stories    -- Define requirements (AI interviews you about what to build)
2. Architect  -- Design architecture (AI maps stories to components)
3. Design     -- Generate detailed specs (validated designs for each component)
4. Implement  -- Build with full traceability (code matches design, tests validate)
5. QA         -- Verify the running application (automated and manual testing)
```

Once your components are defined, everything downstream knows its boundaries. Design specs are generated for specific components. Tests know which component owns which behavior. Implementation works within well-defined architectural limits. The requirement system tracks progress through 22 checkers that verify everything from spec file existence to test alignment.

## The MCP Servers

Architecture capabilities are split across two MCP servers:

**Architecture Server** (2 tools) -- Focused analysis tools:
- Validate the dependency graph for circular dependencies
- Analyze stories to identify natural component groupings

**Components Server** (17 tools, including shared story tools) -- Full component lifecycle:
- CRUD operations for components and dependencies
- Context design sessions (start and review)
- Architecture visualization and health summaries
- Story-to-component linking
- Similar component tracking for consistency
- Context statistics and orphan detection

Both servers connect via HTTP and work from Claude Code or any MCP client.

## Getting Started

**Prerequisites:**
- CodeMySpec account with active project
- User stories created (use Stories first)
- Claude Code or any MCP-compatible client

**First conversation:**
```
You: I have 15 user stories ready. Let's design the architecture.

AI: [Loads your 15 unsatisfied stories]

    I see stories about authentication, API key management,
    and conversation handling. Let me ask some questions to
    map these to components...
```

From there, the AI guides you through creating contexts and surface components, linking stories, defining dependencies, and validating the overall architecture health.

---

**Previous:** [Stories](/pages/stories-feature) -- Gather requirements through AI interviews

**Next:** [Design Documentation](/pages/design-documentation-feature) -- Structured, validated specs for every component
