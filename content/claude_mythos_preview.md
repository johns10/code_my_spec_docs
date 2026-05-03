# Claude Mythos: What We Know, What We Don't, and Why the Harness Still Matters

Anthropic's next model leaked before they were ready to announce it. Here's what's actually confirmed and what's still speculation.

## How We Got Here

On March 26, security researchers [discovered a misconfigured data store](https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/) on Anthropic's infrastructure that exposed roughly 3,000 internal files. Among them: a draft blog post describing a model called "Claude Mythos" with a new tier codenamed "Capybara" sitting above Opus.

Five days later, Anthropic [accidentally shipped Claude Code v2.1.88 to npm](https://fortune.com/2026/03/31/anthropic-source-code-claude-code-data-leak-second-security-lapse-days-after-accidentally-revealing-mythos/) with a 59.8 MB source map containing the full TypeScript source. That confirmed the Mythos references. Two security lapses in one week.

The timing near April 1 caused massive confusion. [Lead Stories confirmed](https://leadstories.com/hoax-alert/2026/04/fact-check-leak-of-anthropics-claude-code-source-code-was-not-an-april-fools-prank.html) it was not a prank. Anthropic issued DMCA takedowns against repos that forked the code.

## What Anthropic Actually Confirmed

An Anthropic spokesperson [told Fortune](https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/): "We're developing a general purpose model with meaningful advances in reasoning, coding, and cybersecurity." They called it "a step change" and "the most capable we've built to date."

That's the official statement. Everything else comes from leaked internal documents.

## What the Leaked Docs Claim

According to the draft blog post that was never meant to be published:

- 10 trillion parameters. If accurate, the largest known model.
- New "Capybara" tier above Opus, making the lineup: Haiku, Sonnet, Opus, Capybara.
- [93.9% on SWE-bench Verified](https://smartchunks.com/anthropic-claude-mythos-5-10-trillion-parameters-cybersecurity/) - a double-digit lead over Opus 4.6.
- "Dramatically" better coding performance across complex, interconnected codebases.
- Recursive self-correction without intermediate human input.
- [Cybersecurity capabilities](https://edition.cnn.com/2026/04/03/tech/anthropic-mythos-ai-cybersecurity) described as "currently far ahead of any other AI model." Found thousands of zero-day vulnerabilities including a 27-year-old OpenBSD bug.

I can't verify any of these numbers independently. They come from internal documents Anthropic didn't choose to release.

## Project Glasswing

The cybersecurity angle is getting the most mainstream press. [Axios reported](https://www.axios.com/2026/03/29/claude-mythos-anthropic-cyberattack-ai-agents) that Mythos is being tested through "Project Glasswing," a defensive cybersecurity initiative with AWS, Apple, Cisco, CrowdStrike, Google, JPMorganChase, Microsoft, and Nvidia.

The model is NOT available to the public. It's restricted to this consortium for defensive security research. Estimated public access: Q3 2026, possibly timed with Anthropic's reported IPO.

## Pricing Speculation

Nothing official. Based on current Opus 4.6 pricing ($5/$25 per M tokens), analysts estimate 2-3x: roughly $30-45 per M input, $150-225 per M output. That's expensive enough that context management and token efficiency matter even more.

## What This Means for Agentic Coding

Here's my take: a better model raises the ceiling. It does not change the process.

If Mythos delivers on the SWE-bench claims, every tool that uses Claude as a backbone (Claude Code, Cursor, Augment) gets a capability bump. Code generation quality improves. Reasoning over complex codebases improves. That's genuinely exciting.

But the lessons from the last year still apply. The [harness matters more than the model](/blog/the-harness-layer). On SWE-bench Verified, the same model swings nearly 5 points depending on the scaffold wrapping it. A 93.9% model with a bad harness will still produce unmaintainable code. A good harness with Opus 4.6 already ships production software.

The teams that invested in specs, architecture, verification, and harness engineering won't need to change anything when Mythos ships. Their harnesses will just produce better output. That's the whole point.

---

## Sources

1. [Fortune: Anthropic 'Mythos' step change](https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/)
2. [Fortune: Second data leak - Claude Code source](https://fortune.com/2026/03/31/anthropic-source-code-claude-code-data-leak-second-security-lapse-days-after-accidentally-revealing-mythos/)
3. [Lead Stories: Not an April Fools prank](https://leadstories.com/hoax-alert/2026/04/fact-check-leak-of-anthropics-claude-code-source-code-was-not-an-april-fools-prank.html)
4. [CNN: Mythos cybersecurity](https://edition.cnn.com/2026/04/03/tech/anthropic-mythos-ai-cybersecurity)
5. [Axios: Cyberattack concerns](https://www.axios.com/2026/03/29/claude-mythos-anthropic-cyberattack-ai-agents)
6. [SmartChunks: 10T parameters](https://smartchunks.com/anthropic-claude-mythos-5-10-trillion-parameters-cybersecurity/)
