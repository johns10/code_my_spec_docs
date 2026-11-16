---
# Metadata for design_driven_code_generation.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: design-driven-code-generation
type: blog  # Options: blog, page, landing
title: Design-Driven Code Generation, The Missing Layer Between Specs and Code

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2025-10-28T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: Design-Driven Generation, The Layer Between Specs and Code
meta_description: Design-driven development adds explicit, reviewable designs that define component architecture before implementation begins.
og_title: Design-Driven Code Generation, The Missing Layer
og_description: Why positioning humans at architectural decision points, not code review, creates better AI-generated systems
og_image: null  # URL to Open Graph image

# Additional metadata (custom key-value pairs)
metadata:
  template: article  # Options: default, article, tutorial
  author: CodeMySpec Team
  category: AI Development
  featured: true

# Tags (optional, list of tag names)
tags:
  - ai
  - llm
  - code-generation
  - software-architecture
  - design-driven-development
  - test-driven-development
  - phoenix
  - elixir
---

# Design-Driven Code Generation

AI code generation tools all make the same promise: write a spec, let AI break it into tasks, generate code, ship it.

Here's the thing. **When does a human check if you're building the right thing the right way?**

## How do errors compound in a spec-to-code AI pipeline?

Every transformation in a spec-to-code pipeline compounds errors. A vague requirement becomes a flawed spec. A flawed spec becomes incorrect tasks. Incorrect tasks become buggy code. Tests generated from the same flawed understanding validate wrong behavior.

By the time a human reviews generated code, architectural mistakes are already embedded in thousands of lines. You can build the wrong thing very, very quickly.

## Why is explicit design the missing layer in AI code generation?

I've found that the fix is a layer most tools skip entirely: **explicit, reviewable design documents that define component architecture before code is written.**

The flow:

```
Stories → Architecture (component graph) → Three Amigos → BDD Specs → Implementation → QA → Promotion
```

Each step has requirements that must pass before proceeding. Notice where humans intervene: at architectural decision points, not at code review. The executable layer is the BDD specs, which run with `mix spex`. Per-component design documents are an input you can use, and a project decides how much of that layer it wants.

## What is the 1:1:1 principle for design documents, code, and tests?

When a component has a design document, the layout is one document per code file per test file:

```
.code_my_spec/spec/sessions/
  orchestrator.md              # Spec document

lib/code_my_spec/sessions/
  orchestrator.ex              # Implementation

test/code_my_spec/sessions/
  orchestrator_test.exs        # Tests
```

Design defines what should exist. Code realizes the design. Tests validate code matches design. When anything changes, you have a clear reference point.

## Where should humans approve decisions in an AI code generation pipeline?

The key insight isn't about *who generates* artifacts. It's about *when humans approve* architectural decisions.

### Gate 1: Story to Architecture

AI proposes how to decompose stories into bounded contexts and components. Humans approve the component graph before any spec work begins.

Why? This determines where functionality lives. Get it wrong and every line of code that follows is in the wrong place.

### Gate 2: Architecture to Specs and Scenarios

The behavior gets pinned down before code does. A Three Amigos session per story produces rules, scenarios, and questions, and the story isn't ready until every question is answered. Those scenarios become executable BDD specs. Where you keep component design documents, they follow strict templates by component type, and humans review them before implementation.

Why? Scenarios and designs define public behavior, data structures, dependencies, and interaction patterns. This is your last chance to catch design issues before they become code.

### Gate 3: Specs to Implementation

AI implements components against the approved specs. The validation pipeline runs automatically: compiler, ExUnit, Credo, Sobelow, and Spex (BDD). A story isn't certified ready for QA until every analyzer is clean and its own specs are green, and promotion checks again.

Why? With approved specs in place, implementation becomes mechanical. When a spec fails, you have a clear reference: does the code match the spec, or does the spec need revision?

## How do you constrain dozens of specialized agent tasks in a code generation system?

We don't have one generic "code generation" agent. We have dozens of specialized agent tasks, each with a narrow scope:

- **Product**: PersonaResearch, StoryInterview, ThreeAmigos
- **Design**: TechnicalStrategy, ArchitectureDesign
- **Implementation**: DevelopContext, DevelopLiveView, ComponentCode
- **Testing**: WriteBddSpecs, FixBddSpecs, FixAllBddSpecs, ReadyForQa
- **QA**: QaSetup, QaStory, QaJourney, TriageIssues, FixIssues
- **Shipping**: PromoteWork, Deploy

