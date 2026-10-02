# QA Brief — Story 970: I script the tools instead of calling them one at a time

## Tool

`.code_my_spec/qa/scripts/qa_code_mode.sh`

## Auth

No login. This is the local MCP endpoint on the dev port, scoped by harness id
rather than by session — the same door an agent comes through.

```
URL:  http://localhost:4004/mcp
Header: X-Harness-Id: <harness_id from .cms_harness.json in the working copy>
```

Read the id with:

```
python3 -c "import json;print(json.load(open('.cms_harness.json'))['harness_id'])"
```

The MCP handshake is three calls and the third is easy to miss: `initialize`,
then the **`notifications/initialized`** notification, then `tools/call`.
Without the notification every call answers `Server not initialized`, which
reads like a broken tool rather than an incomplete handshake.

## Seeds

None. Every criterion is about the runtime's behaviour rather than about
project data, and the two that touch stories (`create_story`, list) make and
read their own inside the test.

The one thing to know: `create_story` requires **both** `title` and `story`,
though its schema marks only `title` required. A script passing just a title
gets `story: can't be blank`.

## What To Test

Against `http://localhost:4004/mcp`, using `run_script` and `tool_docs`.

**Documentation is looked up, not carried**
- `tool_docs` with no arguments → an index of ~100 tools, one line each, and
  well under the ~82 KB the full tool list costs. No argument detail.
- `tool_docs` with `name: "get_story"` → that tool's arguments and a runnable
  example, and *not* the other hundred.
- `tool_docs` with `search: "epic"` → the epic tools, one line each.
- `tool_docs` with `name: "get_stories"` (a near miss) → suggests `get_story`.

**Scripts call real tools**
- `run_script` returning `list_story_titles()` → the project's stories.
- A script that prints twice and returns a value → both printed lines come
  back, in order, alongside the value.
- A script that creates three stories then one invalid → the answer names the
  fourth as failed and the first three are still listed afterwards.

**What a script cannot do**
- `pcall(os.execute, ...)` and `pcall(io.open, ...)` → both refused as
  sandboxed. Assert on the *call*: `io` is still a table, so `io == nil` would
  pass against a VM where `io.open` works.
- `while true do end` → stops itself with "instruction budget exceeded", and a
  second call straight after still answers.
- `string.rep("x", 100000000)` → refused as too large, and the response is
  small.
- `ask_user({...})` and a loop over `start_agent` → both fail; neither is bound
  into a script.
- `run_script` calling `run_script` → not bound either, so a script cannot
  nest VMs inside itself.

**Scope**
- A script only sees the project the connection names. There is no argument by
  which it reaches another.

## Result Path

`.code_my_spec/qa/970/result.md`

## Setup Notes

The tools only exist on a server that has been restarted since they were
registered, and any agent that connected earlier holds a cached tool list —
`/mcp` in Claude Code to refresh it. `just refresh` does the restart.

Evidence for this brief was captured against the dev port 4004 on build
`19cc7b68`.
