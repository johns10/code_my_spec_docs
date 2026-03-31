# The Model Layer: What Your AI Coding Tool Actually Is (and Isn't)

_Part 2 of "The Anatomy of Agentic Coding Systems," a series breaking down how AI coding tools actually work._

---

When someone says "Claude wrote my authentication system" or "GPT refactored my database layer," they're wrong. Not in a pedantic way. In a way that leads to bad decisions about which tools to use, how much to pay, and where to invest your time.

The model didn't write anything. It generated tokens. Everything else, reading your files, running your tests, editing your code, committing to git, happened in layers above the model that most developers never think about.

This article is about that bottom layer: the model itself. What it actually does, what it doesn't do, and why understanding the difference matters more than you think.

---

## What a model actually is

A large language model is a next-token predictor. That's it. That's the whole thing.

You give it a sequence of tokens (words, code, punctuation, whitespace), and it predicts the most probable next token. Then it appends that token to the sequence and predicts again. And again. Until it decides it's done.

```
Input:  "def fibonacci(n):\n    if n <="
Model:  " 1"  (most probable next token)
Input:  "def fibonacci(n):\n    if n <= 1"
Model:  ":"   (most probable next token)
...and so on until the function is complete
```

Every model in every coding tool works this way. Claude, GPT, Gemini, DeepSeek, Llama, Qwen. All next-token prediction under the hood. The differences are in how well they predict, how much context they can consider, and how they were trained.

As Simon Willison puts it: "An LLM is a machine learning model that can complete a sentence of text." That's genuinely all it is. Everything else you see when you use these tools is built on top of that one capability.

### What the model does not do

This is the part most people get wrong. The model:

- **Has no state.** Every API call starts fresh. It doesn't remember your last conversation unless someone feeds that conversation back in as input. As Willison says, "LLMs are stateless: every time they execute a prompt they start from the same blank slate."
- **Cannot read files.** It can only process text that's been placed in its context window.
- **Cannot run code.** It generates text that looks like bash commands. Something else executes them.
- **Cannot edit files.** It generates text that describes edits. Something else applies them.
- **Has no goals.** It doesn't "want" to fix your bug. It predicts tokens that look like a response to your prompt.

When you use Claude Code and it reads a file, runs a test, and fixes a bug, the model generated the _intent_ for each action. The agent layer (covered in the next article) actually executed them.

---

## The models powering coding tools in 2026

Here's what's actually running under the hood of the tools you use. I've put everything in one table so you can compare directly.

### Proprietary models

| Model             | Context | Input / Output (per 1M tokens) | Notes                                       |
| ----------------- | ------- | ------------------------------ | ------------------------------------------- |
| Claude Opus 4.6   | 1M      | $5 / $25                       | Strongest reasoning. Adaptive thinking.     |
| Claude Sonnet 4.6 | 1M      | $3 / $15                       | Best balance of speed and quality.          |
| Claude Haiku 4.5  | 200K    | $0.80 / $4                     | Fast and cheap.                             |
| GPT-5.4           | 1M      | $2.50 / $15                    | Current OpenAI flagship. Native tool use.   |
| GPT-5.4 mini      | 1M      | $0.75 / $4.50                  | Fast, cheap. Good for autocomplete.         |
| o3                | 200K    | $2 / $8                        | Reasoning model. Chain-of-thought built in. |
| o4-mini           | 200K    | $1.10 / $4.40                  | Compact reasoning. Great cost-performance.  |
| Gemini 3.1 Pro    | 1M      | $2 / $12                       | Google's current flagship. Deep thinking.   |
| Gemini 3 Flash    | 1M      | $0.50 / $3                     | Fast thinking model for agentic workflows.  |
| Gemini 3.1 Flash-Lite | 1M  | $0.25 / $1.50                  | Google's cheapest Gemini 3 option.          |

### Open-weight models

| Model            | Context | Cost                  | Notes                                |
| ---------------- | ------- | --------------------- | ------------------------------------ |
| DeepSeek V3.2    | 164K    | $0.28 / $0.42 per 1M  | 10-50x cheaper than proprietary.     |
| Qwen 3.5 Flash   | 1M      | $0.10 / $0.40 per 1M  | Cheapest frontier-quality option.    |
| Llama 4 Scout    | 10M     | Free (self-hosted)    | 10M context is almost absurd.        |
| Llama 4 Maverick | 1M      | Free (self-hosted)    | 400B total params, 17B active (MoE). |

