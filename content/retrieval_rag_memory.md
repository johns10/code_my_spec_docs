# Retrieval and RAG: the category everyone reaches for first

Every time someone asks me about agent memory, the first thing they ask is "should I set up RAG?" The answer is almost always no.

This is the fourth post in a series on agent memory systems. So far we've covered repo-native (files in the repo), dedicated memory stores (purpose-built backends the model writes to), and transcript-derived (process logs after the fact). This post covers the category with the most academic mindshare, the most vendor pitches, and the most over-application to coding specifically: retrieval-augmented generation.

If you're confused about why your RAG-based memory keeps surfacing the wrong context at the wrong moment, this one is for you.

## What "retrieval / RAG" actually means

The memory store is a corpus of documents (or conversation chunks, or code snippets) that have been embedded into a vector space. At query time, the user's question (or the agent's current context) is embedded the same way. The system finds the top-k most similar chunks. Those chunks are injected into the model's context as "relevant memory."

The defining trait: memory is consulted *reactively*. It's not loaded by default. It's fetched on each query based on similarity to whatever is happening right now.

The boundary against repo-native is loading vs retrieving. A `CLAUDE.md` is loaded — it's there, in the system prompt, every session. A vector store is retrieved — it's somewhere, accessed only when a query semantically matches.

The boundary against dedicated memory stores is what gets stored vs how things are found. Dedicated stores have intentional writes (the agent or user decides what's worth keeping); retrieval-based systems index everything and answer "what's similar to this query?" Many production systems do both.

What counts: vector databases (Pinecone, Weaviate, Chroma, pgvector). Cursor's codebase semantic search. Claude Projects' file uploads. mem0 in vector mode. MemPalace's verbatim-text + ChromaDB index. Hindsight's parallel-strategy retrieval. LlamaIndex's `VectorMemory`. Aider's tree-sitter repo map (a *structural* retrieval — not vector — solving the same problem).

## How it actually works

Three steps. Indexing: documents split into chunks, each chunk embedded, vectors written to the store with metadata. Querying: current query embedded, store returns top-k by cosine or dot-product similarity, often a reranker rescores. Injection: retrieved chunks inserted into the model's context.

Real systems add complexity: hybrid search (vector + keyword), entity extraction, temporal weighting, retrieval-time filtering. Production-grade systems like Hindsight run four parallel retrieval strategies and rerank the union.

The mechanism is well-understood. The hard part isn't running the pipeline. It's making the retrieved chunks be the right ones.

## What it looks like in the wild

**Cursor's codebase semantic search.** Vector index over your repository. Works well for "where is the login handler defined?" Works poorly for "what was the rationale behind this pattern?" because rationale isn't in the code.

**Claude Projects with file uploads.** Functional for reference docs. Frustrating when document structure is load-bearing — chunked retrieval shreds it.

**mem0 in vector mode.** Production-deployed at AWS scale. For coding specifically, the vector mode is the one most coders try first and the one with the most subtle quality issues.

**MemPalace** as a hybrid example. Verbatim conversation history, ChromaDB index, structured "memory palace" metaphor on top. The retrieval is real RAG; the metaphor is presentation. Jamie Lord's evaluation found raw ChromaDB outperformed every MemPalace-specific mode — the value is the local embeddings, not the architecture.

**Hindsight (Vectorize).** Four parallel retrieval strategies (semantic, BM25, entity-graph traversal, temporal filter) reranked with a cross-encoder. The serious version of "make retrieval actually work." Built-in MCP server. Lower mindshare than MemPalace, technically more sophisticated.

**Aider's repo map.** Tree-sitter parses the codebase. Graph-rank scores files by importance. Top-N files (default 1k tokens) get included. This is *structural retrieval* — not vector — but it solves the same problem with a different shape. One of the most under-rated patterns in the space.

## When it works

- The corpus is large. Hundreds, thousands, hundreds of thousands of documents. You can't load it all into context. Retrieval is the only option.
- Queries are well-formed and topic-specific. "How does the OAuth flow work?" maps cleanly to specific documents. "Why did we make this decision?" doesn't.
- You have time to tune. Retrieval quality depends on chunking, embedding model, reranker, query rewriting. None of this is set-and-forget.
- Latency budget allows. Each query requires an embedding call, a vector lookup, often a rerank.
- Approximate is good enough. RAG retrieves *plausible* matches, not *correct* matches.

The use case retrieval was designed for — answering questions over a large unstructured corpus — is exactly where it works. ChatGPT-over-your-PDFs is a real product. Cursor's codebase search is a real productivity boost.

## When it breaks

**Silently wrong retrieval.** The top-k looked plausible. The model's answer was confident. The relevant document never surfaced. You don't know it failed unless you cross-check.

**Semantic distance ≠ relevance.** "Critical security note about admin permissions" and "user permissions for the admin panel" are semantically similar but the first is a warning and the second is a routing question. Retrieval can't tell which one matters.

**Chunking destroys structure.** A function definition gets split across two chunks. A spec's "given/when/then" gets separated. Retrieved chunks make less sense than the original document. The model fills in the gaps and gets confident answers wrong.

**Embedding drift.** The embedding model that indexed your corpus six months ago is older than the one running queries today. Quality degrades silently. Re-embedding is operationally painful.

**Context rot.** Chroma's [context rot research](https://www.trychroma.com/research/context-rot) shows that LLM quality degrades as input length grows even on simple tasks even within nominal context windows. Retrieving 20 chunks "to be safe" makes the answer worse, not better.

ETH Zurich went further. Their research found that "repository context files tend to reduce task success rates compared to no context at all." More context isn't more help; sometimes it's less. Retrieval that floods context with semantically-similar-but-not-actually-relevant chunks is a textbook way to trigger this.

**Cold start every query.** No memory of what was retrieved last turn. The agent re-runs retrieval every time. If your last query established useful context, that context isn't available to the next query unless retrieval happens to find it again.

**Tuning is real engineering.** Embedding model, chunking strategy, top-k value, reranker, hybrid weights, query rewriting, metadata filters. Six knobs minimum. Most teams don't tune them and accept mediocre retrieval.

**Over-applied to coding.** This is my biggest complaint with RAG specifically for coding. Most coding context isn't a "search this corpus" problem — it's a "what's in this file right now" problem. RAG turns a definite question into a probabilistic one and wastes compute on the conversion.

## How to pair it with other categories

Retrieval is most useful as a *fallback* when other categories can't cover the case:

- **Pair with repo-native as the primary, retrieval as the long tail.** Load CLAUDE.md and Memory Bank by default. When the agent needs something specific that wasn't loaded — a stack trace, a function definition, a doc page — retrieval can fetch it. Don't put RAG at the top of the stack.
- **Pair with transcript-derived for historical lookup.** Once you have many session summaries, a vector index lets you answer "did we deal with this bug before?"
- **Pair with structural retrieval (Aider-style repo map) for code-shaped questions.** Vector retrieval misses code's structure; structural retrieval respects it. Use both.
- **Skip pairing with dedicated memory stores over the same content.** Two systems that both decide "what's relevant" disagree at the worst moments.

## The honest verdict

RAG is over-applied to coding and the right tool for general-purpose document-search use cases.

For a coding agent on a single project: retrieval is rarely the bottleneck. You know what file you're editing. You know what context you need. Loading the right files into context is more reliable than embedding the codebase and hoping similarity surfaces the right chunks.

For a coding agent across many projects, or a question-answering system over a large doc corpus, or anywhere with hundreds of thousands of documents and a real "find the needle" problem: RAG is the right shape. Tune it seriously. Don't expect it to be set-and-forget.

The reason RAG keeps getting recommended is that it's the most academically respected memory pattern. There are papers. There are conferences. There are vendors. None of that means it's the right tool for the specific problem you have.

Next post: graph and structured memory. The category with the most architectural ambition, the most novel academic work, and the highest hype-to-traction ratio. If RAG is over-applied, graph memory is over-aspired-to.

If you've replaced a RAG setup with something simpler and gotten better results, what worked? I keep finding teams who deleted their vector DB and felt instant relief; the writeups never seem to make it online.
