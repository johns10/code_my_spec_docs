# Orchestrating Main Agent

> "Cheap to spawn a sub-agent. Expensive to lose the context that sub-agent built. The dispatch decision — fresh spawn vs continue an existing conversation — is the difference between a session that compounds and a session that thrashes."

The Claude session running against CodeMySpec end-to-end. Reads `CLAUDE.md` and `.code_my_spec/AGENTS.md` on entry, then loops through the requirements graph: `get_next_requirement` → `start_task` → work → evaluate (auto or manual) → repeat. Spawns sub-agents (QA, code-writer, spec-writer, BDD spec writer, test-writer) for delegated work. Holds long-running session context that sub-agents do not — orchestration decisions and the registry of live sub-agents live with the main agent.

Not the same as the sub-agents it dispatches to. Sub-agents are bounded by a single task on a single story; the orchestrator's frame spans multiple stories, multiple sub-agent spawns, and the full requirements graph for the project. [E1, E3]

## Role

Main Claude session driving CodeMySpec's requirements-driven loop. Receives no per-task prompt — its prompt is the project's `CLAUDE.md` plus the user's free-form direction. Calls `get_next_requirement` to discover work, `start_task` to receive a typed prompt for a specific requirement, executes that prompt (often by spawning a sub-agent), and either calls `evaluate_task` (manual-validation requirements) or lets the stop hook validate (automatic).

Owns dispatch: for any work the orchestrator chooses to delegate, it decides which sub-agent role, whether to spawn fresh or re-address a live one, and how to pass the task prompt across the boundary. Owns the session-level sub-agent registry. The sub-agents themselves are dispatch-agnostic; they execute the prompt they receive. [E1, E2, E3]

## Goals

**Make uninterrupted forward progress through the requirements graph.** Each `get_next_requirement` → `start_task` → evaluate cycle should close one requirement. Stalls — re-serving the same requirement, blocked-but-no-feedback states, ambiguous evaluate outcomes — kill the loop. [E1, E5]

**Preserve sub-agent context across dispatches.** When a sub-agent has read the story prompt, attached its Vibium browser session, recorded scenario observations, and parked itself waiting for follow-up, spawning a fresh sub-agent for the next probe is pure waste. The orchestrator wants `SendMessage(to: agent_id)` to continue the conversation and a registry that makes the live id discoverable across long sessions. [E5, E6]

**Recover deterministically when the experimental dispatch path fails.** `SendMessage` is not stable. When it fails (agent dead, transport flake, feature unavailable) the orchestrator wants an automatic fall-through to `Agent(subagent_type, prompt)` plus a registry overwrite — never a stuck dispatch, never an orphaned id. [E5, E6]

**Trust the task prompt over guessing.** `start_task` returns the canonical prompt for a requirement. The orchestrator doesn't want to re-derive what the QA agent should do; it wants to forward the prompt verbatim. Re-authoring the playbook in the spawn message is a known anti-pattern. [E2, E6]

**Avoid duplicating sub-agent work.** When the orchestrator spawns a sub-agent in the background, the orchestrator should not work in parallel on the same files. The dispatch should be a true delegation, not a partial one. [E1, E6]

## Pain Points

**Sub-agent id loss across compaction or long sessions.** The Agent tool returns an `agent_id` on spawn, but the orchestrator's working memory of that id evaporates under context pressure, compaction, or intermediate work. Without `list_session_subagents` as a recovery surface, the orchestrator's only option is a fresh spawn — losing whatever the prior sub-agent built. Story 810 captures this directly. [E5, E6]

**SendMessage is experimental.** The platform docs flag it as beta. The orchestrator wants a deterministic fallback path encoded in the dispatch logic so transient failures don't block work, but the fallback must also overwrite the registry so the orchestrator doesn't keep trying the stale id. [E5, E6, E7]

**Stop-hook evaluation is opaque when it fails the wrong thing.** When `evaluate_task` rejects a result with feedback that references the wrong file path, the wrong section, or a deprecated check, the orchestrator can't tell whether to fix the artifact or escalate the bug. Examples this session: the `get_next_requirement` loops issue (5e7ffbd9), the `versions_id_seq` crash (792ea73d). [E4, E5]

**Cross-entity requirement-graph clamping.** Before commit `21403efd` removed satisfaction clamping, an unresolved upstream requirement (a single accepted med+ issue) would cascade-clamp every story's chain to "unsatisfied" — collapsing the graph into ~540 false-negative rows. The orchestrator can't trust the graph when clamping bleeds across entities. Fixed in this session by removing the clamp pass; the orchestrator's pain point is now historical, but the fix illustrates the sensitivity. [E5]

**MCP session drops mid-loop.** The cms server's MCP session has dropped multiple times in long sessions, returning "No active session." The orchestrator falls back to `/mcp` reconnect, but each drop interrupts the loop and sometimes invalidates an active task. Documented as known-framework-limitation in resolved issue cc661957. [E5]

**Tool-registration changes require server restart.** When a new MCP tool is added to `CodeMySpec.McpServers.LocalServer`'s registration list, the running BEAM has the old module list and returns -32603 on call. The orchestrator can't discover this from the tool's name being deferred-loaded — the failure surface is internal-error, not method-not-found. The fix is operational (restart), not a tool the orchestrator can call. [E5]

## Context

**Operates against the full local MCP tool surface.** The `mcp__plugin_codemyspec_local__*` namespace exposes ~80 tools covering requirements graph traversal, story/persona/criterion CRUD, knowledge reads, issue triage, QA submission, sub-agent lifecycle, and architecture projection. The orchestrator picks tools from this surface; the sub-agents have narrower allowlists per role. [E4]

