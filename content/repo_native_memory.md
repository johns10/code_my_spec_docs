# Repo-native memory: the boring answer that wins

I've tried four memory systems for Claude Code in the last six months. The one that actually works is a directory of markdown files in my repo.

I've burned weekends on MemPalace, on a custom claude-mem setup, on a half-built mem0 deployment with embeddings I never finished tuning. Each one promised "your agent will finally remember." Each one became its own maintenance project. Meanwhile, the agent that pairs with me every day reads and writes plain markdown files in `.code_my_spec/`, and it remembers everything that matters.

This is the first post in a series on agent memory systems. I'm starting with the category I use because it has the least mystique and the most evidence.

## What "repo-native memory" actually means

Memory that lives as files in the project's working tree. Markdown, plain text. Version-controlled. Loaded into context at session start or fetched on demand.

Two boundaries worth being precise about.

**It's not the same as `CLAUDE.md` or `AGENTS.md`.** Those are operating instructions — prescriptive, written upfront, don't accumulate from interaction. CLAUDE.md tells the agent how to behave; memory tells it what happened. Different artifact, different purpose. (Full argument in the flagship piece.)

**It's not the same as repo-native retrieval** like Aider's tree-sitter repo map. Those re-derive structure from code each session. Repo-native memory is durable state.

What counts: Cline / Roo "Memory Bank" patterns (`activeContext.md`, `decisionLog.md`, `progress.md`). Doug's `journal-N.md` pattern. ADRs and the newer Agent Decision Records. Hypercubed's git loop on r/ChatGPTCoding. The whole `.code_my_spec/` tree we use on CodeMySpec.

What also counts, and most people don't realize this: **Claude Code's own auto memory is repo-native.** The March 31 source leak revealed a three-layer architecture — in-context, external file (`MEMORY.md`), structural project (`CLAUDE.md`). Auto memory writes to `~/.claude/projects/<project>/memory/` as plain markdown. Topic files load on demand. There's even an unshipped consolidation daemon called autoDream that processes transcripts into the markdown files while you sleep. Anthropic's own answer to "where should memory live" is files in a directory.

## How it actually works

There's no infrastructure. That's the point.

The agent reads the repo at session start. It writes back into the same files when something happens worth remembering. Git tracks the changes. Diffs are reviewable. Bad memory is `git revert`. Good memory is the same content next session and the session after that.

The Cline Memory Bank pattern is the most explicit example. Five canonical files. The agent reads them in a defined order. After significant work, the agent updates `activeContext.md` (what we're working on now) and `progress.md` (what's done). `decisionLog.md` accumulates choices. `systemPatterns.md` documents conventions.

Doug's journal pattern is even simpler. One file per session. Append-only. The agent writes ISO-timestamped entries: command + actual output, files edited and why, hypotheses + outcomes, dead ends + reasons. Doug found the imperative tone matters — "consider keeping a journal" gets skipped; "keep a journal" doesn't.

In both cases, the storage is the working tree. The retrieval is `cat` or the agent's file-read tool. The schema is "humans can read this." That's the whole stack.

## What it looks like in the wild

**Cline Memory Bank.** Cline's official blog endorses it. The `activeContext / decisionLog / productContext / progress / systemPatterns` shape has been ported to Roo Code, Cursor variants, and Cascade. It's becoming a folk standard.

**Doug's journal post on doug.sh.** Pulled 73 upvotes on r/ClaudeAI with the comment "more useful than any 'memory system' I've tried."

**Karpathy's LLM-Wiki gist.** Three operations: Ingest, Query, Lint. Markdown wiki between LLM and raw sources. Multiple third-party tools released in March-April 2026 cite this gist as inspiration.

**Mission.md pattern.** A user with 3,500+ sessions documented this on GitHub: a single `mission.md` briefing — "what's done, what's next, what's blocked" — beats trying to remember everything. Memory files get `type` and `description` frontmatter for relevance filtering.

