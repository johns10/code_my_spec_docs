# MCP: The Protocol Connecting AI Coding Tools

## What Is MCP?

MCP went from "Anthropic's proposal" to "Linux Foundation standard" in 17 months. That's fast. And as of April 7, 2026, the Linux Foundation's Agentic AI Foundation (AAIF) formally stewards it -- alongside OpenAI's AGENTS.md and Block's Goose. Platinum members include AWS, Anthropic, Block, Bloomberg, Cloudflare, Google, Microsoft, and OpenAI. That's every major player in the space signing on to the same protocol.

The Model Context Protocol is an open standard that lets AI coding tools connect to external data sources and capabilities. Think of it as USB for AI agents -- a universal plug that lets any supporting tool talk to any compatible server.

**In plain terms:** Without MCP, every AI tool needs custom integrations for every data source. With MCP, you write one server and every tool can use it.

## How It Works

MCP defines a client-server protocol. The AI tool is the client. MCP servers provide:

- **Tools** -- Functions the AI can call (run a database query, create a GitHub issue, send a Slack message)
- **Resources** -- Data the AI can read (file contents, API responses, documentation)
- **Prompts** -- Pre-built prompt templates for common tasks

Configure an MCP server in your coding tool, and the agent discovers what that server offers and uses it naturally during conversations.

Example: An analytics MCP server might expose `run_report(property_id, date_range, metrics)` and `get_realtime_data(property_id)`. The agent calls these like functions.

## Who Supports MCP (April 2026)

Adoption is effectively universal across top-tier CLI tools. Claude Code originated it. Codex, Gemini CLI, and Goose ship it. Continue.dev added MCP in April 2026. Tabnine added it at their Agentic tier in the April pricing overhaul. If a serious coding tool doesn't support MCP in 2026, that's the news.

### Full MCP Support

| Tool | MCP Details |
|---|---|
| **Claude Code** | 1,000+ community servers. MCP is core to the ecosystem. Elicitation support. |
| **Codex CLI** | 9,000+ MCP plugins (largest ecosystem). Plus 90+ proprietary Codex plugins. `codex mcp add` command. `@plugin` mentions in chat. |
| **Gemini CLI** | Full server support. Admin allowlisting. Google published a Codelab for building servers in Go. |
| **Cursor** | Full tools support (not resources yet). MCP Apps (v2.6) render interactive UIs. Up to 40 tools. |
| **GitHub Copilot** | Full MCP in VS Code 1.99+. GitHub MCP Registry for discovery. Auto-configured for Coding Agent. |
| **Cline** | Full MCP tool integration. One of the earliest non-Anthropic adopters. |
| **Goose** | Full MCP support. Now donated to Linux Foundation AAIF (April 2026). |
| **Continue.dev** | Added MCP in April 2026. |
| **Tabnine** | Added MCP at the Agentic tier in their April 2026 pricing overhaul. |
| **Windsurf** | MCP support for tools. |
| **Zed** | Via Agent Client Protocol (ACP) -- broader than MCP but compatible. |

### No Native MCP Support (Yet)

| Tool | Status |
|---|---|
| **Aider** | GitHub issue #4506 open. Third-party servers exist. |
| **OpenCode** | Not yet. |
| **Roo Code** | Not confirmed. |

## What MCP Enables

### Cross-Tool Workflows

The same MCP server works with Claude Code, Codex CLI, Cursor, and Copilot. Build one server that exposes your team's documentation and every developer on every tool can use it. Before MCP, you wrote N integrations for N tools. Now you write one.

This is the interop breakthrough. And it composes with the other cross-tool standard that landed this month: GitHub's `gh skill` command (April 16, 2026) ships Agent Skills that work across Copilot, Claude Code, Cursor, Codex, Gemini CLI, and Antigravity. MCP handles the data pipe; Agent Skills handle the task definitions. Same thesis: portability beats lock-in.

### Domain-Specific Intelligence

MCP servers extend agents into specialized domains:

- **Databases** -- Query and modify Postgres, MySQL, SQLite, MongoDB directly
- **Analytics** -- Pull GA4, Mixpanel reports into your development context
- **Infrastructure** -- Kubernetes status, CloudWatch logs, deployment controls
- **Documentation** -- Internal docs, API references, runbooks
- **Project management** -- Jira, Linear, status updates, issue creation

