---
# Metadata for start_implementation.md

# Required fields
slug: start-implementation
type: documentation
title: "Start Implementation: The Full Cycle"

# Publishing control
protected: false
publish_at: 2026-03-15T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Start Implementation - Full Dev Cycle"
meta_description: The graph-driven orchestrator that walks stories to deployed software. How CodeMySpec dispatches architecture, implementation, and QA tasks autonomously.
og_title: "Start Implementation: The Full Cycle"
og_description: Define your stories. The system designs architecture, generates specs, implements code, runs QA, and triages issues. One loop until everything passes.
og_image: null

metadata:
  template: article
  author: John Davenport
  category: Documentation
  featured: true

tags:
  - documentation
  - automation
  - orchestration
  - full-cycle
  - dark-factory
  - fuellytics
  - case-study
  - level-5
---

# Start Implementation: The Full Cycle

In the five levels article, I described Level 5 as the "dark factory", specs in, software out. The full autonomous cycle where you define stories and the system handles everything between those stories and running software.

That sounds like marketing. Let me show you what it actually is.

## The Loop

`/codemyspec:implement` turns on continuous mode. After that, the stop hook won't let the agent stop while requirements remain. It directs the agent back to the next one. The loop is:

```
get_next_requirement, start_task, (do the work), evaluate_task, repeat
```

1. `get_next_requirement` reads the requirement graph: project, stories, contexts, components, dependencies
2. It offers the first requirement that isn't satisfied and whose prerequisites are met
3. `start_task` dispatches the matching agent task, which builds the prompt
4. When the agent finishes, the task evaluates the result
5. If something is still unsatisfied, the agent is sent back with specific feedback
6. If nothing actionable remains, continuous mode clears and the loop stops. `/codemyspec:implement stop` ends it early

That's it. There's no planning step and no separate task queue. The orchestrator doesn't decide what to do next by reasoning about it. It walks the graph, finds the gap, and fills it. The graph is the plan.

## The Setup Phase

Before any business logic gets written, project initialization runs through the same loop.

**Init** checks the pre-project steps: you're signed in, a Phoenix project exists in the directory, and the CLI config links it to a CodeMySpec project.

**ProjectSetup** turns that project into one that works with CodeMySpec. It adds the dependencies and compilers, configures `mix spex`, sets up the test boundaries and the spex test case, creates the `.code_my_spec/` structure, and installs `AGENTS.md`, `CLAUDE.md`, rules, and Credo checks. The evaluation is deterministic: each step checks exactly what's missing.

Then the project graph runs in order: personas, stories, technical strategy, architecture design, the spex boundary, and code generation (auth, accounts, and the other scaffolds). Every task follows the same pattern: generate a prompt with instructions and current state, let the agent execute, then evaluate with hard checks. No subjective review. Either the artifact exists and is correct, or it doesn't and the agent gets specific feedback about what to fix.

## Story and Component Work

Once setup is done, the graph works story by story. Each story needs a linked component, a Three Amigos session that settles questions and acceptance criteria, and executable BDD specs. Then the components get implemented.

Components with children are containers. A context's own implementation waits behind its children and behind the contexts it depends on, so the work flows in dependency order: schemas first, then the modules that use them, the context module last. Within a layer, components can run in parallel.

After implementation come the quality gates for the story: `ready_for_qa`, `qa_complete` (QA run against the running app), triaged issues, and promotion.

## The Dispatch Pattern

This is the key insight. The loop doesn't know how to write code, design architecture, or run QA. It knows how to walk a graph and dispatch.

The requirements in the graph map to tasks:

- Architecture not designed yet? Dispatch architecture design.
- A component needs implementing? Dispatch the component code task.
- A story needs BDD specs? Dispatch the spec-writing task.
- Story needs QA validation? Dispatch the story QA task.
- Technology decisions not made? Dispatch technical strategy.

Each of those is a complete agent task with its own prompt builder and its own evaluator. The orchestrator picks the right one based on what the graph says is missing.

When an agent finishes work, the project state syncs (picking up new files, updated requirements) and the graph is walked again. If the work satisfied the requirement, the graph moves forward. If it didn't, the evaluation feedback goes back to the agent. The loop continues until everything is green or something fails hard enough to surface an error.

## What This Actually Produces

Fuellytics is a fuel card management platform with Stripe Treasury integration, fraud detection, and financial compliance requirements. It went from an empty repository to user acceptance testing in six weeks. One person defining requirements. The system handling implementation.

55 commits. Full financial services platform. Stripe Treasury for fund management. Real-time transaction monitoring. Compliance workflows. Multi-tenant architecture with role-based access control.

The orchestrator walked the graph hundreds of times. Each pass found the next gap, a schema that needed implementing, a context that needed tests, a story that needed QA validation. Each gap got dispatched to the right command. Each command ran its agent, produced artifacts, got evaluated.

The human work was defining the stories, approving the architecture decisions (Stripe Treasury vs. alternatives, fraud detection approach, compliance strategy), and making product calls when the system surfaced questions it couldn't answer from the spec alone.

## What the Human Still Does

I want to be clear about this because the "dark factory" framing can be misleading.

The human defines stories. Not vague ideas, structured stories with acceptance criteria that can be mechanically verified. This is product work. It requires understanding the domain, the users, and what correct behavior looks like.

The human approves architecture. When the system proposes a component graph, dependency structure, or technology decision, a human reviews it. Architecture mistakes are expensive and the system doesn't have the product context to make those calls autonomously.

The human makes product decisions. When a story has ambiguity that can't be resolved from the spec, the system surfaces it. Someone has to decide. That someone understands the business.

The human isn't removed from the process. They're elevated. Instead of writing code, reviewing diffs, and debugging test failures, they're working at the level of "what should this system do and why." Everything below that, the how, is automated and verified.

## The Loop That Makes It Work

The reason this works isn't the AI. The AI is the same Claude that everyone has access to. What makes it work is the loop.

The orchestrator dispatches a command. The agent does work. The evaluator checks the work with deterministic criteria. If it fails, the feedback is specific and actionable, not "try again" but "`.env.example` is missing, tests don't compile, these three components still need implementation files." The agent gets that feedback and fixes exactly what's wrong.

This loop runs until every requirement on the graph is satisfied. Not until the AI thinks it's done. Until the checks pass. The checks don't get tired. They don't skim. They don't approve something because it looks close enough at 11pm.

That's the difference between Level 2 and Level 5. At Level 2, you're the loop. At Level 5, the graph is the loop, and you're the person who defined what the graph should look like.

## The Bottleneck Was Never Typing Code

In the five levels article, I used the YouTube analogy. When YouTube launched, professional videographers dismissed it. They were right that amateurs weren't making cinema. They were wrong about what that meant.

YouTube didn't succeed because amateurs got better at cinematography. It succeeded because the bottleneck was never operating a camera. It was knowing what to point it at.

The same thing is true here. The bottleneck in software development was never typing code. It was knowing what to build, defining what correct looks like, and verifying that what got built matches the definition.

The implementation loop is a walk over a graph that dispatches tasks. The graph is the interesting part. The graph is the spec, stories, contexts, components, dependencies, requirements. If the graph is right, the software is right. If the graph is wrong, no amount of code quality saves you.

The skill that matters at Level 5 is the same skill that mattered before AI: understanding the problem well enough to define the solution. The difference is that everything between the definition and the running software is now automated. Not by magic. By a loop that checks its own work, over and over, until the checks pass.
