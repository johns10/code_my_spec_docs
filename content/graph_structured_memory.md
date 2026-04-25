# Graph and structured memory: the most ambitious category, the most vaporware

Karpathy posted a gist in April called "LLM Knowledge Base Architecture" and the entire AI coding industry tried to build the same thing in three weeks. Most of it is vaporware. Some of it is brilliant. None of it has won yet.

This is the fifth and final category post in a series on agent memory systems. The previous four covered repo-native (files in the repo), dedicated memory stores (purpose-built backends the model writes to), transcript-derived (process logs after the fact), and retrieval / RAG (embed and retrieve). This one covers memory stored as nodes and relationships, navigated rather than retrieved.

If you've ever looked at an Obsidian graph view and thought "I want my coding agent to think in this shape" — this category is for you. Whether you should actually use it is the question.

## What "graph / structured" actually means

Memory is stored as entities (nodes) connected by relationships (edges). Some implementations include temporal information — when did this fact become true, when was it ingested, when was it superseded. Navigation happens via traversal — "find all decisions related to this module" — rather than vector similarity.

The defining trait: structure is *load-bearing*. The shape of the memory matters as much as its contents. A retrieval system can return chunks in any order; a graph system returns paths.

The boundary against retrieval / RAG is how things are found. RAG asks "what's similar?" Graph asks "what's connected?" RAG returns top-k chunks by similarity. Graph returns subgraphs by traversal.

The boundary against repo-native is the role of structure. A markdown file with hyperlinks is technically a tiny graph. When the structure is the primary access path, you're in graph territory. When it's just navigation aid for humans, you're still in repo-native.

## How it actually works

Three operations matter. **Ingestion**: source material is processed to extract entities (people, projects, modules, decisions) and relationships. Usually LLM-powered. **Querying**: a query is mapped to graph operations — "find nodes of type Decision connected to a node named Authentication." Results returned as subgraphs, often serialized back to text. **Maintenance**: schema evolves, nodes get renamed, relationships get invalidated. Graphiti's bi-temporal model handles some of this with validity intervals on edges. Most implementations don't.

The interesting variations are in the schema. Letta's "memory blocks" are tiny structured memory with two canonical types. Graphiti is general-purpose with three subgraphs (episodic, semantic entities, communities). Karpathy's LLM-Wiki is essentially a manual-ish graph: 10-15 markdown wiki pages with cross-references plus a "Lint" operation that finds contradictions, stale claims, orphans, gaps.

The mechanism is impressive. The hard part isn't building the graph. It's keeping it accurate as the world changes.

## What it looks like in the wild

**Zep / Graphiti.** Temporal knowledge graph. Three subgraphs: episodic (raw messages, non-lossy), semantic entities, communities. Bi-temporal: tracks when an event occurred *and* when it was ingested. Edges have validity intervals. Old facts marked invalid, not deleted. Reports 94.8% on DMR (vs 93.4% MemGPT in their paper). Up to 18.5% accuracy improvement, 90% latency reduction over baselines. Most rigorous temporal-memory architecture in the space. Adoption is primarily in customer-facing agent apps; coding-specific use is rare.

**mem0 graph mode.** Optional graph layer on top of mem0's hybrid store. Auto-extracts entities and relationships. AWS published a reference architecture using mem0 + Neptune Analytics. For non-coding agents, real adoption.

**Basic Memory.** MCP server. AI writes markdown files with semantic content and `[[wiki-links]]`. Designed to coexist with Obsidian (same vault). The cleanest realization of "memory = files you can read in any editor" with graph traversal as the access pattern. Bridges repo-native and graph categories.

**Karpathy's LLM-Wiki gist.** Three operations: Ingest (process source → 10-15 markdown wiki pages with cross-refs), Query (answer + file good answers back as new pages), Lint (find contradictions, stale claims, orphans, gaps). The most influential graph framing of 2026 by a wide margin. Not a product — a gist. Multiple third-party tools released in March-April cite it as inspiration.

**Self-evolving knowledge base plugins.** Multiple competing implementations launched in the weeks after Karpathy's April 4 gist. The pattern: compact each conversation into an "episode," extract structured facts and entities with timestamps, mark superseded facts on contradiction. Top comment on one launch thread: "everyone reinvented episodic memory with a JSON store and a contradiction flag, called it self-evolving." Hype-to-traction ratio is unusually high in this corner.

