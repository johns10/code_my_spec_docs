# Design-Driven Code Generation: The Missing Layer Between Specs and Code

AI code generation is having a moment. GitHub's SpecKit promises to transform specifications into working code through structured workflows. Dozens of other tools offer variants on the same theme: write a spec, let AI break it down into tasks, generate implementation, ship it.

But there's a fundamental problem these approaches don't address: **when do humans check if you're building the right thing the right way?**

## The Error Amplification Problem

Every transformation in a spec-to-code pipeline compounds errors:

- A vague requirement becomes a flawed specification
- A flawed specification becomes incorrect task breakdowns
- Incorrect tasks become buggy implementations
- Tests generated from the same flawed understanding validate wrong behavior

At each step, the LLM is interpreting—translating from one representation to another. And each interpretation can introduce or amplify mistakes.

The problem isn't that LLMs are bad at this. They're remarkably good. The problem is that **there are no human checkpoints at architectural decision points**. By the time a human reviews generated code, architectural mistakes are already embedded in thousands of lines of implementation.

You can build the wrong thing very, very quickly.

## What's Missing: The Design Layer

Design-driven code generation introduces a crucial layer between specifications and implementation: **explicit, reviewable design documents that define component architecture before code is written**.

The workflow looks like this:

```
User Story
    ↓ (human review)
Context Architecture
    ↓ (human review)
Component Design
    ↓ (AI implementation)
Code + Tests
```

Notice where humans intervene: at architectural decision points, not at code review.

## The 1:1:1 Principle

The elegance comes from extending a simple convention:

**Elixir/Phoenix convention**: One test file per code file
**Design-driven extension**: One design document per code file per test file

```
docs/design/sessions/
  orchestrator.md              # Design document

lib/code_my_spec/sessions/
  orchestrator.ex              # Implementation

test/code_my_spec/sessions/
  orchestrator_test.exs        # Tests
```

This creates traceable artifacts:
- Design document defines **what should exist**
- Implementation **realizes the design**
- Tests **validate implementation matches design**

When anything changes, you have a clear reference point.

## Human Approval Gates: Where Review Actually Matters

The key insight isn't about *who generates* artifacts—it's about *when humans approve* architectural decisions. Design-driven development creates explicit approval gates at three critical decision points:

### Gate 1: Story → Architecture

Humans work with AI to define user stories, then AI proposes how to decompose them into bounded contexts (modules/components). **Humans must approve the architectural decomposition before any design work begins.**

**Why this matters**: This determines where functionality lives. Get it wrong, and every line of code that follows is in the wrong place. Fixing it later means massive refactoring.

### Gate 2: Architecture → Design

Humans work with AI to generate design documents following strict templates based on component type (database layer, business logic, UI, etc.). **Humans must review and approve each design before implementation begins.**

**Why this matters**: Design documents specify public APIs, data structures, dependencies, and interaction patterns. This is your last chance to catch architectural issues before they become code.

### Gate 3: Design → Implementation

AI implements components based on approved designs, generating both code and tests from the same design specification. **Automated tests validate that implementation matches design intent.** If tests persistently fail, the session escalates for human review.

**Why this matters**: With approved designs in place, implementation becomes more mechanical. When tests fail, you have a clear reference: does the code match the design, or does the design need revision?

## Design Documents as First-Class Artifacts

In traditional spec-driven approaches, specifications are transient—they guide initial implementation, but code becomes the source of truth. Specifications rot.

In design-driven development, **design documents live alongside code** as permanent artifacts:

- They're version-controlled
- They're required for every component
- They're the reference for future modifications
- They provide context for code reviewers
- They serve as documentation for new team members

When someone asks "why does this component exist?" or "what's this function supposed to do?", the design document answers—not archaeology through Git history.

## Session Orchestration: Structured AI Work

Rather than one long conversation where an LLM generates everything, design-driven development breaks work into **discrete sessions** with specific goals:

### Component Design Session
1. Read requirements and architecture context
2. Load design rules for component type
3. Generate design document (human-guided or autonomous)
4. Validate structure against required schema
5. Human review and approval
6. Finalize design

### Component Coding Session
1. Read approved design document
2. Generate implementation and tests
3. Run automated tests
4. Fix failures (with design as reference)
5. Commit when tests pass

Each session has clear start/end conditions and success criteria. Sessions are resumable, auditable, and can be assigned to different AI agents.

Crucially, **the orchestrator enforces the sequence**. The LLM doesn't decide whether to skip validation or tests—the workflow makes those steps mandatory.

### The Human Involvement Spectrum

The amount of human participation can vary by session type and project maturity:

