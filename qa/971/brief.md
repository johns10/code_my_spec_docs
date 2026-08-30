# QA Brief — Story 971: I connect with a short tool list

## Tool

`.code_my_spec/qa/scripts/qa_spine.sh`

## Auth

No login. The local MCP endpoint on the dev port, scoped by harness id — the
same door an agent comes through.

```
URL:  http://localhost:4004/mcp
Header: X-Harness-Id: <harness_id from .cms_harness.json>
```

Handshake is three calls: `initialize`, the **`notifications/initialized`**
notification, then `tools/call`. Skipping the middle one answers
`Server not initialized`, which reads like a broken tool.

## Seeds

None. The subject is the tool list itself.

## What To Test

**The list is short**
- `tools/list` returns ~15 tools, not 111.
- Its payload is a fraction of the 82,591 bytes measured on 2026-08-28.
- `run_script`, `tool_docs`, `get_next_requirement`, `start_task`,
  `evaluate_task` and `sync_project` are all present.

**Nothing became unreachable**
- A tool that moved (`list_stories`, `create_story`, `submit_qa_result`) is not
  in `tools/list`, and a script that calls it works.
- Every tool a script may *not* call — `ask_user`, `start_agent`, `tap_out` —
  is still in `tools/list`. This is the rule the story ends on: excluded from
  scripts *and* absent from the list means reachable by no route at all.

**A stale client is told what happened**
- Call a moved tool directly by name, the way a session holding the old cached
  list would. It should say the tool moved to code mode and how to reach it —
  not "method not found".
- Call a name that never existed. It should still just fail; a typo must not be
  told to script something imaginary.

**The saving is real, not moved**
- The `tool_docs` index plus the spine together should still be far less than
  the old list. If the index simply absorbed the cost, the story bought nothing.

## Result Path

`.code_my_spec/qa/971/result.md`

## Setup Notes

Requires a server restarted since the split, and any agent connected earlier
holds a cached list — `/mcp` in Claude Code to refresh. `just refresh` does the
restart.

Worth knowing while testing: the spine came out at 15,615 bytes, not the ~2,000
an index-only estimate suggested, because the tools that *had* to stay are the
expensive ones. `ask_user` alone is 2,398 bytes. The saving is 81%, not 90%.