**Aider's repo map (worth mentioning).** Tree-sitter builds a dependency graph. Graph-rank scores files by importance. Returns top-N within a token budget. Structurally a graph; functionally a retrieval scorer. Important to understand because it shows what graph-shaped memory looks like when applied to code specifically.

## When it works

- The domain has explicit entities and relationships. People, projects, decisions, modules, customers, tickets. If you can sketch the schema on a whiteboard, the domain might fit. If your sketch is just "things and other things," it probably doesn't.
- Temporal correctness matters. "What did we decide six weeks ago?" "When did this fact become true?" Graphiti's bi-temporal model is the right shape.
- Queries are graph-shaped. "Who decided X, and when?" "What modules depend on this one?" These are traversal queries.
- Schema decisions are durable. If you can commit to a schema and not change it every two months, graph memory pays back the build cost.
- You have a graph DB or are willing to run one. Neo4j, FalkorDB, Memgraph.

The use case where this category clearly wins: customer-facing agents that need to remember complex relationship state over time (banking, healthcare, support). Graphiti is the strongest tool for that shape.

## When it breaks

**Schema-fit problems.** The schema you designed in week 1 doesn't match the queries you actually need in week 12. Migration is real engineering. Most teams ship a v1 schema and then patch around its limitations forever.

**Rename and refactor invalidate IDs.** A function gets renamed. A module gets restructured. The graph still has the old node IDs. Queries return phantom results. Cleanup is manual.

**Graph rot.** The most common failure mode. Nobody updates relationships when code changes. Edges become wrong. Traversal returns lies. The graph still answers queries — confidently, with full topology — but the answers are stale.

**Maintenance becomes the bottleneck.** "We need to update the graph" gets added to every PR description. People stop doing it. The graph drifts. By month six, querying it is no better than reading the codebase.

**The graph DB is overkill.** Your schema turns out to be three node types and two edge types. You could have stored that in three Postgres tables.

**Coding-specific weakness.** Code already has graph structure (call graphs, dependency graphs, module graphs). Tools like Aider derive that structure on demand. Maintaining a separate knowledge graph that duplicates it is pure overhead. The exception is decision and history graphs ("when did we decide this?") which the codebase itself doesn't capture.

**The "self-evolving" trap.** The systems that promise the graph maintains itself usually mean "an LLM updates it." Which means the graph is wrong in subtle, confidently-stated ways the moment the LLM hallucinates a relationship.

## How to pair it with other categories

Graph is most useful as a specialized layer for graph-shaped queries, with simpler memory underneath:

- **Pair with repo-native for the project-scoped stuff.** Don't put your spec or architecture decisions in the graph. They go in markdown files. The graph holds *relationships between* the markdown artifacts when you actually need to traverse them.
- **Pair with retrieval for the unstructured corpus.** mem0's hybrid mode (vector + graph) is a credible model. Vector handles "find me docs like this." Graph handles "what entities are related to this."
- **Pair with transcript-derived as the ingestion pipeline.** Conversations get summarized; summaries get parsed for entities and relationships; the graph absorbs the structured facts. Don't try to ingest raw conversation directly into a graph — too noisy.
- **Skip pairing with dedicated memory stores.** Two systems both deciding "what's important to remember" produce inconsistent state.

## The honest verdict

For coding work specifically, I haven't found a graph-based memory system that earns its complexity. The exception is Aider's repo map, which uses graph structure for retrieval scoring rather than as a memory store — a clever pattern that doesn't require maintaining a separate graph.

For non-coding agents that genuinely have entity-relationship state worth tracking — customer-facing chatbots in banking, healthcare, support — Graphiti is the strongest tool I've seen. The bi-temporal model is the differentiator: it doesn't just remember what's true, it remembers when each thing became true and when each thing was learned.

For the broader "self-evolving knowledge base" category that exploded after Karpathy's gist: most of it is vaporware. The best implementations are essentially Karpathy's three operations productized in slightly different ways. The Lint operation is the most under-appreciated piece — most products implement Ingest and Query and skip the operation that catches contradictions and stale claims. That's why most graphs rot.

If you're tempted by graph-based memory, ask yourself: is your domain genuinely graph-shaped, or do you just like graph databases? The honest answer determines whether this category is the right shape for you.

This is the last category post. The next post is the flagship — a synthesis that makes the case for one of these categories as the boring, durable, winning answer for coding specifically. If you've been reading along, you can probably guess which one. The argument is sharper than the guess implies.

If you're using a graph-based memory system in production for coding work specifically and it's actually paying back the maintenance cost, I want to hear it. The case has to be made; the data hasn't made it on its own.
