# Project Setup Should Create/Append CLAUDE.md

## Problem

The first thing Claude Code looks at when entering a project is `CLAUDE.md` in the project root. Currently, `project_setup` generates an `AGENTS.md` inside `.code_my_spec/` but does nothing with `CLAUDE.md`.

This means Claude Code has no upfront awareness of the `.code_my_spec/` directory, the architecture decisions, or the project's coding conventions until an agent task explicitly tells it.

## Proposed Solution

`ProjectSetup` should create or append to the target project's `CLAUDE.md`:

1. **If no CLAUDE.md exists**: Create one with a section pointing to `.code_my_spec/`
2. **If CLAUDE.md exists**: Append a managed section (with markers like `<!-- code_my_spec:start -->` / `<!-- code_my_spec:end -->`) so it can be updated idempotently

### Content should include

- Pointer to `.code_my_spec/` as the project knowledge base
- Instruction to read architecture decisions before making technology choices
- Reference to `AGENTS.md` for detailed directory structure
- Key conventions (Scope pattern, context boundaries, etc.)

## Why This Matters

CLAUDE.md is loaded into every Claude Code conversation automatically. Making it the entry point to `.code_my_spec/` means every interaction — not just agent tasks — benefits from project awareness. Ad-hoc Claude Code sessions (debugging, quick edits, exploration) would also follow the project's established decisions.

## Files to Modify

- `lib/code_my_spec/agent_tasks/project_setup.ex` — add CLAUDE.md generation step