Each task has clear start/end conditions, success criteria, and specific validation requirements. The orchestrator enforces the sequence. The LLM doesn't decide whether to skip validation, because the requirement dependency graph makes those steps mandatory.

## Why should design documents be treated as first-class artifacts?

In most spec-driven approaches, specifications are transient. They guide initial implementation, then rot.

In our system, **design documents live alongside code** as permanent artifacts. They're version-controlled, the reference for future modifications, and context for code reviewers.

When someone asks "why does this component exist?" the document answers, not archaeology through Git history.

## What problems does design-driven code generation prevent?

**Architectural drift**: Humans approve structure before implementation begins.

**Context accumulation**: Each agent task operates with explicit, scoped inputs, not accumulated conversation history.

**Test bypass**: Testing is a mandatory pipeline step, enforced by the requirement graph.

**Traceability loss**: Every component traces back through its scenarios to an architectural decision to a user story.

## What is the tradeoff between speed and architectural integrity?

More human review time. Slower initial velocity. More artifacts to manage.

But here's what I keep finding: the time I spend on design reviews is less than the time I'd spend fixing architectural mistakes downstream. The "slow" approach is faster in aggregate.

## When does design-driven code generation make sense versus rapid prototyping?

Design-driven development fits when you're building production systems where architectural integrity matters for long-term maintainability. When multiple people need to understand system design. When you need traceability from requirements to implementation.

It's overkill for throwaway prototypes and quick experiments. I won't pretend otherwise.

{{design_gate_cta headline="By review time the architectural mistake is already in thousands of lines." sub="You can build the wrong thing very quickly." body="A design gate is cheaper than the rewrite." label="Put the gate before the code" campaign="design-driven-code-generation"}}

## What is the bottom line on AI code generation for production systems?

AI code generation isn't going away. The question is how to use it for production systems without creating a mess.

Pure spec-to-code optimizes for speed but compounds errors through transformation chains. Design-driven development adds a layer: explicit, reviewable designs before implementation. Humans review at decision points. AI handles mechanical transformation. The validation pipeline enforces structure.

Slower initial velocity. Higher architectural integrity. In production, that's the tradeoff worth making.

## Frequently Asked Questions

**What is design-driven code generation?** Design-driven code generation is an approach where explicit, reviewable design documents are created and approved before any code is written. Instead of going directly from spec to code, the pipeline includes architecture proposals, per-component specifications, and human approval gates at each decision point. This catches errors before they become embedded in implementation.

**How is design-driven development different from traditional spec-driven development?** In traditional spec-driven approaches, specifications guide initial implementation and then are forgotten. In design-driven development, design documents are permanent, version-controlled artifacts that live alongside the code. They serve as the reference for future modifications, code reviews, and understanding why a component exists.

**Does this approach work for small projects or solo developers?** It depends on the project's lifespan. For throwaway prototypes and quick experiments, the overhead is not justified. For production systems that need to be maintained over months or years, even a solo developer benefits from having explicit design documents. The time spent on design reviews is consistently less than the time spent fixing architectural mistakes downstream.

**What are human approval gates in an AI code generation pipeline?** Human approval gates are specific points in the pipeline where a human reviews and approves AI-generated decisions before the next phase begins. The three key gates are story-to-architecture, architecture-to-specs, and specs-to-implementation. Humans intervene at architectural decision points rather than at code review, which is where the highest leverage exists.

**How do specialized agent tasks differ from a single general-purpose code generation agent?** Each specialized task has a narrow scope, clear start and end conditions, specific validation requirements, and explicit success criteria. A general-purpose agent must decide what to do, when to validate, and when it is done. Specialized tasks remove those decisions entirely, making the output predictable and the failure modes diagnosable.

## Related Articles

- [How to write design documents that keep AI from going off the rails](/blog/writing-design-documents)
- [Code Generation is About Control, Not Prompts](/blog/control-over-prompts)
- [How to design architecture that keeps AI on track](/blog/managing-architecture)
- [ADRs Are the Best Thing You Can Give Your AI Agent](/blog/architectural-decision-records)
