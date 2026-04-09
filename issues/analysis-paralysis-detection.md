# Analysis Paralysis Detection: Prevent Agents from Endless Exploration

## Problem

Agents sometimes enter a read-loop where they keep reading files, grepping for patterns, and exploring the codebase without ever writing code. This burns context window and time without progress. It's especially common when:

- The requirement is ambiguous and the agent isn't confident about the approach
- The codebase is large and the agent keeps "checking one more thing"
- A dependency chain leads the agent down a rabbit hole of unrelated modules

## Design

Track consecutive read-only tool calls (Read, Grep, Glob, Bash reads) without any write action (Edit, Write, Bash writes). When the count exceeds a threshold, intervene.

### Threshold and response

| Consecutive reads | Action |
|---|---|
| 7+ | Inject reminder: "You've read 7 files without writing. State your plan and act." |
| 12+ | Inject stronger guidance: "Stop exploring. Either start implementing or report what's blocking you." |

### Implementation options

**Hook-based**: A PostToolUse hook that counts tool types in the session and injects `additionalContext` warnings. Resets the counter on any write action.

**MCP-based**: If the agent is calling MCP tools between reads, the MCP server can track the pattern and append guidance to tool responses.

### What this is NOT

This isn't about preventing thorough research. Reading specs, checking existing patterns, and understanding context before coding is good. The guard only triggers after an unusually long read-only streak — the kind that indicates the agent is stuck, not preparing.

## Inspiration

GSD framework's "analysis paralysis guard" — 5+ consecutive reads without writes triggers forced explanation and action. We use a slightly higher threshold (7) since our codebase has more spec/rule files that legitimately need reading before implementation.
