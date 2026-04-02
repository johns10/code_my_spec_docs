# Testing AI-Generated Code: The Self-Confirming Loop and How to Break It

I'm going to say something that sounds obvious but apparently isn't: when the same AI writes your code and your tests, you don't actually have tests. You have a mirror.

This is the self-confirming loop, and it's the single biggest risk in agentic development right now. The agent misunderstands a requirement, writes code that handles it wrong, then writes tests that confirm the wrong behavior. Tests pass. Coverage looks great. App is broken. I've seen it. You've probably seen it too.

One case study lays it out perfectly. An AI agent [wrote 275 E2E tests in a single session](https://dev.to/htekdev/i-let-an-ai-agent-write-275-tests-heres-what-it-was-actually-optimizing-for-32n7). An audit found assertion-free tests that ran code and counted as coverage but verified nothing. Worse, when the agent couldn't hit an 80% coverage threshold, it silently lowered the bar instead of asking why coverage was unreachable. The agent wasn't testing. It was optimizing the metric you gave it.

## The Numbers Don't Lie

CodeRabbit analyzed [470 pull requests](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report) and found AI-authored code produces 1.7x more issues per PR than human-written code (10.83 vs 6.45). Logic and correctness issues rise 75%. Security vulnerabilities rise 1.5-2x. Performance problems appear nearly 8x more often. And the tests the AI wrote for that code? They didn't catch any of it.

So what actually works?

## TDD Is Back, and It's Better With Agents

Here's the irony. Human teams always said they'd do TDD and almost never actually did. Too slow, too much overhead. With agents, that argument disappears. Simon Willison nails it - ["use red/green TDD" is a four-word prompt](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/) that unlocks engineering discipline already baked into the models. He starts every coding session by telling the agent how to run tests and saying "use red-green TDD."

The [Superpowers framework](https://github.com/obra/superpowers) takes this further. It enforces RED-GREEN-REFACTOR without negotiation. If code gets written before a failing test exists, the framework deletes it. 99K+ GitHub stars in three months tells you something about demand.

But here's where it gets counterintuitive. The [TDAD research](https://arxiv.org/abs/2603.17973) found that adding TDD instructions to agents WITHOUT telling them which specific tests to check actually INCREASED regressions from 6.08% to 9.94%. Read that again. Telling the agent "do TDD" made things worse. The fix was building a dependency graph between source code and tests, then telling the agent which tests to verify. That reduced regressions by 70%, down to 1.82%. Agents don't need to be told HOW to do TDD. They need to be told WHICH tests to check.

## BDD Specs From Acceptance Criteria

The self-confirming loop breaks when tests come from a different source than the implementation. BDD does this naturally. Every acceptance criterion on every [user story](/pages/stories-feature) becomes an executable scenario. The tests come from what you told the system to build, not from what it decided to build.

AI makes BDD cheap enough to actually do consistently. Product managers write scenarios in natural language, and AI translates them into executable tests. [Thoughtworks calls spec-driven development](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) "one of the most important practices to emerge in 2025."

The counter-thesis is real though. BDD specs test components through their APIs and interfaces. They don't open a browser and test the running application. I've had stories with 8 BDD scenarios all passing while a QA agent testing the running app found 4 bugs including a fraud vulnerability. BDD reduces what QA has to catch. It doesn't eliminate it.

## Testing Non-Deterministic LLM Output

If you're building features that call LLMs, you have a different problem. LLM output is non-deterministic even with temperature=0. Hardware differences and floating-point ordering [introduce variation that makes assertEquals useless](https://arxiv.org/html/2408.04667v5).

The cassette/recorder pattern solves this. Adapted from [Ruby's VCR library](https://anaynayak.medium.com/eliminating-flaky-tests-using-vcr-tests-for-llms-a3feabf90bc5), the idea is simple: first test run makes live LLM API calls and records responses. Subsequent runs replay recorded responses. Tests are fast, deterministic, and cheap. If the request payload changes, the cassette doesn't match and the test fails - surfacing regressions in your application behavior, not in the model's randomness.

The practical approach is to separate deterministic code (your harness, data flow, schema validation) from non-deterministic LLM output. Test the deterministic parts aggressively with traditional tests. For LLM output, test structure and schema rather than content. "Response contains required fields" instead of "response equals this exact string."

## Meta's Ephemeral Tests

The most radical idea I've seen comes from Meta. [Just-in-Time Tests](https://engineering.fb.com/2026/02/11/developer-tools/the-death-of-traditional-testing-agentic-development-jit-testing-revival/) are generated per PR and then discarded. When a pull request is submitted, an LLM reads the diff, infers developer intent, and generates a test designed to catch regressions introduced by that exact change. The test runs once. If it passes, it's thrown away. If it fails, a human reviews it.

This eliminates the mounting costs of traditional test suites - maintenance burden, false positives, flaky tests, slow CI. JiTTests reduced human review load by [70%](https://engineering.fb.com/2026/02/11/developer-tools/the-death-of-traditional-testing-agentic-development-jit-testing-revival/). They don't replace regression suites for critical paths, but they catch change-specific regressions without adding permanent maintenance burden.

## What I'd Actually Do

After digging through 35+ sources on this, here's the stack that works:

1. **Enforce TDD with structure, not instructions.** Use Superpowers, custom slash commands, or explicit phase separation. Don't just say "do TDD" - that makes things worse per the TDAD research. Tell the agent which tests to check.
2. **Write acceptance criteria before the agent touches code.** Turn them into BDD specs. This breaks the self-confirming loop because the tests come from what you intended, not what the agent built.
3. **Use separate agents for generation and review.** Addy Osmani from Google Chrome [describes "quality guardian" agents](https://addyosmani.com/blog/self-improving-agents/) that audit generated code. Different prompt, different context, different incentives than the generating agent.
4. **Use the cassette pattern for LLM-powered features.** Record once, replay forever. Test structure, not content.
5. **Test the running application, not just the components.** BDD specs passing doesn't mean the app works. [QA against the actual running system](/pages/agentic-qa) catches what unit tests miss at integration boundaries.
6. **Don't trust coverage numbers.** An agent can inflate coverage in an afternoon with assertion-free tests. High coverage with AI-generated tests can be worse than low coverage with thoughtful tests because it creates false confidence.

The reality is that AI makes testing simultaneously easier and more dangerous. Easier because the overhead argument for TDD is gone - agents will happily write tests all day. More dangerous because the tests might be confirming exactly the wrong thing. The discipline isn't in writing tests. It's in making sure the tests come from the right source.

What's your testing workflow look like with AI agents? Are you enforcing TDD, or still doing implementation-first and hoping the tests catch something?
