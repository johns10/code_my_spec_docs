# Qa Story Brief

## Tool

mix spex

## Auth

None — this story has no UI/API surface. All 7 criteria assert
internal contracts (MCP tool registration, embedding sync behavior,
file projection rows after sync) that are observable only through the
spex layer.

## Seeds

None. The spex suite spins up its own sandboxed OTP environment.

## What To Test

- Run `mix spex test/spex/689_always_fresh_hex_documentation_search/`
  and confirm all 7 criterion specs pass:
  - 5977 — A newly installed hex package becomes searchable after sync
  - 5978 — An upgraded hex package's new version content replaces the old
  - 5979 — An uninstalled hex package's docs are removed from search
  - 5980 — Repeat sync with unchanged dependencies does no embedding work
  - 5981 — Agent's MCP tool list does not expose `embed_hexdocs`
  - 5982 — Sync completes when the embedding pipeline is unavailable
  - 5983 — Projected hex doc files appear in the files projection after sync

The agent surface for all 7 criteria is observable only through
`mix spex` — there is no LiveView, controller, or `curl`-able API
path that exercises hex doc embedding directly. The MCP-tool
registration check (5981) enumerates `LocalServer.__components__(:tool)`
in process; the sync-completion checks (5977–5980, 5982, 5983) drive
file-change events through the `Fixtures.notify_file_changed` bridge
and observe the resulting `Files` / `Embeddings` state.

## Result Path

.code_my_spec/qa/689/result.md

## Setup Notes

This is a Phase-2-only story for the QA flow: write the brief, run
the spex suite, write the result. No browser screenshots, no auth
flow, no scripted setup. The brief still gets validated by the
evaluator even when the test surface is internal.
