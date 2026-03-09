# Your AI Product Manager

Stop writing user stories. Start talking about what you want to build.

## The Problem

You sit down to write requirements. Two hours later you have vague stories, missing edge cases, and no confidence you've covered everything. Then you hand it to an AI that makes assumptions about everything you didn't specify.

## The Fix

The Stories MCP Server flips the script. Instead of you writing, **the AI interviews you**. It asks the questions you'd miss:

- "Who manages API keys — admins or users?"
- "What happens when a revoked key is used?"
- "Should sessions work across devices?"
- "Max failed logins before lockout?"

Through conversation, stories emerge that are specific, testable, and complete.

## Why Not Just Chat With Claude?

You can have a requirements conversation in any chat window. The difference is what happens to the output.

In a chat, requirements live in a conversation transcript. You copy them somewhere, forget to update them, and three weeks later your codebase has drifted from specs nobody references.

The Stories MCP Server writes requirements directly to your project's database as structured records. Each story has typed acceptance criteria, version history, component links, and status tracking. When you change a story after implementation starts, it's automatically flagged dirty. The AI reads these stories at the start of every architecture and coding session — not because you remembered to paste them, but because the tooling does it for you.

Requirements stop being documents you write once. They become living data your entire development process references.

## What You Get

**Structured data, not documents.** Acceptance criteria are discrete records — add, update, or delete one without touching the rest. They map directly to test assertions.

**Traceability.** Every story links to the component that satisfies it. Navigate from requirement to architecture to spec to code to test. When stories change after implementation, they're flagged dirty.

**Persistent context.** Every AI session loads your stories automatically. No copy-pasting. No "here's my requirements doc." The AI already knows what you're building.

**12 MCP tools.** Story CRUD, individual criterion management, tagging, priority, and AI-driven interview sessions. All scoped to your project.

## Where It Fits

Stories is step one. Everything downstream traces back here:

```
Stories → Architecture → Design → Implementation → QA
```

Components satisfy stories. Tests validate acceptance criteria. When something breaks, you know exactly which business requirement isn't being met.

[See the full Stories feature →](/pages/stories-feature)

[See the Stories MCP technical reference →](/pages/stories-mcp-documentation)
