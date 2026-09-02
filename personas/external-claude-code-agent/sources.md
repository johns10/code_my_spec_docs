# Sources — External Claude Code Agent

Codebase citations are pinned to `921a8859`, so each line is reproducible at the
commit it was read at.

## Codebase

- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/plugins/claude/hooks/hooks.json — the seven hook events this agent's runtime fires: SessionStart, PreToolUse, PostToolUse, Stop, SubagentStart, SubagentStop, PermissionRequest. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/stop.ex — `decide/2` and the whole stop response: `block_with_reason/4`'s envelope and cap, `wait_directive/1`'s curl instruction, `nudge_open_task/2` firing via `tap/2` on every stop with an open task, and `maybe_terminate_stuck/5`'s R8 escape. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/post_tool_use.ex — lines 6-10: the file-edit key `(external_session_id, agent_id, file_path)` and the statement that `agent_id` is nil for main-agent edits and a UUID for Task-spawned ones. This is the citation proving a subagent shares its parent's session. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/subagent_stop.ex — the second caller of `Validation.validate_stop/3`, carrying both `session_id` and `agent_id`. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/analysis_alert.ex — `check/2`, the `{__MODULE__, working_copy_id, session_id}` dedup key, and the push-the-fact-pull-the-detail rationale for what the alert may contain. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/validation/menu.ex — the ranked classes (problems, issues, requirements) and the standing offers (check_answer, ask_user, semantic_search, tap_out), plus why a detectable row is not automatically a class. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/mcp_servers/local_server.ex — the deliberately short advertised tool list, the two reasons a tool earns a place on it, and the measured cost of the 111-tool list it replaced: 82,591 bytes, ~20,600 tokens per connect. Accessed 2026-09-02.

## Stories

- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/890 — story 890, *Analysis results reach the agent that caused them*, sealed with this persona linked; its notes carry the 2026-08-12 incident first-hand, including three stop decisions inside the damage window that all allowed. Accessed 2026-09-02.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/894 — story 894, *Stop hook is a main menu*: the class/offer distinction, the empty-body-on-allow decision, and the criterion deleted because of it. Accessed 2026-09-02.

## Observed friction

- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/issues — issue `927c2b78`, *The analysis alert dedupes on session_id, so a subagent and its parent silence each other*, filed during story 890's Three Amigos: where this agent's session-shaped identity breaks a guarantee the product intends. Accessed 2026-09-02.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/issues — issue `f0cc65ab`, *An internal agent gets no stop decision and no nudge*: the mirror-image evidence for what is specific to running under Claude Code. Accessed 2026-09-02.

## Upstream

- https://docs.claude.com/en/docs/claude-code/hooks — hook events, payload shapes, and the blocking semantics of a Stop hook response. Accessed 2026-09-02.
- https://modelcontextprotocol.io/ — the MCP `tools/list` and `tools/call` contract this agent's client speaks against `codemyspec-local`. Accessed 2026-09-02.
- https://docs.anthropic.com/en/docs/agents-and-tools/ — agent tool-use patterns behind the short-tool-list decision. Accessed 2026-09-02.

## Self-reflection

- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/CLAUDE.md — first-person: the session that wrote this file is an instance of this class, working a CodeMySpec worktree under the harness this file describes. Used only where triangulated against a code or story citation above; every claim in `summary.md` carries at least one non-reflective source. Accessed 2026-09-02.
