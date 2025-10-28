# Design-Driven Code Generation: Beyond Spec-Driven Development

## The Promise and Peril of AI Code Generation

The software industry is experiencing a seismic shift. AI coding assistants can now generate thousands of lines of code from natural language descriptions, promising unprecedented productivity gains. Approaches like spec-driven development (SDD) have emerged to harness this power systematically, with tools like GitHub's SpecKit creating structured workflows from specifications to implementation.

But there's a critical flaw in the pure spec-to-code pipeline: **error amplification**.

## The Error Amplification Problem

Consider the traditional spec-driven approach:

1. Write a high-level requirement or user story
2. AI generates a detailed specification
3. AI breaks the spec into tasks
4. AI implements each task
5. AI generates tests

At each transformation step, any ambiguity or misunderstanding compounds. A vague requirement becomes a flawed specification. A flawed specification becomes incorrect task breakdowns. Incorrect tasks become buggy code. And tests generated from the same flawed understanding simply validate the wrong behavior.

This is the fundamental challenge with fully automated specification-to-code pipelines: **they optimize for speed at the expense of direction**. Without human checkpoints at critical decision points, you can build the wrong thing very, very quickly.

## Enter Design-Driven Development

Design-driven development takes a different approach. Rather than treating specifications as intermediate artifacts on the way to code, it treats **design documents as first-class artifacts** that live alongside your code.

The core philosophy: **One design document per code file per test file**.

This might sound like more work, but it fundamentally changes the relationship between intent and implementation:

```
User Story
    “ (human checkpoint)
Context Architecture Design
    “ (human checkpoint)
Component Design Document
    “ (AI implementation)
Implementation + Tests
    “ (automated validation)
Working Code
```

## Human Checkpoints: The Critical Difference

The key innovation isn't the design documents themselvesit's the **structured human approval gates** at critical architectural decisions:

