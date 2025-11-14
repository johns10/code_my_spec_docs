# Architect: AI-Guided Phoenix Architecture

> **Turn context design into a conversation with an expert architect.** Instead of staring at blank diagrams, let AI interview you about your requirements and map them to clean Phoenix contexts.

## The Problem

Designing Phoenix context architecture is hard. Most developers either create god contexts that own everything, or over-fragment their apps into dozens of tiny contexts. You need to understand entity ownership, dependency flow, and domain boundariesall before writing a single line of code.

## What Architect Does

Architect transforms architecture design from a solo planning exercise into a guided dialogue. The AI acts as your architecture consultant, asking clarifying questions, proposing context boundaries, and validating your decisions against Phoenix best practices.

Your architecture isn't a diagram you draw once. It lives as structured data in your database. Every context knows which stories it satisfies, which entities it owns, and which other contexts it depends on. This enables automatic health checks, circular dependency detection, and complete traceability from requirements to implementation.

## How It Works

**1. Start the conversation**
Tell the AI you're ready to design architecture. It automatically loads all your unsatisfied user stories and any existing context definitions.

**2. AI analyzes and asks questions**
The AI identifies natural groupings in your stories and asks targeted questions: "Should authentication and user management be one context or separate? Should rate limiting be part of the ApiKeys context or its own coordination context?"

**3. Map stories to contexts together**
Based on the conversation, create domain contexts (that own entities) and coordination contexts (that orchestrate workflows). The AI helps you assign stories to the right contexts.

**4. Define dependencies**
Declare which contexts depend on which. The system validates there are no circular dependencies and that domain boundaries stay clean.

**5. Review architecture health**
At any time, trigger an architecture review. The AI evaluates your context structure against Phoenix patterns and flags potential issues: contexts depending on too many others, stories without assigned contexts, or contexts with no stories at all.

## Key Capabilities

- **Guided design conversations** - AI interviews you using Phoenix context principles
- **Structured context data** - Query, validate, and navigate your architecture as data, not diagrams
- **Automatic architecture reviews** - AI evaluates against best practices on demand
- **Circular dependency detection** - Catch architectural problems before implementation
- **Complete traceability** - Navigate from user story � implementing context � actual code
- **Domain vs coordination types** - System enforces proper separation of entity ownership and orchestration

## Integration with Your Workflow

Architect is the **second step** in the CodeMySpec process:

```
1. Stories � Define requirements (AI Product Manager interviews you)
2. Architect � Design architecture (AI Architect maps stories to contexts)
3. Design Sessions � Generate detailed component specs within context boundaries
4. Test Sessions � Create tests based on acceptance criteria and designs
5. Coding Sessions � Implement with clear architectural boundaries
```

Once your contexts are defined, everything downstream knows its boundaries. Design sessions generate specs for specific contexts. Test sessions know which context owns which behavior. Coding sessions work within well-defined architectural limits.

## Getting Started

**Prerequisites:**
- CodeMySpec account with active project
- User stories created (use Stories MCP first)
- Claude Code or Claude Desktop
- Architect MCP Server installed

**First conversation:**
```
You: I have 15 user stories ready. Let's design the context architecture.

AI: [Loads your 15 unsatisfied stories]

    I see stories about authentication, API key management,
    and conversation handling. Let me ask some questions to
    map these to contexts...
```

From there, the AI guides you through creating domain and coordination contexts, linking stories, defining dependencies, and validating the overall architecture health.

---

**Previous:** [Stories MCP Server](/pages/stories-feature) - Gather requirements through AI interviews

**Next:** [Design Sessions](/pages/design-sessions) - Generate detailed component specs from architecture

**Documentation:** [Architect MCP Reference](/docs/architect-mcp) - Complete API reference and technical details