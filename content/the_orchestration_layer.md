# The Orchestration Layer: Coordinating Multiple Agents

*Part 6 of "The Anatomy of Agentic Coding Systems," a series breaking down how AI coding tools actually work.*

---

For most of the AI coding era, the mental model has been simple: one developer, one agent, one conversation. You type a prompt, the agent reads files, writes code, runs tests, and loops until it's done. That single-agent loop is powerful. It's also hitting its ceiling.

The next frontier isn't making one agent smarter. It's coordinating multiple agents to work together on problems too large, too complex, or too parallelizable for a single context window.

This is the orchestration layer, the newest, least mature, and most interesting layer in the five-layer taxonomy. The gap between multi-agent demos and reliable multi-agent systems is wider than most marketing copy suggests.

## Workflows vs. agents (again)

Anthropic's ["Building Effective Agents"](https://www.anthropic.com/research/building-effective-agents) research draws a line that matters at the orchestration level too. **Workflows** orchestrate LLMs through predefined code paths, you define the steps, the LLM executes within them. **Agents** dynamically direct their own processes. Both patterns apply to multi-agent systems: you can orchestrate agents through predefined workflows (safer, more predictable) or let an orchestrator agent dynamically delegate (more flexible, harder to control).

Their five composable patterns, prompt chaining, routing, parallelization, orchestrator-workers, and evaluator-optimizer, are the building blocks. Real systems combine them: routing selects an orchestrator, which parallelizes across workers, each using prompt chaining internally, with an evaluator checking the final output.

## What's actually working today

The most mature form of orchestration in production isn't "multiple autonomous agents" coordinating. It's a single primary agent spawning sub-agents for focused tasks. This works because it solves a real problem: context windows are finite, and a single agent trying to hold an entire codebase in its head produces worse results than one that delegates.

### Claude Code sub-agents

Claude Code's [Agent tool](https://code.claude.com/docs/en/sub-agents) is the clearest implementation. When Claude Code encounters a task that benefits from isolation, it spawns a sub-agent with its own context window, filtered tool access, and a focused prompt. Anthropic calls this a ["context firewall"](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), the sub-agent sees only what it needs, focuses deeply without drowning in irrelevant context, and returns a summary rather than flooding the parent's window.

