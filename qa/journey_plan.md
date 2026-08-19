# QA Journey Plan

## Journeys

### Harness-to-Server Projection QA (story 873)

1. Confirm this worktree's harness reports unclassified files rather
   than dropping them silently.
2. Confirm a story created while the harness is joined gets its later-
   written spec linked, not cached stale.
3. Confirm a spex file naming a nonexistent story is stored but linked
   to nothing.
4. Confirm a Files-writing MCP tool refuses when no harness id scopes
   the request, rather than silently falling back to a default.
