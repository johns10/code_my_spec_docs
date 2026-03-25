# Writing Applications for LLMs

There are two different things happening around AI coding agents right now, and everyone is lumping them together.

The first is writing applications for LLMs. Config files, skills, structured knowledge. Software that the LLM consumes.

The second is harnessing LLMs. Hooks, orchestration, validation pipelines. Software that controls the LLM.

These are not the same activity. A CLAUDE.md file is settings. A skill is a library. These are things you build for the agent to use. A hook that runs your test suite after every file write? That's your code controlling the agent. A harness that dispatches tasks to specialized agents, validates output, and manages state across sessions? That's your application using the LLM as a component.

The industry calls all of this "harness engineering." I think that's imprecise. The harness is the part that controls the LLM. The application is the part the LLM uses. Both matter. They're different skills.

## Applications for LLMs

### Settings: The Config File

The simplest application you can write for an LLM is a single markdown file. CLAUDE.md, .cursorrules, GEMINI.md. One document that says: here's my stack, here's my conventions, here's what to avoid.

This works surprisingly well for small projects. Then your project grows. The file hits 100, 150 lines. Research from ETH Zurich found that bloated context files can actually hurt agent performance. Models follow instructions too literally, running unnecessary checks, reading irrelevant files, burning tokens on thoroughness instead of output. Anthropic recommends keeping CLAUDE.md under 200 lines. Practitioners report compliance degrading well before that.

You hit the ceiling. The agent starts ignoring your conventions. It introduces patterns you told it not to use. You spend more time correcting than building.

So you move up. Not by choice. Because your current level broke.

### Skills: The Library

A skill is a directory with markdown files and potentially some tools that an agent can invoke on demand. If CLAUDE.md is a config file, a skill is a library.

The key difference: CLAUDE.md is always loaded. Skills are loaded on demand. The agent reads the skill's frontmatter, decides if it's relevant, and only pulls in the full instructions when it needs them. Progressive disclosure. The agent sees a menu of capabilities but only loads the details for the one it's using.

A skill can be simple: a markdown file describing how to create a new API endpoint. Or complex: a directory with instructions, reference files, even a learnings subdirectory where the skill accumulates knowledge across sessions. Skills that learn.

Skills solve the context bloat problem. Instead of stuffing everything into one file, you distribute knowledge into focused, composable units. The agent discovers what it needs, when it needs it.

But skills are probabilistic. The agent decides when and how to apply them. It uses judgment. Sometimes that judgment is wrong. It skips a skill that was relevant. It applies a skill in the wrong context.

You can't enforce behavior through documentation alone.

This is where the nature of what you're building changes. You stop writing things for the LLM to use and start writing things that control the LLM.

## Harnessing LLMs

### Hooks: Where Determinism Enters

Hooks are code that runs in response to agent actions. Before a tool executes. After a file is written. When the agent finishes a task. Unlike skills, hooks are deterministic. They run every time, no exceptions. The agent doesn't decide whether to invoke them. They just fire.

Skills are suggestions. Hooks are enforcement. You're not writing documentation the agent should follow. You're writing middleware the agent can't bypass.

A hook can be simple: log every file write. Or it can trigger a full validation pipeline. Compile the code, run tests, check for security vulnerabilities, validate against BDD specs, feed the results back to the agent as structured feedback.

Mitchell Hashimoto's principle: "Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again." That solution is usually a hook.

For many projects, good skills plus a few enforcement hooks is enough. You don't need to go further unless you do.

### Orchestration: Your Application Uses the LLM

This is where the relationship fully inverts. With config files and skills, the LLM uses your artifacts. With orchestration, your application uses the LLM. The LLM becomes a component in your system, not the center of gravity.

Orchestration means your code decides what to work on, which agent to assign, what context to provide, when to validate, and when to hand off. The LLM is a powerful but unreliable code generator that your application calls when it needs text generated.

Anthropic described a version of this in their article on [effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents). A two-agent architecture where an Initializer agent sets up the environment and a Coding Agent executes within it. The harness bridges sessions through structured artifacts. Progress files, feature lists, verification checklists. The agents don't decide the workflow. The harness does.

OpenAI calls this "harness engineering." Three engineers built a million-line product in five months by designing environments where agents write code, rather than writing code themselves. The metaphor comes from horse tack: reins, saddle, bit. The complete set of equipment for channeling a powerful but unpredictable animal in the right direction.

LangChain proved the harness matters independently of the model. Their coding agent jumped from outside the Top 30 to Top 5 on Terminal Bench 2.0 by changing only the harness. Same model. A 13.7-point improvement from infrastructure alone.

At this level you're unambiguously writing software. Your application has a dependency graph of requirements. It dispatches tasks to specialized agents. It validates output through automated pipelines. It manages state across sessions. The LLM is a function you call, not a conversation you have.

## Two Activities, One Progression

Here's the thing. You don't choose to move up this progression. You get forced up when your current level breaks.

This is how all software infrastructure evolves. You start with a bash script. Then the bash script gets too complex so you write a real program. Then the program needs configuration so you add config files. Then you need multiple programs coordinating so you build a system. Nobody designs for orchestration on day one. You build what you need when you need it.

The levels aren't aspirational. They're reactive. And the appropriate level depends on your domain. A marketing workflow needs good skills. A code generation pipeline needs full orchestration. A personal project might live at a single config file forever, and that's fine.

But the two activities stay distinct even as they grow together. You're always doing both: building better applications for the LLM to consume, and building better harnesses that control the LLM's behavior. The config file gets more refined. The skills get more composable. The hooks get tighter. The orchestration gets more sophisticated. They grow in parallel, not in sequence.

| | Applications for LLMs | Harnesses for LLMs |
|---|---|---|
| What it is | Software the LLM consumes | Software that controls the LLM |
| Examples | CLAUDE.md, skills, reference docs, MCP tools | Hooks, validation pipelines, task dispatchers, orchestration |
| Character | Knowledge, context, capability | Enforcement, verification, coordination |
| Analogy | The textbook you give the intern | The process the intern must follow |
| Probabilistic or deterministic | Probabilistic. The LLM decides what to use. | Deterministic. Runs every time. |

## What This Means

If what you build around an AI coding agent is software, then the skills that matter are software engineering skills. Not prompt engineering. Not "talking to AI." Architecture. Domain modeling. Validation pipelines. State management. The same things that have always mattered in software.

The model is commodity. What you build around it is the differentiator.

Right now, the ecosystem gives you the building blocks. CLAUDE.md files, skills, hooks, MCP servers, subagents. You assemble them yourself. Eventually, tools will emerge that help you build and manage these applications the same way web frameworks emerged to help you build web applications. Right now we're in the hand-rolled HTML era of LLM applications.

In the meantime, treat what you're building around the agent with the same rigor you'd treat any software project. Version control it. Test it. Iterate on it. Because that's what it is.

## Sources

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic: Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic: Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [OpenAI: Harness Engineering](https://openai.com/index/harness-engineering/)
- [LangChain: Improving Deep Agents with Harness Engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
- [LangChain: The Anatomy of an Agent Harness](https://blog.langchain.com/the-anatomy-of-an-agent-harness/)
- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [HumanLayer: Skill Issue](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents)
- [Philipp Schmid: The Importance of Agent Harness in 2026](https://www.philschmid.de/agent-harness-2026)
- [ETH Zurich: New Research Reassesses AGENTS.md Files](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [MIT Missing Semester: Agentic Coding](https://missing.csail.mit.edu/2026/agentic-coding/)
