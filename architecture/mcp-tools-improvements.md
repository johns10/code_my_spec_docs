# MCP Architecture Tools - Improvement Plan

Issues discovered during design cycle testing with Fuellytics stories.

## Completed Fixes

- [x] Working directory - Files now created in Claude Code's project directory, not CLI directory
- [x] Parent-child relationships - Components now correctly linked to parent contexts
- [x] Schema types - Fixed `{:array, ...}` to `{:list, ...}` in Hermes schemas
- [x] Account nil handling - `set_story_component` now handles CLI context where `active_account` is nil

## Completed (This Session)

- [x] **Deterministic component IDs** - Already implemented using UUID v5 based on project_id + module_name. No changes needed.
- [x] **Markdown authoring workflow** - Implemented in `ProposalMarkdown` module:
  - `propose_architecture` now creates `docs/architecture/proposals/{app_name}.proposal.md`
  - `validate_proposal` reads from the markdown file (only needs `app_name`)
  - `execute_proposal` reads from the markdown file (only needs `app_name`)
  - Claude can read/edit the proposal file using normal Edit tool between steps

## Open Issues

### 1. Verbose Tool Responses
**Status:** Fixed by markdown workflow - tools now return concise summaries instead of full JSON.

### 3. Story Overlap in analyze_stories
**Problem:** Keyword matching causes every story to appear in 5+ contexts (e.g., "driver verification" matches both Driver and Verification themes).
**Impact:** Doesn't help determine primary ownership for architecture design.
**Options:**
- Distinguish "primary context" vs "related contexts"
- Use verb/action focus to determine ownership
- Just provide suggestions, human assigns

### 4. Story-Component Linking Architecture
**Problem:** Stories are in remote PostgreSQL, components are in local SQLite. Can't link via foreign key.
**Impact:** "Related Stories" feature doesn't work in CLI/MCP context.
**Solution:** Tags system (see issue #5).

### 5. Tags System
**Problem:** Need decoupled way to associate stories with components across database boundaries.
**Spec:** `docs/spec/code_my_spec/tags.spec.md`
**Key Concept:** String-based tags instead of FK relationships. Components use deterministic UUIDs (project_id + module_name), so module_name alone identifies a component within a project.

## Remaining Discussion Questions

1. **Story ownership:** How should analyze_stories determine primary ownership? Or should it just suggest and let human decide?

2. **Tags priority:** Should tags be implemented before other improvements?