### Specification-Driven Development

This is where MCP gets interesting for spec-driven workflows. An MCP server can serve specifications to any supporting agent: BDD specs, design documents, acceptance criteria, context files (CLAUDE.md, .cursorrules) generated from specs. Instead of copy-pasting specs into chat, the agent reads them through MCP.

### Interactive Capabilities

MCP supports **elicitation** -- servers can request structured input from users mid-task. Cursor's **MCP Apps** (v2.6) render interactive UIs from MCP servers: charts, diagrams, whiteboards directly in the chat interface. This moves MCP from "data pipe" into "interactive collaborator."

## The Ecosystem by the Numbers

- **9,000+** MCP plugins in Codex CLI's marketplace (largest)
- **1,000+** community servers in the Anthropic ecosystem
- **GitHub MCP Registry** for Copilot discovery
- **geminicli.com/extensions** for Gemini CLI
- **awesome-claude-code** repo aggregates community contributions

Popular categories: GitHub/GitLab/Jira/Linear/Sentry, Postgres/MySQL/SQLite/MongoDB, AWS/GCP/Azure, Slack/Discord, Google Analytics/Mixpanel, Playwright/Puppeteer, local files/S3/Google Drive.

## Building an MCP Server

The protocol uses JSON-RPC over stdio or HTTP. SDKs in TypeScript (most popular), Python, Go (Google's Codelab), Rust, and Java. A minimal server exposing one tool is ~50 lines. The barrier is intentionally low.

## What MCP Doesn't Solve

MCP is infrastructure, not intelligence. It doesn't:

- **Make bad models better** -- MCP gives models more tools, not more reasoning
- **Guarantee security** -- Each server has its own auth/trust model. No standard for fine-grained permissions (though Cursor and Copilot add org-level policy controls)
- **Standardize data formats** -- MCP standardizes the transport, not the payload. Two analytics servers might return completely different shapes
- **Replace domain expertise** -- You still have to know what tools to build and what data to expose

## The Analogy: MCP Is the API Gateway for AI

If REST APIs connected web services to frontends, MCP connects data sources to AI agents:

1. **Before standardization** -- Custom integrations everywhere, fragmented ecosystem
2. **Standard emerges** -- One protocol, universal adoption
3. **Ecosystem explodes** -- Thousands of implementations, marketplace dynamics
4. **Becomes invisible** -- Developers stop thinking about the protocol and focus on what it enables

MCP is firmly in stage 3, and the AAIF donation pushes it toward stage 4. By then, you won't "configure an MCP server" -- your tools will just know how to talk to your data.

## What to Watch

1. **AAIF governance.** MCP is now under Linux Foundation stewardship. Expect a more formal spec process, more cross-vendor interop testing, less unilateral change.
2. **Resources support expanding.** Cursor supports tools but not resources yet. As this fills in, the data-serving use case gets stronger.
3. **Agent-to-agent via MCP.** Today MCP connects tools to data. Tomorrow it connects agents to agents -- an orchestration protocol.
4. **Enterprise controls maturing.** Copilot and Cursor offer org-level MCP policy controls. Every enterprise tool will follow.
5. **Spec servers.** MCP servers that serve development specifications to any supporting agent -- this is the CodeMySpec integration path.

## Sources

- [MCP Specification -- modelcontextprotocol.io](https://modelcontextprotocol.io/)
- [MCP, AGENTS.md, Goose donated to Linux Foundation AAIF -- April 7, 2026](https://www.linuxfoundation.org/press/agentic-ai-foundation)
- [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp)
- [Codex MCP Documentation](https://developers.openai.com/codex/mcp/)
- [Gemini CLI MCP Servers](https://geminicli.com/docs/tools/mcp-server/)
- [Cursor MCP Docs](https://cursor.com/docs/context/mcp)
- [Copilot MCP Docs](https://docs.github.com/en/copilot/concepts/context/mcp)
- [GitHub `gh skill` command -- April 16, 2026](https://github.blog/)
