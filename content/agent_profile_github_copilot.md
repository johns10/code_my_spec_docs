# GitHub Copilot in 2026: Features, Pricing, Benchmarks, and Community Sentiment

## Overview

On April 20, 2026, GitHub paused new Pro, Pro+, and Student signups. They tightened usage limits on existing individual plans and pulled Claude Opus models from the Pro tier (Pro+ only now). The official framing is "prioritizing service quality for existing paying customers." The honest read: Copilot's growth outran its capacity, and the cheapest path to premium models just got more expensive and harder to get into.

Copilot is still the incumbent. First mainstream AI coding tool, biggest installed base, broadest editor support -- VS Code, JetBrains, Eclipse, Xcode, Neovim, Visual Studio, GitHub.com, Mobile, Windows Terminal. It's grown past autocomplete into Agent Mode (autonomous multi-file editing), a cloud agent (async background work from Issues, now branch-capable), and an agentic Code Review system that's done 60M+ reviews, roughly 1 in 5 reviews on GitHub.

For teams already on GitHub it's still the "don't change anything" option -- Issues, PRs, Actions, code search all feed the agent. But the April 20 move lines up with the JetBrains AI Survey pegging Copilot adoption as "growth stalled" at 29% while Claude Code is at 18% with 6x growth in nine months. Copilot's not dying, but the scoreboard is moving.

## Key Differentiators

- **Widest editor support** -- VS Code, JetBrains, Eclipse, Xcode, Neovim, Visual Studio, GitHub.com, GitHub Mobile, Windows Terminal. Nothing else comes close.
- **Copilot cloud agent** (renamed from "coding agent" April 2026) -- Assign Issues or branch tasks; now does branch-only work, implementation plans, and deep codebase research without opening a PR.
- **Remote CLI control** -- Drive terminal sessions from your phone or browser via QR code (v1.0.23, April 2026).
- **Copilot CLI** (GA Feb 2026) -- Autopilot mode, specialized sub-agents (Explore, Task, Code Review, Plan), multi-model.
- **`gh skill` command** (April 16, 2026) -- Portable Agent Skills spec working across Copilot, Claude Code, Cursor, Codex, Gemini CLI.
- **GitHub-native workflow** -- Issues trigger the cloud agent, Code Review on PRs, Actions for execution, code search for RAG.
- **60M+ code reviews** -- Agentic architecture, 10X growth since launch, 1 in 5 reviews on GitHub.
- **Copilot Memory on by default** -- Persistent repo-level understanding.
- **Transparent usage counter** -- You see exactly how many premium requests you've burned. (Though exact Pro limits are no longer published post-April 2026.)

## Pricing

> **April 20, 2026:** New Pro/Pro+/Student signups are paused. Existing subscribers keep their plans, but usage limits were tightened and Opus models were pulled from Pro (Pro+ only). Refunds available through May 20 if you want out.

| Plan | Price | Details |
|------|-------|---------|
| Free | $0 | 50 premium requests/month + 2,000 completions |
| Pro | $10/mo ($100/yr) | Unlimited completions, agent mode, cloud agent. Exact request count tightened and no longer published (April 2026). Opus models removed from Pro; Sonnet 4.6 is now the highest Claude tier on Pro. |
| Pro+ | $39/mo ($390/yr) | More than 5x Pro limits, all models including Claude Opus 4.7 (replacing 4.5/4.6), Copilot Memory |
| Business | $19/user/mo | 300 premium/user/month, org management, SSO, audit logs, IP indemnity |
| Enterprise | $39/user/mo | 1,000 premium/user/month, knowledge bases, custom models |
| Overage | $0.04/request | Additional premium requests beyond plan allocation |

## Strengths

- Works everywhere -- widest IDE/editor coverage of any AI coding tool
- Cheapest path to premium models at $10/mo (when signups reopen)
- GitHub context no one else has -- issues, PRs, org knowledge, code search
- Cloud agent for async background work -- assign issue, come back to a PR
- 60M+ code reviews on agentic architecture
- Multi-model -- GPT-5, Claude, included models at no premium cost
- Real enterprise story -- SSO, audit logs, IP indemnity
- Transparent usage counter vs Cursor's opaque credits
- Copilot Memory cuts down context re-explanation
- MCP support with GitHub MCP Registry
- Students and OSS maintainers get Pro free

## Weaknesses

- **Supply-constrained as of April 20, 2026** -- New individual signups paused, limits tightened, Opus yanked from Pro. GitHub is gating growth to protect service quality.
- **Growth stalled per JetBrains AI Survey (April 2026)** -- 76% awareness, 29% adoption, described as "growth stalled" versus Claude Code at 18% and 6x growth in 9 months.
- Agent depth trails Cursor -- no subagents, no cloud agents with computer use, no automations
- Code quality trails Claude Code and Cursor on complex autonomous tasks per community consensus
- Premium quotas burn fast for heavy users; new Pro limits post-tightening aren't published
- Surprise charges happen -- $0.04/request overages, student-plan edge cases
- Cloud agent works best on well-tested codebases with low-to-medium complexity tasks
- Context window limits bite on multi-repo work
- Microsoft/GitHub platform lock-in

