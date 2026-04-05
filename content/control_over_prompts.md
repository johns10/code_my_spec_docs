# Code Generation is About Control, Not Prompts

Every AI coding tool competes on the wrong thing. Bigger context windows. Better prompts. More sophisticated memory. More autonomy for the agent.

Here's what I learned building CodeMySpec: **the best way to get reliable code from an LLM isn't better prompting. It's better enforcement.**

## Why does prompt engineering fail for complex code generation?

Cursor, Windsurf, Copilot -- they all work the same way. Give the LLM maximum context, craft a prompt, hope it does the right thing.

Sound familiar?

The LLM decides what files to read. What order to work in. Whether to run tests. When it's "done." You're along for the ride.

This works fine for small tasks. But autonomous decision-making compounds errors. An LLM will skip validation it thinks is unnecessary. It'll generate tests that pass but test the wrong behavior. It'll drift from your architecture as context accumulates. Each decision looks reasonable in isolation. Collectively, they're chaos.

**Autonomy without constraints is technical debt with a faster commit rate.**

## What is the difference between control-based and suggestion-based code generation?

Traditional tools work through suggestion: "Here's my codebase, here's the feature, please write good code."

Then they add guardrails after the fact -- sandboxed execution, human review gates, safety checks. These are defensive measures against an adversarial problem. You're trying to catch the LLM after it goes off the rails.

Control-based systems don't prevent bad decisions. They prevent certain decisions from being made at all.

## How do you enforce workflow constraints on an AI code generator?

We built on a different premise: code generation should be a constrained workflow, not an autonomous agent.

### 1. Requirement Dependency DAG

Instead of letting the LLM decide what to do next, we define a directed acyclic graph of 22 requirement checkers. Each checker has explicit dependencies. The hierarchical checker validates parent-child satisfaction. The dependency checker ensures all prerequisites pass before implementation starts.

The LLM cannot skip steps. The orchestrator enforces the sequence through the graph. If a requirement fails, the only path forward is fixing it.

### 2. Stop-and-Validate Pattern

The agent writes one artifact. Stops. The validation pipeline runs: compiler, tests, Credo, Sobelow, Spex (BDD specs), spec doc validation, QA. Only after validation passes does the next step begin.

This isn't prompt engineering. It's interface enforcement. The LLM doesn't decide how to handle results -- the pipeline does.

### 3. Structural Validation Between Steps

We don't ask the LLM to "make sure it's valid." We parse its output against required structure. Design documents get validated against type-specific required and optional sections -- specs, context specs, schemas, LiveViews, architecture proposals, ADRs. Each document type has its own rules.

If validation fails, the system forces correction with explicit error details. The LLM doesn't get to explain why the missing section doesn't matter.

### 4. Test-Driven Enforcement

Testing is a mandatory workflow step, not an LLM suggestion. The validation pipeline runs compiler checks, then tests, then static analysis, then BDD specs. Tests pass or the workflow doesn't complete.

The LLM cannot decide "the tests are flaky." The problems system captures every failure as a unified representation. Fix it or stop.

### 5. Dirty Tracking and Scoped Analysis

File changes mark components as dirty. The validation pipeline runs scoped analysis only on dirty components through the problems system. No wasted cycles revalidating clean code. No opportunity for the LLM to claim unrelated failures.

### 6. Boundary Enforcement

Every module uses `use Boundary` for compile-time dependency enforcement. 14 component types with specific requirements per type. The LLM can't "helpfully" wander into unrelated parts of your codebase -- the compiler won't let it.

## What kinds of problems does a control-based approach prevent?

**Hallucinated Workflows**: The requirement DAG defines all possible transitions. The LLM cannot invent process steps.

**Validation Bypass**: 22 requirement checkers, enforced by code, not prompts.

**Context Drift**: State is explicit and scoped, not accumulated in conversation history.

**Test Avoidance**: Tests are mandatory steps in the pipeline.

**Architectural Violations**: `use Boundary` catches dependency violations at compile time.

## What are the tradeoffs of enforcing control over AI code generation?

This approach isn't free. More upfront design. Less flexibility. The LLM can't creatively adapt to unexpected situations -- you need a human for that.

But here's what you get: **predictability**. When a controlled workflow completes, every required validation passed. All tests ran. The design conforms to required structure. You have a complete audit trail.

I've found that predictability beats speed every time in production systems.

## How should you rethink your approach to AI code generation?

Stop optimizing prompts. They'll always be fragile. Ask instead: what workflow constraints would make bad outputs impossible?

Stop adding more context. LLMs already have enough context to generate bad code confidently. Add structural validation between generation steps.

Stop treating the LLM as an agent. Treat it as a powerful, unreliable code generator that needs supervision at every step.

Start building enforcement architectures. Define your workflows as dependency graphs. Make validation mandatory. Build pipelines that cannot be bypassed.

The future of AI-assisted development isn't smarter agents. It's better engineering.

## Frequently Asked Questions

**What is a requirement dependency DAG in AI code generation?** A requirement dependency DAG is a directed acyclic graph that defines the order in which code generation tasks must be completed. Each requirement has explicit prerequisites, and the system enforces the sequence so the LLM cannot skip steps or work out of order. This eliminates the class of errors caused by autonomous task selection.

**Can you use control-based code generation with any AI coding tool?** The principles apply to any tool, but the enforcement mechanisms need to be built into your workflow. You need validation pipelines, structural checks between steps, and an orchestrator that gates progress. Tools like Claude Code with MCP servers make this easier because you can build the enforcement into the tool interface itself.

**Does control-based generation slow down development?** It adds overhead per step but reduces total time by eliminating rework. When every step is validated before proceeding, you catch errors early instead of discovering them after thousands of lines of generated code. Predictability beats raw speed for production systems.

**What is the stop-and-validate pattern?** The stop-and-validate pattern means the agent writes one artifact, stops, and a validation pipeline runs automatically before the next step begins. The pipeline can include compiler checks, tests, static analysis, and structural validation. The LLM does not decide whether validation passed -- the pipeline does.

**How does boundary enforcement prevent architectural drift?** Boundary enforcement uses compile-time dependency checking to prevent modules from importing code they should not access. In Elixir, `use Boundary` enforces this at the compiler level. The LLM cannot introduce cross-boundary dependencies because the code will not compile, regardless of what the prompt says.
