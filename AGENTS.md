# Project Development Guide

This guide describes how the project's `docs/` directory works so you can locate what you need efficiently.

## Project Structure

```
docs/
├── AGENTS.md              ← You are here
├── architecture/          ← System component graph and dependencies
├── status/                ← Implementation status of every component
├── spec/                  ← Specifications for every module
├── rules/                 ← Coding standards by component type
├── issues/                ← Known bugs and technical debt
└── knowledge/             ← Domain-specific operational knowledge
```

## Progressive Disclosure: Where to Look

### 1. Orientation — What exists and how it's organized

Start here to understand the system shape.

| Need | File |
|---|---|
| List of all components, types, and dependencies | `architecture/overview.md` |
| Hierarchical tree view by Elixir namespace | `architecture/namespace_hierarchy.md` |
| Dependency graph (Mermaid) | `architecture/dependency_graph.mmd` |
| Technology decisions and rationale | `architecture/decisions.md` → `architecture/decisions/` |

### 2. Status — What's done and what's not

Check here before starting work on a component.

| Need | File |
|---|---|
| Top-level status of all contexts | `status/code_my_spec.md` |
| Web layer status | `status/code_my_spec_web.md` |
| Status of a specific context | `status/code_my_spec/<context_name>.md` |

Status files use a checklist format:
```
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

Specs follow a standard format:
- **Title**: Fully qualified module name with type
- **Delegates**: Functions delegated to other modules
- **Functions**: Public API with `@spec`, process steps, and test assertions
- **Dependencies**: Required modules
- **Fields**: (schemas only) Ecto field definitions

Spec paths mirror the Elixir module namespace.

### 4. Rules — Coding standards for each component type

Read before writing code. Rules are scoped by component type.

| Component Type | Design Rules | Test Rules |
|---|---|---|
| Context | `rules/context_design.md` | — |
| Repository | `rules/repository_design.md` | `rules/repository_test.md` |
| Schema | `rules/schema_design.md` | — |
| LiveView | `rules/liveview_design.md` | — |
| LiveView component | `rules/liveview_component_design.md` | — |
| Elixir (general) | `rules/elixir_design.md` | `rules/elixir_test.md` |

### 5. Issues — Known problems and technical debt

Check before working in an area to avoid known pitfalls.

Issues live in `issues/` as individual markdown files describing the problem, reproduction steps, and possible solutions.

### 6. Knowledge — Operational knowledge

Deep dives on specific topics that don't fit elsewhere. Check `knowledge/` for available guides.
Project-specific library knowledge (populated by `/technical-strategy` or `/research-topic`) lives in `knowledge/{topic}/`.

## Phoenix Contexts Architecture

All code follows Phoenix Contexts conventions:

- **Contexts** are the public API boundary. They live at `lib/code_my_spec/<context_name>.ex` and delegate to child modules.
- **Repositories** handle data access. They live under the context namespace.
- **Schemas** define Ecto schemas. They live under the context namespace.
- **Scope** is the first parameter to all public context functions. It carries user, account, project, and optionally working directory.

### Key Conventions

- All public functions accept `%Scope{}` as the first parameter
- Database queries filter by scope foreign keys
- Return consistent `{:ok, result}` / `{:error, reason}` tuples

## Working with the Docs Directory

**Before implementing a component:**
1. Check `status/` — is it already done?
2. Read `spec/` — what should it do?
3. Read `rules/` — what conventions apply to this component type?
4. Check `issues/` — are there known problems in this area?

**Before modifying an existing component:**
1. Read the spec to understand the intended behavior
2. Read the current implementation
3. Check if there are open issues related to it
4. Follow the rules for that component type

**When you need context on the bigger picture:**
1. Read `architecture/namespace_hierarchy.md` for the component tree
2. Read `architecture/overview.md` for dependency relationships
