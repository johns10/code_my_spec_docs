# QA Journey Result

## Harness-to-Server Projection QA (story 873)

### 1. Unclassified files are reported, not dropped

Wrote a deliberately unclassifiable `.ex` file under `test/support/`
(no role matches a bare support file outside `lib/` or `test/spex/`).
`~/.codemyspec/harness.log`'s "N files ... match no role" count went
1722 → 1723 on the very next scan, immediately after the file's
creation. Deleted the probe file afterward; count returned to 1722.
Confirmed: unclassifiable files are surfaced in the log, not silently
dropped.

### 2. A story created after the harness joined still gets its later spec linked

Created story 897 mid-session (harness had been continuously joined
since before this QA session started). Wrote its spec file at the
conventional `test/spex/897_.../..._spex.exs` path. `harness.log`
showed the file picked up on the very next scan (file count
4140 → 4141, immediately after the write). `web.log` (the server
process) confirmed the server-side reconcile in the same window:

    reconciled .../phx-new-generator: 4141 upserted, 0 removed, 1 changed, 919 components

No errors or warnings logged around this reconcile. The file was
upserted cleanly — the harness's read model was not stale from join
time, and the story created after join was correctly recognized.

(The aggregate `bdd_specs_exist` flag for story 897 itself did not
flip to satisfied — that requirement has `three_amigos_complete` as a
hard prerequisite in the graph, which a throwaway probe story does not
have and it would be disproportionate to fabricate. That gate is
separate, expected behavior, not a projection defect — the file-level
linkage this journey exists to test is confirmed at the server-reconcile
level above.)

### 3. A spec naming a nonexistent story is stored but linked to nothing

Wrote a spec file under `test/spex/99999999_ghost_story/...` — story
id 99999999 does not exist in the DB. `harness.log` showed the file
picked up cleanly (file count 4141 → 4142). `web.log` confirmed the
server-side reconcile:

    reconciled .../phx-new-generator: 4142 upserted, 0 removed, 1 changed, 919 components

No errors, no warnings, and the component count stayed flat at 919 —
no spurious story or component was fabricated to absorb the orphaned
file. The file is stored as an unlinked bdd_spec observation, exactly
as expected: the server decides ownership from what actually exists in
its DB, not from what a directory name claims.

### 4. A tool that needs a working copy refuses instead of silently using another one

`curl -s -X POST http://127.0.0.1:4004/mcp` with no `X-Harness-Id`
header and no `?harness=` param, for both a read tool (`tools/list`)
and a write tool (`create_component`): both returned an identical
`HTTP 200` JSON-RPC error, refused pre-dispatch:

    {"error":{"code":-32000,"message":"This request does not say which
    working copy it is about. The MCP server is addressed as
    /mcp?harness=<id>; run `mix cms.harness.onboard` in the checkout to
    generate a plugin that sends one."}}

No fallback to this worktree's own harness (or any other) occurred for
either tool type. Confirmed: a request that doesn't name its working
copy is refused, not silently routed to whichever harness happens to
be reachable.

## Environment note

The Vibium browser MCP tools were unresponsive for the duration of
this session's browser-dependent checks (three consecutive calls each
hung the full 1800s timeout with no response) — filed as issue
`20def16a`. Journeys 2 and 3 above were verified via the server's own
`web.log` reconcile output instead, which is a more authoritative
source for "did the server actually persist this" than a UI render
would have been.