### Checkpoint 1: Story to Architecture
When user stories are complete, an AI architect proposes how to decompose them into contexts (Phoenix's term for bounded contexts). But a human architect reviews and approves this mapping before proceeding.

**Why this matters**: This is where you define component boundaries, decide what entities live where, and establish your system's fundamental structure. Get this wrong, and every line of code that follows is in the wrong place.

### Checkpoint 2: Architecture to Design
For each component, AI generates a detailed design document following strict templates based on component type (context, repository, schema, LiveView, etc.). Human architects review each design before implementation begins.

**Why this matters**: Design documents specify the public API, data structures, dependencies, and interaction patterns. This is your last chance to catch architectural issues before they become code.

### Checkpoint 3: Design to Implementation
AI agents implement components based on approved designs, generating both code and tests from the same design document. The tests validate that implementation matches the design's intent.

**Why this matters**: With approved designs in place, implementation becomes more mechanical. When tests fail, you have a clear reference point: does the code match the design, or does the design need revision?

## The 1:1:1 Principle

The elegance of design-driven development comes from extending a simple convention:

**Elixir/Phoenix convention**: One test file per code file
**Design-driven extension**: One design document per code file per test file

```
docs/design/
  sessions/
    orchestrator.md          # Design document

lib/code_my_spec/sessions/
  orchestrator.ex            # Implementation

test/code_my_spec/sessions/
  orchestrator_test.exs      # Tests
```

This creates a traceable chain:
- **Design document** defines what should exist
- **Implementation** realizes the design
- **Tests** validate the realization matches the design

When any piece changes, you have a clear reference point for what else needs updating.

## Comparing Approaches

### Traditional Spec-Driven Development (e.g., SpecKit)

**Strengths:**
- Fast iteration from idea to code
- Structured workflow prevents "vibe coding"
- Works with multiple AI assistants
- Markdown specifications are version-controlled

**Weaknesses:**
- No architectural approval gates
- Specifications are transientcode becomes truth
- Error amplification through transformation chain
- Tests generated from same potentially flawed understanding
- Difficult to maintain alignment as systems evolve

### Design-Driven Development

**Strengths:**
- Human oversight at critical architectural decisions
- Design documents live alongside code as first-class artifacts
- Clear traceability from requirement ’ architecture ’ design ’ code
- Component boundaries explicitly defined and validated
- Designs serve as reference for future modifications
- Error correction happens at design level, not code level

**Weaknesses:**
- More human review time required
- Slower initial velocity (by design)
- Requires discipline to maintain design-code synchronization
- More artifacts to manage

## When Error Correction Matters

The critical question is: **When do you catch errors?**

In pure spec-driven approaches, you catch errors when:
- Tests fail (but tests may validate wrong behavior)
- Integration reveals mismatches
- Humans review generated code (high cognitive load)
- Production catches what testing missed

In design-driven approaches, you catch errors when:
- Architects review context decomposition (before code exists)
- Architects review component designs (before implementation)
- Automated tests validate implementation against design
- Design-code drift is detected

The earlier you catch errors, the cheaper they are to fix. A flawed architectural decision is easy to change in a design document. It's expensive to change after thousands of lines of code are built on it.

## The Session Orchestration Model

Design-driven development introduces another key concept: **session orchestration**. Rather than one long AI conversation that generates everything, work is broken into discrete sessions with specific goals:

**Component Design Session:**
1. Read component requirements
2. Read design rules for component type
3. Generate design document
4. Validate design structure
5. Human review and approval
6. Finalize design

**Component Coding Session:**
1. Read approved design document
2. Generate implementation and tests
3. Run tests
4. Fix failures (with design as reference)
5. Commit passing code

Each session has a clear start, end, and success criteria. Sessions can be resumed, replayed, or assigned to different agents. Crucially, each session's output (design or code) is validated before the next session begins.

## Practical Implementation

How does this work in practice? Let's trace a feature from story to code:

### 1. User Story
```
As a project manager, I want to view all active sessions
so that I can monitor ongoing AI-assisted work.
```

### 2. Architect Reviews Context Mapping
AI proposes: "Add list_sessions/2 to existing Sessions context"
Human approves: "Yes, this belongs in Sessions context"

### 3. Component Design Generated
```markdown
# Sessions.list_sessions/2

## Purpose
Returns list of sessions filtered by status and scoped to user's account/project.

## Public API
def list_sessions(scope, opts \\ [])
  Returns: [%Session{}]
  Options: :status (list of atoms, defaults to [:active])

## Dependencies
- SessionsRepository.list_sessions/2
- Scope must contain valid account_id and project_id
```

Human reviews and approves design.

### 4. Implementation Generated
AI agent reads approved design and generates:
- Implementation in `lib/code_my_spec/sessions.ex`
- Tests in `test/code_my_spec/sessions_test.exs`

### 5. Tests Validate Against Design
Tests verify:
- Function signature matches design
- Scope filtering works as specified
- Status filtering behaves correctly
- Returns expected data structures

If tests fail, agent fixes implementation (not design). If failures persist, session escalates for human reviewpotentially indicating design issues.

## The Philosophy: Process-Guided AI

The deeper insight is that **AI needs process, not just prompts**.

Spec-driven development provides process, but design-driven development provides **process with checkpoints**. It acknowledges that AI is excellent at generation but needs human judgment for architectural decisions.

This isn't a limitationit's a feature. Architectural decisions have long-term consequences. Making them reversible is expensive. Making them visible and reviewable before they're encoded in thousands of lines of code is pragmatic.

## Is This Approach Right for You?

Design-driven development makes sense when:

- You're building production systems (not prototypes)
- Architectural integrity matters
- Multiple people need to understand system design
- You need traceability from requirements to implementation
- You're working with LLM-assisted development but want human oversight
- You value correctness over speed

It may be overkill when:

- Building quick prototypes or experiments
- System complexity is low
- You're a solo developer who holds the architecture in your head
- Rapid iteration matters more than long-term maintainability

## The Future of AI-Assisted Development

The conversation about AI code generation often focuses on capabilities: how much code can AI generate? How accurate is it? Can it fix its own bugs?

Design-driven development asks different questions: Where do humans add the most value? What decisions are expensive to reverse? How do we maintain architectural integrity as systems scale?

The answer isn't to remove humans from the loopit's to position humans at the leverage points where judgment matters most. Let AI handle the mechanical transformation from design to code. Reserve human attention for the architectural decisions that determine whether you're building the right thing.

Spec-driven development is fast. Design-driven development is **deliberate**. And in production systems, deliberate beats fast.

## Getting Started

If you're intrigued by design-driven development:

1. **Start small**: Pick one context or module to design explicitly
2. **Use templates**: Create design document templates for your common component types
3. **Establish conventions**: Decide where design documents live and how they're named
4. **Review deliberately**: Don't rubber-stamp AI-generated designsactually read them
5. **Iterate**: Designs can evolve; use version control to track why decisions changed

The goal isn't perfect designs upfrontit's **visible, reviewable architectural decisions** before they become expensive to change.

## Conclusion

The software industry is learning how to work with AI code generation. Early approaches optimized for speed and automation. But as systems move from prototype to production, we're discovering that speed without direction creates costly mistakes.

Design-driven development acknowledges that AI is a powerful tool for code generation, but architectural decisions require human judgment. By introducing structured checkpoints at critical decision points, it maintains the productivity benefits of AI while preserving the architectural integrity that production systems demand.

The future of AI-assisted development isn't removing humansit's positioning humans where they add the most value. That happens at the design level, not the code level.

---

## Further Reading

- **SpecKit**: GitHub's open-source toolkit for spec-driven development - [github.com/github/spec-kit](https://github.com/github/spec-kit)
- **Phoenix Contexts**: Understanding bounded contexts in Elixir/Phoenix - [hexdocs.pm/phoenix/contexts.html](https://hexdocs.pm/phoenix/contexts.html)
- **Test-Driven Development with AI**: How TDD principles apply to LLM code generation
- **Architectural Decision Records**: Documenting architectural decisions over time
