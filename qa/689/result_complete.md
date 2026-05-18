# Qa Story Result

## Status

pass

## Scenarios

### 5977 — A newly installed hex package becomes searchable after sync

PASS. Spex drives a file-change event simulating a new hex dep,
runs sync, and asserts the package's docs are queryable via
`semantic_search`. Observed via `mix spex`.

### 5978 — An upgraded hex package's new version content replaces the old

PASS. Spex installs v1 of a package, syncs, upgrades to v2, syncs
again, and asserts the v1 chunks are removed while v2 chunks
appear. Observed via `mix spex`.

### 5979 — An uninstalled hex package's docs are removed from search

PASS. Spex installs a package, syncs, removes it from deps, syncs
again, and asserts the package no longer appears in
`semantic_search` results. Observed via `mix spex`.

### 5980 — Repeat sync with unchanged dependencies does no embedding work

PASS. Spex runs sync twice on an unchanged dep set and asserts no
new embeddings are written on the second run (idempotency check).
Observed via `mix spex`.

### 5981 — Agent's MCP tool list does not expose `embed_hexdocs`

PASS. Spex enumerates `LocalServer.__components__(:tool)` and
asserts `embed_hexdocs` is absent while related tools
(`semantic_search`, etc.) are present. Observed via `mix spex`.

### 5982 — Sync completes when the embedding pipeline is unavailable

PASS. Spex disables the embedding service and asserts sync still
completes successfully (degraded mode). Observed via `mix spex`.

### 5983 — Projected hex doc files appear in the files projection after sync

PASS. Spex runs sync and asserts the `Files` projection contains
rows for the projected hex doc files. Observed via `mix spex`.

## Evidence

- `mix spex test/spex/689_always_fresh_hex_documentation_search/`
  output: `7 tests, 0 failures` in 0.3 seconds. No browser
  screenshots — all criteria are observed in-process via the
  spex layer.

## Issues

### QA result template is unforgiving about section headers

#### Severity
LOW

#### Scope
QA

#### Description
The result template requires the exact H2 headers `## Status` and
`## Scenarios` — using synonymous headers like `## Outcome` and
`## Acceptance Criteria` causes the evaluator to reject the result
even when content is correct. The brief template seems more
forgiving. Either the brief should fail the same way, or both
templates should accept reasonable aliases (or the required
sections should be surfaced more prominently in the task prompt).

### Internal-contract stories generate full QA ceremony

#### Severity
LOW

#### Scope
QA

#### Description
Story 689 has zero browser/HTTP surface — all 7 criteria are
testable only through `mix spex`. The QA workflow still requires
the full brief + result + evaluate cycle (~9KB of prompt + two
markdown files), even though the entire evidence reduces to one
command and one output line. A `:spex_only` story tag could
short-circuit to "run spex, record result" and skip the
browser-shaped ceremony.

### Component linkage for 689 lists `Files` but story is about `Embeddings`/`Knowledge`

#### Severity
LOW

#### Scope
DOCS

#### Description
The task prompt's "Linked component" section says
`CodeMySpec.Files`, but the story is primarily about hex doc
embedding and search, which lives in `Embeddings` + `Knowledge`.
Only criterion 5983 (file projection) touches Files. The spex
files cover the right surfaces, so this is a linkage-metadata
issue, not a test gap.
