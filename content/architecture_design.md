---
# Metadata for architecture_design.md

# Required fields
slug: architecture-design
type: documentation
title: "Architecture Design: Defining the System Before Code Exists"

# Publishing control
protected: false
publish_at: 2026-03-15T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Architecture Design - Stories to Components - CodeMySpec"
meta_description: How CodeMySpec maps user stories to bounded contexts and components with guided design sessions and ADRs, validated by procedural code.
og_title: "Architecture Design: Defining the System Before Code Exists"
og_description: Architecture design, technical strategy, and design reviews. The human defines structure, procedural code validates proposals, AI handles the creative work.
og_image: null

metadata:
  template: article
  author: John Davenport
  category: Documentation
  featured: false

tags:
  - documentation
  - architecture
  - design-review
  - adr
  - phoenix-contexts
  - bounded-contexts
  - level-4
---

# Architecture Design: Defining the System Before Code Exists

Most AI coding workflows put the human in the review seat. The AI writes code, you read it, you approve or reject. That works until the AI is producing code faster than you can read.

Level 4 flips the relationship. You stop reviewing code and start defining what correct looks like. On the architecture side, that means defining the system's structure: contexts, components, dependencies, technology decisions, before any implementation begins.

This is where procedural code matters most. The AI proposes. Deterministic validation checks the proposal. The human approves structure, not code.

## Architecture Design

`/codemyspec:design architecture` starts a guided session that turns user stories into a component graph. The requirement graph offers it as `architecture_designed` once stories and a technical strategy exist.

The agent receives the unsatisfied user stories, the current component count, and tools to read the architecture: an overview, a Mermaid dependency graph, and a namespace hierarchy. Its job is to analyze the stories, identify bounded contexts, and map each story to surface components (the LiveView or controller the user interacts with). The dependency graph determines domain context involvement. If a surface component depends on a context, stories on that surface flow to the context.

Procedural validation enforces story mapping, not AI judgment. Every story must be linked to a component, and the system checks real story numbers, not AI-generated ones. If the mapping is incomplete or invalid, the agent gets specific feedback about exactly what's wrong.

The session has two modes. With no components yet, the agent writes a proposal to `.code_my_spec/architecture/proposal.md` following a strict document schema. When the session stops, procedural code parses the proposal, validates it, and executes it: creating component records, linking stories to components in the database, and building out the component tree. With components already in place, the agent revises through tools (`create_component`, `add_dependency`, `set_story_component`) and the evaluator checks the story is linked. No human reads the proposal line by line. The validation catches structural problems. The human reviews the architecture at the level of "does this decomposition make sense for the product?"

## Technical Strategy

Before any code gets written, technology decisions need to happen. `/codemyspec:design strategy` handles this through Architecture Decision Records.

The system auto-writes ADRs for the standard stack: Elixir, Phoenix, LiveView, Tailwind, DaisyUI, phx.gen.auth, hand-written Req clients tested with ReqCassette, BDD specs with SexySpex, Dotenvy, Resend, Hetzner deployment, and Pow Assent integrations. These are pre-made decisions baked into procedural code. They get committed as accepted records without discussion because they're not decisions anymore. They're the platform.

Then the agent looks at the project's architecture, stories, and dependencies to identify open decisions. Testing strategy. Deployment approach. Third-party integrations. Background job infrastructure. For each topic, it does cursory research, evaluates options against project needs, and writes a decision record with context, options considered, and consequences.

The evaluate step is deterministic: check that all pre-made decisions have ADR files and that the decisions index exists. The system captures technology choices as documents before the first line of implementation code. This matters because it means the AI has explicit constraints to work within, not implicit assumptions to guess at. Afterward, `check_decisions` compares the ADRs against `mix.exs` and flags dependencies no decision covers.

## Architecture Review

The architecture tools review the health of the existing architecture. `architecture_health_summary` calculates metrics (story coverage, context distribution, high fan-out, circular dependencies, orphaned components), `check_architecture` compares the planned architecture against live code, and `show_architecture_overview` and `show_namespace_hierarchy` generate fresh views.

The agent reviews surface-to-domain separation, dependency flow direction, component responsibilities, story coverage, and architectural issues. It uses tools to investigate and make changes directly: linking stories to components, checking for cycles, reading component records.

This is a conversational session. There's no strict validation gate. The value is in catching drift: components that lost focus, dependencies that flow the wrong direction, stories that fell through the cracks. You run this periodically, not as part of every build.

## Context Design Review

`start_context_design` and `review_context_design` validate the design of the bounded contexts before implementation begins. The agent reads the components, their dependencies, and the linked user stories, then checks the design against the principles: each story maps to exactly one context, dependencies are explicit and non-circular, and contexts are the right size (a context carrying 7 or more stories is a split candidate).

If it finds problems, it fixes the component records directly. The executable BDD specs are where the contract is finally pinned down: each acceptance criterion links to a scenario you run with `mix spex`, and implementation is written against those.

## The Pattern

Across all these commands, the human works at the level of "what should this system do and why." You define stories. You approve architecture. You make technology decisions.

Everything below that (mapping stories to components, validating proposals, writing ADRs for standard decisions, calculating architecture health metrics) runs as a combination of AI doing the creative work and procedural code validating the output. The AI proposes. The code checks. The human approves at the structural level.

This is what makes Level 4 architecture different from "ask the AI to design your system." Procedural code validates the AI's proposals against real data: actual story IDs, actual component graphs, actual dependency chains. When it gets something wrong, the feedback is specific and mechanical, not a vague "try again."

The architecture side defines what should exist. The QA side verifies that what exists is correct. Together, they close the loop.