## Community Sentiment

### What People Love

- **Best value under $20** -- "CoPilot, your first 300 premium requests are $10/month and then pay as you go $0.04/each additional after that." -- u/Ir0nMann, r/vibecoding. Consistently cited as cheapest path to premium models.
- **Transparent usage tracking** -- "GitHub clearly shows how many premium requests you've used and how many you have left... With tools like Cursor, it often feels like tokens are constantly burning in the background." -- u/0xdps, r/vibecoding
- **Pro+ actually converts people** -- "I used ClaudeCode since the beta.. then moved to GH Copilot and will never go back or switch to anything. It's super. Also upgraded to the 39 EUR tier.. still using full Claude, but not being rate limited every 2 prompts." -- u/exitcactus, r/vibecoding
- **Lives inside your existing workflow** -- The "don't change anything" option for teams on GitHub.
- **Multi-IDE** -- Nobody else covers this many editors.

### Common Complaints

- **Context windows choke on multi-repo work** -- Especially big C++/Python bug investigations.
- **Premium requests burn fast** -- 300/month on Pro felt tight before the April tightening; limits are not public now.
- **Surprise charges** -- Students charged for Opus usage despite Student Developer Pack.
- **Cloud Agent PR failures** -- "Anyone keep running to issues of it not being able to complete task. Even if I use Claude model when it comes to pushing the PR thing it fails if it's not stated perfectly." -- u/Mstep85, r/ChatGPTCoding
- **Breadth vs depth** -- Copilot wins breadth (6+ IDEs, GitHub-native), Cursor wins depth (subagents, plan mode, cloud agents with computer use).

### Notable Quotes

> "I used ClaudeCode since the beta.. then moved to GH Copilot and will never go back or switch to anything. It's super." -- u/exitcactus, r/vibecoding

> "GitHub clearly shows how many premium requests you've used and how many you have left... With tools like Cursor, it often feels like tokens are constantly burning in the background." -- u/0xdps, r/vibecoding

> "CoPilot, your first 300 premium requests are $10/month and then pay as you go $0.04/each additional after that." -- u/Ir0nMann, r/vibecoding

> "Copilot is mature, battle-tested, and works inside your existing setup, making it the 'don't change anything' option." -- Second Talent review

## Performance Notes

**A note on benchmarks:** SWE-bench measures models and their scaffolding, not the tools developers use. GitHub Copilot as a product has not been independently benchmarked against other coding agents in a standardized way. There is no widely-adopted benchmark for comparing coding agents head-to-head.

**Product metrics:**
| Metric | Value | Notes |
|--------|-------|-------|
| Code Reviews | **60M+** completed | 1 in 5 reviews on GitHub, 10X growth |

**Community consensus:** Copilot wins on breadth -- widest editor support, cheapest premium model access (when signups are open), deepest GitHub integration. It loses on autonomous depth. For complex multi-file autonomous work, developers lean toward Claude Code or Cursor. Copilot is still the "don't change anything" pick for teams already on GitHub.

## Recent Changes (2025-2026)

### The big one

- **Signup pause + limit tightening** (April 20, 2026) -- New Pro/Pro+/Student signups paused. Opus pulled from Pro (Pro+ only). Individual plan usage limits tightened. Refund window through May 20. Existing subscribers unaffected, but this is a clear signal GitHub's growth outran its capacity.

### April 2026

- **Claude Opus 4.7 on Pro+** -- Replaced Opus 4.5/4.6 in the picker.
- **`gh skill` command** (April 16) -- Portable Agent Skills spec, cross-agent (Copilot, Claude Code, Cursor, Codex, Gemini CLI, Antigravity).
- **Remote CLI via QR code** (v1.0.23, April 10-13) -- Drive terminal sessions from phone or browser. New `--mode`, `--autopilot`, `--plan` flags.
- **Cloud agent renamed + expanded** (April 1) -- Formerly "coding agent." Now does branch-only work, implementation plans, deep codebase research. No PR required.
- **Copilot SDK public preview** (March-April) -- Embed Copilot agent capabilities in third-party apps.
- **VS Code Autopilot mode** (public preview) -- Fully autonomous sessions without approval prompts.

### Earlier

- **Copilot CLI GA** (Feb 25, 2026) -- Autopilot mode, multi-model (Opus 4.6, Sonnet 4.6, GPT-5.3-Codex, Gemini 3 Pro), sub-agents, enterprise policy controls.
- **Agent Mode GA** -- Autonomous multi-file editing. Custom agents, sub-agents, plan agent. JetBrains GA March 2026.
- **Code Review agentic architecture** (March 2026) -- Tool-calling for broader repo context.
- **Copilot Memory on by default** (March 2026) -- Persistent repo-level understanding for Pro/Pro+.
- **MCP support** -- Full MCP in VS Code 1.99+. GitHub MCP Registry. Auto-configured for cloud agent.

## Integration Ecosystem

