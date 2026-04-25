# Transcript-derived memory: the category nobody's writing about

A colleague at work built a tool called [session-kit](https://github.com/jstoobz/session-kit) that processes Claude Code session transcripts into durable memory artifacts. It's the cleverest pattern I've seen in months. It has 0 stars and 12 commits. Nobody is writing about this category.

This is the third post in a series on agent memory systems. The first covered repo-native (files in the repo). The second covered dedicated memory stores (the model decides what to remember during the conversation). This one covers the under-discussed third leg: processes that read conversation logs *after* the work is done and turn them into memory the next session can use.

If you've ever watched `/compact` happen in Claude Code and thought "I wish that summary survived to the next session, not just the next chunk of this one" — you're already thinking about transcript-derived memory.

## What "transcript-derived" actually means

A separate process — usually async, often LLM-powered — reads the conversation transcript and produces durable memory artifacts. The model in the live conversation is not the curator. The processing happens *after* the work is done (or before context compaction).

The boundary against dedicated memory stores is timing. Their writes happen *during* the conversation, with the same model that's helping you code. Transcript-derived writes happen *after*, with a separate process. Often a separate model.

The boundary against repo-native is what's being persisted. Repo-native is structured artifacts (specs, decision records, plans) that humans or agents wrote intentionally. Transcript-derived is extracted from conversation history that wasn't written for memory purposes — it's archaeology on the chat log.

## How it actually works

Three steps:

1. Conversation happens. Claude Code writes a transcript to disk.
2. A trigger fires — `PreCompact` hook, `Stop` hook, `SessionEnd` hook, or a cron job.
3. A process reads the transcript. Could be deterministic (rule-based extraction) or LLM-powered (a summarizer or "compiler"). Output gets written somewhere durable. Next session loads the durable output as part of its context.

Anthropic's hook system is the load-bearing infrastructure for most Claude-specific implementations. `PreCompact` and `SessionStart` receive JSON with `transcript_path`, `cwd`, trigger type. You point them at a script. The script does whatever you want.

The processing step is where the design decisions matter. A literal transcript dump is too much. A pure LLM summary loses fidelity. The good implementations are between those poles: extract specific signals (file edits, decisions, errors), summarize the rest, output something the next session can actually use.

## What it looks like in the wild

**session-kit** ([github.com/jstoobz/session-kit](https://github.com/jstoobz/session-kit)). My colleague's tool. Central archive at `~/.stoobz/`. Manifest.json as a searchable index. Sessions archived by project and date. The skill set is the load-bearing piece: `/prime` analyzes a repo and creates expert skills, `/park` ends the session and archives artifacts, `/pickup` resumes with prior context loaded, `/index` searches past sessions, `/relay` and `/handoff` generate different output formats. Memory artifacts include `TLDR.md`, `CONTEXT_FOR_NEXT_SESSION.md` (the "relay baton"), `INVESTIGATION_SUMMARY.md`, `HONE.md`, `RETRO.md`, `HANDOFF.md`. It's the most complete implementation of the pattern I've seen, and it's solo-developed with 0 stars. The category is genuinely under-discussed.

**Claude Code's autoDream** (unshipped per the source leak, but real). Anthropic's own answer to transcript-derived consolidation. Runs automatically when 24+ hours and 5+ sessions have passed. Four phases: Orient (scan memory directory), Gather Signal (search transcripts narrowly for user corrections, explicit saves, recurring themes, important decisions), Consolidate (merge into existing files, convert relative dates to absolute, remove contradictions, eliminate stale entries), Prune and Index (keep MEMORY.md under 200 lines). Read-only on project code, lock files prevent concurrent runs, runs in background. Observed performance: 913 sessions consolidated in ~8-9 minutes. This is what "transcript-derived done at platform scale" looks like.

**claude-mem.** Claude Code plugin. Hooks capture session transcripts. The agent SDK compresses them. Future sessions get progressive context injection — high-level overview first, deeper history on demand. Productized version of what most sophisticated Claude Code users end up building themselves.

**claude-memory-compiler** (coleam00). Hooks capture sessions. The agent SDK extracts decisions and lessons. An LLM "compiler" organizes everything into structured cross-referenced articles. The result reads like internal documentation rather than a chat log. Explicitly cites Karpathy's LLM Knowledge Base architecture as inspiration.

**claude-memory** (itsjwill). Auto-captures decisions, learnings, client info. Cloud backup to Supabase with syncing every 5 minutes. Semantic search via pgvector. Different tradeoff — cloud sync vs local-only.

**Custom session-end summarizers.** The folk pattern. Spawn `claude -p` as a subprocess at session end. Pass the transcript. Get back a markdown summary. Append to a journal file. Most sophisticated coders eventually build one.

## When it works

- Sessions are long and produce useful learnings. A two-hour debug session has signal worth extracting. A 5-minute query doesn't.
- You want to decouple "doing the work" from "recording the work." The model focused on coding shouldn't context-switch to write memory entries.
- You have hooks or automation infrastructure to run the summarizers reliably. Claude Code's hook system makes this trivial.
- Compaction is a regular event for you. Transcript-derived memory is "extend that summary's lifespan past the current session."
- You want a paper trail. Transcripts are durable. Summaries are derivative. Together you get both.

The strength against dedicated memory stores: no curation contamination. The summarizer is a fresh process. It doesn't accumulate biases the way long-running curated memory does.

## When it breaks

**Summary drift.** Each summary summarizes the previous summary. After N sessions, the memory is a Xerox of a Xerox. Detail vanishes. Opinions creep in. Some implementations re-process from raw transcripts every time to avoid this; most don't.

**Hallucinated structure.** The summarizer LLM imposes structure that wasn't in the conversation. "Decisions made" sections that include things you never decided. "Open questions" that you actually resolved. Always more confident than the underlying material warrants.

**Volume becomes the problem.** Run the summarizer over 100 sessions and you have 100 summaries. Now you need a memory system *for the memory*.

**Pipeline brittleness.** Hook fails silently. Subprocess hits a rate limit. Disk fills up. The agent has no idea any of this happened and confidently proceeds without the memory it expected.

**Cost.** Every session ends with another LLM call. For heavy users, that's not free.

**Over-engineering.** This category attracts maximalist architecture. Multi-stage pipelines. Custom DSLs for memory schemas. Most of it doesn't ship. The folk version (a `claude -p` subprocess at session end) outperforms most of the elaborate ones.

## How to pair it with other categories

Transcript-derived is great as a *feeder* into other categories:

- **Pair with repo-native as the destination.** The summarizer's output goes into `journal-N.md` or `progress.md`. The transcript is the source; the markdown file is the durable memory. Best of both worlds.
- **Pair with retrieval/RAG when summaries pile up.** Once you have 100+ session summaries, a vector index becomes useful. The summarizer fills the corpus; retrieval finds what's relevant later.
- **Skip pairing with dedicated memory stores.** Two curators (the in-session model and the post-session summarizer) produce memory that disagrees.

## The honest verdict

Transcript-derived is the most under-rated category. The implementations are real (claude-mem, claude-memory-compiler, session-kit, Anthropic's own autoDream). The pattern is well-supported by Anthropic's hook infrastructure. The failure modes are gentler than dedicated memory stores. The main reason it's under-discussed is that it doesn't have "memory product" branding the curated stores have. It's plumbing. Plumbing isn't sexy.

If you're a heavy Claude Code user with sessions that routinely hit compaction, set up a `PreCompact` hook that dumps the transcript and runs a summarizer that writes to a markdown file in your repo. Total setup: an afternoon. Total upside: your next session starts with real context from the previous one, every time, without you having to remember to write anything down.

If you're not a heavy user — short sessions, throwaway work — skip this category. The overhead isn't worth it.

Next post: retrieval / RAG. The category everyone reaches for first, and almost nobody should reach for first. The most discussed memory pattern in AI generally and the most over-applied to coding.

If you've built a session-end summarizer or `PreCompact` hook for your own workflow, what's in the prompt? The extraction prompt is where these systems live or die, and there's almost no public writing on what works.
