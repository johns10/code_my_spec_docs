# Codex CLI in 2026: Features, Pricing, Benchmarks, and Community Sentiment

## Overview

Codex CLI is OpenAI's CLI agent, and it's the one I'd hand a cost-conscious developer doing terminal-heavy work. Unlike Claude Code, it's open source -- Apache 2.0, written in Rust, 62K+ GitHub stars, 365 contributors. Ships with GPT-5.3-Codex, codex-mini, and now GPT-5.4.

$20/mo via ChatGPT Plus with generous limits. Users consistently report 2-3x token efficiency over Claude Code. Community consensus: go-to for DevOps, infra, and CI/CD. The Codex App (macOS + Windows) runs parallel agent threads across projects.

The pace is absurd: 553 releases in 10 months, 9,000+ plugins, a Rust rewrite in alpha, and Codex-Spark on Cerebras WSE-3 at 1,000+ tokens/sec.

## Key Differentiators

- **Open source in Rust** -- Apache 2.0, 365 contributors. You can audit it
- **Token efficiency** -- 2-3x fewer tokens than Claude Code for comparable work
- **DevOps/infra** -- Community-consensus leader for terminal-heavy workflows
- **GitHub code review** -- Auto-reviews on PRs. Entrenched enough that Codex flagged a Claude-generated PR (609 upvotes, r/OpenAI)
- **Codex Desktop** -- macOS + Windows app for parallel agent threads. Now with background computer use (v26.415, April 2026) and integrated browser
- **90+ proprietary plugins** -- Atlassian Rovo, CircleCI, GitLab, Figma, Notion (separate from the 9,000+ open MCP ecosystem)
- **Voice transcription** -- Hold spacebar to dictate in the TUI
- **9,000+ MCP plugins** -- Largest plugin ecosystem in the category
- **Tiered plans up to $200** -- $20 Plus, $100 Pro (5x, April 2026), $200 Pro (~20x). Direct Claude Max competitor

## Pricing

| Plan | Price | Details |
|------|-------|---------|
| ChatGPT Plus | $20/mo | Baseline Codex sessions, rebalanced April 2026 to spread across the week (heavy single-day promo ended) |
| ChatGPT Pro ($100 tier) | $100/mo | Introduced April 9, 2026. 5x Plus usage (10x promo through May 31, 2026). Same model access as $200 tier. |
| ChatGPT Pro ($200 tier) | $200/mo | ~20x Plus usage; heaviest daily use |
| API (codex-mini) | $1.50/$6 per 1M tokens | 75% prompt caching discount |
| API (GPT-5) | $1.25/$10 per 1M tokens | Full model |
| Business/Enterprise | Per-seat + credits | Team features |

## Strengths

- Best value at $20/mo. Users report rarely hitting caps
- 2-3x more token-efficient than Claude for comparable work
- Wins on terminal-heavy workflows (DevOps, infra, CI/CD)
- Open source. 365 contributors, real audit trail
- Fastest release cadence in the category (553 in 10 months)
- Parallel multi-agent work via Codex App
- Voice transcription is a genuine productivity win
- GitHub code review is deeply entrenched
- 9,000+ plugins, the biggest MCP ecosystem
- Rust rewrite in progress for zero-dep install

## Weaknesses

- OpenAI models only
- Frontend/UI work is the consistent weakness. April 2026 additions (integrated browser, gpt-image-1.5) target it but community verdict is pending
- Doesn't follow instructions literally -- "writes what it thinks you meant, not what you actually said"
- Rate limits still frustrating for heavy GPT-5.4 users even on the new $100 tier
- April 2026 rebalance pushes Plus power users toward the $100 tier
- API vs subscription billing confusion
- Erratic in extended sessions
- Custom code review instructions are CLI-only (missing in Codex App)
- Code quality trails Claude on complex multi-file work, per community consensus

## Community Sentiment

### What People Love

- **Cost + token efficiency** -- 2-3x fewer tokens than Claude Code. Users rarely hit limits even with heavy worktree use -- u/Jippylong12, r/ChatGPTCoding
- **Terminal workflows** -- DevOps/infra/CI-CD devs consistently pick Codex
- **Code review** -- GitHub auto-review on PRs. Entrenched enough that a Claude Code PR got flagged by Codex (609 upvotes, r/OpenAI)
- **Open source ecosystem** -- 365 contributors, 553 releases, community-built best-practice repos
- **Voice transcription** -- Hold spacebar to dictate

### Common Complaints