**The 59-compactions story.** GitHub issue #34556. One power user, 12-18 hours/day, 26 days, 59 compactions. Built a complete 3-tier system because the platform doesn't ship one: L1 `MEMORY.md` (~100 lines, always loaded), L2 topic files (loaded on demand), L3 vault (~200 files including 127 conversation narratives, a 1,477-line changelog). Token cost: ~3,100 tokens per session just to reload. Real pain, real solution, all in markdown files.

**CodeMySpec's `.code_my_spec/` tree.** What I use. Specs, status files, decisions, knowledge — markdown, in the repo, loaded by the agent on demand via skills and slash commands. I'm biased about this one, but the bias was earned by trying the alternatives first.

Jamie Lord, who's done more honest evaluation than anyone in this space, said it straight: "Native CLAUDE.md, auto memory, plan mode, hooks, and skills cover roughly 80% of what third-party memory and planning tools promise."

## When it works

- The work lives in the repo. Coding fits. Customer support doesn't.
- You want vendor portability. Markdown works in Claude Code, Cursor, Codex, Windsurf, OpenCode. And in Notepad.
- You want auditability. Git diff is the audit log.
- The team can read what's written. So can your future self.
- Long-horizon projects. A two-month project benefits from durable state. A throwaway script doesn't.

The headline data point: the [most-starred "memory artifact" in the AI coding landscape](https://github.com/forrestchang/andrej-karpathy-skills/stargazers) is `forrestchang/andrej-karpathy-skills` at 87k+ stars (as of 2026-04-25) — a single CLAUDE.md file. (It's actually operating instructions, not memory, which is the whole flagship argument. The point holds: the dominant pattern by community attention is files in the repo, not infrastructure.) [MemPalace](https://github.com/mempalace/mempalace/stargazers), the most-marketed dedicated memory system, sits at 49.6k by comparison.

## When it breaks

I'd be lying if I said this scales infinitely.

- **Cross-project memory.** Lives in one repo. If your agent works across many projects and you want shared learning, this isn't it.
- **Non-code domains.** No repo, no memory.
- **File bloat.** Loading everything into context every session gets expensive fast. Chroma's [context rot research](https://www.trychroma.com/research/context-rot) shows quality degrades as input length grows even within nominal context limits.
- **Discipline lapses.** If the agent stops updating the journal, files get stale. Stale files are worse than no files because the agent confidently follows them.
- **Truly novel work.** Prior memory doesn't help when you're doing something for the first time.

The failure mode worth naming explicitly: rot. Files describe how the codebase used to work. Agent confidently follows stale guidance. Six months in, you've quietly accumulated a memory bank that's lying to you.

## How to pair it with other categories

Repo-native works best as a foundation, with selective use of other categories on top:

- **Pair with transcript-derived processing** to keep the journal fresh. A `PreCompact` hook dumps the session into a markdown file before context compaction. The journal writes itself.
- **Pair with retrieval/RAG** for the long tail. If you have 200 spec files, you load an index and retrieve specifics. Aider's repo map is a low-tech version of this idea.
- **Pair sparingly with dedicated memory stores.** Vendor memory features can capture cross-project preferences ("I use 4-space indentation"). Project-scoped knowledge belongs in the repo.
- **Skip graph/structured for most projects.** Unless you genuinely have a graph-shaped problem, the maintenance cost of a knowledge graph isn't worth the marginal precision.

## The honest verdict

Use repo-native if you're doing serious coding work in a single repo over weeks or months and you want the simplest pattern that survives vendor churn. The Cline Memory Bank shape is a great starting template. Doug's journal pattern is the simplest credible version. Pick one, commit to writing in it for a week, see if your agent's coherence improves.

Don't use it as your only memory if you're doing customer-facing chatbot work, multi-project agent infrastructure, or anything where the work doesn't live in version control.

The reason this pattern keeps winning, despite being unglamorous, is that the alternatives keep losing in the specific way they were supposed to win. Vector retrieval misses obvious context. Dedicated memory stores accumulate contamination. Graph databases become their own maintenance project. A markdown file the agent reads on Monday is the same markdown file the agent reads on Friday.

Next post: dedicated memory stores. The category that gets the most marketing and has the messiest tradeoffs. Spoiler — I tried four of them and went back to markdown.

What's your stack? Repo-native already, or are you still chasing infrastructure?
