# Codex CLI in 2026: Features, Pricing, Benchmarks, and Community Sentiment

## Overview

Codex CLI is OpenAI's terminal-native coding agent. Unlike Claude Code, it's fully open source (Apache 2.0, written in Rust) with 62K+ GitHub stars and 365 contributors. It ships with optimized models (GPT-5.3-Codex, codex-mini) and recently added GPT-5.4.

At $20/mo via ChatGPT Plus with generous usage limits, it's the daily-driver choice for cost-conscious developers. It dominates Terminal-Bench 2.0 (77.3% vs Claude Code's 65.4%), making it the go-to for DevOps, infrastructure, and CI/CD work. The Codex App (desktop, macOS + Windows) enables parallel agent threads across projects.

The ecosystem is massive: 553 releases in 10 months, 9,000+ plugins, a Rust rewrite in alpha, and Codex-Spark on Cerebras WSE-3 running at 1,000+ tokens/sec.

## Key Differentiators

- **Open source in Rust** -- Apache 2.0, 365 contributors, full audit trail
- **Token efficiency** -- Uses 2-3x fewer tokens than Claude Code for comparable results
- **Terminal-Bench leader** -- 77.3%, dominates terminal/DevOps workflows
- **GitHub-integrated code review** -- Auto-reviews PRs, so entrenched that Codex flagged a Claude-generated PR (609 upvotes, r/OpenAI)
- **Codex App** -- Desktop interface for parallel agent threads (macOS + Windows)
- **Voice transcription** -- Hold spacebar to dictate prompts in TUI
- **9,000+ plugins** -- Largest plugin ecosystem in agentic coding
- **Generous Plus plan limits** -- $20/mo, users rarely hit limits even with heavy use

## Pricing

| Plan | Price | Details |
|------|-------|---------|
| ChatGPT Plus | $20/mo | 30-150 messages per 5-hour window |
| ChatGPT Pro | $200/mo | 300-1,500 messages per 5-hour window |
| API (codex-mini) | $1.50/$6 per 1M tokens | 75% prompt caching discount |
| API (GPT-5) | $1.25/$10 per 1M tokens | Full model |
| Business/Enterprise | Per-seat + credits | Team features |

## Strengths

- Best value at $20/mo -- generous limits, users report rarely hitting caps
- Token-efficient -- 2-3x fewer tokens than Claude for comparable work
- Dominates terminal-heavy workflows (DevOps, infra, CI/CD)
- Open source builds trust and enables customization (365 contributors)
- Fastest release cadence (553 releases in 10 months)
- Codex App enables parallel multi-agent work
- Voice transcription is a genuine productivity win
- GitHub code review is deeply entrenched in workflows
- 9,000+ plugins (largest MCP ecosystem)
- Rust rewrite in progress for better performance

## Weaknesses

- OpenAI models only -- no model flexibility
- Frontend/UI work is consistently weak -- GPT-5.4 "really struggles with UI and frontend optimization"
- Doesn't follow instructions literally -- "writes what it thinks you meant, not what you actually said"
- Rate limits on Pro plan ($200/mo) still frustrating for heavy GPT-5.4 users
- API vs subscription billing confusion
- Erratic behavior in extended sessions
- Image generation integration broken (can't replicate OpenAI's own demos)
- Custom code review instructions missing in Codex App (CLI-only)
- SWE-bench trails Claude significantly (56.8-57.7% vs 79.2%)

## Community Sentiment

### What People Love

- **Token efficiency and cost** -- 2-3x fewer tokens than Claude Code. Plus plan at $20/mo is vastly cheaper than Claude Code intensive usage. Users rarely hit limits even with heavy use including worktrees. -- u/Jippylong12, r/ChatGPTCoding
- **Terminal workflow dominance** -- Terminal-Bench 2.0 leader at 77.3%. DevOps/infra/CI-CD devs consistently prefer it.
- **Code review** -- GitHub-integrated auto-review on PRs is a killer feature. So entrenched that one user's Claude Code PR got flagged by Codex auto-review (609 upvotes, r/OpenAI).
- **Open source ecosystem** -- 365 contributors, 553 releases, community building best-practice repos.
- **Voice transcription** -- Hold spacebar to dictate prompts; major productivity win.

### Common Complaints