Open-weight models are the escape hatch from API pricing. Coding quality generally trails the frontier proprietary models, but the gap has narrowed significantly. And Llama 4 Scout's 10 million token context window means you could load an entire monorepo into a single session.

**Who uses what:** Claude Code is Claude-only. Codex CLI is OpenAI-only (GPT-5.4, GPT-5.3-Codex, codex-1). Gemini CLI is Gemini-only. Everything else (Cursor, Aider, Cline, Copilot, Roo Code, OpenCode) lets you bring your own model.

---

## How models get evaluated for coding

This is where the industry is most confused. And where getting it wrong leads to the worst tool decisions.

### SWE-bench: the benchmark everyone cites and most people misunderstand

SWE-bench gives models real GitHub issues from real open-source projects and asks them to produce a patch that resolves the issue. It's the most-cited coding benchmark. It's also the most misunderstood.

SWE-bench does not test a model in isolation. Every submission runs inside an agent scaffold, a wrapper that provides tools, manages context, and orchestrates the model's actions. The score belongs to the model-plus-scaffold system, not the model alone.

How much does the scaffold matter? Look at the actual leaderboard data:

- Claude 4.5 Opus scores 79.20% in live-SWE-agent but 76.80% in mini-SWE-agent (high reasoning) and 74.40% in mini-SWE-agent (medium reasoning). Same model, nearly 5 points of swing just from scaffold and reasoning settings. ([SWE-bench Verified leaderboard](https://www.swebench.com/), scraped 2026-03-27)
- In Morph LLM's independent testing across 731 issues, Augment's Auggie, Cursor, and Claude Code all ran Opus 4.5 but scored 17 problems apart. "Same model, different scaffolding. The agent's architecture matters as much as the model underneath." ([Morph LLM](https://www.morphllm.com/ai-coding-agent))
- On Terminal-Bench, Claude Opus 4.6 ranks #33 in Claude Code but #5 in a different harness. Same model. Wildly different results. ([HumanLayer](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents))

As HumanLayer put it: "It's not a model problem. It's a configuration problem."

**SWE-bench does NOT tell you how Claude Code, Cursor, or Copilot will perform.** Those tools aren't on the SWE-bench leaderboard. They use different scaffolds, different prompting strategies, different tool sets.

### The benchmarks that actually matter

**FeatureBench** ([ICLR 2026](https://arxiv.org/abs/2602.10975)) tests end-to-end feature implementation across 24 repositories. The original FeatureBench paper tested Claude Opus 4.5 and found it scored 74.4% on SWE-bench Verified but only 11.0% on FeatureBench. That gap tells you how much SWE-bench overstates real-world capability.

**Terminal-Bench 2.0** is the closest thing to an agent-level benchmark. LangChain improved their Deep Agents CLI from 52.8% to 66.5% _without changing the model_. Just harness improvements. That 13.7-point jump is one of the strongest pieces of evidence that what surrounds the model matters as much as the model itself.

### The benchmark nobody has built yet

Nobody has built the benchmark developers actually need: take the same model and test it across Claude Code, Cursor, Codex CLI, Gemini CLI, and Aider on identical tasks. Until that exists, tool comparison is vibes, not data.

---

## The "model is commodity" thesis

Here's the most important idea in this article, and the one that frames the rest of this series:

**The model is becoming a commodity. The harness is the product.**

The evidence is overwhelming:

1. **Scaffold swings outweigh model differences.** On SWE-bench Verified, Claude 4.5 Opus swings from 74.40% to 79.20% depending on the scaffold. On Terminal-Bench, the same model jumps from #33 to #5 based on harness alone.

2. **LangChain proved it.** 13.7-point improvement on Terminal-Bench without changing the model. Only harness changes: system prompts, available tools, and middleware hooks.

3. **Models are converging.** In early 2024, there were huge gaps between GPT-4 and everything else. By 2026, Claude, GPT, Gemini, DeepSeek, and Qwen are all "good enough" for most coding tasks. The differences are real but narrow compared to the gap between a good harness and a bad one.

4. **Prices are collapsing.** GPT-4 cost $30/$60 per million tokens in 2023. GPT-5.4 costs $2.50/$15 in 2026, and GPT-5.4 mini is down to $0.75/$4.50. That's a 12-40x price drop in three years while capability skyrocketed. When the model is cheap, the value shifts to what surrounds it.

Even OpenAI agrees. Their harness engineering team wrote: "Early progress was slower than we expected, not because Codex was incapable, but because the environment was underspecified." The model maker is telling you the model isn't the bottleneck.

None of this means models don't matter. A better model raises the ceiling. Claude Opus with extended thinking produces different quality output than Gemini Flash. But a great model with a bad harness produces worse results than a good model with a great harness.

The analogy: the model is the engine. You wouldn't buy a car based on the engine alone. You'd want to know about the brakes, the steering, the safety systems, the navigation. In agentic coding, those things are the harness layer.

---

## What this means for you

If you're choosing an AI coding tool:

1. **Don't pick based on benchmarks alone.** SWE-bench scores don't tell you how a tool will perform in your workflow. The scaffold matters at least as much as the model.

2. **Think about your token budget.** DeepSeek at $0.28/1M input vs. Claude Opus at $5/1M is an 18x difference. For many tasks, the cheaper model is good enough.

3. **Consider model flexibility.** Tools that support multiple models let you match model to task. That flexibility might matter more than any single model's benchmark score.

4. **Watch the context window.** 1M tokens is standard now. But how the tool manages that context, what goes in, what gets compacted, what gets cached, is an agent-layer decision that dramatically affects quality.

---

## Next in the series

The model is just a token predictor. It can't do anything in the real world. So how does "predict the next token" turn into "read a file, run a test, fix a bug, commit the change"?

That's the agent layer. The execution loop, tool use, and context management that turn a stateless text generator into something that can actually write software. That's [Article 3: The Agent Layer](/pages/the-agent-layer).

---

## Sources

**Vendor Documentation & Pricing:**

- [Anthropic: Claude Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- [Anthropic: 1M Context GA for Opus 4.6 and Sonnet 4.6](https://claude.com/blog/1m-context-ga)
- [Anthropic: Building with Extended Thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Anthropic: Introducing Claude Opus 4.5](https://www.anthropic.com/news/claude-opus-4-5)
- [Anthropic: Quantifying Infrastructure Noise in Agentic Coding Evals](https://www.anthropic.com/engineering/infrastructure-noise)
- [OpenAI: API Pricing](https://openai.com/api/pricing/)
- [OpenAI: Introducing GPT-5.4](https://openai.com/index/introducing-gpt-5-4/)
- [OpenAI: Codex CLI Models](https://developers.openai.com/codex/models)
- [Google: Gemini 3.1 Pro](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-pro/)
- [Google: Gemini 3.1 Flash-Lite](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-flash-lite/)
- [Google: Gemini Developer API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [Meta: The Llama 4 Herd](https://ai.meta.com/blog/llama-4-multimodal-intelligence/)
- [DeepSeek: Models and Pricing](https://api-docs.deepseek.com/quick_start/pricing)

**Harness vs. Model:**

- [OpenAI: Harness Engineering](https://openai.com/index/harness-engineering/)
- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [HumanLayer: Skill Issue - Harness Engineering for Coding Agents](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [Morph LLM: We Tested 15 AI Coding Agents](https://www.morphllm.com/ai-coding-agent)

**Benchmarks:**

- [SWE-bench Official](https://www.swebench.com/)
- [SWE-bench Pro Paper](https://arxiv.org/html/2509.16941v1)
- [Terminal-Bench Official](https://www.tbench.ai/)
- [LangChain: Improving Deep Agents with Harness Engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
- [FeatureBench (ICLR 2026)](https://arxiv.org/abs/2602.10975)
- [Dissecting SWE-Bench Leaderboards](https://arxiv.org/html/2506.17208v2)

**LLM Fundamentals:**

- [Simon Willison: How Coding Agents Work](https://simonwillison.net/guides/agentic-engineering-patterns/how-coding-agents-work/)
- [Transformer Explainer (Georgia Tech)](https://poloclub.github.io/transformer-explainer/)

**Multi-Model & Routing:**

- [TensorZero: Reverse Engineering Cursor's LLM Client](https://www.tensorzero.com/blog/reverse-engineering-cursors-llm-client/)
- [IDC: The Future of AI Is Model Routing](https://www.idc.com/resource-center/blog/the-future-of-ai-is-model-routing/)

**Context Windows:**

- [Context Window Scaling: Does 200K Tokens Help?](https://dasroot.net/posts/2026/02/context-window-scaling-200k-tokens-help/)
- [Factory.ai: The Context Window Problem](https://factory.ai/news/context-window-problem)

**Industry Analysis:**

- [Simon Willison: 2025 - The Year in LLMs](https://simonwillison.net/2025/Dec/31/the-year-in-llms/)
- [Anthropic: 2026 Agentic Coding Trends Report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf)

**Full source compilation with extracted quotes and facts:** See `02-sources.md` in this directory.
