# Context Budget Awareness: Warn Agents Before Context Exhaustion

## Problem

Agents can silently hit context window limits during long task sessions. When this happens, the agent loses earlier context (file contents, requirement details, architectural decisions) and starts making mistakes — referencing stale information, forgetting constraints, or producing incomplete implementations.

There's no mechanism to detect approaching limits or take preventive action (checkpoint progress, commit partial work, summarize and continue).

## Design

### Option A: Claude Code Hook (CLI agent sessions)

A PostToolUse hook that monitors context usage and injects warnings:

| Threshold | Severity | Injected guidance |
|---|---|---|
| 65% used | WARNING | "Context at 65%. Finish current task, commit work, avoid reading large files." |
| 75% used | CRITICAL | "Context at 75%. Commit all progress now. Summarize remaining work in a comment." |

The hook reads context metrics from Claude Code's statusline data and injects via `additionalContext` in the hook response. Debounce: only warn every 5 tool calls (with severity escalation bypassing debounce).

### Option B: MCP Tool Response Guidance

If context metrics aren't available to hooks, the MCP server can track tool call count as a rough proxy. After N tool calls in a session, start appending context budget reminders to tool responses.

### Degradation tiers

| Tier | Context remaining | Agent behavior |
|---|---|---|
| PEAK | >60% | Normal operation |
| GOOD | 40-60% | Avoid reading files already seen, prefer targeted reads |
| DEGRADING | 25-40% | Finish current task only, no exploration |
| POOR | <25% | Commit immediately, write continuation notes |

## Open questions

- Can we reliably get context metrics from Claude Code's runtime in a hook? The statusline bridge file approach (writing to `/tmp/`) works in GSD but feels fragile.
- Should the MCP server track session-level tool call counts as a proxy?

## Inspiration

GSD framework's context monitor hook and context budget reference docs.