- **Frontend/UI is the #1 weakness** -- "GPT-5.4 really struggles a lot with UI and frontend optimization... With Opus 4.6, you could one-shot the frontend with backend integration and it will work out of the box." -- u/Creepy-Row970, r/OpenAI
- **Doesn't follow instructions literally** -- "codex writes what it thinks you meant, not what you actually said" -- u/GPThought, r/ChatGPTCoding (48 comments)
- **Pro rate limits** -- Even $200/mo users hit weekly limits with GPT-5.4
- **Billing confusion** -- API vs subscription separation trips people up

### Notable Quotes

> "After 8 attempt with codex, thought I'll give Claude code a try. And as soon as it created a PR..." -- u/Rude-Explanation-861, r/OpenAI (609 upvotes -- Codex auto-review flagged a Claude-generated PR)

> "GPT-5.4 really struggles a lot with UI and frontend optimization... With Opus 4.6, you could one-shot the frontend with backend integration and it will work out of the box." -- u/Creepy-Row970, r/OpenAI

> "Just ask it why it did it that way and go down a 5 hour rabbit hole that gets you nowhere. That's what I do at least." -- u/Dwman113, r/ChatGPTCoding (24 upvotes)

> "Honestly, Codex is like a Surgeon and Claude is more like a Surgical Resident" -- u/Reza______, r/vibecoding

## Performance Notes

**On benchmarks:** SWE-bench measures models plus scaffolding, not the CLI tools developers use. Neither Codex CLI nor Claude Code has been submitted. Terminal-Bench scores are also model-level, not tool-level. There is no widely-adopted benchmark for comparing coding agents head-to-head.

**Community consensus:** Codex wins on DevOps, infrastructure, and terminal-heavy work. 2-3x token efficiency vs Claude Code. Claude wins on complex multi-file architecture and frontend. Different tools, different jobs.

## Recent Changes (2025-2026)

### April 2026

- **Codex Desktop background computer use** (April 16, v26.415) -- Agents interact with macOS apps (browser, Figma, Notion) while you work. Integrated browser, `gpt-image-1.5`, multiple terminal tabs, remote devbox via SSH (alpha)
- **90+ proprietary Codex plugins** -- Atlassian Rovo, CircleCI, GitLab, Figma, Notion, GitHub. Separate from the 9,000+ open MCP ecosystem
- **Memory + persistent threads** (gradual rollout) -- Preferences and edit history across sessions. Enterprise and EU first
- **$100 Pro tier** (April 9) -- 5x Plus usage (10x promo through May 31). Direct Claude Max competitor. Plus plan rebalanced to spread sessions across the week
- **Codex-Spark** (April 7) -- Research preview for Pro. Cerebras WSE-3 at ~1,000 TPS, 128K context

### Earlier

- **GPT-5.4** (March 2026) -- Latest model
- **GPT-5.3-Codex** (Feb 5, 2026) -- 25% faster, coding-optimized (superseded by Spark for Pro)
- **Codex App for macOS** (Feb 2, 2026)
- **Codex App for Windows** (March 4, 2026) -- Native PowerShell + Windows sandbox
- **Rust rewrite (codex-rs)** -- Alpha. Replaces Node/TS for zero-dep install
- **Multi-agent** -- `spawn_agents_on_csv`, sub-agent nicknames
- **`@plugin` mentions** -- Auto-include MCP/app/skill context in chat
- **553 releases in 10 months** -- Fastest cadence in the category

## Integration Ecosystem

- **MCP:** Full support. `codex mcp add` command. 9,000+ plugins (largest in agentic coding). `@plugin` mentions in chat.
- **Code Review:** GitHub-integrated auto-review on PRs. Custom review instructions in CLI (not yet in App).
- **IDE:** VS Code extension + Codex App (macOS + Windows) for parallel agent threads
- **Agents SDK:** Official integration with OpenAI Agents SDK for custom orchestration
- **Open Source:** Apache 2.0, 62K+ stars, 365 contributors, 553 releases
- **Community Tools:** codex-cli-best-practice, voice hooks, remote approvals (Greenlight AI), acp-loop scheduler, multi-agent MCPs

## CodeMySpec Integration

Open source and the biggest plugin ecosystem make Codex a natural target for spec consumption.

- **Context files:** Codex adopted the Agent Skills spec from Claude Code (Dec 2025) and reads `AGENTS.md`. CodeMySpec can generate these from specs
- **MCP support:** Full support, 9,000+ plugins, `codex mcp add` to wire up. Specs can be served via MCP and referenced inline with `@plugin` mentions
- **Hooks:** No documented pre/post hook system. Custom verification means external scripting
- **Subagents:** `spawn_agents_on_csv` enables multi-agent workflows. Decompose a spec into a CSV of tasks, each a parallel agent. Sub-agent nicknames help track which component each is implementing
- **Skills/commands:** Agent Skills spec support means skills files can define reusable workflows that consume specs
- **Memory:** None across sessions. Context files + MCP are how you carry spec context forward

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
