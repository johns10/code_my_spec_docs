# Dedicated memory stores: the category with the most marketing and the messiest tradeoffs

[MemPalace](https://github.com/mempalace/mempalace/stargazers) has 49.6k stars on GitHub. mem0 powers production agents at AWS. Letta has the cleanest abstraction for agent-managed memory in the OSS world. They're all impressive. I tried them. I went back to markdown.

This is the second post in a series on agent memory systems. The first covered repo-native — files in the repo, no infrastructure. This one covers the category with the most VC money, the most papers, the most blog posts, and the most subtle failure modes: dedicated memory backends where the model writes for you.

## What "dedicated memory stores" actually means

Memory lives in a purpose-built backend — a vector DB, a graph DB, a hosted cloud service, or a structured local store — that's separate from your project's working tree. The model writes to it. The model (or a retrieval layer) reads from it.

The defining trait isn't who writes the memory. It's where the memory lives: a dedicated system, not a markdown file in your repo. Both repo-native and dedicated stores can have the agent as curator. The distinguishing feature is the backend.

Triggers for writes vary. Cadence-based: every N turns the model is prompted to extract and persist key facts (MemPalace defaults to roughly every 15). Session-end: a summarizer runs when the conversation closes. On-demand: the user says "remember X" and the model writes it. Heuristic: the model decides on its own.

The boundary against transcript-derived (next post) is timing: dedicated-store writes happen *during* the conversation. Transcript-derived processes the log *after*.

The boundary against retrieval / RAG is who decides what gets stored. Dedicated stores have intentional writes (the agent or user decides what's worth keeping). RAG indexes everything and decides relevance at query time.

## How it actually works

Most systems run some version of this loop:

1. Conversation happens.
2. Trigger fires.
3. The model is prompted to extract key facts, decisions, preferences.
4. Extracted memory is written to the store, often after de-duplication or contradiction-checking.
5. Next conversation: relevant memory chunks are surfaced into the system prompt or context.

The interesting variation is in surfacing. ChatGPT's consumer memory injects a summary into the system prompt every conversation. Cursor's Memories injects only when the model decides a memory is relevant. mem0 runs hierarchical retrieval at the user/session/agent level.

The mechanism is impressive on paper. The hard part isn't writing or retrieval. It's curation quality: did the model save something worth saving, and will it surface it at the right moment in a future conversation?

## What it looks like in the wild

**MemPalace** (49.6k stars). Created by Milla Jovovich and developer Ben Sigman, released April 5, 2026. The "memory palace" metaphor — Wings (people/projects) → Rooms (topics) → Halls (memory types) → Drawers (verbatim originals) — is more marketing than mechanism. Under the hood it's structured RAG over verbatim conversation history with a temporal entity-relationship graph in SQLite. ChromaDB for embeddings. Two Claude Code hooks save periodically and before compaction.

Reports 96.6% recall at R@5 on LongMemEval (their own measurement). And here's the part nobody quotes: Jamie Lord's independent evaluation found "raw ChromaDB was the strongest configuration, with every MemPalace-specific mode scoring lower." The palace metaphor added zero measurable benefit over raw vector search. The value proposition is local embeddings + ChromaDB, not the architecture. Worth knowing before you commit.

**mem0**. The most production-deployed agent-memory layer outside coding. Hybrid store: vector + optional graph + key-value. Hierarchical at user/session/agent. Auto-extracts and summarizes. Claims ~26% accuracy lift over OpenAI native memory on LOCOMO. AWS published a reference architecture using mem0 + ElastiCache + Neptune Analytics. For coding specifically, less common — most coders prefer file-based.

**Letta** (formerly MemGPT). Memory blocks attach and detach from agents. Two canonical blocks: Human (user facts) and Persona (agent self-concept). Self-editing via tools. The cleanest abstraction in the space; influences other tools (OpenCode plugins explicitly cite Letta).

**Cursor Memories.** Auto-generated from Chat. Project-scoped. Requires user approval before save. Requires privacy mode off. Stored in Cursor's cloud. Removed and reintroduced after the original version had issues. The privacy-mode requirement is a real adoption blocker for enterprise.

**Windsurf Cascade Memories.** Auto-generated, stored locally in `~/.codeium/windsurf/memories/`. Workspace-scoped. Doesn't consume credits. Cleaner separation of "memory" (what I learned) vs "rules" (what I require) than Cursor.

**GitHub Copilot Memory.** Server-side, GitHub-hosted, shared across Copilot surfaces. Memories auto-expire after 28 days unless re-validated. The only major vendor with explicit expiry — they're implicitly acknowledging "stale memory" is the headline failure mode for this category.

**Minolith.** Hosted API with 19 entry types (rule, decision, warning, pattern, event, workflow). Priority/scope/tag filtering. Structured retrieval instead of semantic search. Bootstrap endpoint returns agent identity + high-priority context + active progress in one call. Different shape from the others — explicitly structured, not embedding-based.

**Codex `~/.codex/memories`.** Younger feature, 32 KiB cap. Few people seem to be using `/m_update` actively yet.

## When it works

- You're building a chatbot, assistant, or customer-facing agent where users expect "the system knows me." mem0 is purpose-built for this.
- Cross-session continuity matters but you don't want memory in git.
- You stay in one vendor's ecosystem. The ecosystem boundary is the cost.
- You trust the model's curation judgment for your domain. Some domains are easy to extract from. Some are not.

## When it breaks

The failure modes are well-documented, just not in the marketing copy.

**Contamination.** One bad memory ("user wants single-quote strings") survives forever and corrupts every future session. The agent confidently writes single-quotes even when the project's style guide says double. You spend an afternoon figuring out which entry is poisoning your sessions.

**Opacity.** You can't always tell what's in the memory. ChatGPT's "saved memories" UI is decent; most others are worse. When the agent does something weird, "is that the system prompt, the rules, or a memory entry I forgot about?" becomes a real debugging question.

**Vendor lock-in.** Cursor Memories don't migrate to Codex. ChatGPT memory doesn't migrate to Claude. The OSS systems port between models, but the operational story is "set up your own infrastructure" — not free.

**Storage limits.** Codex caps at 32 KiB. Copilot expires after 28 days. Cursor's privacy-mode requirement blocks enterprise users. Each vendor has policy you have to work around.

**Curation drift.** What the model decided to save in January isn't what you'd want it to save now. Most systems don't have a great "review what's stored" UX.

**Hallucinated memory.** The model writes a memory entry that sounds plausible but doesn't reflect anything that actually happened. The memory becomes the source of truth even when it's wrong.

## How to pair it with other categories

If you're using these for coding work:

- **Pair with repo-native for the project-scoped stuff.** Vendor memory should hold cross-project preferences. Project knowledge belongs in `CLAUDE.md` or the spec tree.
- **Pair with transcript-derived as a quality check.** A post-hoc process can catch contamination the in-session curator missed.
- **Don't pair with retrieval/RAG over the same content.** Two systems that both decide "what's relevant" disagree at the worst moments.

## The honest verdict

For non-coding agents — customer-facing chatbots, personal assistants, SaaS products that learn user preferences — dedicated memory stores are real infrastructure. mem0 and Letta are the strongest OSS options.

For coding specifically, I find this category disappointing in proportion to the marketing. MemPalace is technically impressive, but Jamie Lord's evaluation showed raw ChromaDB outperforms every MemPalace-specific mode — meaning the palace architecture is paying for itself in marketing copy, not retrieval quality. Cursor Memories solves a small slice ("remember my style") for users who live entirely in Cursor. The rest of the time, the failure modes outweigh the convenience.

The reason coders keep returning to repo-native isn't that they're afraid of infrastructure. It's that the maintenance cost of a dedicated memory store rarely pays back for a single project. If you're a vendor building a multi-tenant agent product, this is your category. If you're a developer trying to make Claude Code remember what you decided last week, write it down in a markdown file.

Next post: transcript-derived. The under-discussed category. Decouples writing from chatting and avoids the contamination problem dedicated stores have.

If you've used MemPalace, mem0, or Letta in production for coding specifically, what did you learn? I want to be wrong about this category for coding workflows; the data hasn't convinced me yet.
