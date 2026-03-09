# Architecture MCP Server - Technical Reference

## Overview

The Architecture MCP Server (`architecture-server`) is a local-only MCP server that provides architecture analysis tools for AI agents. It exposes 2 tools for validating component dependency graphs and analyzing user stories by tag groupings to inform architectural design decisions.

**Endpoint:** `/mcp/architecture` (localhost:4001 only)
**Transport:** Streamable HTTP via Hermes MCP
**Auth:** LocalOnly plug, WorkingDir header, LocalScope from config.yml

## What It Does

The Architecture Server provides two focused analysis capabilities:

1. **Validates dependency graphs** for circular dependencies that violate clean architecture
2. **Analyzes stories by tags** to identify domain groupings and inform context design

This is a lightweight, local-only server intended for AI agents working on the codebase directly. For full component CRUD and architecture design, use the Components MCP Server (web, `/mcp/components`).

## Available Tools

### validate_dependency_graph

**Purpose:** Validates the component dependency graph for circular dependencies.

**Parameters:** None

**What it does:**
- Loads all components and their dependencies for the current project
- Detects circular dependency cycles (e.g., A depends on B depends on A)
- Returns validation result: success or detailed list of detected cycles

**Returns:**
- Success: confirmation that no circular dependencies exist
- Failure: list of detected cycles with component paths

**Use case:** Run after modifying dependencies to ensure clean architecture is maintained. Circular dependencies make code harder to test, maintain, and reason about.

### analyze_stories

**Purpose:** Analyzes user stories grouped by their tags to inform architecture design.

**Parameters:** None

**Prerequisites:** Stories should be tagged first using `tag_stories` or individual tag tools from the Stories Server.

**What it does:**
- Loads all stories in the current project
- Groups stories by their tags (supports both simple tags and prefixed `category:value` tags)
- Identifies tag co-occurrences (tags that frequently appear together on stories)
- Lists untagged stories that need categorization

**Returns:** Markdown report with:
- Summary: total stories, tagged count, untagged count
- Tag groupings: stories organized by tag with counts
- Tag co-occurrences: tag pairs appearing together on 2+ stories (top 15)
- Untagged stories: list of stories needing tags (up to 10 shown)

**Use case:** Before designing Phoenix contexts, tag stories by domain area, then run `analyze_stories` to see natural groupings that suggest context boundaries.

**Example output:**
```
## Story Analysis

**Total:** 24 | **Tagged:** 20 | **Untagged:** 4

### Tags

**Domain**
  - authentication (5): id1, id2, id3, id4, id5
  - billing (3): id6, id7, id8
  - notifications (4): id9, id10, id11, id12

### Tag Co-occurrence

- authentication + notifications (3 stories)
- billing + notifications (2 stories)

### Untagged Stories

- [id20] Admin exports audit log
- [id21] User updates profile photo
```

## Transport and Authentication

- **Local only:** Served at localhost:4001 via the LocalOnly plug
- **Scope resolution:** Uses `WorkingDir` header and `LocalScope` from config.yml
- **No OAuth required:** Designed for local AI agent use (Claude Code, Claude Desktop)
- **Framework:** Hermes MCP with Streamable HTTP transport

## Integration with Workflow

The Architecture Server complements the Components Server:

```
1. Stories Server     -> Create and refine user stories
2. Stories Server     -> Tag stories by domain area
3. Architecture Server (this) -> analyze_stories to see groupings
4. Components Server  -> Design contexts based on analysis
5. Architecture Server (this) -> validate_dependency_graph after adding deps
```

## Technical Implementation

**Framework:** Hermes MCP Server
**Server name:** `architecture-server` v1.0.0
**Capabilities:** Tools only (no resources or prompts)
**Location:** `lib/code_my_spec/mcp_servers/architecture_server.ex`

**Tool modules:**
```elixir
component(CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph)
component(CodeMySpec.McpServers.Architecture.Tools.AnalyzeStories)
```

## Error Handling

**Scope errors:**
- Authentication failed: user needs to run `codemyspec auth login`
- Needs authentication: no credentials configured

**Data errors:**
- No stories found: import stories first using Stories Server tools
- Unexpected results: logged and returned with inspect details

All errors return descriptive messages with resolution guidance.
