# Design-Driven Code Generation

AI code generation tools all make the same promise: write a spec, let AI break it into tasks, generate code, ship it.

Here's the thing. **When does a human check if you're building the right thing the right way?**

## Error Amplification

Every transformation in a spec-to-code pipeline compounds errors. A vague requirement becomes a flawed spec. A flawed spec becomes incorrect tasks. Incorrect tasks become buggy code. Tests generated from the same flawed understanding validate wrong behavior.

By the time a human reviews generated code, architectural mistakes are already embedded in thousands of lines. You can build the wrong thing very, very quickly.

## The Missing Layer: Design

I've found that the fix is a layer most tools skip entirely: **explicit, reviewable design documents that define component architecture before code is written.**

The flow:

```
Stories → Architecture (component graph) → Specs (per-component) → Design Review → Implementation → Tests → BDD Specs → QA
```

Each step has requirements that must pass before proceeding. Notice where humans intervene: at architectural decision points, not at code review.

## The 1:1:1 Principle

One design document per code file per test file:

```
.code_my_spec/spec/sessions/
  orchestrator.md              # Spec document

lib/code_my_spec/sessions/
  orchestrator.ex              # Implementation

test/code_my_spec/sessions/
  orchestrator_test.exs        # Tests
```

Design defines what should exist. Code realizes the design. Tests validate code matches design. When anything changes, you have a clear reference point.

## Human Approval Gates

The key insight isn't about *who generates* artifacts. It's about *when humans approve* architectural decisions.

### Gate 1: Story to Architecture

AI proposes how to decompose stories into bounded contexts and components. Humans approve the component graph before any spec work begins.

Why? This determines where functionality lives. Get it wrong and every line of code that follows is in the wrong place.

### Gate 2: Architecture to Specs

AI generates spec documents following strict templates based on component type -- context, schema, LiveView, GenServer, repository, and 12+ other types. Each document type has required and optional sections. Humans review and approve specs before implementation.

Why? Specs define public APIs, data structures, dependencies, interaction patterns. This is your last chance to catch design issues before they become code.

### Gate 3: Specs to Implementation

AI implements components based on approved specs, generating both code and tests. The validation pipeline runs automatically: compiler, tests, Credo, Sobelow, Spex (BDD), spec doc validation. If validation fails persistently, the system escalates for human review.

Why? With approved specs in place, implementation becomes mechanical. When tests fail, you have a clear reference: does the code match the spec, or does the spec need revision?

## 41+ Agent Tasks, All Constrained

We don't have one generic "code generation" agent. We have 41+ specialized agent tasks, each with a narrow scope:

- **Spec tasks**: ComponentSpec, ContextSpec, LiveViewSpec
- **Design**: ArchitectureDesign, ContextDesignReview
- **Implementation**: StartImplementation, DevelopComponent
- **Testing**: WriteBddSpecs, FixBddSpecs, FixAllBddSpecs
- **QA**: QaStory, QaJourneyPlan, QaJourneyExecute, QaJourneyWallaby
- **Research**: ResearchTopic, TechnicalStrategy

Each task has clear start/end conditions, success criteria, and specific validation requirements. The orchestrator enforces the sequence. The LLM doesn't decide whether to skip validation -- the requirement dependency DAG makes those steps mandatory.

## Design Documents as First-Class Artifacts

In most spec-driven approaches, specifications are transient. They guide initial implementation, then rot.

In our system, **spec documents live alongside code** as permanent artifacts. They're version-controlled. Required for every component. The reference for future modifications. Context for code reviewers.

When someone asks "why does this component exist?" the spec document answers -- not archaeology through Git history.

## What This Prevents

**Architectural drift**: Humans approve structure before implementation begins.

**Context accumulation**: Each agent task operates with explicit, scoped inputs -- not accumulated conversation history.

**Test bypass**: Testing is a mandatory pipeline step, validated by 22 requirement checkers.

**Traceability loss**: Every component traces back through spec to architectural decision to user story.

## The Tradeoff

More human review time. Slower initial velocity. More artifacts to manage.

But here's what I keep finding: the time I spend on design reviews is less than the time I'd spend fixing architectural mistakes downstream. The "slow" approach is faster in aggregate.

## When This Makes Sense

Design-driven development fits when you're building production systems where architectural integrity matters for long-term maintainability. When multiple people need to understand system design. When you need traceability from requirements to implementation.

It's overkill for throwaway prototypes and quick experiments. I won't pretend otherwise.

## The Bottom Line

AI code generation isn't going away. The question is how to use it for production systems without creating a mess.

Pure spec-to-code optimizes for speed but compounds errors through transformation chains. Design-driven development adds a layer: explicit, reviewable designs before implementation. Humans review at decision points. AI handles mechanical transformation. The validation pipeline enforces structure.

Slower initial velocity. Higher architectural integrity. In production, that's the tradeoff worth making.
