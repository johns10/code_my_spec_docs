# The Five Layers of an Agentic Coding System

_Part 1 of "The Anatomy of Agentic Coding Systems," a series breaking down how AI coding tools actually work._

---

When someone says "Claude wrote my authentication system," they're conflating at least three different things. The model predicted tokens. The agent loop executed tools. The harness enforced rules and ran tests. The environment provided the filesystem and shell access. And maybe an orchestrator coordinated multiple agents across the task.

Most developers treat their AI coding tool as a single thing. It's not. It's a system with distinct layers, each doing fundamentally different work. And the layer most people focus on, the model, is usually the least important variable in whether the tool produces good output.

I've spent months digging into how these systems actually work. This series breaks it down into five layers, maps real tools onto them, and argues that understanding the layers changes how you use these tools, evaluate them, and build with them.

## The five layers

```
┌─────────────────────────────────────────────────┐
│            ORCHESTRATION LAYER                  │
│  Multi-agent coordination, task decomposition   │
├─────────────────────────────────────────────────┤
│              HARNESS LAYER                      │
│  Rules, verification, lifecycle, persistence    │
├─────────────────────────────────────────────────┤
│              AGENT LAYER                        │
│  Agent loop, tool use, context management       │
├─────────────────────────────────────────────────┤
│              MODEL LAYER                        │
│  The LLM: reasoning, generation, tool decisions │
├─────────────────────────────────────────────────┤
│           ENVIRONMENT LAYER                     │
│  IDE, sandbox, filesystem, git, runtime         │
└─────────────────────────────────────────────────┘
```

Every AI coding tool you use, Claude Code, Cursor, Copilot, Codex, Aider, Gemini CLI, is a specific combination of choices at each layer. The differences between them aren't mainly about which model they use. They're about how they implement the agent loop, what constraints the harness enforces, what environment the agent runs in, and how (if at all) multiple agents coordinate.

## The model layer

The model is a next-token predictor. That's it. You give it a sequence of tokens, it predicts the most probable next token. Everything you see when you use these tools, reading files, running tests, editing code, committing to git, is built on top of that one capability by the layers above.

The model determines the ceiling of reasoning quality. But a great model with a bad harness produces worse results than a decent model with a great harness. On SWE-bench Verified, the same model swings nearly 5 points depending on the scaffold wrapping it. The model matters. It's just not the bottleneck most people think it is.

**[Read the full article: The Model Layer](/blog/the-model-layer)**

## The agent layer

