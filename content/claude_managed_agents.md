# Anthropic Just Made the Agent Harness a Product

Anthropic launched [Claude Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) in public beta on April 8, 2026. I've been tracking the "harness engineering" thesis for months now, and this is the clearest validation yet: the model is commodity, the harness is the product.

## What It Actually Is

Managed Agents is a hosted agent runtime. Instead of building your own agent loop, tool execution, sandboxing, and session management, you get all of that as a service. You define an agent (model + system prompt + tools + MCP servers), configure an environment (a cloud container with packages and network rules), and start sessions against it. Claude runs autonomously, streams results back via SSE, and you can steer or interrupt mid-execution.

Four core concepts: **Agent** (the config), **Environment** (the container template), **Session** (a running instance doing work), and **Events** (messages between your app and the agent). That's it. [The docs](https://platform.claude.com/docs/en/managed-agents/overview) describe it as a "pre-built, configurable agent harness that runs in managed infrastructure."

There's the word. Harness. Anthropic is literally selling you the harness now.

## How It Fits With Everything Else

Anthropic now has three tiers of agent building:

1. **Messages API** - raw model access. You build the tool loop yourself.
2. **Agent SDK** (formerly Claude Code SDK) - same tools and agent loop that power Claude Code, available as a [Python/TypeScript library](https://platform.claude.com/docs/en/agent-sdk/overview). Runs on your infrastructure.
3. **Managed Agents** - the Agent SDK's capabilities, but Anthropic hosts everything. Best for long-running async work.

The Agent SDK gives you local control. Managed Agents gives you "I don't want to run containers." Both share the same tool set: Bash, file operations, web search, MCP servers. The SDK also supports [Agent Teams](https://code.claude.com/docs/en/agent-teams) for local multi-agent coordination where peers share a task list. Managed Agents has its own multi-agent capability in research preview where agents can spawn and direct other agents.

## Early Customers

The launch included four notable names:

- **Notion** deployed Claude through Custom Agents (private alpha) - engineers shipping code while knowledge workers generate presentations and websites ([blockchain.news](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment))
- **Rakuten** stood up enterprise agents across product, sales, marketing, finance, and HR within a week per deployment via Slack and Teams ([blockchain.news](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment))
- **Asana** built "AI Teammates" that pick up tasks and draft deliverables inside project management workflows ([blockchain.news](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment))
- **Sentry** paired their Seer debugging agent with Claude to write patches and open PRs - shipped in weeks versus months initially projected ([blockchain.news](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment))

A week per deployment at Rakuten is wild. That's the pitch: you skip the months of building agent infrastructure.

## Pricing

Two dimensions: tokens and session runtime ([pricing docs](https://platform.claude.com/docs/en/about-claude/pricing)).

Tokens bill at standard API rates. Opus 4.6 is $5/$25 per million tokens input/output. Prompt caching works. Web search is $10 per 1,000 searches.

Session runtime is **$0.08 per session-hour**, metered to the millisecond, only while the session status is `running`. Idle time doesn't count.

Worked example from the docs: a one-hour Opus 4.6 session consuming 50K input + 15K output tokens costs $0.705 total. With prompt caching, that drops to $0.525. Cheap enough that you could run these at scale without sweating it.

No batch mode, no fast mode, no data residency multiplier. Those are Messages API features. Managed Agents is its own thing.

## Why This Matters

Here's my take. For the last year, every serious agentic coding effort has converged on the same architecture: model + harness + tools + environment. OpenAI coined "harness engineering." Anthropic built the harness into Claude Code. Now they're selling it as infrastructure.

This is Anthropic saying: "We know the hard part isn't the model. It's everything around the model." Internal testing showed [up to 10 percentage points](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment) improvement in success rates on structured tasks compared to rolling your own agent loop. The harness matters.

For developers, the calculus changes. If you're building a product that needs Claude doing autonomous work - code generation, data pipelines, document processing - you no longer need to build and maintain sandboxes, session management, or tool execution infrastructure. You configure an agent, point it at an environment, and go.

The beta header is `managed-agents-2026-04-01`. It's enabled by default for all API accounts. Multi-agent coordination, outcomes, and memory are in research preview behind a [request form](https://claude.com/form/claude-managed-agents).

What's your take - does it make sense to use Anthropic's harness, or does the lock-in scare you?

---

## Sources

- [Claude Managed Agents Overview - Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/overview)
- [Agent SDK Overview - Anthropic Docs](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Claude API Pricing - Anthropic Docs](https://platform.claude.com/docs/en/about-claude/pricing)
- [Anthropic Launches Claude Managed Agents Platform - Blockchain News](https://blockchain.news/news/anthropic-claude-managed-agents-enterprise-ai-deployment)
- [Anthropic Launches Managed Agents to Simplify AI Deployment - TechBuzz](https://www.techbuzz.ai/articles/anthropic-launches-managed-agents-to-simplify-ai-deployment)
- [Agent Teams - Claude Code Docs](https://code.claude.com/docs/en/agent-teams)