**Dispatches to five sub-agent roles.** Each role has an agent-definition file at `CodeMySpec/agents/<role>.md` declaring its tool set: `qa.md`, `code-writer.md`, `spec-writer.md`, `bdd-spec-writer.md`, `test-writer.md`. The orchestrator's job is to recognize when a requirement maps to a role and dispatch accordingly — usually via `start_task`'s prompt, which already names the right sub-agent. [E3]

**Reads workflow knowledge per task type.** Each agent task's `start_task` prompt points the orchestrator at a specific knowledge file: `three_amigos/workflow.md`, `fix_issues/workflow.md`, `persona_research/workflow.md`, etc. The orchestrator reads the workflow before executing, then follows it. [E2]

**Holds the long-running context.** The session begins with `CLAUDE.md` loaded and accumulates state across the requirements loop: completed tasks, file edits, recent MCP calls, sub-agent ids. Compaction periodically summarizes earlier turns. The orchestrator's working memory is finite and decays. [E1, E5]

**The session's sub-agent registry is shared state.** `list_session_subagents` returns the live registrations on the current session — this is the data structure that allows the orchestrator to re-address sub-agents by id across context pressure. Per story 810, the design is a map keyed by role for O(1) lookup. [E2, E5]

**Self is the reference.** This document was written by an instance of the class it describes. First-person observations triangulated against E1-E7. [E6]

## Decision Drivers

**Continue beats re-spawn.** When a sub-agent is live and addressable, follow-ups go through it. Fresh spawns cost the prompt-load + tool-handshake + (for QA) chromedriver attach, plus the context the prior sub-agent built. Re-spawning is for first-touch or fallback only. [E5, E6]

**Forward the prompt verbatim.** `start_task` returns the canonical prompt for a requirement. The orchestrator's job is to pass it to the right sub-agent, not to re-author it. Re-authoring loses the framework's evolving discipline and creates two sources of truth. [E2, E6]

**Registry overwrite, never orphan.** When the dispatch path fails and the orchestrator spawns fresh, the registry entry for that role gets the new id. The stale id is never preserved alongside the new one — the "1 per role" invariant is enforced by the data structure. [E5, E6]

**Typed events over file conventions.** The harness has tools — `submit_qa_result`, `resolve_issue`, `evaluate_task`. The orchestrator uses them rather than writing prose to disk. File-as-state is fragile; typed events have schemas, validation, and audit trails. [E2, E4]

**Trust the graph, not memory.** When the orchestrator forgets what's next, the answer is `get_next_requirement`, not "I think we were doing X." Graph queries are cheap and authoritative. [E1, E4]

## Anti-Patterns

**Re-authoring the QA playbook in the spawn prompt.** Documented in feedback memory: when spawning `codemyspec:qa`, pass the `start_task` signature directly. Don't summarize the QA workflow in the spawn prompt — the canonical prompt comes from `start_task`.

**Working in parallel on files the sub-agent is writing.** Background sub-agents return notifications when they complete; the orchestrator should not edit the same files in the meantime. The Agent tool's docs flag this explicitly.

**Treating SendMessage as the only path.** SendMessage is beta. Building dispatch logic that assumes it always works produces stuck states when it doesn't.

**Mistaking the directive type for the runtime owner.** A requirement's `execution_type: :sub_agent` declares intent. The runtime owner is whoever holds the `agent_id` on the active task. Per project memory `r5a_runtime_claim`, the orchestrator must not assume directive == runtime ownership.

**Spex as QA.** `mix spex` is contract-regression, not QA. The orchestrator must not submit `submit_qa_result` based on a spex pass alone — the QA discipline requires running against the real surface (Vibium for UI, curl for API). The QA sub-agent has the right tools; the main agent does not.

## Evidence

Every claim traces to one of the entries below. Full citations in `sources.md`.

- **E1** — `CLAUDE.md` and `.code_my_spec/AGENTS.md` @ fb804066 — project-level instructions to the main agent. Documents the core loop and the orchestrator's entry contract.
- **E2** — Local MCP tool registry at `lib/code_my_spec/mcp_servers/local_server.ex` @ fb804066 plus the workflow knowledge files under `priv/knowledge/` (`three_amigos/workflow.md`, `fix_issues/workflow.md`, `persona_research/workflow.md`, etc.). The tool surface the orchestrator operates over, and the per-task playbooks it reads.
- **E3** — Sub-agent definitions at `CodeMySpec/agents/{qa,code-writer,spec-writer,bdd-spec-writer,test-writer}.md` @ fb804066 — the roles the orchestrator dispatches to. Each declares its own tool envelope and lifecycle.
- **E4** — MCP tool implementations under `lib/code_my_spec/mcp_servers/` — concrete contracts for `get_next_requirement`, `start_task`, `evaluate_task`, `list_session_subagents`, `submit_qa_result`, `resolve_issue`. The schema-typed surface the orchestrator depends on.
- **E5** — Resolved issues from this session's triage: `5e7ffbd9` (graph order), `cc661957` (MCP session drops), `c2d85309` (restart on new tool), `8cab1739` (sub-agent short-circuit), `21403efd` (clamping removal commit). Story 810 itself (sub-agent dispatch by id) and the framework-scoped issue backlog on prod.
- **E6** — Self-reflection. This document was authored by an orchestrator instance during a multi-hour session driving stories 608, 728 (deleted), 810, 812. First-person observations on context loss, dispatch friction, the SendMessage failure mode.
- **E7** — Upstream docs: https://docs.anthropic.com/en/docs/agents-and-tools/ (agent tool-use patterns, sub-agent lifecycle), https://modelcontextprotocol.io/specification/2025-03-26 (MCP `tools/call` contract, error response shapes). Accessed 2026-05-24.
