---
# Metadata for components_mcp_server.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: components-mcp-server
type: documentation  # Options: blog, page, landing
title: Components MCP Server - AI Software Architect

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2025-10-28T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: Components MCP Server - AI Phoenix Architect | CodeMySpec
meta_description: MCP Server helps design contexts, dependencies, and analyze architectural health for Elixir applications.
og_title: Components MCP Server - AI Software Architect
og_description: Design clean Phoenix architecture with AI-guided context design, dependency management, and health monitoring
og_image: null  # URL to Open Graph image

# Additional metadata (custom key-value pairs)
metadata:
  template: article  # Options: default, article, tutorial
  author: CodeMySpec Team
  category: MCP Servers
  featured: true

# Tags (optional, list of tag names)
tags:
  - documentation
  - mcp-server
  - components
  - architecture
  - phoenix
  - contexts
  - dependencies
  - ai-architect
  - claude-code
  - elixir
---

# Components MCP Server: Technical Reference

## Overview

The Components MCP Server (`components-server`) is CodeMySpec's web-accessible MCP server for designing, managing, and analyzing Phoenix application architecture. It exposes 16 tools for component CRUD, dependency management, architecture design sessions, health analysis, and linking stories to components.

**Endpoint:** `/mcp/components` (web)
**Transport:** Streamable HTTP
**Auth:** OAuth2 token required; the project comes from the request's project or harness header

The same tools are also part of the main tool library, so an agent connected to the harness reaches them through `run_script`. See [progressive tool disclosure](/blog/progressive-disclosure).

## What It Does

The Components Server acts as your AI software architect. It helps you:

1. **Design Phoenix contexts and modules** based on user stories
2. **Model component architecture** with proper type classification
3. **Manage dependencies** between components with cycle detection
4. **Analyze architectural health** with coverage and quality metrics
5. **Link components to stories** to establish traceability
6. **Review and refine architecture** against best practices

## Available Tools (16)

### Core CRUD (5 tools)

#### create_component

Creates a single component as a record. No spec file is written.

- `name` (string, required)
- `type` (string, required): one of `context`, `coordination_context`, `live_context`, `schema`, `behaviour`, `json`, `liveview`, `liveview_component`, `controller`, `module`, `infrastructure`
- `module_name` (string, required): full Elixir module name, for example `MyApp.ApiKeys`
- `description` (string, optional)
- `parent_component_id` (string, optional): the parent component for hierarchical structures

```json
{
  "name": "ApiKeys",
  "type": "context",
  "module_name": "MyApp.ApiKeys",
  "description": "Manages API key generation, revocation, and rotation"
}
```

#### update_component

Updates a component. Requires `component_id`. Any of `name`, `type`, `module_name`, `description`, and `parent_component_id` can be sent. Fields you include are persisted exactly as sent.

#### delete_component

Deletes a component by `component_id`. Its files are left alone. While live code still names the module, the next sync discovers it again.

#### get_component

Reads one component by `component_id` or by `module_name`. Returns its type, description, provenance, parent, what it depends on (marked planned and/or in code), and the files that belong to it.

#### list_components

Lists every component in the current project. No parameters.

### Dependency Management (2 tools)

#### add_dependency

Records that one component depends on another. Takes `source_component_id` (the component that depends) and `target_component_id` (the one it depends on). Self-dependencies and circular dependencies are rejected.

#### remove_dependency

Removes a dependency. Takes the same two arguments.

### Architecture and Design (6 tools)

#### start_context_design

Starts a guided Phoenix context design session. It loads the unsatisfied stories and the existing components and dependencies, then gives the AI an architect persona and a structured prompt. The principles it works from:

- Each user story maps to exactly one context
- Domain contexts own at least one entity type
- Coordination contexts orchestrate workflows across domains
- Dependencies are explicit and justified
- No circular dependencies
- Flat context structure

#### review_context_design

Reviews the current context architecture against best practices. It shows the architecture with dependencies, the stories still needing a component, and the dependency graph check, and it asks whether contexts should be split or merged.

#### show_architecture

Renders the component dependency graph as a Mermaid flowchart. Dependencies on child components are rolled up to the containing surface, so the graph stays at the architecture level.

#### architecture_health_summary

A health overview covering story coverage (assigned and unassigned components), context distribution (contexts with 7 or more stories are split candidates), dependency issues (missing references, high fan-out, cycles), and data quality. It produces an overall score and a health level.

#### context_statistics

Per-context story counts and dependency in and out counts. Takes an optional `sort_by`, defaulting to `story_count`.

#### orphaned_contexts

Lists contexts with no user story and no dependencies, which may need review or removal.

### Story Linkage (3 tools)

#### set_story_component

Links a story to the component that implements it. Takes `story_number` and `module_name`.

#### clear_story_component

Removes a story's component link. Takes `story_number`.

#### list_stories

Lists the project's stories for reference while designing.

## Component Types

| Type                   | Purpose                                         |
| ---------------------- | ----------------------------------------------- |
| `context`              | Domain context owning entities                  |
| `coordination_context` | Workflow orchestration context                  |
| `live_context`         | UI grouping of related LiveViews                |
| `schema`               | Ecto schema (database entity)                   |
| `behaviour`            | Elixir behaviour definition                     |
| `json`                 | Phoenix JSON view for a controller              |
| `liveview`             | Phoenix LiveView page                           |
| `liveview_component`   | Reusable Phoenix LiveView component             |
| `controller`           | Phoenix controller handling HTTP and JSON       |
| `module`               | General case, any other module                  |
| `infrastructure`       | Infrastructure with no requirements of its own  |

Each type carries its own requirement template and a conventional file path. Components default to `module` when no type is given.

## Component Hierarchy

Components follow a parent-child hierarchy based on module namespace:

- A context like `MyApp.Accounts` is the parent
- Its schemas (`MyApp.Accounts.User`) and other modules are children
- Children reference their parent via `parent_component_id`
- Dependencies are tracked between components, and the graph views roll child dependencies up to the containing context

Components are records. They come from two places: an agent authors them with the tools above, or a sync discovers them from your code. A component's provenance records which.

## Security and Multi-Tenancy

All operations are scoped:

- Components can't be accessed across accounts
- All queries filter by account and project
- Scope comes from the OAuth2 token and the project header
- Story-to-component links are validated within project boundaries

## Integration with Workflow

```
1. Stories              define requirements
2. Components (here)    plan architecture
3. Executable BDD specs say what each story must do (run with mix spex)
4. Code and tests       implement against the specs
5. QA                   checks the running app
```

Components created here drive:

- Implementation order (dependency resolution)
- File creation (module names and types)
- Traceability (which component satisfies which story)
- Requirement tracking in the requirements graph

## Errors

- Missing required fields (`name`, `type`, `module_name`) or an invalid component type
- Circular or self dependencies
- Component not found, or not in the active project
- Invalid or missing OAuth2 token

Errors return descriptive messages with field-level detail for validation failures.
