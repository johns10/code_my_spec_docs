# Stories: Your AI Product Manager

> **Stop writing user stories. Start having conversations about what you want to build.** The Stories MCP Server turns requirements gathering into an interview with an expert product manager who asks the questions you'd miss.

## The Problem

Most teams either skip proper requirements gathering or spend hours writing user stories that are too vague, miss edge cases, or don't translate well into tests. You end up with "As a user, I want to manage API keys" instead of crisp, testable specifications.

## What Stories Does

Stories transforms requirements gathering from a writing exercise into a structured conversation. The AI acts as your product manager, asking targeted questions about your feature, drilling down on vague requirements, and helping you discover edge cases before you design or code anything.

Your requirements aren't trapped in markdown files or documentsthey live as structured data in your database. Every story knows which component implements it, which tests validate it, and whether it's become "dirty" (changed after implementation). This enables automatic traceability from business need through architecture to working code.

## How It Works

**1. Start the interview**
Tell the AI what feature you want to build. It automatically loads your existing stories for context and begins asking clarifying questions.

**2. AI drills down on requirements**
The AI asks about tenancy (user-scoped or account-scoped?), security implications, edge cases, error handling, and validation rules. It follows a structured PM persona that ensures comprehensive coverage.

**3. Create stories from the conversation**
Based on the discussion, the AI drafts user stories with specific, testable acceptance criteria. Stories follow the standard format but with precision gained from the interview.

**4. Review quality on demand**
At any point, trigger a quality review. The AI evaluates all your stories against best practices: Are acceptance criteria testable? Are stories appropriately sized? Are edge cases covered?

**5. Link to implementation**
During architecture design, assign each story to the component (Phoenix context) that will satisfy it. Now you have bidirectional traceability: from requirement to code and back.

## Key Capabilities

- **Guided requirement interviews** - AI asks questions you'd miss on your own
- **Structured story data** - Query, filter, and navigate stories as database records, not text files
- **Automatic quality reviews** - AI evaluates against best practices and identifies gaps
- **Complete traceability** - Navigate from story � component � tests � code
- **Dirty detection** - System flags stories modified after implementation
- **Batch operations** - Create or update multiple stories efficiently
- **Multi-tenancy** - Automatic project and account scoping
- **Collaboration support** - Locking mechanism prevents concurrent editing conflicts

## Integration with Your Workflow

Stories is the **first step** in the CodeMySpec process:

```
1. Stories � Define requirements (AI Product Manager interviews you)
2. Architect � Design architecture (maps stories to Phoenix contexts)
3. Design Sessions � Generate detailed specs (uses story acceptance criteria)
4. Test Sessions � Create tests (validates acceptance criteria)
5. Coding Sessions � Implement with tests (complete traceability to requirements)
```

Once stories are defined, everything downstream traces back to them. Tests validate story acceptance criteria. Components satisfy specific stories. When tests fail, you know exactly which business requirement isn't being met.

## Getting Started

**Prerequisites:**
- CodeMySpec account with active project
- Claude Code or Claude Desktop
- Stories MCP Server installed

**First conversation:**
```
You: I want to add API key management to my app. Let's start a story interview.

AI: [Loads your existing stories for context]

    Great! Let me ask some questions to flesh this out:
    - Who manages keys - account admins or individual users?
    - What operations do they need? (create, revoke, rotate, list)
    - Do keys need scopes or rate limits?
    - How should expiration be handled?
    - What happens when a revoked key is used?
    ...
```

From there, the AI guides you through a complete requirements analysis, creates the stories, and you're ready to move on to architecture design.

---

**Next:** [Architect MCP Server](/pages/architect-mcp-feature) - Design Phoenix contexts from your stories

**Documentation:** [Stories MCP Reference](/docs/stories-mcp) - Complete API reference and technical details