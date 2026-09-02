# Sources — Internal Alloy Agent

Codebase citations are pinned to `921a8859`, so each line is reproducible at the
commit it was read at.

## Codebase — the runtime

- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/cms_harness/agents/engine.ex — `tools/1` lists the ten modules this agent carries; `send_message/4` resolves a live pid and hands off `{:send, ref, message, timeout}`, deciding started-or-queued without running a turn; `terminate/2` runs `on_stop`, which is agent termination and not turn end. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/cms_harness/agents.ex — `launch/1` taking a working copy, provider, credential and role; `message/4`, `send_message/4`, `withdraw/2`, and `status/1` distinguishing an agent mid-turn from one waiting. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/cms_harness/agents/tools/run_script.ex — how this agent reaches the project's scriptable tools through one schema rather than a catalogue. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/cms_harness/agents/tools/run_browser_script.ex — the browser's own sandbox with a caller-set deadline, the second of the two ways in. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/cms_harness/mcp.ex — one MCP session per agent, named after it, so two agents on one machine cannot read each other's. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/agents/transport/harness.ex — how the server reaches this agent at all: start, message, dispatch, stop and machine-tool calls, each a channel push to the working copy's holder. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/agents.ex — `machine_tools/3`, granting browser tools only for the main, qa and coding roles. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/mix.exs — `{:alloy, "~> 0.12"}`, the dependency this agent class runs on. Accessed 2026-09-02.

## Codebase — the gap, cited against the external mechanisms

- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/stop.ex — `decide/2`, whose only caller is the external HTTP controller; `pending_analysis?/1` and `wait_directive/1`, the branch that exists only because a hook must answer before the answer exists; `maybe_terminate_stuck/5`, the session-scoped escape from a block the agent cannot act on. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/validation.ex — `validate_stop/3` has exactly two callers, both hooks, and `ensure_stale_runs/3` is reached only through it. This is the citation proving nothing enqueues analysis when an internal turn ends. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/lib/code_my_spec/hooks/analysis_alert.ex — `check/2` requires a `session_id`, which this agent does not have, and dedupes on it. Accessed 2026-09-02.
- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/plugins/claude/hooks/hooks.json — the seven hook events that are properties of the Claude Code CLI and that this runtime does not produce. Accessed 2026-09-02.

## Stories

- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/987 — story 987, *Analysis results reach the agent running inside our own BEAM*: six rules and seven scenarios written for this persona. Accessed 2026-09-02.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/988 — story 988, *The stop decision reaches the agent running inside our own BEAM*: eight rules, including that the agent is never told to wait for the analyzers, and that one told the same unfixable thing is eventually left alone. Accessed 2026-09-02.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/890 — story 890, the external counterpart, whose persona narrowing is what made this one's absence visible. Accessed 2026-09-02.

## Observed friction

- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/issues — issue `f0cc65ab`, *An internal agent gets no stop decision and no nudge*, found by QA of story 985 and closed as superseded by 987 and 988; carries the direction on transport verbatim. Accessed 2026-09-02.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/issues — issue `927c2b78`, the cost of treating `session_id` as an agent identity, observed on the external agent and directly relevant to how this one must be keyed. Accessed 2026-09-02.

## Upstream

- https://modelcontextprotocol.io/ — the client contract this agent's own session speaks against the project's server. Accessed 2026-09-02.
- https://docs.anthropic.com/en/docs/agents-and-tools/ — agent tool-use patterns behind the two-ways-in-plus-lookup design this agent carries. Accessed 2026-09-02.

## Self-reflection — stated as a limit

- https://github.com/Code-My-Spec/code_my_spec/blob/921a8859/CLAUDE.md — the author of this file is an External Claude Code Agent, not a member of this class, so first-person observation is not a source here and the agent-persona guide's allowance for it does not apply. Every claim rests on code, story or issue citations; where this persona's wants are described they are read off its runtime's capabilities and the rules sealed on 987 and 988, not off introspection. It is the one persona on this project nobody in the room has been. Accessed 2026-09-02.
