# CodeMySpec Development Environment Guide

CodeMySpec is a Phoenix/LiveView application that helps teams manage software development through structured requirements, component architecture, and test-driven development. It follows **Phoenix Contexts architecture** throughout.

This guide describes how the project's `docs/` directory works so you can locate what you need efficiently.

## Project Structure

```
docs/
├── AGENTS.md              ← You are here
├── architecture/          ← System component graph and dependencies
├── status/                ← Implementation status of every component
├── spec/                  ← Specifications for every module
├── issues/                ← Known bugs and technical debt
└──knowledge_base/        ← Domain-specific operational knowledge
```

## Progressive Disclosure: Where to Look

### 1. Orientation — What exists and how it's organized

Start here to understand the system shape.

| Need | File |
|---|---|
| List of all components, types, and dependencies | `architecture/overview.md` |
| Hierarchical tree view by Elixir namespace | `architecture/namespace_hierarchy.md` |
| Dependency graph (Mermaid) | `architecture/dependency_graph.mmd` |
| How contexts map to user-facing features | `context_mapping.md` |
| Project mission and scope | `executive_summary.md` |

### 2. Status — What's done and what's not

Check here before starting work on a component.

| Need | File |
|---|---|
| Top-level status of all contexts | `status/code_my_spec.md` |
| Web layer status | `status/code_my_spec_web.md` |
| Status of a specific context | `status/code_my_spec/<context_name>.md` |

Status files use a checklist format:
```markdown
- [ ] spec_file - Context specification file exists
- [x] implementation_file - Component implementation file exists
- [ ] test_file - Component test file exists
- [x] tests_passing - Component tests are passing
```

### 3. Specifications — What a module should do

Read before implementing or modifying any module.

| Need | File |
|---|---|
| Spec for a module | `spec/<module_path>.spec.md` |
| Spec format definition | `new_spec_format.md` |

Specs follow a standard format:
- **Title**: Fully qualified module name with type
- **Delegates**: Functions delegated to other modules
- **Functions**: Public API with `@spec`, process steps, and test assertions
- **Dependencies**: Required modules
- **Fields**: (schemas only) Ecto field definitions

Spec paths mirror the Elixir module namespace. For `CodeMySpec.Components.ComponentRepository`, look at `spec/code_my_spec/components/component_repository.spec.md`.

### 4. Design Documents — How and why things are built a certain way

Read when you need architectural context beyond what the spec provides.

| Need | File |
|---|---|
| Design for a backend module | `design/code_my_spec/<context>/<module>.md` |
| Design for a LiveView | `design/code_my_spec_web/<feature>_live/index.md` |
| Design for a web component | `design/code_my_spec_web/<feature>_live/components/<name>.md` |

Design documents include purpose, public API, architecture principles, workflow steps, and design patterns used.

### 5. Rules — Coding standards for each component type

Read before writing code. Rules are scoped by component type and session type.

| Component Type | Design Rules | Test Rules |
|---|---|---|
| Context | `rules/context_design.md` | — |
| Repository | `rules/repository_design.md` | `rules/repository_test.md` |
| Schema | `rules/schema_design.md` | — |
| LiveView | `rules/liveview_design.md` | — |
| LiveView component | `rules/liveview_component_design.md` | — |
| LiveView forms | `rules/liveview_forms.md` | — |
| Elixir (general) | `rules/elixir_design.md` | `rules/elixir_test.md` |
| Tools / MCP | `rules/tool_design.md` | — |

Rules use YAML front matter to declare their scope:
```yaml
---
component_type: "context"
session_type: "design"
---
```

### 6. Issues — Known problems and technical debt

Check before working in an area to avoid known pitfalls.

Issues live in `issues/` as individual markdown files describing the problem, reproduction steps, and possible solutions.

### 7. Knowledge Base — Operational knowledge

Deep dives on specific topics that don't fit elsewhere.

| Topic | Entry point |
|---|---|
| Testing patterns, fixtures, recording | `knowledge_base/test/index.md` |

The test knowledge base covers the project's unique testing challenges: CodeMySpec acts on *other* Phoenix projects, so tests use CLI recording (ExCliVcr), HTTP recording (ExVCR), and a pool of pre-built fixture repositories.

## Phoenix Contexts Architecture

All code follows Phoenix Contexts conventions:

- **Contexts** are the public API boundary. They live at `lib/code_my_spec/<context_name>.ex` and delegate to child modules.
- **Repositories** handle data access. They live under the context namespace.
- **Schemas** define Ecto schemas. They live under the context namespace.
- **Scope** (`CodeMySpec.Users.Scope`) is the first parameter to all public context functions. It carries `user`, `active_account`, `active_project`, and optionally `cwd` (filesystem working directory).

### Key Conventions

- All public functions accept `%Scope{}` as the first parameter
- Database queries filter by scope foreign keys
- Return consistent `{:ok, result}` / `{:error, reason}` tuples
- `cwd` on Scope is a runtime concern for filesystem operations, not persisted

## Technology Stack

- Elixir / Phoenix 1.8-rc / LiveView 1.1-rc
- Ecto SQL / PostgreSQL
- Oban (background jobs)
- Hermes MCP (AI agent integration)
- OAuth2 Provider (multi-tenant auth)
- ExCliVcr + ExVCR (test recording)

## Working with the Docs Directory

**Before implementing a component:**
1. Check `status/` — is it already done?
2. Read `spec/` — what should it do?
3. Read `design/` — how should it be built?
4. Read `rules/` — what conventions apply to this component type?
5. Check `issues/` — are there known problems in this area?

**Before modifying an existing component:**
1. Read the spec to understand the intended behavior
2. Read the current implementation
3. Check if there are open issues related to it
4. Follow the rules for that component type

**When you need context on the bigger picture:**
1. Read `architecture/namespace_hierarchy.md` for the component tree
2. Read `architecture/overview.md` for dependency relationships
3. Read `context_mapping.md` for how contexts serve user needs
