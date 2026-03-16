# The Five Levels of AI-Assisted Development

When YouTube launched, professional videographers said the same things experienced developers are saying about AI coding tools. "These people aren't filmmakers. They don't understand lighting, composition, narrative structure." They were right.

But YouTube didn't put Hollywood out of business. It expanded the role of video into everything -- training, marketing, education, internal comms. More work in video now than ever. More money too.

And it wasn't just YouTube. Phone cameras got better. Editing software got accessible. Distribution became free. Lighting kits showed up on Amazon for $50. An entire ecosystem emerged around the core capability, and each piece raised the ceiling for what an amateur could produce.

The same thing is happening with code right now.

## Why the Other Analogies Are Wrong

The drawing analogy is popular. Anyone can pick up a pencil. That doesn't make them an artist. The plumbing analogy too -- a vibe plumber hammers the pipe shut, a real plumber finds the root cause.

These analogies miss three things.

**You don't just get a pencil.** When you pick up an AI coding tool, you also get the equivalent of magic glasses that tell you when your drawing is wrong. Verification pipelines, static analysis, BDD specs, automated QA -- none of these exist for pencils. A plumber doesn't get a vibe wrench that also comes with a vibe pressure tester, a vibe pipe inspector, and a vibe building code validator. But in software, that's exactly what's possible. The AI generates code. Procedural tools verify it. The ecosystem around the AI is what closes the quality gap.

**You can make it draw like a different artist.** You can't hand a pencil a Picasso and say "draw like this." But you can hand an AI a codebase with established patterns, architecture docs, and component specs, and it will match the style. The tool adapts. Pencils don't.

**No trade has the same breadth of complexity.** Plumbing has maybe a few hundred patterns. Software engineering has effectively unlimited combinatorial complexity. That's exactly why structured scaffolding matters more here than anywhere -- the problem space is too large for a human to review manually, which means the verification has to be automated.

The real question isn't "can amateurs produce code?" They obviously can. The question is: **what scaffolding do you put around the AI to close the quality gap?**

Not more AI. More structure. The combination of AI with procedural code and human guidance.

## Five Levels

Dan Shapiro described five levels of AI-assisted programming, inspired by the driving automation scale. Simon Willison wrote about them. Here's how I think about them.

### Level 0: Autocomplete

GitHub Copilot tab-completion. ChatGPT snippets you paste in. A faster keyboard. Every IDE has this now.

### Level 1: The Intern

You describe what you want. The AI writes a function or a file. You read every line. The business user saving $10k/month on a custom tool lives here, and there's nothing wrong with that. YouTube-era video. Claude, ChatGPT, Cursor in chat mode all do this well.

Levels 0 and 1 are solved by existing tools. The interesting stuff starts at Level 2.

### Level 2: Pair Programming

You and the AI go back and forth. It writes, you review, you redirect. Most experienced developers using Cursor or Claude Code are here. The "learn to code review" advice is Level 2 advice.

**This is where structured tooling starts to matter.** In CodeMySpec, Level 2 is individual commands that generate one artifact at a time -- spec, code, test -- each with procedural guardrails. The spec validates against a schema. The code validates against the spec. The tests validate against acceptance criteria. You're still driving, but each step has a deterministic safety net.

[How component development works](/documentation/component-development)

### Level 3: AI Develops, Humans Review

The AI generates most of the code. You shift from writing to reviewing. This is where things break down -- human code review doesn't scale when AI generates code 100x faster than you can read it. You start skimming. You miss things.

**In CodeMySpec, Level 3 is orchestrated commands** that develop an entire bounded context end-to-end -- specs for every child component, design review, implementation in dependency order, tests, validation. Procedural code decides what to do next, not AI reasoning about it.

[How context development works](/documentation/context-development)

### Level 4: Humans Define, Systems Verify

The shift. Humans stop reviewing code and start defining what correct looks like. Architecture documents. Specifications. Acceptance criteria. Verification pipelines.

**In CodeMySpec, Level 4 splits into two systems.** Architecture: guided design sessions mapping stories to component graphs, technology decisions captured as ADRs, design reviews gating implementation. QA: story-level testing with a procedural state machine (plan → brief → test → issues), end-to-end journey testing with browser automation, automated issue triage. The human works at "what should this system do and why." Procedural code handles everything below that.

[Architecture design](/documentation/architecture-design) | [QA verification](/documentation/qa-verification)

This is where the YouTube analogy matters most. At Level 4, you're not just giving amateurs a camera. You're giving them the camera, the editing software, the color grading, the distribution, and the analytics -- the full ecosystem that lets amateur output approach professional quality. The scaffolding around the AI is what closes the gap.

### Level 5: Specs In, Software Out

**In CodeMySpec, Level 5 is a graph-driven orchestrator.** It walks stories, contexts, components, and dependencies to find the next unsatisfied requirement and dispatches the right agent task. AI handles implementation. Deterministic evaluation checks the output. The loop continues until every requirement passes. The human defines stories and approves architecture. Everything between stories and deployed software is automated -- procedural code controlling AI, not AI controlling AI.

[How the full cycle works](/documentation/start-implementation)

A full financial services platform -- fuel cards, Stripe Treasury, fraud detection, compliance -- went from empty repository to UAT in six weeks. One person defining requirements. The system handling implementation.

## Where You Can Go

If you built something useful at Level 1 -- that's real. You solved a problem.

But you're not stuck there. The gap between what you're building now and production-grade software isn't talent or a CS degree. It's scaffolding. With the right structure -- specs that define behavior, architecture docs that prevent drift, verification pipelines that catch mistakes mechanically -- a solo founder can produce software that's more consistently correct than what many teams ship manually.

Most conversations about AI coding are Level 1-2 advice: "learn to code review," "write unit tests." Not wrong, but it's asking you to be the quality gate. The real unlock is Level 4 -- define correctness upfront and let automated systems verify it. You don't need to understand every line of code. You need to understand what the code is supposed to do.

That's what YouTube proved about video. The bottleneck was never operating a camera. It was knowing what to point it at. The people who figured that out -- educators, creators, domain experts -- built empires. The same thing is about to happen with software.
