# Opus 4.7 Migration Guide: What Breaks, What's Better, What to Watch

Opus 4.7 dropped today. If you're running Claude through the API, Claude Code, or any harness, read this before you upgrade. Three breaking changes will hard-fail your integration.

## What Breaks

All three return 400 errors. Not deprecation warnings. Hard failures.

### 1. Extended Thinking Budgets Are Gone

**Before (breaks):**

```json
{
  "model": "claude-opus-4-7-20260415",
  "thinking": {
    "type": "enabled",
    "budget_tokens": 10000
  }
}
```

**After (works):**

```json
{
  "model": "claude-opus-4-7-20260415",
  "thinking": {
    "type": "adaptive"
  }
}
```

The model decides how much thinking it needs now. Anthropic took the knob away.

### 2. Sampling Parameters Are Gone

`temperature`, `top_p`, `top_k` -- all return 400 if set to non-default values. If you tuned these, that's over. Remove them entirely.

```json
{
  "model": "claude-opus-4-7-20260415"
}
```

Control output through system prompts and effort levels instead.

### 3. Thinking Content Hidden by Default

Won't crash your app, but will break your UX. Thinking blocks return empty unless you ask for them. If you stream reasoning, you'll see a long pause then everything at once.

**Fix:**

```json
{
  "thinking": {
    "type": "adaptive",
    "display": "summarized"
  }
}
```

You get a summary, not the raw chain-of-thought.

## The Stealth Price Increase

Same price per token. More tokens per request.

The new tokenizer maps identical text to up to 35% more tokens. A request that cost $1.00 on 4.6 could cost $1.35 on 4.7. Your dashboards will show an increase even if nothing changes on your end.

Run a sample through `count_tokens` on both models before you migrate. Check your budget caps.

If you're going to charge me 35% more for the same work, just say that. Don't hide it behind a tokenizer change.

## Behavioral Shifts

### Fewer Tool Calls

4.7 reasons more, calls tools less. Generally better -- fewer roundtrips, lower cost. But if your harness expects a certain tool-call cadence, you'll see different behavior. Raise the effort level if you need more tool usage.

### Fewer Subagents

Same pattern. Tasks that 4.6 split across two or three subagents now get handled by one. If your orchestration assumes aggressive delegation, test it.

### More Literal Instruction Following

Double-edged sword. Precise prompts get more consistent results. Loose prompts that relied on the model figuring out what you meant will surprise you. Tighten up your system prompts.

### Cybersecurity Safeguards

New protections trigger false positive refusals on legitimate security work. If you're doing pentesting or touching network protocols, test before switching.

## What's Actually Better

| Benchmark | Opus 4.6 | GPT-5.4 | Opus 4.7 |
|-----------|----------|---------|----------|
| SWE-bench Pro | 53.4% | 57.7% | **64.3%** |
| SWE-bench Verified | 80.8% | -- | **87.6%** |
| CursorBench | 58% | -- | **70%** |

10-point jump on SWE-bench Pro. That's not noise.

**xhigh effort level** -- new default recommendation for coding. Sits between `high` and `max`. Start there.

**Task budgets (beta)** -- advisory token budget across an entire agentic loop. Not a hard cap, but the model is aware of it and prioritizes accordingly. Useful for managing runaway agent costs.

**/ultrareview** -- dedicated deep code review in Claude Code. Haven't tested it yet.

**3x image resolution** -- up to 2,576px. Matters for screenshots and diagrams.

**Auto Mode for Max plan** -- model picks Opus vs Sonnet per-request based on complexity.

## Migration Checklist

- [ ] Search for `budget_tokens` -- remove, switch to `"type": "adaptive"`
- [ ] Search for `temperature`, `top_p`, `top_k` -- remove from API calls
- [ ] Add `"display": "summarized"` if you stream thinking content
- [ ] Run `count_tokens` on both models -- measure the tokenizer impact
- [ ] Update cost alerts (expect up to 35% token count increase)
- [ ] Update hardcoded token budget caps
- [ ] Review system prompts for ambiguous instructions
- [ ] Test tool-calling patterns in your harness
- [ ] Test multi-agent setups with reduced subagent spawning
- [ ] Test security-adjacent workflows for false positive refusals
- [ ] Try `xhigh` effort for coding tasks
- [ ] Update model string to `claude-opus-4-7-20260415`

## My Take

The performance gains are real. 10 points on SWE-bench Pro translates to practical coding tasks, not just benchmark gaming.

The breaking changes are frustrating. Removing sampling parameters entirely is a strong opinion. Some of us had reasons for tuning temperature.

The tokenizer thing bothers me most. Technically honest, practically misleading.

Upgrade for the performance. Budget time for the migration. This isn't a drop-in replacement.
