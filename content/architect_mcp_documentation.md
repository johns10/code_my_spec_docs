---
# Metadata for architect_mcp_feature.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: architect-mcp-documentation
type: documentation  # Options: blog, page, landing
title: Architect - AI-Guided Context Design

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2025-11-13T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: AI-Guided Phoenix Context Design for CodeMySpec
meta_description: AI-guided architecture design. Map user stories to contexts, validate, refine, maintain traceability.
og_title: Architect - AI-Guided Context Design
og_description: Have AI design your Phoenix context architecture through expert-guided conversations. The Architect MCP Server turns architecture design into an iterative dialogue that maps user stories to well-defined contexts.
og_image: null  # URL to Open Graph image

metadata:

# Tags (optional, list of tag names)
tags:
  - architect
  - mcp-server
  - architecture
  - phoenix-contexts
  - context-design
  - vertical-slice
  - dependencies
  - traceability
  - claude
  - structured-data
  - domain-driven-design
---

# Architecture Tools: Technical Reference

## Overview

There is no separate architecture server anymore. The architecture tools are part of CodeMySpec's tool library, and they run alongside the component tools and the story tools. An agent reaches them through the harness MCP server, either with `run_script` (call `tool_docs` first for arguments) or through the `/codemyspec:design architecture` skill, which drives the design session for you.

The tools check and project the component graph. The component records themselves are managed with the [Components tools](/documentation/components-mcp-server).

## What They Do

1. **Validate** the dependency graph for circular dependencies.
2. **Analyze** stories by tag to suggest context boundaries.
3. **Compare** the planned architecture against live code and report drift.
4. **Compare** architecture decision records against `mix.exs`.
5. **Show** the architecture as an overview or a namespace tree.
6. **Apply** a written architecture proposal.

## Tools

### validate_dependency_graph

No parameters. Loads every component and dependency in the project and reports circular dependencies as a list of cycles, or confirms there are none. Run it after adding dependencies.

### analyze_stories

No parameters. Groups the project's stories by tag, shows which tags co-occur, and lists untagged stories. Tag stories first with `tag_stories`, then use the groupings to decide where context boundaries belong.

### check_architecture

No parameters. Compares the planned architecture against live code and reports where they disagree: an unplanned dependency, a planned dependency the code never uses, a planned component with no code, or code with no planned owner. It always runs on request. The project's `architecture` configuration switch only changes whether the stop hook reports findings.

### check_decisions

No parameters. Compares the ADRs in `.code_my_spec/architecture/decisions/` against `mix.exs`. It reports a direct dependency no ADR covers, an ADR covering a dependency that is gone, and an ADR that declines a dependency you actually use. Each ADR declares coverage in frontmatter with `deps: [...]` and `declined: [...]`.

### show_architecture_overview

No parameters. Returns every component grouped by parent context, with types, descriptions, and dependencies.

### show_namespace_hierarchy

Shows the components as a module-namespace tree, two levels deep by default. Optional arguments: `depth`, `prefix` (for example `MyApp.Accounts`), and `descriptions` (default true). It's the first thing to read for an overview.

### execute_proposal

No parameters. Reads the architecture proposal at `.code_my_spec/architecture/proposal.md`, validates it, and creates or updates components and story links. Use it when you rewrite the proposal for a larger restructure instead of editing component by component.

### regenerate_proposal

Takes `confirm: true`. Rewrites `proposal.md` from the architecture that already exists in the project, discarding any unexecuted edits. Useful when a project has components but no proposal document.

## How the Design Session Uses Them

The design task has two modes:

- **Initial**: no components and no proposal yet. The agent writes `proposal.md`, and the evaluator validates and executes it.
- **Revision**: components already exist. The agent edits through the tools (`create_component`, `add_dependency`, `set_story_component`), and the evaluator checks that the task's story is linked to a component.

## Scope and Auth

Every call is scoped to the project the working copy belongs to, and the client's OAuth identity decides which account you're in. The local server forwards MCP traffic to `https://codemyspec.com/mcp/harness`. Without sign-in, calls fail with an authentication error; run `/codemyspec:init auth`.
