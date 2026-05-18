# Sources — Per-Story QA Agent

Link list per source. Access date: 2026-05-17.

## E1 — QA Agent Definition (repo file)

- Path: `CodeMySpec/agents/qa.md`
- Title: QA Agent — agent definition and tool surface
- Access date: 2026-05-17
- Notes: First-person source. Defines tool surface, lifecycle phases, stop-hook gating, and artifact requirements for the QA agent class.

## E2 — QA Brief and Result Patterns (repo files)

- Path: `.code_my_spec/qa/124/brief.md`, `.code_my_spec/qa/124/result_complete.md`
- Path: `.code_my_spec/qa/460/brief.md`, `.code_my_spec/qa/460/result_complete.md`
- Path: `.code_my_spec/qa/538/brief.md`
- Path: `.code_my_spec/qa/553/result_complete.md`
- Title: Per-story QA briefs and results (stories 124, 460, 538, 553)
- Access date: 2026-05-17
- Notes: Observed patterns across multiple QA runs. Briefs encode auth, seed, scenario, and result-path requirements. Results demonstrate multi-phase gating, evaluation feedback loops, and the pass/fail/issue structure the agent produces.

## E3 — Story 559 QA Result (repo file)

- Path: `.code_my_spec/qa/559/result_complete.md`
- Title: QA Result — Story 559: Three Amigos UI smoke
- Access date: 2026-05-17
- Notes: Direct evidence of brief drift (brief written for port 4003, LiveView moved to port 4000 mid-session), MCP session drop causing fallback to `mix run`, and mid-execution discovery of mismatch. First-hand account of the "brief vs running app" synchronization failure mode.

## E4 — QA Tooling Framework Knowledge (repo file)

- Path: `.code_my_spec/framework/qa-tooling.md`
- Title: QA Tooling Patterns
- Access date: 2026-05-17
- Notes: Framework-level guidance on tool selection (Vibium MCP vs curl), structured seed patterns, golden rule for auth routing. Encodes system decisions about what the QA agent surface is expected to look like.

## E5 — Story 668 Criterion 5484 and QA Result (repo files)

- Path: `.code_my_spec/qa/668/result_complete.md`
- Title: QA Result — Story 668: QA Setup
- Access date: 2026-05-17
- Notes: Documents the empty-section validation gap (bare H2 headers passing document parsing while carrying no content). Criterion 5484 was added to the story's acceptance criteria because this failure mode was observed in practice, making it a direct evidence source for the "silent acceptance of incomplete results" pain point.

## E6 — Self-reflection (first-person, this session)

- Source: Claude Sonnet 4.6, session 2026-05-17
- Title: First-person agent self-reflection
- Access date: 2026-05-17
- Notes: The agent producing this persona is a member of the class it describes. Preferences for typed tool boundaries, structured evaluation feedback, and durable audit trails are first-person observations about what LLM agents performing multi-phase QA tasks actually need to operate reliably. Triangulated against E1-E5 for grounding; not treated as the sole source for any single claim.

## Reference: Anthropic Agent Documentation

- URL: [https://docs.anthropic.com/en/docs/agents-and-tools/](https://docs.anthropic.com/en/docs/agents-and-tools/)
- Title: Agents and Tools — Anthropic Documentation
- Access date: 2026-05-17
- Notes: Background reference for tool-use patterns, structured tool calls, and how LLM agents reason about typed vs. freeform interfaces. Not cited as a primary source for any specific claim but informs the framing of "typed events over file parsing."

## Reference: Model Context Protocol Specification

- URL: [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- Title: Model Context Protocol
- Access date: 2026-05-17
- Notes: Background reference for MCP tool surface design. Informs claims about typed tool parameters, validation at boundaries, and structured tool responses. Not cited as a primary source but relevant to the "typed tool calls over freeform writes" decision driver.
