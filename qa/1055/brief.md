# Qa Story Brief — Story 1013 / 1055: The main agent can read its agents' conversations

## Tool

`run_script` (MCP tool `mcp__plugin_codemyspec_local__run_script`)

The tool under test, `read_agent_conversation`, is a `MainAgent` capability
registered only in `CodeMySpec.McpServers.ScriptableTools` — it has no HTTP
route in `lib/code_my_spec_web/router.ex` (confirmed: `grep -rln "MainAgent"
lib/code_my_spec_web/` finds no `/mcp` forward for it, unlike
`components`/`gsc`/`ga4`/etc.). The only externally reachable surface is the
Lua sandbox `run_script` exposes to whatever session is acting as the
project's main agent — which is exactly this QA session's own role here.
`curl`/Vibium do not apply; there is nothing at `:4000` to hit.

## Auth

None to configure. `run_script` authenticates as the calling session's own
`current_scope` (this QA session is itself a main-agent-privileged session on
project `code_my_spec`). No login, token, or header needed.

## Seeds

None. Do **not** seed synthetic agents/conversations for this story — the
project already has real, currently-running agents with organic
conversations, and that is deliberately what this brief tests against
instead of fixtures.

At brief-writing time, `list_agents({})` returned 8 real running agents
across 5 working copies and 4 roles (main, coding, product, qa). Use
`list_agents({})` / `list_agent_work({})` to get current IDs — the ones
below **will be stale** by the time you run this (agents cycle constantly).
Re-resolve them, don't hardcode.

**Do not** call `restart_agent`, `message_agent`, `set_agent_continuous`, or
`start_agent` against any of these real agents during this QA pass — they
are doing real project work, several are mid-task or blocked on real
questions, and disrupting them is out of scope for testing a read-only tool.
Everything below is satisfied with `read_agent_conversation` alone (plus
`list_agents`/`list_agent_work` for discovery), which is side-effect-free.

## What To Test

Resolve current agent IDs first via `list_agents({})` / `list_agent_work({})`,
then drive `read_agent_conversation` through `run_script`:

- **3280 (stuck agent's recent turns, in order):** `read_agent_conversation({ agent_id = <any running agent> })` — confirm the reply is a plain chronological transcript (no need to message the agent to get this).
- **3281 (exact error text, not paraphrased):** read a busy agent's transcript and look for a `tool failed id=...` line — confirm the full multi-line provider/tool error appears byte-for-byte, not summarized. (A real one exists today on `f8fbe49e-*`: a `get_story` call rejected for a wrong argument type, full Lua compiler error preserved verbatim.)
- **3282 (targeted answer without reading it all):** `read_agent_conversation({ agent_id = <id>, last_call_of = "get_next_requirement" })` (or any tool name the agent has actually called) — confirm the reply is just that one call + result, not the surrounding transcript.
- **3283 (two agents merged on one timeline):** `read_agent_conversation({ agent_ids = {id1, id2}, since = <iso>, until = <iso> })` — pick a window (from `list_agent_work` "last said" timestamps) where both agents were actually active, and confirm both agent IDs appear, interleaved in time order rather than one agent's block followed by the other's.
  - **Lua gotcha, read before you do this:** `until` is a reserved word in Lua and `{ until = "..." }` is a **syntax error** (`compile: Failed to compile Lua! Expected expression`) — the script never runs. Use `args["until"] = "..."` (build the table with `since` only, then assign the bracketed key) instead. See Setup Notes / filed issue.
- **3284 (repeated result not collapsed):** find (or produce by reading a longer transcript) two identical consecutive lines — the recurring `"The harness restarted. Nothing of your own was in flight, so nothing was lost."` operator broadcast is a reliable naturally-occurring example across every long-lived agent — and confirm both instances render separately, not deduplicated into one.
- **3285 (last ten turns, not the whole history):** `read_agent_conversation({ agent_id = <id with a long history>, limit = 10 })` — confirm the reply is visibly bounded and the truncation notice appears (there is more history than 10 turns for any of the long-lived agents).
- **3286 (time range narrows to the incident):** `read_agent_conversation({ agent_id = <id>, since = <iso ~10min ago> })` (add `until` via the bracket workaround above to bound both ends) — confirm only turns inside the window come back, not the full history.
- **3287 (broad query cut to the limit, and told so):** `read_agent_conversation({ agent_id = <id with a long history> })` with no `limit` — confirm the reply opens with a truncation notice ("This conversation was truncated — the oldest turns are not shown...") rather than silently returning a partial transcript.
- **3288 (restarted agent's earlier life still readable):** don't restart anything yourself — read a long-lived agent's transcript and look for an `operator: Restarted: <reason>` line (these occur naturally; `f8fbe49e-*` and `93bdde5a-*` both have one). Confirm turns from **before** that line and turns from **after** it are both present, under the same `agent_id`.
- **3289 (no agent's conversation is closed to the main agent):** call `read_agent_conversation({ agent_id = <id> })` once per role (main/coding/product/qa) and per distinct working copy present in `list_agents`. Confirm every call succeeds (no error) regardless of role or working copy.
- **3301 (query inside the limit comes back whole):** a narrow `since` window that only catches a couple of very recent turns (e.g. last 5–10 minutes on a currently-idle agent) — confirm the reply contains exactly those turns and **no** truncation notice.

## Setup Notes

**The `until` argument cannot be written as a plain Lua table field.**
`until` is a reserved keyword in Lua grammar, so `read_agent_conversation({
since = "...", until = "..." })` fails to compile before the tool ever runs
— the sandbox reports `compile: Failed to compile Lua! Expected expression`,
which gives no hint that `until` is the cause. The only way to pass it is
the bracket form:

```lua
local args = { agent_id = "...", since = "..." }
args["until"] = "..."
read_agent_conversation(args)
```

This was filed as a framework-scope issue during this QA pass (see below) —
it doesn't block any criterion (the workaround exists and was verified to
work), but it is a real trap for the next caller, agent or human, who reads
the tool's own schema (`field(:until, :string, ...)`) and writes the obvious
thing.

## Result Path

Findings are filed live via `create_issue` as they're found (see the
workflow's "Findings and done signal" section) — this file only records the
brief; there is no separate result.md to fill in.
