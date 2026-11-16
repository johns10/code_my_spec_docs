---
# Metadata for context_development.md

# Required fields
slug: context-development
type: documentation
title: "Context Development: Let the AI Build the Whole Thing"

# Publishing control
protected: false
publish_at: 2026-03-15T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Context Development - Orchestrated Lifecycle"
meta_description: How develop context builds a whole bounded context. The AI walks the component tree in dependency order against executable BDD specs.
og_title: "Context Development: Let the AI Build the Whole Thing"
og_description: Stop driving one file at a time. The develop-context command handles specs, design review, implementation, and testing for an entire bounded context.
og_image: null

metadata:
  template: article
  author: John Davenport
  category: Documentation
  featured: false

tags:
  - documentation
  - contexts
  - orchestration
  - phoenix-contexts
  - bounded-contexts
  - automation
  - level-3
---

# Context Development: Let the AI Build the Whole Thing

> **Part of the [CodeMySpec Methodology](/methodology)**, Level 3: AI Develops, Humans Review.

At Level 2, you drive one component at a time. Design it, write the specs, generate the code, run validation, fix what breaks, repeat for the next component. You're in control the whole way, and every step has guardrails.

It works. But when a context has a dozen components with dependencies between them, you're spending most of your time deciding what to build next, not reviewing what gets built. You become the scheduler.

Level 3 is where you stop scheduling and start reviewing.

## What develop context Does

You run `/codemyspec:develop context MyApp.Accounts` and point it at a bounded context. The system takes over from there.

Here's what happens, end to end:

1. **Read the design.** The context and its children are component records. The agent lists them with `show_namespace_hierarchy` (prefixed with the context) and reads each with `get_component`.
2. **Implement in dependency order.** Leaves first. Components with no dependencies get built before the ones that depend on them: schemas, then the modules that use them, then the context module itself, last. Each child's code is written by a code-writer subagent against the story's executable BDD specs.
3. **Validate.** Every component is checked against its implementation requirement, and the analyzers run (compile, Credo, stale tests). The context isn't done until every component in the tree is satisfied.

You review the output as a whole. A finished context, not a pile of individual files.

## The Requirement Graph

Heavy orchestration lives in the requirement graph, not in the command. For a context, the graph holds:

- a `dependencies_met` junction that waits on every context this one depends on
- an `implementation_file` requirement for each child, gated by that junction
- an `implementation_file` requirement for the context module itself, which waits on its children

Markdown specs and reviews are inputs to this work, not extra stages. The stage gates that matter, specs that pass and QA that holds, live at the story level. Each requirement is satisfied by a specific agent task, and the graph figures out what's actionable (unsatisfied, with all prerequisites met), dispatches it, and moves on.

## Dependency Ordering

The system doesn't build components in any order. It walks the dependency graph. If a repository depends on a schema, the schema gets built first. If your context delegates to the repository, the repository gets built before the context. Blocking is transitive, so a child behind an unfinished dependency simply isn't offered yet.

This means the system naturally works bottom-up through the component tree.

## The Design Checkpoint

Review before the code, not after. The design gate is the architecture. `start_context_design` and `review_context_design` check the context boundaries and dependencies against your stories, and you read that before implementation starts. If something is wrong, you catch it while it's still a record you can edit, before the system generates thousands of lines of code from a flawed design.

## develop live-context: The UI Variant

A live context is a container for a group of LiveViews and LiveComponents. It doesn't have a code file of its own. Only its children have implementations, with LiveComponents built before the LiveViews that use them. The parent is done when all its children satisfy their implementation requirements.

## Other Modes

`/codemyspec:develop liveview ModuleName` orchestrates a single LiveView and its child components. `/codemyspec:develop refactor` is an interactive refactoring mode.

## How It Knows When It's Done

The evaluate step checks the same thing everywhere: are all implementation requirements satisfied across all components in scope? For a context, that means the context plus all children. For a live context, only the children.

When all requirements are satisfied, the task reports completion. When they're not, it lists exactly which components still need work.

## What This Feels Like

You pick a context. You run the command. You go do something else.

When you come back, the tree is green or the evaluation says exactly what's missing. Your job shifted from "write this schema, now write this repository, now write these tests, now write the context module" to "does this architecture make sense, and do the specs say what I meant?" That's the Level 3 transition. You went from driving to reviewing.

## What Comes Next

This works well when you know which context to build. You point the system at an Accounts context, it builds the Accounts context.

But who decides that Accounts and Transactions are the right contexts in the first place? Who maps user stories to bounded contexts? Who designs the dependency graph between them?

That's Level 4, where humans define the architecture and the system builds everything that follows from it.
