# The Agentic Software Development Process

*Most teams are using AI agents for one phase of development. Here's what happens when you use them for all eight.*

---

The conversation about AI coding tools is stuck on one question: "which agent writes the best code?" That's the wrong question. Code generation is one phase of software development. There are seven others, and most of them matter more.

I've spent the last year building with AI agents across the full development lifecycle. Not just implementation. Requirements gathering, architecture design, specifications, testing, QA verification, deployment, and maintenance. Each phase has its own tools, its own failure modes, and its own hard-won lessons.

Here's the process, phase by phase.

## 1. Requirements: the bottleneck moved

A year ago the hard part was writing code. Now the hard part is knowing what to build. AI agents are shockingly good at implementation. They're terrible at reading your mind.

[Atlassian said it bluntly](https://www.atlassian.com/blog/artificial-intelligence/how-ai-turns-software-engineers-into-product-engineers): "Shipping the wrong feature quickly is worse than shipping the right feature slowly." Every gap in your requirements is an invitation for the agent to guess. The probability of all those guesses being correct [approaches zero](https://docs.bswen.com/blog/2026-03-25-why-vibe-coding-fails-production/) in any real system.

The fix: requirements as conversations, not documents. Tools like [ChatPRD](https://www.chatprd.ai/) (100K+ PMs), [Kiro](https://kiro.dev/) (AWS), and [GitHub spec-kit](https://github.com/github/spec-kit) turn requirements gathering into an interview where the AI asks the questions you'd miss. MCP servers connect agents directly to Jira, Linear, and structured story systems so requirements are live data, not stale documents.

**[Full article: Bad Requirements Are Why Your AI Agent Writes Bad Code](/blog/agentic-requirements)**

## 2. Architecture: the 26-point gap

BSWEN measured a [26-point quality gap](https://docs.bswen.com/blog/2026-03-25-why-vibe-coding-fails-production/) between AI-only code and human-guided architecture (59/105 vs 85/105). The entire gap comes from design dimensions: async design, abstraction quality, maintainability, code organization. AI handles implementation fine when given clear architectural direction. The problem is nobody provides it.

The emerging winner is the modular monolith with bounded contexts. Shopify proved it at [2.8M lines](https://www.linkedin.com/pulse/ai-agents-will-force-your-code-become-more-modular-enrico-piovesan-x7vxf/). OpenAI proved it with their [layered architecture](https://openai.com/index/harness-engineering/) (3 engineers, ~1M lines, 5 months). The pattern: keep each unit of work small, bounded, and clearly contracted. The agent stays in the quality zone when it doesn't have to hold the whole codebase in context.

**[Full article: Architecture for AI Agents: Which Patterns Actually Work?](/blog/agentic-architecture)**

## 3. Specifications: the asset shifted

Code is no longer the asset. The specification is. When agents generate code at near-zero cost, the thing that constrains, directs, and validates that code becomes the primary deliverable.

A [GitClear study of 211M lines](https://www.augmentcode.com/guides/vibe-coding-vs-spec-driven-development) found that after AI adoption, refactoring dropped 60% and duplication rose 48%. The [VibeContract paper](https://arxiv.org/abs/2603.15691) calls it the "illusion of correctness" - code that compiles and passes superficial tests but doesn't do the right thing.

Spec-driven development tools (Kiro, spec-kit, Tessl, cc-sdd, BMAD-METHOD) all converge on the same workflow: define requirements, design architecture, decompose into tasks, generate code, validate against the spec. The key insight from [Augment Code](https://www.augmentcode.com/guides/what-is-spec-driven-development): debug specifications, not code.

**[Full article: Your AI Agent Is Only as Good as Your Spec](/blog/agentic-specifications)**

## 4. Implementation: the paradox

Everyone's talking about AI code generation like it's solved. [Copilot has 20M users](https://www.getpanto.ai/blog/github-copilot-statistics). [Cursor hit $2B ARR](https://techcrunch.com/2026/03/02/cursor-has-reportedly-surpassed-2b-in-annualized-revenue/). [41% of code is now AI-generated](https://www.netcorpsoftwaredevelopment.com/blog/ai-generated-code-statistics).

The paradox: METR ran a rigorous study and found experienced developers are [19% slower with AI tools](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) - but they perceive themselves as 20% faster. Vibe coding produces [2.74x more security vulnerabilities](https://thenewstack.io/vibe-coding-could-cause-catastrophic-explosions-in-2026/). Gartner predicts [2500% defect increase by 2028](https://www.armorcode.com/report/gartner-predicts-2026-ai-potential-and-risks-emerge-in-software-engineering-technologies) from prompt-to-app approaches. One CTO: [93% of developers use AI, real productivity gain is about 10%](https://shiftmag.dev/this-cto-says-93-of-developers-use-ai-but-productivity-is-still-10-8013/).

The skill that matters isn't prompting. It's [harness engineering](/pages/the-harness-layer): convention files, test commands, hooks, verification pipelines. The [agent loop](/pages/the-agent-layer) is commodity. What wraps around it is the differentiator.

**[Full article: The Implementation Phase: AI Writes the Code, But Who's Actually Driving?](/blog/agentic-implementation)**

## 5. Testing: the self-confirming loop

When the same AI writes your code and your tests, you don't have tests. You have a mirror. The agent misunderstands a requirement, writes wrong code, writes tests that confirm the wrong behavior. Tests pass. Coverage looks great. App is broken.

[CodeRabbit analyzed 470 PRs](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report): AI code produces 1.7x more issues, 8x more performance problems, 1.5-2x more security vulnerabilities. The tests didn't catch any of it.

The fix: TDD where the agent is told which specific tests to check (not just "do TDD" - that [makes things worse](https://arxiv.org/abs/2603.17973)). BDD specs from acceptance criteria so tests come from requirements, not implementation. The [cassette pattern](https://anaynayak.medium.com/eliminating-flaky-tests-using-vcr-tests-for-llms-a3feabf90bc5) for non-deterministic LLM output. And Meta's [JiTTests](https://engineering.fb.com/2026/02/11/developer-tools/the-death-of-traditional-testing-agentic-development-jit-testing-revival/) concept: ephemeral tests per PR, discarded after they run.

**[Full article: Testing AI-Generated Code: The Self-Confirming Loop and How to Break It](/blog/agentic-testing)**

## 6. QA and verification: the real gap

[96% of developers don't trust AI code](https://www.itpro.com/software/development/software-developers-not-checking-ai-generated-code-verification-debt) but commit it anyway. [50% don't verify](https://www.itpro.com/software/development/software-developers-not-checking-ai-generated-code-verification-debt) before committing. DORA found that for [every 25% increase in AI adoption, delivery stability decreases ~7.2%](https://dev.to/dmitry_turmyshev/quality-assurance-in-ai-assisted-software-development-risks-and-implications-34kk).

Anthropic discovered agents [mark features complete without end-to-end verification](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents). The fix: browser automation (Playwright MCP, Puppeteer) where the agent tests as a user would. Cursor's cloud agents [record video of themselves using the app](https://devops.com/cursor-cloud-agents-get-their-own-computers-and-35-of-internal-prs-to-prove-it/) and attach it to the PR. Model-as-judge patterns where a separate model evaluates the output.

The testing pyramid is inverting. E2E tests verify behavior. Unit tests verify implementation details the agent can regenerate at will. When code is disposable, behavior is what matters.

**[Full article: The Verification Gap: Why Agents Ship Broken Code](/blog/agentic-qa-verification)**

## 7. Deployment: knowledge files, not cloud credentials

[78% of enterprises have AI agent pilots](https://www.digitalapplied.com/blog/ai-agent-scaling-gap-march-2026-pilot-to-production) but under 15% reach production. The deployment gap is real. Agents build apps but can't ship them.

Two approaches: give agents direct infrastructure access through MCP servers ([AWS has 66](https://awslabs.github.io/mcp/)), or teach agents about your infrastructure through knowledge files. I use the second. Four markdown files documenting my Hetzner/Docker/Cloudflare/S3 stack. Claude reads them and generates deployment commands I review before running. No credentials exposed. The agent follows my documented decisions instead of making its own.

**[Full article: Teaching AI Agents to Deploy](/blog/agentic-devops-knowledge-files)**

## 8. Maintenance: where agents earn their keep

[60-80% of total software cost](https://flairstech.com/blog/ai-software-maintenance-support) is maintenance. Always has been. And it's where agents deliver the most proven value because maintenance tasks have clear success criteria.

The baseline: assign a GitHub issue to Copilot, get a PR back. OpenAI's [garbage collection pattern](https://openai.com/index/harness-engineering/) runs background agents that scan for drift and open cleanup PRs on a cadence. Anthropic's [multi-agent code review](https://claude.com/blog/code-review) dispatches specialized agents per issue class with <1% false positive rate.

The paradox: AI agents are generating technical debt faster than they're cleaning it up. [Cumulative AI-introduced issues exceeded 110,000 by February 2026](https://arxiv.org/html/2603.28592v1). The teams getting it right run cleanup agents at the same cadence as generation agents. Maintenance equilibrium doesn't happen by accident.

**[Full article: Maintenance: Where Agents Actually Earn Their Keep](/blog/agentic-maintenance)**

## The process, not the tools

The tools change every month. The process doesn't. Define what to build. Design how it fits together. Specify the contracts. Generate the code. Test it from multiple angles. Verify the running application. Deploy with documented knowledge. Maintain with the same rigor you built with.

Most teams are doing step 4 (implementation) and skipping the other seven. That's why AI-generated codebases fall apart at month three. The code was generated fine. Everything around the code was missing.

The agentic software development process isn't about finding the best AI coding tool. It's about building the full lifecycle so the tool has something to work with.