Sub-agents [cannot spawn their own sub-agents](https://blog.promptlayer.com/claude-code-behind-the-scenes-of-the-master-agent-loop/), preventing infinite nesting. You can also define [custom sub-agents](https://code.claude.com/docs/en/sub-agents) in Markdown files with YAML frontmatter, building a stable of specialists: security reviewer, API designer, test writer, each with purpose-built instructions and tool constraints.

### Agent Teams

[Agent Teams](https://code.claude.com/docs/en/agent-teams), introduced in Claude Code v2.1.32 as a research preview, push further. Instead of parent-child hierarchy, teammates are peers: one session leads, others work independently in their own context windows, and unlike sub-agents, teammates can message each other directly.

The use cases that work are inherently parallel: research across multiple aspects, separate modules of a new feature, competing debugging hypotheses. What doesn't work: sequential tasks, same-file edits, or anything with heavy dependencies. Agent Teams use significantly more tokens than a single session. Anthropic is [explicit about the trade-off](https://addyosmani.com/blog/claude-code-agent-teams/): for routine tasks, a single session is more cost-effective.

### Cursor's parallel agents

[Cursor 2.0](https://cursor.com/docs/configuration/worktrees) introduced native parallel agent support using git worktrees, up to eight agents working simultaneously, each in an isolated copy of the codebase. Their most interesting pattern is the ensemble approach: run multiple agents on the same task, then automatically select the best result. For hard problems, multiple attempts measurably improves quality.

### The coordination problem

Running agents in parallel sounds straightforward. Making them coordinate is where things break. Research from [Augment Code](https://www.augmentcode.com/guides/why-multi-agent-llm-systems-fail-and-how-to-fix-them) and [Mike Mason's analysis](https://mikemason.ca/writing/ai-coding-agents-jan-2026/) of a 1M-line multi-agent build surfaced hard truths:

- **Equal-status agents with locking failed.** Agents held locks too long, and 20 agents slowed to the throughput of 2-3.
- **Optimistic concurrency control failed.** Agents became risk-averse and avoided hard tasks to minimize conflicts.
- **Hierarchical roles succeeded.** Planners explore the codebase and create tasks, Workers execute independently, Judges evaluate results. No agent tries to do everything.
- **Coordination gains plateau beyond 4 agents.** Adding more doesn't help proportionally.

Google's 2025 DORA Report found that [increased AI adoption correlated with a 9% bug rate climb, 91% increase in code review time, and 154% increase in PR size](https://mikemason.ca/writing/ai-coding-agents-jan-2026/). Multi-agent parallelism amplifies these problems if consistency isn't actively managed.

## The hard problems

### Context isolation vs. sharing

The fundamental tension: agents need isolation to avoid context overload, but shared context to coordinate. Too much isolation and agents duplicate work or make contradictory decisions. Too much sharing and you're back to the single-context-window problem.

Git worktrees solve file-level isolation. But conceptual isolation, ensuring Agent A's architectural decisions are visible to Agent B without flooding B's context, remains largely unsolved. The current state of the art is "put decisions in files that other agents can read." Effective but crude.

### Error propagation

As information flows between agents, context gets lost or diluted. Summaries filter out details. An error in Agent A's research gets encoded in Agent B's implementation, which gets locked in by Agent C's tests that validate the wrong behavior. [Research shows](https://arxiv.org/abs/2503.13657) that [41-86.7% of multi-agent systems fail in production](https://www.augmentcode.com/guides/why-multi-agent-llm-systems-fail-and-how-to-fix-them), and nearly 79% of problems come from specification and coordination issues, not technical implementation.

### Cost

Multiple agents means multiple model calls. An orchestrator with four workers, each making 10 calls, produces 40+ calls per task. Add an evaluator loop and you hit 100+. At current pricing, complex multi-agent workflows cost $5-20 per execution. This is why the industry is gravitating toward better context management and stronger first passes, the cheapest orchestration is the orchestration you don't need.

## Where this is heading

### The near term: better sub-agents (2026)

The immediate trajectory is clear: single-agent systems with increasingly capable sub-agent support. Custom sub-agents with specialized instructions, filtered tool access, and independent context windows are becoming standard. This gets you 80% of the benefit with 20% of the complexity.

### The medium term: workflow-driven orchestration (2026-2027)

As teams build confidence, the next step is codified workflows: spec-to-implementation pipelines, automated review chains, deployment orchestration. Agents handle execution at each step, but the overall flow is deterministic.

### Spec-driven orchestration

One direction I find particularly promising: using specifications as the orchestration contract. Instead of agents coordinating with each other directly (hard, expensive, error-prone), agents coordinate through shared artifacts. A spec defines what to build. An implementation agent builds to the spec. A test agent validates against the spec. A review agent checks for compliance. The spec is the shared state. Agents don't need to talk to each other if they can all read the same contract.

This pattern has the advantage of being inspectable and debuggable by humans. When something goes wrong, you look at the spec and see exactly where the contract was violated.

## What this means for your stack

**Solo developer:** Sub-agents within your existing tool (Claude Code's Agent tool, Cursor's parallel agents) give you most of the benefit. Start here.

**Small team:** Shared conventions (CLAUDE.md, architectural rules) act as implicit orchestration. When every agent follows the same rules, you get consistency without coordination infrastructure.

**Building pipelines:** Workflow orchestration, the [OpenAI Agents SDK](https://openai.github.io/openai-agents-python/multi_agent/) for handoff patterns, [LangGraph](https://www.langchain.com/langgraph) for complex graphs, or shell scripts calling agent CLIs for the simplest case.

**Enterprise scale:** The Planner/Worker/Judge hierarchy, custom sub-agents, and tiered human checkpoints. Build incrementally, start with single-agent workflows that work, then add coordination.

The orchestration layer is where the biggest unsolved problems live. The teams that figure out reliable multi-agent coordination will build software at a pace that seems impossible from a single-agent perspective. But they'll get there through better harnesses, not better prompts.

---

*This is Part 6 of "The Anatomy of Agentic Coding Systems." [Part 5 covered the Environment Layer](/blog/the-environment-layer) - where AI code actually runs. Next: Article 7, "What Cursor Actually Is: An Agentic System Breakdown."*

---

## Sources

1. [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) - Anthropic
2. [Claude Code Sub-Agents](https://code.claude.com/docs/en/sub-agents) - Anthropic
3. [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) - Anthropic
4. [Claude Code Swarms](https://addyosmani.com/blog/claude-code-agent-teams/) - Addy Osmani
5. [Parallel Agents](https://cursor.com/docs/configuration/worktrees) - Cursor
6. [AI Coding Agents in 2026: Coherence Through Orchestration, Not Autonomy](https://mikemason.ca/writing/ai-coding-agents-jan-2026/) - Mike Mason
7. [Why Multi-Agent LLM Systems Fail](https://www.augmentcode.com/guides/why-multi-agent-llm-systems-fail-and-how-to-fix-them) - Augment Code
8. [Why Do Multi-Agent LLM Systems Fail?](https://arxiv.org/abs/2503.13657) - Cemri et al., ICLR 2025
9. [Agent Orchestration](https://openai.github.io/openai-agents-python/multi_agent/) - OpenAI Agents SDK
10. [LangGraph](https://www.langchain.com/langgraph) - LangChain
11. [2026 Agentic Coding Trends Report](https://resources.anthropic.com/2026-agentic-coding-trends-report) - Anthropic
12. [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Anthropic
