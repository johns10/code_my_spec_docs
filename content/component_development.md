---
# Metadata for component_development.md

# Required fields
slug: component-development
type: documentation
title: "Component Development: One File at a Time"

# Publishing control
protected: false
publish_at: 2026-03-15T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Component Development - Spec, Code, Test"
meta_description: "How CodeMySpec builds one component at a time with guardrails: design, executable BDD specs, generated code, and tests. Each step is validated."
og_title: "Component Development: One File at a Time"
og_description: The 1:1:1 principle in practice. One spec, one code file, one test file. Each with schema validation, artifact checking, and BDD alignment.
og_image: null

metadata:
  template: article
  author: John Davenport
  category: Documentation
  featured: false

tags:
  - documentation
  - components
  - specs
  - testing
  - bdd
  - code-generation
  - level-2
---

# Component Development: One File at a Time

> **Part of the [Five Levels of AI-Assisted Development](/blog/five-levels-of-ai-coding)**, Level 2: Pair Programming.

You've got your architecture. You've got your stories mapped to bounded contexts. Now you need to turn those into working code.

The temptation is to say "build the whole thing" and let the AI go. That's Level 3. We're not there yet. At Level 2, you're pair programming. You and the AI take turns, one artifact at a time. You stay in the driver's seat. The AI does the typing. Each step has a safety net so the AI can't silently drift off course.

## What a Component Is

Every component in your system is a record with a type, a description, a parent, dependencies, and linked stories. The agent reads it with `get_component` and reads the wider picture with `show_namespace_hierarchy`. There's no spec file to keep in sync. The contract that matters most is the story's executable BDD specs.

```
Component record   (MyApp.Accounts, a context with its dependencies)
BDD spex           test/spex/<story_number>_*/   (run with mix spex)
lib/my_app/accounts.ex                           (code)
test/my_app/accounts_test.exs                    (test)
```

Change behavior by changing the spec first, then the code.

## Step 1: Design the Component

You create or adjust the component with the architecture tools (`create_component`, `update_component`, `add_dependency`) or through an architecture design session. You're deciding the type, the responsibility, and what it depends on. Those are the decisions that matter, and they're cheap to change before any code exists.

## Step 2: Write the Spex

Each story's acceptance criteria become Given-When-Then scenarios. They run with `mix spex`, not `mix test`. They drive the app the way a user would, so they define the component's public API from the outside. The three amigos session settles the questions first, and the spec-writing task then produces files under `test/spex/`.

## Step 3: Generate the Code

The component code task takes a component and generates the implementation. Its prompt includes:

- **The component's record**, read with `get_component`
- **The test file path**, so the AI reads the expected behavior
- **The story's spex**, which are the contract for the component's public API
- **Coding rules** for that component type, from `.code_my_spec/rules/`

The instructions are explicit: read the component, read the tests and the spex, implement the public API implied by them. The AI isn't inventing architecture. It's filling in the implementation for a design you already approved.

### What the Evaluation Checks

After generation, the system checks the implementation file exists, then runs analyzers: compilation errors, Credo, and stale tests. If requirements aren't satisfied, the AI gets structured feedback and tries again. Static analysis problems come back as actionable feedback, not a vague "something's wrong."

## Step 4: Write the Tests

The component test task writes unit tests under the component type's test rules. If the implementation doesn't exist yet, the AI writes tests TDD-style. Test failures are expected in that mode, so they're filtered out during evaluation. Compilation errors and Credo warnings still get caught. If the implementation exists, the tests validate it.

## The Guardrails

Three things keep this process honest:

**Rules per component type.** `.code_my_spec/rules/` holds design and test conventions for each type, and every prompt includes the matching ones.

**Requirement checking.** Each step has explicit requirements in the graph, computed from real files and records. If a step's requirements aren't met, you get told what's missing.

**Executable specs.** The BDD specs fail until the behavior exists. There's no way to claim a component is done while its spex are red.

## When This Works Best

Component development works well when you're building something new and want to be deliberate about it. You design the component, think about how it fits the architecture, then let the AI implement it while the guardrails keep it honest.

It also works well for learning a codebase's patterns. Watch what the AI generates for the first few components. Adjust your rules. By the time you've built a handful of components, the output is consistent.

Where it gets tedious: a context with twelve child components. Reviewing each one and waiting for each evaluation loop means you're still the bottleneck.

## Moving to Level 3

When you're tired of driving one file at a time, that's the signal to move up. `/codemyspec:develop context ModuleName` takes an entire bounded context and walks its component tree in dependency order. You review the output as a whole instead of line by line.

But you need to earn that. Level 2 is where you learn what good designs and specs look like, what the guardrails catch, and what they miss. Start here. Do a few components manually. When the process feels mechanical, you're ready.
