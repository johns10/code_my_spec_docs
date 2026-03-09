# How to manage user stories to get the most out of AI

> **Part of the [CodeMySpec Methodology](/methodology)** — Phase 1: Requirements & Stories.

User stories are the interface to your entire product. They define the architecture, design, tests, and code. They're also a plain-english definition of what the product does -- useful for positioning, documentation, and test assertions.

When working with AI, stories are the context that keeps everything honest.

## The Problem

On human teams, customers talk to product. Stories become tickets. Tickets go to devs. Code gets written. Tickets get closed.

But nobody maintains them. Nobody re-evaluates them to make sure the application stays on track. Nobody reads the original stories when they make changes.

Now AI generates code faster than ever, and the chaos gets worse.

## How I Started

I kept a single markdown file, `user_stories.md`, with all requirements. Not a PRD with fluff. Not technical specs. Just user stories with acceptance criteria.

```markdown
# My Project

## User Story 1: Authentication
As a user, I want to log in with email and password so that I can access my account securely.

**Acceptance Criteria:**
- User can register with email and password
- User can log in with email and password
- Passwords are hashed (never stored in plain text)
- Sessions persist for 30 days
- User can log out
- Password reset via email link
```

Simple. Readable. Version-controlled.

## How I Write Them

Instead of writing stories alone, I have the AI interview me. Here's how my first requirements conversation actually started:

```
Yeah I'm just an ideating about this elixir coating agent and I'm thinking about whether I
should be developing my mCP tools as like quote on quote part of the application or like
where I just have tools that I that are implemented and then I use them internally ... I
know that I just basically answered my own question and I'm just talking to myself at this
point but tell me what you think about this
```

Terrible. But it started a real conversation and real thinking. You don't need a polished prompt to start.

The AI asks questions I didn't think of: "What happens if a user resets their password for an email that doesn't exist?" "Should sessions work across devices?" "Max failed login attempts before lockout?"

Through these interviews, the stories get refined, critiqued, and expanded.

## How CodeMySpec Does This Now

Here's the thing. I started with copy-pasting markdown. I built something better.

CodeMySpec has a **Stories MCP Server** with 12 tools. It's not planned -- it's built and working:

- **AI-driven story interviews** via `start_story_session` (interview mode or review mode)
- **Structured acceptance criteria** with individual criterion CRUD
- **Story tagging, priority, and locking** (30-minute locks to prevent conflicts)
- **PaperTrail audit trail** on every change
- **Story-to-component linking** for traceability
- **Real-time WebSocket notifications** via StoriesChannel

Stories live in the database, not markdown files. The AI accesses them directly through MCP tools. No more copy-pasting.

## Using Stories Effectively

**1. Start with interviews.** Use `start_story_session` in interview mode. The AI asks questions you haven't considered, identifies missing acceptance criteria, and catches conflicts.

**2. Review regularly.** Switch to review mode. The AI evaluates completeness, clarity, and consistency across all your stories.

**3. Link stories to components.** When you implement a story, link it to the responsible context. This creates traceability from requirement to code.

**4. Watch for conflicts.** Does Story 15 contradict Story 3? Does the new admin panel break the earlier privacy requirement? Catch these early.

**5. Spend more time here than feels necessary.** If you think you're done, run a review session. I've found that the stories I thought were complete always had gaps.

## What This Enables

**Consistent AI context.** Every conversation starts from the same foundation. No more "wait, did I tell you about the session limit?"

**Requirements traceability.** Story to component to design doc to code. Audit trail shows when requirements changed and why.

**Team alignment.** New team members read the stories and understand what the application does. Everyone uses the same requirements.

## The Philosophy

This is not about speed. It's about having a tool that makes it *feasible* to do things the right way.

Writing stories and keeping them updated used to be aspirational. Most teams started with good intentions, then let documentation rot. The overhead was too high.

With AI, stories become your primary interface. They're not documentation maintained *after* writing code -- they're the input you use *to write* code. Keeping them accurate isn't overhead. It's how you work.