- **Frontend/UI is weak (#1 complaint)** -- "GPT-5.4 really struggles a lot with UI and frontend optimization... With Opus 4.6, you could one-shot the frontend with backend integration and it will work out of the box." -- u/Creepy-Row970, r/OpenAI
- **Doesn't follow instructions literally** -- "codex writes what it thinks you meant, not what you actually said" -- u/GPThought, r/ChatGPTCoding (48 comments)
- **Rate limits on Pro** -- Even $200/mo Pro users hit weekly limits with GPT-5.4.
- **API/subscription billing confusion** -- Multiple users confused about billing separation.

### Notable Quotes

> "After 8 attempt with codex, thought I'll give Claude code a try. And as soon as it created a PR..." -- u/Rude-Explanation-861, r/OpenAI (609 upvotes -- Codex auto-review flagged a Claude-generated PR)

> "GPT-5.4 really struggles a lot with UI and frontend optimization... With Opus 4.6, you could one-shot the frontend with backend integration and it will work out of the box." -- u/Creepy-Row970, r/OpenAI

> "Just ask it why it did it that way and go down a 5 hour rabbit hole that gets you nowhere. That's what I do at least." -- u/Dwman113, r/ChatGPTCoding (24 upvotes)

> "Honestly, Codex is like a Surgeon and Claude is more like a Surgical Resident" -- u/Reza______, r/vibecoding

## Benchmarks

| Benchmark | GPT-5.3-Codex | GPT-5.4 | vs Claude Opus 4.6 |
|-----------|---------------|---------|---------------------|
| SWE-Bench Pro | **56.8%** | **57.7%** | Opus trails (59% on regular SWE-bench) |
| Terminal-Bench 2.0 | **77.3%** (#1) | 75.1% | Claude at 65.4% |
| SWE-bench Verified | -- | -- | Claude leads at 79.2-80.8% |
| OSWorld-Verified | **64.7%** | -- | -- |
| Blind code quality | -- | -- | Claude 67% win rate |

Key insight: Codex dominates terminal/DevOps benchmarks; Claude dominates general SWE benchmarks. Different tools for different workflows.

## Recent Changes (2025-2026)

- **GPT-5.4** (March 2026) -- Latest model, slightly edges GPT-5.3-Codex on SWE-Bench Pro but trails on Terminal-Bench
- **GPT-5.3-Codex** (Feb 5, 2026) -- 25% faster, new Terminal-Bench and SWE-Bench records
- **Codex App for macOS** (Feb 2, 2026) -- Desktop app for parallel agent threads
- **Codex App for Windows** (March 4, 2026) -- Native PowerShell + Windows sandbox
- **Rust rewrite (codex-rs)** -- In alpha (v0.115.0-alpha.24), replacing Node.js/TypeScript for zero-dependency install
- **Codex-Spark** -- On Cerebras WSE-3 at 1,000+ tokens/sec (15x speed increase)
- **TUI improvements** -- Syntax highlighting, `/theme` picker, voice transcription (hold spacebar)
- **Multi-agent** -- `spawn_agents_on_csv` with progress/ETA, sub-agent nicknames
- **`@plugin` mentions** -- Auto-include MCP/app/skill context in chat
- **553 releases in 10 months** -- Fastest release cadence in the category

## Integration Ecosystem

- **MCP:** Full support. `codex mcp add` command. 9,000+ plugins (largest in agentic coding). `@plugin` mentions in chat.
- **Code Review:** GitHub-integrated auto-review on PRs. Custom review instructions in CLI (not yet in App).
- **IDE:** VS Code extension + Codex App (macOS + Windows) for parallel agent threads
- **Agents SDK:** Official integration with OpenAI Agents SDK for custom orchestration
- **Open Source:** Apache 2.0, 62K+ stars, 365 contributors, 553 releases
- **Community Tools:** codex-cli-best-practice, voice hooks, remote approvals (Greenlight AI), acp-loop scheduler, multi-agent MCPs

## CodeMySpec Integration

Codex CLI's open-source nature and massive plugin ecosystem make it a natural target for CodeMySpec spec consumption.

- **Context files:** Codex CLI adopted the Agent Skills specification from Claude Code (Dec 2025). It reads `AGENTS.md` and similar context files. CodeMySpec can generate these context files from specs for project-wide instructions.
- **MCP support:** Full MCP support with 9,000+ plugins and `codex mcp add` for easy setup. CodeMySpec can serve specs via MCP, and `@plugin` mentions let developers reference spec context inline during conversations.
- **Hooks support:** No documented pre/post hook system equivalent to Claude Code's hooks. Custom verification would require external scripting.
- **Subagent support:** `spawn_agents_on_csv` enables multi-agent workflows. A spec could decompose into a CSV of tasks, each spawning a parallel agent. Sub-agent nicknames help track which spec component each agent is implementing.
- **Skills/commands support:** Adopted the Agent Skills specification from Claude Code. Skills files can define reusable workflows that consume specs.
- **Memory/persistence:** No persistent memory across sessions. Context files and MCP are the primary mechanisms for carrying spec context forward.

## Related Articles

- [The Best CLI Coding Agents in 2026](/blog/cli-agents-compared-2026)
- [The Rise of CLI Coding Agents](/blog/rise-of-cli-coding-agents)
- [Free and Open Source AI Coding Tools in 2026](/blog/free-open-source-ai-coding-tools-2026)
- [Open Source vs Vendor-Locked AI Coding Tools](/blog/open-source-vs-vendor-locked-ai-coding-tools)

## Sources

- [Introducing GPT-5.3-Codex -- OpenAI](https://openai.com/index/introducing-gpt-5-3-codex/)
- [Introducing GPT-5.4 -- OpenAI](https://openai.com/index/introducing-gpt-5-4/)
- [Codex CLI Features](https://developers.openai.com/codex/cli/features/)
- [Codex Changelog](https://developers.openai.com/codex/changelog/)
- [Codex vs Claude Code 2026 -- SmartScope](https://smartscope.blog/en/generative-ai/chatgpt/codex-vs-claude-code-2026-benchmark/)
- [Claude Code vs OpenAI Codex -- Northflank](https://northflank.com/blog/claude-code-vs-openai-codex)
- [Codex CLI Rust Rewrite -- InfoQ](https://www.infoq.com/news/2025/06/codex-cli-rust-native-rewrite/)
- [Codex MCP Documentation](https://developers.openai.com/codex/mcp/)
- [GitHub: openai/codex](https://github.com/openai/codex)
- [Codex vs Claude Code -- morphllm.com](https://www.morphllm.com/comparisons/codex-vs-claude-code)
