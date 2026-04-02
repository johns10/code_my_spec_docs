# Bad Requirements Are Why Your AI Agent Writes Bad Code

The bottleneck moved and most people haven't noticed.

A year ago, the hard part of building software was writing the code. Now the hard part is knowing what to build. AI coding agents have gotten shockingly good at implementation. They'll generate a working feature in minutes. But if you told them to build the wrong thing, you just got the wrong thing faster.

Atlassian put it bluntly: ["Shipping the wrong feature quickly is worse than shipping the right feature slowly."](https://www.atlassian.com/blog/artificial-intelligence/how-ai-turns-software-engineers-into-product-engineers) When implementation is cheap, building the wrong thing is the most expensive mistake you can make.

I've watched this play out in my own work. The times my agents went off the rails, it wasn't because Claude or Cursor got dumber overnight. It was because I gave them vague instructions and expected them to read my mind. Every gap in your requirements is an invitation for the AI to guess. And as [BSWEN documented](https://docs.bswen.com/blog/2026-03-25-why-vibe-coding-fails-production/), the probability of all those guesses being correct approaches zero in any real production system.

## Requirements Went From Documents to Conversations

The old way of doing requirements was painful. Someone writes a 40-page PRD, throws it over the wall, developers misinterpret half of it, and three months later you have something nobody wanted.

AI didn't fix that process. It replaced it with something fundamentally different.

Now you can have a conversation with an AI agent about what you want to build. The agent asks clarifying questions, identifies edge cases you missed, and generates structured requirements you can actually hand to a coding agent. [ChatPRD](https://www.chatprd.ai/) pioneered this and now has over 100,000 PMs using it. The idea-to-PRD pipeline that used to take days takes minutes.

But ChatPRD is just the beginning. [Kiro from AWS](https://kiro.dev/) built an entire IDE around a three-phase spec workflow: Requirements, Design, Tasks. You tell the agent what you want, it structures it, you refine it together, and then it generates implementation tasks. [GitHub's spec-kit](https://github.com/github/spec-kit) does something similar with an open source CLI that works across agents. Their vision is that "intent is the source of truth," not code.

This is what Deepak Singh, AWS VP of Developer Agents, [told Stack Overflow](https://stackoverflow.blog/2025/10/31/vibe-coding-needs-a-spec-too/): senior engineers at Amazon - 80% of whom are using AI agents - naturally gravitated to writing specs first. They didn't need to be told. They figured out that "vibe coding needs a spec, too."

## The Tools

The spec-driven development space got crowded fast. [Kiro](https://kiro.dev/) (AWS) built an entire IDE around Requirements > Design > Tasks. [GitHub spec-kit](https://github.com/github/spec-kit) is open source and works across agents. [Tessl](https://tessl.io/blog/tessl-launches-spec-driven-framework-and-registry/) is the radical one where specs ARE the source code and code gets regenerated, never edited directly. [cc-sdd](https://github.com/gotalab/cc-sdd) brings Kiro-style commands to Claude Code, Cursor, and Copilot. [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) throws 12+ domain expert agents at it.

On the PM side, [McKinsey found](https://aipmtools.org/articles/best-ai-product-management-tools-2026) AI tools reduce time on repetitive PM tasks by 50-60%. That tracks with what I've seen.

## The MCP Approach: Agents That Talk to Your Tools

Here's my favorite pattern: MCP servers that connect your AI agent directly to your project management tools.

[Atlassian launched an official MCP server](https://www.atlassian.com/platform/remote-mcp-server) for Jira and Confluence. Your coding agent can read tickets, check requirements, and reference documentation without you copy-pasting anything. [DX Heroes built a unified MCP server](https://playbooks.com/mcp/dxheroes-jira-linear) that works with both Jira and Linear for teams split across tools.

The pattern I find most interesting is the [Stories MCP Server approach](/pages/stories-feature). Instead of requirements living in a document that gets stale, they live in a structured system that your coding agent queries in real time. The agent reads the story, understands the acceptance criteria, writes the code, and verifies against the criteria. No copy-paste. No context getting lost between tools.

Dean Peters built [Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills) with 65 skills and 36 chained workflows that cover the full PM lifecycle inside Claude Code. You can run a discovery chain that goes from brainstorming ideas to identifying assumptions to prioritizing experiments. This isn't science fiction. People are doing this now.

## The 70% Wall Is a Requirements Problem

Addy Osmani wrote about [the 70% problem](https://addyo.substack.com/p/the-70-problem-hard-truths-about): non-engineers hit a wall where AI gets them a functional prototype, but they can't finish the last 30%. That last 30% is "an exercise in diminishing returns." The AI misses error messaging, edge cases, accessibility, performance, UX.

I think most people read that as an AI capability problem. It's not. It's a requirements problem.

When your spec says "build a login page," the AI builds a login page. It doesn't know you need rate limiting, password complexity rules, account lockout after failed attempts, or accessible error messages. You didn't ask for those things because you assumed them. The AI didn't assume them because it has, as [Vectorian puts it](https://www.vectorian.be/articles/agentic-project-management/), "zero short-term memory." It's a brilliant, fast intern that only does exactly what you tell it.

Vectorian claims 90% of agent output is correct on first attempt when you use their framework of Context Curation, Externalized Memory, and Atomic Scoping. I can't verify that number, but the direction is right. Better specs produce dramatically better agent output.

## What Actually Works

After doing this for a while, here's what I've learned about requirements for AI agents:

**Be explicit about what you'd normally assume.** Error handling, edge cases, validation rules, accessibility requirements. If you wouldn't explain it to a new hire, you need to explain it to the agent.

**Use structured formats.** Given-When-Then acceptance criteria give agents something concrete to implement and verify against. "As a user, I want to log in" is useless. "Given a user with valid credentials, when they submit the login form, then they should be redirected to their dashboard and see a welcome message" is actionable.

**Keep scope atomic.** One story, one behavior, one verifiable outcome. The bigger the scope, the more the agent guesses. Break things down until each piece is boring and obvious.

**Connect your agent to your requirements system.** Whether it's MCP servers, CLAUDE.md files, or structured markdown, your agent should be able to read requirements directly. Copy-pasting context is where things get lost.

**Iterate on specs, not on code.** When the output is wrong, resist the urge to manually fix the code. Fix the spec and regenerate. This is the key insight from [Vectorian](https://www.vectorian.be/articles/agentic-project-management/): adjusting specs and re-running beats manual debugging every time.

[Thoughtworks called](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) spec-driven development "one of the most important practices to emerge in 2025." I think they're right, but with a caveat: the practice matters more than any specific tool. Whether you use Kiro, spec-kit, BMAD-METHOD, or just a well-structured markdown file, the point is the same. Think before you build. Be specific. Let the agent do what it's good at. Then [write the spec](/blog/agentic-specifications) and [verify the output](/blog/agentic-qa).

The reality is that requirements have always been the hardest part of software. AI just made it impossible to ignore.
