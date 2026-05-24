# Sources — Orchestrating Main Agent

GitHub URLs are pinned to commit `fb804066`. Internal issue/story IDs are stable
across the project DB.

## Agent definition (E1)

- https://github.com/johns10/code_my_spec/blob/fb804066/CLAUDE.md — CLAUDE.md, project-level instructions loaded into every main-agent session. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/.code_my_spec/AGENTS.md — AGENTS.md, full workflow guide; defines the core loop and the three init/sync/next states of `get_next_requirement`. Accessed 2026-05-24.

## MCP tool registry + workflow knowledge (E2)

- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/mcp_servers/local_server.ex — `component(...)` registration list; source of truth for `mcp__plugin_codemyspec_local__*` tools. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/priv/knowledge/persona_research/workflow.md — playbook for personas_complete. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/priv/knowledge/persona_research/agent_personas.md — methodology guide for LLM-agent personas; this document follows it. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/priv/knowledge/three_amigos/workflow.md — Example Mapping workflow used in this session for stories 608, 728, 810. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/priv/knowledge/fix_issues/workflow.md — per-issue JIT-discovery procedure referenced in story 608. Accessed 2026-05-24.

## Sub-agent definitions (E3)

- https://github.com/johns10/code_my_spec/blob/fb804066/CodeMySpec/agents/qa.md — Per-Story QA Agent definition; dispatch target for `qa_complete`. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/CodeMySpec/agents/code-writer.md — Code Writer Agent; dispatch target for implementation_file. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/CodeMySpec/agents/spec-writer.md — Spec Writer Agent; dispatch target for spec_valid / context_spec. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/CodeMySpec/agents/bdd-spec-writer.md — BDD Spec Writer Agent; dispatch target for bdd_specs_exist. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/CodeMySpec/agents/test-writer.md — Test Writer Agent; dispatch target for unit-test-file requirements. Accessed 2026-05-24.

## MCP tool implementations (E4)

- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/mcp_servers/requirements/tools/get_next_requirement.ex — first call of the loop; documents the three response shapes. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/mcp_servers/tasks/tools/start_task.ex — task creation + canonical prompt return. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/mcp_servers/tasks/tools/evaluate_task.ex — pass/fail evaluation for manual-validation tasks. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/sessions/subagent.ex — sub-agent registration record; documents `Task.agent_id` as the source of runtime ownership. Accessed 2026-05-24.

## Observed friction (E5)

- https://github.com/johns10/code_my_spec/commit/21403efd — "Requirements graph: remove satisfaction clamping; satisfaction is local truth" commit; documents the cascade-clamp bug that broke graph-trust for cross-entity prerequisites. Accessed 2026-05-24.
- https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec_local_web/controllers/hooks/stop_controller.ex#L50 — R5a short-circuit predicate keying off `Task.agent_id != nil`. Resolution surface for the project-memory `r5a_runtime_claim` thread. Accessed 2026-05-24.
- Resolved issue `cc661957` (MCP session drops during long implementation sessions) — closed as known-framework-limitation in this session's triage. Reference: https://github.com/johns10/code_my_spec/blob/fb804066/.code_my_spec/issues — accepted-issues directory. Accessed 2026-05-24.
- Resolved issue `c2d85309` (new MCP tools require local server restart) — closed as documented-behavior. Reference: https://github.com/johns10/code_my_spec/blob/fb804066/CLAUDE.md — restart-requirement noted in CLAUDE.md. Accessed 2026-05-24.
- Resolved issue `5e7ffbd9` (graph picks implementation_file for tools before schemas) — closed as behaves-as-expected. Reference: https://github.com/johns10/code_my_spec/blob/fb804066/lib/code_my_spec/requirements/requirement_graph.ex — graph-ordering source. Accessed 2026-05-24.

## Self-reflection (E6)

- https://github.com/johns10/code_my_spec/blob/fb804066/.code_my_spec/personas/orchestrating-main-agent/summary.md — this document was authored 2026-05-24 by an orchestrating-main-agent instance during a multi-hour session driving stories 608, 728 (deleted), 810, and 812. First-person observations: spawning `codemyspec:qa` for 812 in the background while continuing other work, losing the sub-agent's `agent_id` from working memory after intermediate work, triaging the 21 med+ issue backlog. Accessed 2026-05-24.

## Upstream specs (E7)

- https://docs.anthropic.com/en/docs/agents-and-tools/ — Agents and Tools — Anthropic Documentation. Accessed 2026-05-24.
- https://modelcontextprotocol.io/specification/2025-03-26 — Model Context Protocol specification (`tools/call` contract, error response shapes, session lifecycle). Accessed 2026-05-24.
