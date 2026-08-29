# Code mode: running MCP tools from a Lua sandbox

Research behind two stories, done 2026-08-28. Everything here was read from
source or measured against the running system; nothing is from memory.

- **970** — *I script the tools instead of calling them one at a time.* The
  runtime: what a script can do and what it cannot.
- **971** — *I connect with a short tool list.* The surgery on the tool list,
  which depends on 970.

They were one story until the seam showed. The runtime is buildable and
verifiable without changing what any agent sees — build the sandbox, expose it
as one extra tool, prove the contract. Shortening the list is what changes every
connected agent, and a client caches its tool list at connect, so a session that
connected earlier gets "No such tool available" no matter what the server has
loaded (`b2d9c616`). Different risk, different delivery.

## The problem, measured

`tools/list` against the harness on `:4004`:

| | |
|---|---|
| tools on `LocalServer` | **111** |
| payload | **85,979 bytes** |
| cost in context | **~21,500 tokens** |

Every agent pays that at connect, before doing anything, and a typical task
calls three or four tools. The largest single entries were `adopt_repository`
(2,715 B), `list_user_questions` (2,649 B) and `run_devops_setup` (2,415 B).

Reproduce with `initialize` → `tools/list` over raw JSON-RPC; the harness needs
`X-Harness-Id` from `.cms_harness.json`.

The second cost is less visible. Composition happens in the agent's context:
"list the stories, keep the ones with no criteria, count them" is three round
trips plus arithmetic the model does by hand, and every intermediate list is
carried. In a script it is four lines and one call.

## The reference implementation

`ChristianAlexander/amber` — a Phoenix/Ash demo app, cloned to
`code_my_spec_test_repos/amber`. The app-side wiring is **23 lines**:

```elixir
defmodule Amber.Agents do
  use Ash.Domain, otp_app: :amber, extensions: [AshAi]

  tools do
    tool :amber_lua_docs, Amber.Agents.MCPActions, :docs
    tool :amber_lua_eval, Amber.Agents.MCPActions, :eval
  end
  ...
end
```

That is the whole pattern, and it is two tools:

- **`*_docs`** — progressive disclosure. A compact index in context; focused
  pages, type pages and ranked search on request.
- **`*_eval`** — runs a script with the tools bound as functions. Returns the
  script's value, captured `print` output, and a structured error.

What an exchange looks like (from AshLua's own docs):

```
LLM → docs({ name = "work.todo.read" })
←   # the per-operation page

LLM → eval({ script = """
  local overdue = assert(work.todo.read({
    filter = { priority = "high", completed = false,
               due_date = { less_than = today() } },
    operation = "count" }))
  local sample = assert(work.todo.read({ ..., limit = 5 }))
  return overdue, sample
""" })
←   { 12, [<5 records>] }
```

## The stack, and which layer we want

```
luerl      Lua 5.3 VM, pure Erlang, rebar3          ← the engine
lua        tv-labs Elixir wrapper, ~> 0.4           ← what we use
ash_lua    Ash bridge, ~5,600 lines                 ← not applicable
```

`ash_lua` is mostly Ash resource introspection — `fields.ex` (804),
`docs.ex` (1,436), `runtime.ex` (1,081), `encoder.ex` (560), `surface.ex` (414)
walk attributes, relationships and filter predicates. We are not on Ash and
need none of it.

**The layer we want is `lua`.** Bindings are one call:

```elixir
Lua.set!(lua, [:stories, :create_story], fn args, state -> ... end)
```

### Why this is cheap for us specifically

Every Anubis tool has the same two things: a `schema do ... end` block and
`execute(params, frame)`. That is already a machine-readable signature and
already a uniform entry point, for all 111. Both the Lua bindings and the
documentation generate from the modules that exist. `ash_lua` had to *build* an
introspection layer; ours is the tool registry.

### Pure Erlang, which matters here

`luerl` has no NIFs. We ship a Burrito binary and have been bitten by a NIF
crashing the BEAM on Windows (MDEx). A Lua VM that is pure Erlang carries none
of that risk.

## Sandbox and limits

`Lua.new/1` sandboxes by default — `io`, `file`, `os.execute`, `require`,
`dofile`. A sandboxed call raises rather than touching the host, and the error
says so:

```
** (Lua.RuntimeException) Lua runtime error: os.execute(_) is sandboxed
```

Two options give deterministic limits without wrapping each evaluation in a
Task:

- `:max_call_depth` — caps nested call depth, raises `"stack overflow"`.
- `:max_instructions` — caps VM instructions, raises
  `"instruction budget exceeded"`.

Both default to `:infinity`, both raise **catchable** errors, so `pcall`
recovers in-band. A `while true do end` under a budget returns an error instead
of spinning a scheduler.

These bound the *VM*. They do not bound a host function that blocks — and our
tools hit the database and external providers — so a wall-clock timeout around
the evaluation is still needed on top. `lua`'s sandboxing guide has the shape:
a `Task` plus separate `receive` arms for timeout and `:killed`, because
`Task.yield || Task.shutdown(:brutal_kill)` collapses the two and misreports a
CPU-bound loop.

## Decisions taken in the Three Amigos session

John's calls, each tagged with the story it lands in:

- **Hybrid surface** *(971)*. The workflow spine stays as direct tools; the rest is
  scripted. Spine ≈ the four workflow tools (`get_next_requirement`,
  `start_task`, `evaluate_task`, `sync_project`), the six that block or spawn,
  and the two code-mode tools.
- **Everything is callable from a script except tools that block on a person or
  spawn work** *(970)* — `ask_user`, `check_answer`, `start_agent`, `assign_subagent`,
  `tap_out`, `show_in_panel`. A loop around those means something different
  from a loop around `get_story`.
- **Consequence, worth stating** *(971)*: the excluded set must be a subset of the
  spine, or those tools become unreachable entirely.
- **No transaction** *(970)*. A script that fails on its fourth call leaves the first
  three standing and reports which failed. Our tools call GitHub, Cloudflare
  and Resend; a database transaction cannot roll those back, and wrapping an
  agent-written script in one holds a long lock.

## Sources

- `github.com/ChristianAlexander/amber` — the demo, and the video it companions
- `ash-lua.hexdocs.pm` — the docs API shape: `index_doc`, `callable_doc`,
  `type_doc`, `search`, `full_doc`
- `github.com/tv-labs/lua` — the wrapper; see its `guides/sandboxing.md`
- `luerl` — the VM