The agent layer is a while loop. The model receives messages, decides whether to call a tool, executes the tool, feeds the result back, and repeats until it produces a plain text response with no tool calls. This is the [ReAct pattern](https://arxiv.org/abs/2210.03629), and every major coding tool runs some variation of it.

The engineering isn't in the loop itself, it's in what surrounds it: tool design (how tools are defined shapes how the model uses them), context management (what fits in the window at any moment), and compaction (what happens when the window fills up). These decisions, not the model, are what separate a good tool from a great one.

**[Read the full article: The Agent Layer](/blog/the-agent-layer)**

## The harness layer

This is the layer most people haven't noticed yet, and the one I think matters most.

The harness is everything that constrains, verifies, and manages the agent to make it reliable. CLAUDE.md files. Linter rules. Test suites. Hooks that fire before and after tool use. Progress tracking across sessions. Architectural enforcement that prevents the model from violating your dependency chain.

OpenAI's Codex team shipped [roughly a million lines of production code](https://openai.com/index/harness-engineering/) with three engineers and zero manually written source. The engineers weren't writing code. They were building the harness. As they put it: ["Not documented. Enforced."](https://openai.com/index/unlocking-the-codex-harness/)

The industry figured this out in three phases: prompt engineering taught us to communicate with models, context engineering taught us to inform them, harness engineering teaches us to _constrain_ them.

**[Read the full article: The Harness Layer](/blog/the-harness-layer)**

## The environment layer

Take the same model, same agent loop, same prompt. Run it in your terminal and it rewrites your test suite in 90 seconds. Run it in a locked-down container and it can't install a dependency. Run it in the cloud and it delivers a PR while you sleep.

The environment determines what the agent can see, touch, and break. CLI agents (Claude Code, Codex CLI, Aider) give full system access. IDE agents (Cursor, Windsurf) give visual feedback and tight editor integration. Cloud agents (Copilot coding agent, Devin) run autonomously for hours. Sandboxing, permissions, and git worktrees control the blast radius.

Anthropic's research found that [infrastructure setup alone swings Terminal-Bench 2.0 scores by 6 percentage points](https://www.anthropic.com/engineering/infrastructure-noise), often exceeding the gap between top models. The environment isn't a detail.

**[Read the full article: The Environment Layer](/blog/the-environment-layer)**

## The orchestration layer

The single-agent loop is hitting its ceiling. The next frontier is coordinating multiple agents on problems too large for one context window.

Sub-agents (Claude Code's Agent tool, Cursor's parallel worktrees) are the most mature form, and they work because they solve a real problem: context isolation. Agent Teams and multi-agent frameworks are promising but early. The hard problems, context sharing between agents, error propagation, cost management, consistency across parallel work, aren't solved yet.

The gap between multi-agent demos and reliable multi-agent production systems is wider than most marketing copy suggests. But the direction is clear.

**[Read the full article: The Orchestration Layer](/blog/the-orchestration-layer)**

## Where the real tools sit

Here's the thing that becomes obvious once you see the layers: most tools only cover layers 1-3 (model, agent, environment). The harness and orchestration layers are where the engineering value lives, and they're mostly left to the developer to build.

| Tool            | Model       | Agent                                    | Environment               | Harness                       | Orchestration             |
| --------------- | ----------- | ---------------------------------------- | ------------------------- | ----------------------------- | ------------------------- |
| **Claude Code** | Claude      | ReAct loop, JIT context                  | CLI, local filesystem     | CLAUDE.md, hooks, permissions | Sub-agents, Agent Teams   |
| **Cursor**      | Multi-model | Composer (RL-trained), semantic indexing | IDE, worktrees, cloud VMs | .cursor/rules/                | Parallel agents, ensemble |
| **Copilot**     | Multi-model | Agent mode, coding agent                 | IDE + GitHub Actions      | AGENTS.md, CI gates           | Issue-to-PR workflow      |
| **Codex CLI**   | OpenAI      | ReAct loop, cloud sandbox                | CLI, OS-level sandbox     | AGENTS.md                     | Codex app, Agents SDK     |
| **Aider**       | Multi-model | ReAct loop, repo map                     | CLI, git-native           | Git commits as checkpoints    | Single agent only         |
| **Gemini CLI**  | Gemini      | Event-driven, 1M context                 | CLI, open-source          | Limited                       | Specialized sub-agents    |

Every tool is strong at the model and agent layers. The differentiation is in the harness and orchestration, and that's where most developers aren't investing their time yet.

## The thesis

If I had to summarize this entire series in one sentence:

**The model is becoming a commodity. The harness is the product.**

Models are converging. Prices are collapsing. The differences between Claude, GPT, Gemini, and DeepSeek are real but narrow compared to the gap between a well-harnessed agent and a bare one. A developer using Claude Code with a comprehensive CLAUDE.md, hooks, verification, and sub-agents is using a fundamentally different system than one typing prompts into a bare chat window, even though the model is identical.

The five-layer framework makes this visible. And once you see it, you can't unsee it.

---

_This is Part 1 of "The Anatomy of Agentic Coding Systems." The series continues with [Part 2: The Model Layer](/blog/the-model-layer)._

---

## Sources

This article synthesizes from the five layer articles in this series. Each has its own detailed source list:

- [Part 2: The Model Layer](/blog/the-model-layer) - 15 sources
- [Part 3: The Agent Layer](/blog/the-agent-layer) - 23 sources
- [Part 4: The Harness Layer](/blog/the-harness-layer) - 12 sources
- [Part 5: The Environment Layer](/blog/the-environment-layer) - 13 sources
- [Part 6: The Orchestration Layer](/blog/the-orchestration-layer) - 12 sources

Key references cited directly in this overview:

1. [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629) - Yao et al., ICLR 2023
2. [Harness Engineering](https://openai.com/index/harness-engineering/) - OpenAI
3. [Unlocking the Codex Harness](https://openai.com/index/unlocking-the-codex-harness/) - OpenAI
4. [Quantifying Infrastructure Noise in Agentic Coding Evals](https://www.anthropic.com/engineering/infrastructure-noise) - Anthropic Engineering
