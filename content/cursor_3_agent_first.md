# Cursor 3 Isn't an IDE Anymore. It's an Agent Switchboard.

Cursor shipped version 3 on April 2, and I've been poking at it for a couple days now. This is not a point release. They rebuilt the entire interface from scratch under the codename "Glass," and the result is a bet that you're going to manage agents, not write code.

Here's what actually changed and what it means for the rest of us.

## They Ditched the IDE Layout

The old Cursor was VS Code with a really good AI chat panel bolted on. Cursor 3 flips that. The primary interface is now an "Agents Window" - a full-screen workspace for running and managing multiple AI agents simultaneously. The traditional editor? Still there, but it's the secondary surface. You switch *into* the IDE when you need it, not the other way around.

This is a philosophical shift. The team [said explicitly](https://cursor.com/blog/cursor-3) they rebuilt the interface "from scratch, centered around agents." They're positioning this as the "third era of software development" where agent fleets ship code autonomously.

## Parallel Agent Fleets

The headline feature is running [up to 8 agents in parallel](https://devtoolpicks.com/blog/cursor-3-agents-window-review-2026) across isolated Git worktrees. You can have Agent A refactoring your auth module, Agent B writing tests, and Agent C fixing CSS - all at the same time, all visible in one sidebar.

These agents run locally, in worktrees, in the cloud, or on remote SSH. And there's a seamless handoff between environments - start a task locally, push it to the cloud when you close your laptop, pull it back when you're ready to test. That's genuinely useful for longer-running tasks.

There's also a `/best-of-n` command that [runs the same task across multiple models in parallel](https://cursor.com/changelog/3-0), each in its own worktree, then compares outcomes. That's clever. Let Claude and GPT race on the same problem, pick the winner.

## Multi-Surface Agent Control

Here's where it gets interesting for the "IDE as orchestration platform" thesis. All local and cloud agents appear in the sidebar, including [agents kicked off from mobile, web, desktop, Slack, GitHub, and Linear](https://cursor.com/blog/cursor-3). You start an agent from your phone, it shows up in your Cursor sidebar. You trigger one from a GitHub PR, same thing.

This is Cursor saying: we're not just where you write code. We're the dashboard for all your coding agents, regardless of where you launched them.

## How This Compares to Claude Code Agent Teams

Anthropic shipped [Agent Teams in February 2026](https://code.claude.com/docs/en/agent-teams) as a research preview. The concept is similar - multiple agents working in parallel on shared tasks, communicating with each other, picking work off a shared list.

The difference is the surface. Claude Code Agent Teams are terminal-native. One session leads, teammates work independently in their own context windows, and they coordinate through a shared task list. Anthropic stress-tested this by having [16 agents build a C compiler](https://www.anthropic.com/engineering/building-c-compiler) - 100,000 lines of Rust across nearly 2,000 sessions.

Cursor wraps the same parallel-agent concept in a visual interface with a unified sidebar. Claude Code gives you raw power and flexibility. Cursor gives you a dashboard. The tradeoff is the usual one: visual control vs. composability.

## Design Mode

Cursor 3 also ships Design Mode, which lets you [annotate UI elements directly in a built-in browser](https://cursor.com/blog/cursor-3) and point agents at specific parts of your interface. It's targeted at frontend iteration - click the thing that's wrong, tell the agent to fix it. Not groundbreaking, but it reduces the friction of describing UI problems in text.

## Pricing: No Change (Sort Of)

Pro is still [$20/month](https://devtoolpicks.com/blog/cursor-3-agents-window-review-2026). They didn't raise prices with this release. But remember that Cursor [switched to credit-based billing in June 2025](https://medium.com/@jimeng_57761/when-cursor-silently-raised-their-price-by-over-20-and-more-what-is-the-message-the-users-are-6af93385f362), and that rollout was rough enough to warrant a public apology. The $20/month Pro plan now includes a $20 credit pool. Your actual costs depend on which models you use and how heavily you lean on agents.

The tier lineup: Hobby (free), Pro ($20/month), Pro+ ($60/month, 3x credits), Ultra ($200/month, 20x credits), and Teams ($40/user/month).

## What This Means for the Landscape

The three lanes of agentic coding are now locked in:

1. **Terminal-native agents**: Claude Code, Codex CLI, Gemini CLI
2. **Agent-first IDEs**: Cursor 3, potentially Windsurf
3. **Multi-editor extensions**: GitHub Copilot

Cursor at [$2B ARR](https://thenewstack.io/cursor-3-demotes-ide/) is the fastest-growing tool in this space, and this release widens the gap. [One reviewer scored it 92/100](https://devtoolpicks.com/blog/cursor-3-agents-window-review-2026). The IDE-as-agent-orchestration-surface is now a real product category, not just a concept.

The reality is that "where do you manage your agents?" is becoming the key question in developer tooling. Cursor is betting it's a visual dashboard. Anthropic is betting it's the terminal. Both are betting it's not a traditional code editor.

What are you using to manage your agent fleet?

---

## Sources

- [Meet the new Cursor - Official Blog](https://cursor.com/blog/cursor-3)
- [Cursor 3.0 Changelog](https://cursor.com/changelog/3-0)
- [Cursor 3 Review: Agents Window, Pricing, Worth It?](https://devtoolpicks.com/blog/cursor-3-agents-window-review-2026)
- [Cursor's $2 Billion Bet - The New Stack](https://thenewstack.io/cursor-3-demotes-ide/)
- [Cursor 3 Is Not an IDE Update - Medium](https://medium.com/@han.heloir/cursor-3-is-not-an-ide-update-its-a-bet-that-you-ll-manage-agents-not-write-code-0d2bc51f0dcb)
- [Cursor Pricing Silent Increase - Medium](https://medium.com/@jimeng_57761/when-cursor-silently-raised-their-price-by-over-20-and-more-what-is-the-message-the-users-are-6af93385f362)
- [Claude Code Agent Teams Docs](https://code.claude.com/docs/en/agent-teams)
- [Building a C Compiler with Parallel Claudes - Anthropic](https://www.anthropic.com/engineering/building-c-compiler)
