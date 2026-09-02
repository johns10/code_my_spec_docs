# External Claude Code Agent

## Role

An LLM agent running inside the Claude Code CLI against a CodeMySpec working
copy — either the top-level session or a subagent it spawned with the Task tool.
It reaches the harness as an MCP client, and the harness reaches *it* only
through the hooks Claude Code fires on its behalf.

That asymmetry is the whole of this persona. Everything the orchestrator has to
say — a stop decision, an analyzer alert, a nudge about an abandoned task —
arrives because Claude Code called out to us at a moment it chose. Seven hooks
are registered: `SessionStart`, `PreToolUse`, `PostToolUse`, `Stop`,
`SubagentStart`, `SubagentStop`, `PermissionRequest` [1].

Distinct from the **Internal Alloy Agent**, which runs inside our own BEAM and
fires no hooks at all. The two were one persona until 2026-09-02, and the
merge is why two stories shipped a delivery path that reached only half the
agents this product runs [6][7].

## Goals

- Find out what its own turn broke while it can still act on it, without having
  to ask. The value is delivery, not latency: on 2026-08-12 the answer that
  would have caught a schema change was ~126 seconds away the whole time, and
  nothing handed it over [6].
- Be told what class of work is available and which call to make, rather than
  guessing. Guessing produced a sweep that returned ~900 "orphan components"
  that were not defects [7].
- Not pay for a catalogue it will not use. Connecting once cost ~20,600 tokens
  of tool list; code mode replaced it with two tools and a lookup [4].
- Close its own task rather than have something close it on its behalf. The
  nudge carries the whole call, task id included, because the agent is being
  told to make it [2].

## Pain Points

- **Its identity is the session, and the session is not the agent.** A
  Task-spawned subagent shares its parent's `session_id`; `PostToolUse` knows
  this and keys file edits on `(external_session_id, agent_id, file_path)`
  because the session alone cannot tell them apart [3]. `AnalysisAlert` does not
  — it dedupes on `{working_copy_id, session_id}` — so a main agent and its
  subagent in one copy silence each other. Filed as issue `927c2b78` during the
  Three Amigos that produced this persona.
- **Its decisions arrive one turn late by construction.** The stop hook must
  answer now, and analysis is pending precisely because the agent just changed
  code. Three stop decisions inside the 2026-08-12 damage window all allowed;
  one for "analysis pending", which is structural rather than a defect [6].
- **The remedy it is offered is a shell command.** When analysis has not
  finished it is told to `curl .../analysis/wait` and stop again, because a hook
  cannot return an answer that does not exist yet [2].
- **A finding it cannot fix blocks it repeatedly.** Eight consecutive blocks on
  a finding belonging to another story was observed spending an entire budget
  unattended; the R8 escape counts a streak and eventually allows the stop [2].

## Context

Reaches the harness through the MCP server mounted by `plugin.json` with
`X-Harness-Id: ${CMS_HARNESS_ID}`. The advertised tool list is deliberately
short — the loop every session walks (`get_next_requirement`, `sync_project`,
`start_task`, `evaluate_task`), the tools a script may not call, and code mode's
own entries; everything else is reached with `run_script` [4].

The harness reaches it only at hook moments. Two carry orchestrator speech:

| Moment | Mechanism | Payload |
|---|---|---|
| after a tool call | `Hooks.PostToolUse` → `Hooks.AnalysisAlert` | an analyzer run landed: source, count, age [5] |
| turn ends | `Hooks.Stop` | block-or-allow, the problem summary, the menu, the nudge [2] |

The content of both is produced by transport-blind code — `validate_stop/3`,
`Validation.Menu.render/2`, `Conversations.record_orchestrator_action/3` — and
only the envelope, the response cap and the wait directive are hook-shaped [2][8].

## Decision Drivers

- **Push the fact, pull the detail.** The alert names the analyzer and the count
  and stops; `list_problems` is one call away. A finding list on every tool call
  is noise the model learns to skip, which costs the signal a second time and
  more permanently [5].
- **Scope is the working copy, never the session or the edited file.** Filtering
  delivery by what the agent touched was rejected: the file edited in the
  motivating incident was nowhere near the four stories whose spex broke [6].
- **One directive, with the rest tallied.** A full menu buries the important
  item among the cheap ones; a strict single directive lets a class starve
  invisibly [7].
- **An allowed stop is an empty body.** Nothing rides the allow path, so the
  menu appears only on refusals [7].
- **Detectable is necessary for a class, not sufficient.** A pending question is
  a visible row and still an offer rather than ranked work, because one stale
  row could otherwise hold the top of the menu permanently [7].

## Evidence

1. `plugins/claude/hooks/hooks.json` @ 921a8859 — the seven registered hooks.
   Accessed 2026-09-02.
2. `lib/code_my_spec/hooks/stop.ex` @ 921a8859 — `decide/2`, `block_with_reason/4`,
   `wait_directive/1`, `nudge_open_task/2`, `maybe_terminate_stuck/5`.
   Accessed 2026-09-02.
3. `lib/code_my_spec/hooks/post_tool_use.ex` @ 921a8859 — lines 6–10, the
   `(external_session_id, agent_id, file_path)` key and "`agent_id` is `nil` for
   main-agent edits and a UUID for Task-spawned". Accessed 2026-09-02.
4. `lib/code_my_spec/mcp_servers/local_server.ex` @ 921a8859 — the advertised
   spine and the measured cost of the list it replaced. Accessed 2026-09-02.
5. `lib/code_my_spec/hooks/analysis_alert.ex` @ 921a8859 — `check/2`,
   `already_told?/3`, and the push-the-fact rationale. Accessed 2026-09-02.
6. Story 890, *Analysis results reach the agent that caused them* — notes and
   acceptance criteria, sealed 2026-09-02. Accessed 2026-09-02.
7. Story 894, *Stop hook is a main menu* — notes recording the class/offer split
   and the allow-path decision. Accessed 2026-09-02.
8. `lib/code_my_spec/validation/menu.ex` @ 921a8859 — the ranked classes and the
   standing offers. Accessed 2026-09-02.
9. https://modelcontextprotocol.io/ — the `tools/list` and `tools/call` contract
   this agent's client speaks. Accessed 2026-09-02.
10. https://docs.claude.com/en/docs/claude-code/hooks — the hook events Claude
    Code fires and their payloads. Accessed 2026-09-02.
11. First-person observation: the author of this file is an instance of this
    class, working a CodeMySpec worktree through the same MCP server and the
    same hooks. Where that observation is load-bearing it is paired with a code
    or story citation above rather than standing alone.