- **Editors:** VS Code (deepest), JetBrains, Visual Studio, Eclipse, Xcode, Neovim, GitHub.com, GitHub Mobile, Windows Terminal
- **MCP:** Full support in VS Code 1.99+. GitHub MCP Registry for discovery. Auto-configured for coding agent. Org policy controls for Business/Enterprise.
- **GitHub-Native:** Coding Agent from Issues, Code Review on PRs, CLI integration (`gh pr create/edit`), Actions for execution environments, code search for RAG
- **Models:** GPT-5.4, GPT-5.3-Codex, Claude Sonnet 4.6, Claude Haiku 4.5 (premium). GPT-5 mini, GPT-4.1, GPT-4o (included free).
- **Skills:** Custom skills, community skills (github/awesome-copilot, anthropics/skills)
- **Metrics:** Copilot Metrics dashboard for team adoption tracking

## CodeMySpec Integration

Copilot's installed base and native GitHub integration make it a high-reach target for CodeMySpec, even with the April signup pause.

- **Context files:** `.github/copilot-instructions.md` is the native project-context file. CodeMySpec generates it from specs -- architecture decisions, component boundaries, coding rules. VS Code and the Cloud Agent both read it automatically.
- **MCP support:** Full MCP in VS Code 1.99+ with GitHub MCP Registry. CodeMySpec serves specs via MCP, auto-configured for the Cloud Agent, so spec context is available even in async background work.
- **Hooks support:** Agent hooks in preview (March 2026). `/create-*` commands define reusable prompts and hooks. Once hooks hit GA, specs can trigger automated verification after edits.
- **Subagent support:** Custom agents, sub-agents, plan agent all available in Agent Mode. The Cloud Agent itself is single-agent (issue in, PR out) -- functional for spec-to-PR but thinner than Claude Code's Agent Teams.
- **Skills/commands:** Custom skills via `/create-*`. Community skills from `github/awesome-copilot`. Specs translate cleanly into skill definitions.
- **Memory/persistence:** Copilot Memory is on by default for Pro/Pro+. Strongest persistence story among IDE-based tools -- spec context compounds over time.

## Related Articles

- [AI IDEs Compared in 2026](/blog/ai-ides-compared-2026)
- [Free and Open Source AI Coding Tools in 2026](/blog/free-open-source-ai-coding-tools-2026)
- [Open Source vs Vendor-Locked AI Coding Tools](/blog/open-source-vs-vendor-locked-ai-coding-tools)

## Sources

- [Agent Mode 101 -- GitHub Blog](https://github.blog/ai-and-ml/github-copilot/agent-mode-101-all-about-github-copilots-powerful-mode/)
- [About Coding Agent -- GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent)
- [Copilot Plans and Pricing](https://github.com/features/copilot/plans)
- [Code Review Agentic Architecture -- GitHub Blog](https://github.blog/changelog/2026-03-05-copilot-code-review-now-runs-on-an-agentic-architecture/)
- [60M Copilot Code Reviews -- GitHub Blog](https://github.blog/ai-and-ml/github-copilot/60-million-copilot-code-reviews-and-counting/)
- [Copilot Memory Default -- GitHub Blog](https://github.blog/changelog/2026-03-04-copilot-memory-now-on-by-default-for-pro-and-pro-users-in-public-preview/)
- [JetBrains Agentic Improvements -- GitHub Blog](https://github.blog/changelog/2026-03-11-major-agentic-capabilities-improvements-in-github-copilot-for-jetbrains-ides/)
- [Copilot CLI Enhancements -- GitHub Blog (Jan 2026)](https://github.blog/changelog/2026-01-14-github-copilot-cli-enhanced-agents-context-management-and-new-ways-to-install/)
- [Copilot CLI GA -- GitHub Blog (Feb 25, 2026)](https://github.blog/changelog/2026-02-25-github-copilot-cli-is-now-generally-available/)
- [Copilot Cloud Agent rename -- GitHub Blog (April 1, 2026)](https://github.blog/changelog/2026-04-01-research-plan-and-code-with-copilot-cloud-agent/)
- [Copilot Metrics cloud-agent aggregation -- GitHub Blog (April 10, 2026)](https://github.blog/changelog/2026-04-10-copilot-usage-metrics-now-aggregate-copilot-cloud-agent-active-user-counts/)
- [gh skill command -- GitHub Blog (April 16, 2026)](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/)
- [Plan changes for individuals -- GitHub Blog (April 20, 2026)](https://github.blog/changelog/2026-04-20-changes-to-github-copilot-plans-for-individuals/)
- [Copilot CLI GA coverage -- InfoQ](https://www.infoq.com/news/2026/04/github-copilot-cli-ga/)
- [MCP and Copilot -- GitHub Docs](https://docs.github.com/en/copilot/concepts/context/mcp)
- [Premium Requests Explained -- GitHub Docs](https://docs.github.com/en/copilot/concepts/billing/copilot-requests)
- [Copilot SWE-bench -- MorphLLM](https://www.morphllm.com/comparisons/cursor-vs-copilot)
- [GitHub Copilot vs Cursor -- DigitalOcean](https://www.digitalocean.com/resources/articles/github-copilot-vs-cursor)
- [Copilot What's New](https://github.com/features/copilot/whats-new)
