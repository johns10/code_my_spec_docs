# It's not memory if you wrote it: the CLAUDE.md confusion

The [most-starred "memory system" in AI coding](https://github.com/forrestchang/andrej-karpathy-skills/stargazers) right now is `forrestchang/andrej-karpathy-skills`. 87k+ stars as of today. It's a single CLAUDE.md file. It's not a memory system. It's four prescriptive principles for how Claude Code should behave: think before coding, simplicity first, surgical changes, goal-driven execution.

People keep calling it memory. It's not. And the conflation is causing real problems — wrong tool choices, wasted infrastructure, six-figure VC bets on the wrong category boundary.

This is the flagship piece in a series on agent memory systems. Five posts follow this one, each covering a real category. Before any of them are useful, you need the distinction this post makes: **operating instructions are not memory.** They look similar from the outside (both are markdown files the agent reads). They solve completely different problems. When you don't see the difference, you reach for the wrong tool.

## Operating instructions vs memory

The defining trait of memory: information that **accumulates from interaction over time.** Episodic, what happened. Semantic, what's true now. Memory updates because something changed.

The defining trait of operating instructions: rules **prescribed upfront.** "Use 4-space indentation." "Never use em dashes in user-facing copy." "Write tests before implementation." Operating instructions don't accumulate from interaction. They're written by you or your team, and they describe how the agent should behave in general.

Direction of information flow tells you which is which:

- **Operating instructions:** human → agent. "Here's how to behave."
- **Memory:** agent or world → store. "Here's what happened, here's what's true now."

CLAUDE.md, AGENTS.md, `.cursor/rules`, `.windsurfrules`, GitHub Copilot's `.github/copilot-instructions.md`, Kiro steering files, Cline's custom instructions: all operating instructions. All prescriptive. All written upfront. None of them accumulate from interaction.

What's striking is the convergence. Anthropic, OpenAI, GitHub, Cursor, Windsurf, AWS Kiro — every major coding-tool vendor independently arrived at the same artifact: markdown files in the repo containing prescriptive rules. The names differ. The file lives in the project. The model loads it at session start. That convergence is itself the argument: this artifact is necessary, and it isn't memory.

Real memory in coding tools looks different. Cline's "Memory Bank" pattern — `activeContext.md`, `decisionLog.md`, `progress.md` — accumulates from interaction. The agent writes those files based on what's happening. Doug's `journal-N.md` pattern is append-only and timestamped, with the agent recording each session's decisions. Claude Code's auto-memory writes to `~/.claude/projects/<project>/memory/` based on user corrections and discovered patterns. Those are memory.

## Why the confusion costs you

I've watched developers spend weekends installing MemPalace because "the agent keeps forgetting things." Their actual problem was a 12-line CLAUDE.md that didn't tell the agent what mattered. They needed operating instructions; they reached for memory infrastructure. Three days later they had a vector store running and the agent still didn't know to use pnpm instead of npm.

The reverse happens too. I've watched developers maintain 800-line CLAUDE.md files trying to make the agent "remember" decisions from the last session. CLAUDE.md doesn't remember anything. It just gets read at session start. They needed memory; they kept stuffing more rules into the operating-instructions file. Eventually adherence dropped because the file got too long. ETH Zurich research found that big context files actually reduce task success rates compared to no context at all — more instructions equals less room for actual thinking.

When you don't see the distinction, you can't pick the right tool. You can't even diagnose which problem you have.

The 87k-star data point matters because it's evidence that the community is voting with attention for the operating-instructions artifact (CLAUDE.md), not the memory infrastructure ([MemPalace at 49.6k stars](https://github.com/mempalace/mempalace/stargazers); mem0 at lower; Letta at lower). The strongest signal in the space is the one almost nobody's reading correctly: people are reaching for the simple thing that works for the prescriptive problem. They're separately, often confusedly, reaching for memory infrastructure to solve a different problem.

## The five categories of actual memory

Memory — the stuff that accumulates from interaction — comes in five distinguishable categories. Each gets its own deep post in this series. Brief tour:

**1. [Repo-native memory](/blog/repo-native-memory).** State persisted as files in the project's working tree. Cline Memory Bank, Doug's journal pattern, ADRs, Claude Code's auto-memory directory. The pattern that wins for coding specifically. Boring, durable, vendor-portable.

**2. [Dedicated memory stores](/blog/dedicated-memory-stores).** Memory lives in a purpose-built backend (vector DB, vendor cloud, structured local store) that the model writes to. MemPalace, mem0, Letta, ChatGPT memory, Cursor Memories, Windsurf Cascade Memories, GitHub Copilot Memory. Best for non-coding agents — chatbots, customer support, personal assistants. For coding, the contamination and opacity failure modes outweigh the convenience.

**3. [Transcript-derived](/blog/transcript-derived-memory).** Process conversation logs after the fact to extract durable memory. Claude Code's PreCompact hooks, claude-mem, claude-memory-compiler, my colleague's [session-kit](https://github.com/jstoobz/session-kit), Anthropic's own autoDream consolidation daemon. The under-discussed category. Pairs beautifully with repo-native as a feeder.

**4. [Retrieval / RAG](/blog/retrieval-rag-memory).** Embed everything, retrieve top-k by similarity at query time. The category academics love. Over-applied to coding, where most context isn't a search problem. Right tool for huge unstructured corpora. Wrong tool for "what's in this file right now."

**5. [Graph / structured](/blog/graph-structured-memory).** Memory as nodes and relationships, navigated via traversal. Zep / Graphiti, mem0 graph mode, Karpathy's LLM-Wiki framing. The most architecturally ambitious category. Genuinely useful when the domain has explicit entities and relationships (banking, healthcare, support). Mostly vaporware in the coding-specific corner that exploded after Karpathy's April 4 gist.

These are the five categories. Three is too coarse — collapsing transcript-derived into dedicated stores hides a real failure-mode difference. Six is dilution. Five with sharp boundaries is the right shape.

## What I actually use

Repo-native as the foundation. Transcript-derived as a feeder. Occasional vendor-specific stuff for cross-project preferences. That's the stack.

For CodeMySpec the foundation is the `.code_my_spec/` tree — specs, status files, decisions, knowledge, all markdown, all version-controlled. The agent reads it on demand via skills and slash commands. The feeders are PreCompact-style hooks that dump session signals into the tree. Cross-project preferences (style, tooling, conventions that aren't project-specific) live in `~/.claude/CLAUDE.md` as operating instructions, not in any dedicated memory store.

I tried four memory systems before landing here. I burned a weekend on MemPalace. I half-built a custom claude-mem setup. I deployed mem0 with embeddings I never finished tuning. Each became its own maintenance project. Each disappointed in the specific way it was supposed to win. The boring answer — files in the repo — kept producing better results.

The reason isn't that infrastructure is bad. It's that the maintenance cost of dedicated memory systems rarely pays back for a single coding project. The math changes if you're a vendor building a multi-tenant agent product, or running a customer-facing chatbot, or working across many projects with shared learning needs. For most coding work, it doesn't.

## How to pick

Three questions get you most of the way there:

**1. Does the work live in a repo?** If yes, default to repo-native. If no — you're building a customer-service agent, a personal assistant, anything where the work isn't code in version control — default to dedicated memory stores and skip to question 3.

**2. Are your sessions long enough that you regularly hit context compaction?** If yes, add transcript-derived as a feeder. A `PreCompact` hook that dumps the session into a markdown file is a one-afternoon setup with a permanent payoff.

**3. Do you have a search problem (large unstructured corpus, fuzzy queries) or a relationship problem (explicit entities and connections that matter)?** If neither, you don't need retrieval or graph. If a search problem and the corpus is genuinely large, retrieval pays off — tune it seriously. If a relationship problem and the schema is durable, graph pays off — but verify the schema fit before committing.

Default order to consider: repo-native first. Add transcript-derived if sessions are long. Add dedicated memory stores only for cross-project preferences. Add retrieval only if you have a search problem. Add graph only if you have a relationship problem.

Most coding setups never need anything beyond the first two.

## What's in the rest of the series

Each category gets one post. Each names real implementations, surfaces honest failure modes, and ends with a recommendation about when to use it (or not).

- [Post 1: Repo-native memory: the boring answer that wins](/blog/repo-native-memory) — Cline Memory Bank, Doug's journal, Claude Code's auto-memory, the 59-compactions story, Jamie Lord's "80% covered by Claude defaults" finding. The category I use.
- [Post 2: Dedicated memory stores: the category with the most marketing and the messiest tradeoffs](/blog/dedicated-memory-stores) — MemPalace, mem0, Letta, vendor offerings, and Jamie Lord's evaluation showing raw ChromaDB outperforms every MemPalace-specific mode. Honest about contamination, vendor lock-in, and curation drift.
- [Post 3: Transcript-derived memory: the category nobody's writing about](/blog/transcript-derived-memory) — claude-mem, claude-memory-compiler, session-kit, autoDream. The under-discussed third leg. Pairs with everything.
- [Post 4: Retrieval and RAG: the category everyone reaches for first](/blog/retrieval-rag-memory) — Cursor semantic search, Hindsight, Aider's repo map. When it works (huge corpora). When it breaks (silently wrong retrieval, semantic distance ≠ relevance, context rot).
- [Post 5: Graph and structured memory: the most ambitious category, the most vaporware](/blog/graph-structured-memory) — Zep / Graphiti, mem0 graph mode, Karpathy's LLM-Wiki, the self-evolving-knowledge-base trap. Real wins for relationship-shaped domains. Mostly hype for coding.

Read in any order. The category that matters for you is the one that fits the question you actually have.

What's your stack? Are you running operating instructions and confused about why they don't accumulate? Or running memory infrastructure and confused about why it doesn't enforce rules? The conflation is the source of most "agent memory doesn't work" complaints I've seen this year.
