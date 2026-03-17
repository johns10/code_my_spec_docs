# MCP: The Protocol Connecting AI Coding Tools

## What Is MCP?

The Model Context Protocol (MCP) is an open standard that lets AI coding tools connect to external data sources and capabilities. Think of it as USB for AI agents — a universal plug that lets any supporting tool talk to any compatible server.

Created by Anthropic, donated to the Linux Foundation's Agentic AI Foundation in December 2025, and adopted by OpenAI and Google DeepMind in early 2025. It went from proprietary to industry standard in under a year.

**In plain terms:** Without MCP, every AI tool needs custom integrations for every data source. With MCP, you write one server and every tool can use it.

## How It Works

MCP defines a client-server protocol. The AI tool is the client. MCP servers provide:

- **Tools** — Functions the AI can call (run a database query, create a GitHub issue, send a Slack message)
- **Resources** — Data the AI can read (file contents, API responses, documentation)
- **Prompts** — Pre-built prompt templates for common tasks

When you configure an MCP server in your coding tool, the AI agent can discover what that server offers and use it naturally during conversations.

Example: An analytics MCP server might expose tools like `run_report(property_id, date_range, metrics)` and `get_realtime_data(property_id)`. The AI agent calls these tools as needed, just like calling a function.

## Who Supports MCP (March 2026)

### Full MCP Support

| Tool | MCP Details |
|---|---|
| **Claude Code** | 1,000+ community servers. MCP is core to the ecosystem. Elicitation support (servers can request structured input). |
| **Codex CLI** | 9,000+ plugins (largest ecosystem). `codex mcp add` command. `@plugin` mentions in chat. |
| **Gemini CLI** | Full server support. Admin allowlisting. Google published a Codelab for building servers in Go. |
| **Cursor** | Full tools support (not resources yet). Per-project or global config. MCP Apps (v2.6) render interactive UIs. Up to 40 tools. |
| **GitHub Copilot** | Full MCP in VS Code 1.99+. GitHub MCP Registry for discovery. Auto-configured for Coding Agent. |
| **Cline** | Full MCP tool integration. One of the earliest non-Anthropic adopters. |
| **Goose** | Full MCP support. Custom extensions + MCP. |
| **Windsurf** | MCP support for tools. |
| **Zed** | Via Agent Client Protocol (ACP) — broader than MCP but compatible. |

### No Native MCP Support (Yet)

| Tool | Status |
|---|---|
| **Aider** | GitHub issue #4506 open. Third-party servers exist (disler, sengokudaikon, lutzleonhardt). |
| **OpenCode** | Not yet. |
| **Roo Code** | Not confirmed. |
| **Tabnine** | Enterprise-focused, different integration model. |

## What MCP Enables

### 1. Cross-Tool Workflows

The same MCP server works with Claude Code, Codex CLI, Cursor, and Copilot. If you build an MCP server that serves your team's documentation, every developer on every tool can access it.

This is the interop breakthrough. Before MCP, if you wanted your analytics data available to your coding agent, you'd need to build a custom integration for each tool. Now you build one server.

### 2. Domain-Specific Intelligence

MCP servers extend AI agents into specialized domains:

- **Database servers** — Query and modify databases directly from your coding agent
- **Analytics servers** — Pull GA4 reports, dashboard data into your development context
- **Infrastructure servers** — Check Kubernetes status, read CloudWatch logs, manage deployments
- **Documentation servers** — Serve internal docs, API references, runbooks
- **Project management** — Read Jira/Linear tickets, update status, create issues

### 3. Specification-Driven Development

This is where MCP gets particularly interesting for spec-driven workflows. An MCP server can serve specifications to any supporting agent:

- **Serve BDD specs** that define what code should do
- **Serve design documents** that describe system architecture
- **Serve acceptance criteria** that the agent can verify against
- **Serve context files** (CLAUDE.md, .cursorrules) generated from specs

Instead of manually copying specs into chat, the agent discovers and reads them through MCP.

### 4. Interactive Capabilities (New)

As of March 2026, MCP supports **elicitation** — servers can request structured input from users mid-task via interactive dialogs. And Cursor's **MCP Apps** (v2.6) render interactive UIs from MCP servers: charts, diagrams, whiteboards directly in the chat interface.

This moves MCP beyond "data pipe" into "interactive collaborator."

## The Ecosystem by the Numbers

- **1,000+** community-built MCP servers (Anthropic ecosystem)
- **9,000+** plugins in Codex CLI's marketplace
- **GitHub MCP Registry** for Copilot discovery
- **geminicli.com/extensions** for Gemini CLI
- **awesome-claude-code** repo aggregates community contributions

Popular server categories:
- **Developer tools** — GitHub, GitLab, Jira, Linear, Sentry
- **Databases** — PostgreSQL, MySQL, SQLite, MongoDB
- **Cloud platforms** — AWS, GCP, Azure
- **Communication** — Slack, Discord, email
- **Analytics** — Google Analytics, Mixpanel
- **Browser automation** — Playwright, Puppeteer
- **File systems** — Local files, S3, Google Drive

## Building an MCP Server

MCP servers are straightforward to build. The protocol uses JSON-RPC over stdio or HTTP. SDKs are available in:

- **TypeScript** (most popular)
- **Python**
- **Go** (Google's Codelab)
- **Rust**
- **Java**

A minimal server that exposes one tool is ~50 lines of code. The barrier to entry is intentionally low.

## What MCP Doesn't Solve

MCP is infrastructure, not intelligence. It doesn't:

- **Make bad models better** — MCP gives models more tools, not more reasoning ability
- **Guarantee security** — Each server has its own auth/trust model. No standard for fine-grained permissions (though Cursor and Copilot add org-level policy controls)
- **Standardize data formats** — MCP standardizes the transport, not the payload. Two analytics servers might return data in completely different formats
- **Replace domain expertise** — You still need to know what tools to build and what data to expose

## The Analogy: MCP Is the API Gateway for AI

If REST APIs connected web services to frontends, MCP connects data sources to AI agents. The pattern is the same:

1. **Before standardization** — Custom integrations everywhere, fragmented ecosystem
2. **Standard emerges** — One protocol, universal adoption
3. **Ecosystem explodes** — Thousands of implementations, marketplace dynamics
4. **Becomes invisible** — Developers stop thinking about the protocol and focus on what it enables

MCP is in stage 3. By stage 4, you won't "configure an MCP server" — your tools will just know how to talk to your data.

## What to Watch

1. **Resources support expanding.** Cursor currently supports MCP tools but not resources. As this fills in, the data-serving use case gets stronger.
2. **Agent-to-agent via MCP.** Today MCP connects tools to data. Tomorrow it connects agents to agents — an orchestration protocol.
3. **Enterprise controls maturing.** Copilot and Cursor now offer org-level MCP policy controls. Expect every enterprise tool to follow.
4. **Spec servers.** MCP servers that serve development specifications to any supporting agent — this is the CodeMySpec integration path.

## Sources

- [MCP Specification — modelcontextprotocol.io](https://modelcontextprotocol.io/)
- [MCP donated to Linux Foundation — Anthropic Blog](https://www.anthropic.com/news/mcp-linux-foundation)
- [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp)
- [Codex MCP Documentation](https://developers.openai.com/codex/mcp/)
- [Gemini CLI MCP Servers](https://geminicli.com/docs/tools/mcp-server/)
- [Cursor MCP Docs](https://cursor.com/docs/context/mcp)
- [Copilot MCP Docs](https://docs.github.com/en/copilot/concepts/context/mcp)
- [Build an MCP Server with Go — Google Codelab](https://developers.googleblog.com/)
