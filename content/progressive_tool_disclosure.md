# Progressive Tool Disclosure: How Claude Handles Hundreds of MCP Tools

*How AI coding tools solve the "too many tools" problem, and what it means for your MCP setup.*

---

Connect five MCP servers to Claude (GitHub, Slack, Jira, Sentry, Grafana) and you've burned [roughly 55,000 tokens](https://www.anthropic.com/engineering/advanced-tool-use) before Claude reads your first message. That's over a quarter of a 200K context window gone to tool definitions just sitting there.

Two Chrome-related MCP servers alone ate [31,700 tokens](https://paddo.dev/blog/claude-code-hidden-mcp-flag/), nearly 16% of my context. And it gets worse than wasted tokens. [Tool selection accuracy collapses from 43% to under 14%](https://www.agentpmt.com/articles/thousands-of-mcp-tools-zero-context-left-the-bloat-tax-breaking-ai-agents) when you overload the model with too many definitions. It picks the wrong tool seven out of eight times.

So how does Claude handle dozens of MCP servers with hundreds of tools? Progressive tool disclosure.

## How it actually works

Don't load every tool definition into context at startup. Give the model a search tool to find the right tools on demand.

Here's Claude's flow:

1. At startup, Claude sees only its core tools (Read, Edit, Bash, Grep, Glob) plus [ToolSearch](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool).
2. MCP tool definitions are deferred. Claude knows they exist (just the names), but full schemas aren't in context.
3. When Claude needs a tool, it calls ToolSearch. That returns the 3-5 most relevant tool definitions.
4. Those definitions get injected inline as `tool_reference` blocks. Claude can now call them normally.
5. The system prompt prefix stays untouched, so [prompt caching is preserved](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool).

The savings are real. Claude Code production shows a [46.9% reduction in total agent tokens](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734) (51K down to 8.5K). Anthropic reports [over 85% reduction](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) in typical multi-server setups.

## But doesn't this add latency?

Yes. One extra round-trip per tool discovery. If a task needs tools from GitHub and Slack, the model searches for the GitHub tool, uses it, then searches for the Slack tool next turn. Multi-intent queries aren't a separate problem, they're just more turns in the normal agent loop.

The mitigation: keep your 3-5 most used tools as non-deferred. Those load at startup with full schemas. Only the long tail gets deferred. In most real workflows, 80% of tool calls hit the same handful of tools. Those stay fast.

The alternative, loading everything upfront, either blows your context window or degrades accuracy so badly the model picks wrong tools anyway. A search round-trip that finds the right tool beats an overloaded context that picks the wrong one.

## Three different approaches

**Anthropic (Claude)** works at the context level. Deferred tools aren't in the system prompt. When discovered, definitions append inline. Saves tokens aggressively, adds a search round-trip.

**Manus** works at the [decoding level](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus). All tool definitions stay in context (full token cost), but logits masking prevents the model from selecting irrelevant tools during generation. Preserves the KV cache perfectly since the prompt never changes, but saves zero tokens.

**Cloudflare** takes the most radical approach with [Code Mode](https://blog.cloudflare.com/code-mode-mcp/). Instead of hundreds of tool definitions, they collapse their entire API into two tools: `search()` and `execute()`. The model writes code against a typed SDK in a V8 sandbox. Their full API would consume 1.17 million tokens as traditional MCP. Code Mode uses ~1,000. A 99.9% reduction.

Different bets. Anthropic bets search latency is acceptable for massive token savings. Manus bets cache efficiency matters more than token count. Cloudflare bets code generation is more natural than tool selection for large APIs.

## Implementing it yourself

**Using Claude's API directly**, mark tools with `defer_loading: true` and add a tool search tool:

```python
tools = [
    {"type": "tool_search_tool_bm25_20251119", "name": "tool_search"},
    {
        "name": "create_github_issue",
        "description": "Create an issue in a GitHub repository",
        "input_schema": {...},
        "defer_loading": True
    },
]
```

The API handles the rest. Anthropic has a [complete Python implementation with embeddings](https://platform.claude.com/cookbooks/tool_use) in their cookbook, and docs for [building custom tool search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#custom-tool-search-implementation) using `tool_reference` blocks if you want your own search logic.

**Rolling your own** without the built-in tool search: expose three meta-tools instead of all your tools directly: `list_tools` (names and descriptions), `describe_tool` (full schema), `execute_tool` (run it). [Benchmarks show](https://www.speakeasy.com/blog/100x-token-reduction-dynamic-toolsets) this keeps initial token usage flat from 40 to 400 tools, while static loading exceeds 200K context at around 200 tools.

**Or just keep it simple.** If you have fewer than 10-15 tools, progressive disclosure adds complexity without much benefit. The problem only gets real at scale.

## What this means for you

If you're using Claude Code or Claude.ai, this is already handled. Your MCP tools are deferred by default. If you're building agents with the API, use `defer_loading: true` for anything beyond your core tools. And if you're building MCP servers, write clear, specific tool descriptions. The model searches by description text, so "manage resources" gets bad results. "Create a GitHub pull request with title, body, base branch, and head branch" gets good ones.

---

## Sources

1. [Tool Search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) - Anthropic
2. [Tool Search with Embeddings Cookbook](https://platform.claude.com/cookbooks/tool_use) - Anthropic (Python implementation)
3. [Custom Tool Search Implementation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#custom-tool-search-implementation) - Anthropic
4. [Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use) - Anthropic Engineering
5. [Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Anthropic Engineering
6. [Context Engineering: Lessons from Building Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) - Manus
7. [Code Mode for MCP](https://blog.cloudflare.com/code-mode-mcp/) - Cloudflare
8. [The Bloat Tax Breaking AI Agents](https://www.agentpmt.com/articles/thousands-of-mcp-tools-zero-context-left-the-bloat-tax-breaking-ai-agents) - AgentPMT
9. [100x Token Reduction with Dynamic Toolsets](https://www.speakeasy.com/blog/100x-token-reduction-dynamic-toolsets) - Speakeasy
10. [Claude Code's Hidden MCP Flag](https://paddo.dev/blog/claude-code-hidden-mcp-flag/) - Paddo.dev
11. [Claude Code Just Cut MCP Context Bloat by 46.9%](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734) - Medium
