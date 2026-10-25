# QA Journey Plan

## Prerequisites

- The working copy's own app is running: `ensure_app_running`, at the URL it reports.
- QA seed data loaded into that app's own database: `MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs` (see `qa/plan.md` for the database it targets).
- Credentials: the QA seed user from `priv/repo/qa_seeds.exs`; never real accounts.
- The copy's harness is connected (`check_machinery`), so analysis runs and file sync reach the server.

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