- **Early stages**: Humans actively guide AI through story definition, architecture decisions, and design generation
- **Mature stages**: AI can autonomously generate designs for an entire context, which humans then batch-review
- **The constant**: Human approval gates remain mandatory regardless of how artifacts are generated

The key is that approval happens *before* implementation begins, not after code is written.

## What This Prevents

Design-driven development eliminates several classes of common AI code generation failures:

**Architectural drift**: Humans approve structure before implementation begins

**Context accumulation**: Each session operates with explicit, scoped inputs—not accumulated conversation history

**Test bypass**: Test generation and execution are mandatory workflow steps

**Invalid outputs**: Structural validation happens between steps, rejecting malformed designs/code before proceeding

**Traceability loss**: Every component traces back through design document to architectural decision to user story

## Comparing Approaches

### Spec-Driven Development (SpecKit, etc.)

**Strengths:**
- Fast from idea to code
- Structured workflow prevents ad-hoc generation
- Version-controlled specifications
- Works with multiple AI assistants

**Weaknesses:**
- No architectural approval gates
- Specifications become stale as code evolves
- Error amplification through transformation chain
- Tests generated from same potentially flawed understanding
- Code review is the first human checkpoint (too late for architecture changes)

### Design-Driven Development

**Strengths:**
- Human oversight at architectural decision points
- Design documents remain relevant as first-class artifacts
- Clear traceability from requirement → design → code
- Explicit component boundaries and dependencies
- Errors caught at design level (cheap to fix)

**Weaknesses:**
- More human review time required
- Slower initial velocity (by design)
- Requires discipline to maintain design/code synchronization
- More artifacts to manage

## The Philosophy: Deliberate Over Fast

The conversation about AI code generation focuses on capability: How much code can AI generate? How accurately? How autonomously?

Design-driven development asks different questions:

- Where do humans add the most value?
- What decisions are expensive to reverse?
- How do we maintain architectural integrity as systems scale?

The answer isn't to remove humans—it's to **position humans at leverage points** where judgment matters most.

Let AI handle mechanical transformation from design to code. Reserve human attention for architectural decisions that determine whether you're building the right thing.

Spec-driven development is fast. Design-driven development is **deliberate**.

## When This Approach Makes Sense

Design-driven development is appropriate when:

- Building production systems (not prototypes)
- Architectural integrity matters for long-term maintainability
- Multiple people need to understand system design
- You need traceability from requirements to implementation
- Working with LLM-assisted development but requiring human oversight

It may be overkill when:

- Building quick experiments or throwaway prototypes
- System complexity is low
- Solo developer who maintains complete mental model
- Rapid iteration matters more than long-term structure

## The Industry Trajectory

Right now, AI coding tools compete on autonomy—how much can the LLM do without human intervention?

This is the wrong competition.

As more teams ship LLM-generated code to production, they'll discover what's becoming clear: **speed without architectural integrity creates technical debt faster**.

The tools that matter won't be the ones with the biggest context windows or most sophisticated prompts. They'll be the ones with the best **architectural enforcement**—systems that position humans at critical decision points while automating mechanical transformations.

## Getting Started

If you want to experiment with design-driven development:

1. **Start small**: Pick one module to design explicitly before implementing
2. **Create templates**: Define design document structure for your component types
3. **Establish conventions**: Decide where designs live and how they're named
4. **Review deliberately**: Actually read AI-generated designs—don't rubber-stamp
5. **Iterate**: Designs can evolve; use version control to track decision evolution

The goal isn't perfect designs upfront—it's **visible, reviewable architectural decisions** before they become expensive to change.

## Conclusion

AI code generation isn't going away. The question is how to harness it for production systems.

Pure spec-to-code approaches optimize for speed, but compound errors through transformation chains. By the time humans review code, architectural mistakes are already embedded.

Design-driven development adds a crucial layer: explicit, reviewable designs that define component architecture before implementation begins. Humans review at decision points. AI handles mechanical transformations. Automated workflows enforce structure.

The result is slower initial velocity but higher architectural integrity. And in production systems, architectural integrity is what matters.

The future of AI-assisted development isn't removing humans from the process—it's positioning them where they add the most value.

That happens at the design level, not the code level.

---

## Further Reading

- **SpecKit**: GitHub's open-source toolkit for spec-driven development - [github.com/github/spec-kit](https://github.com/github/spec-kit)
- **Phoenix Contexts**: Understanding bounded contexts in Elixir/Phoenix - [hexdocs.pm/phoenix/contexts.html](https://hexdocs.pm/phoenix/contexts.html)
- **Test-Driven Development with AI**: How TDD principles apply to LLM code generation
- **Architectural Decision Records**: Documenting architectural decisions over time