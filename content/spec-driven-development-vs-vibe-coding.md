---
# Metadata for spec-driven-development-vs-vibe-coding.md

# Required fields
slug: spec-driven-development-vs-vibe-coding
type: blog
title: "Spec-Driven Development vs Vibe Coding: When Each One Wins"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Spec-Driven Development vs Vibe Coding"
meta_description: "Vibe coding vs spec-driven development: when each wins, why vibe coding fails on maintained code, and why the real fix is a spec that verifies."
og_title: "Spec-Driven Development vs Vibe Coding"
og_description: "Vibe coding is great for throwaway work and terrible for anything you have to maintain. Here is when to use each, and why the real fix is a spec that verifies."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  featured: false

tags:
  - ai
  - ai-coding
  - spec-driven-development
  - vibe-coding
---

# Spec-Driven Development vs Vibe Coding: When Each One Wins

Vibe coding is the fastest way to get a working prototype I have ever used, and it is the fastest way to build something I cannot maintain. Both of those are true, and the difference between them is the whole point of this article. Vibe coding means you describe what you want in a chat, the agent writes code, you eyeball the result, and you keep prompting until it looks right. Spec-driven development (SDD) means you write a durable specification first, treat that spec as the source of truth, and derive and verify code against it. The first is great for throwaway work. The second is what you reach for the moment a human has to live with the code.

I build with a spec-driven harness daily (CodeMySpec, which I make), so I have a horse in this race and I will flag where my bias shows. But I have also vibe coded plenty, and I am not here to tell you it is useless. I am here to tell you exactly where it stops working, and why writing more markdown is not the fix most people think it is.

## What vibe coding actually is

The phrase comes from Andrej Karpathy, who described "fully giving in to the vibes" and forgetting the code even exists: you talk to the model, accept the diffs, and let the thing run. In practice it looks like a chat thread where you say "build me a signup form," then "no, make it a magic link," then "add rate limiting," and the agent keeps editing until the screen does what you wanted.

It works because the model is genuinely good at producing plausible code fast. For small surfaces, plausible and correct are close enough that you ship before the gap matters.

The structural problem is where your intent lives. In vibe coding, the requirement never gets written down anywhere durable. It lives in the conversation history: a scrollback of half-formed asks, corrections, and reversals. That history is ephemeral. It falls out of the context window. It is not the same thing as the next session's history. And it is certainly not something a teammate, or future-you, can read to understand what the system is supposed to do. The code is the only artifact that survives, and the code only tells you what it does, never what it was supposed to do.

That gap is where drift comes from. The agent forgets a constraint you stated forty messages ago, hallucinates an API that does not exist, or "fixes" a bug by quietly breaking an invariant you never restated. On a 200-line script, you catch it. On a real app with twenty interacting modules, you do not, because no human is holding the whole spec in their head and neither is the model.

## What spec-driven development actually is

SDD inverts the usual relationship between spec and code. Normally code is the source of truth and the spec, if one exists, is a stale document describing what the code used to do. SDD makes the spec the maintained artifact and treats code as derived from it and verified against it. GitHub's Spec Kit puts the philosophy bluntly: specifications don't serve code; code serves specifications.

The workflow most SDD tools converge on is four phases: specify (write the what and why as behavior, no implementation detail), plan (turn that into technical design), implement (decompose into ordered tasks and generate code), and validate (confirm the code matches the spec). Requirements are often written in EARS, a constrained-English template ("WHEN a user submits invalid data THE SYSTEM SHALL show validation errors next to the relevant fields") that removes ambiguity and produces testable acceptance criteria.

The payoff is that the spec becomes durable memory. It survives the context window, model swaps, and the six months between when a feature was built and when someone has to change it. When the agent drifts, you have a written contract to drift against, which means you can catch the drift instead of discovering it in production.

### Not all SDD is equally rigorous

Here is the part that matters more than any feature list, and it is why "just write a spec" is not the answer on its own. Birgitta Bockeler on Martin Fowler's site, echoed almost exactly by the 2026 arXiv paper "From Code to Contract," lays out a three-level rigor spectrum:

1. **Spec-first.** The spec gives initial clarity, then is discarded or allowed to drift once code is generated. The code becomes the source of truth again. This is the default behavior of Spec Kit and Kiro.
2. **Spec-anchored.** The spec is maintained alongside the code for the life of the system, and tests enforce alignment between the two. Bockeler calls this the sweet spot for most production systems.
3. **Spec-as-source.** Humans edit only the spec; machines generate all the code; the human never touches the implementation. The most radical form. Tessl aspires here.

Notice the failure mode hiding in level one. A spec-first tool gives you the clean planning ritual, then lets the spec rot the instant generation starts. You did the work of writing the spec and you still ended up vibe coding, just with extra steps. A spec that nobody checks the code against is documentation, and documentation drifts. The rigor spectrum, not the spec itself, is what separates real SDD from a vibe coding session wearing a markdown costume.

## When vibe coding is the right call

I want to be fair here, because the anti-vibe crowd overcorrects. Vibe coding is the correct tool for a real set of jobs:

- **Throwaway prototypes.** You are testing whether an idea feels right. The code's lifespan is hours. Maintainability is irrelevant by definition.
- **Demos and spikes.** You need something clickable for a meeting or a screenshot. Nobody will extend it.
- **Exploration and learning.** You are poking at an unfamiliar API or library to see how it behaves. The conversation itself is the value, not the artifact.
- **One-off scripts.** A data migration you run once, a quick scraper, a format converter. Write it, run it, delete it.

The common thread is that nobody maintains the output. When the code's entire future is "use once and discard," the durable-spec overhead is pure waste. Reaching for SDD on a throwaway script is the same mistake as vibe coding a payment system, just in the other direction.

## When spec-driven development is the right call

SDD earns its overhead the moment any of these is true:

- **More than one person touches the code.** A teammate cannot read your chat scrollback. They can read a spec.
- **The thing has to survive past this week.** Anything you will revisit, extend, or debug later needs a record of intent that is not buried in conversation history.
- **Correctness has a cost.** Auth, billing, data integrity, anything where a silent wrong behavior is expensive. You want acceptance criteria you can verify, not vibes you eyeballed.
- **The codebase is large enough that no human holds it all.** Once the system exceeds what fits in your head and the model's context window, the spec is the only thing that does.

The honest summary: vibe coding optimizes for speed to first working version; SDD optimizes for the total cost of owning the thing over time. Pick based on whether you have to own it.

| | Vibe coding | Spec-driven development |
|---|---|---|
| Source of truth | Chat history (ephemeral) | Durable spec |
| Best for | Prototypes, demos, scripts | Maintained, multi-person systems |
| Intent record | Lives in scrollback, then gone | Written, versioned, readable |
| Failure mode | Silent drift, forgotten constraints | Spec drift if nothing enforces it |
| Time-to-first-result | Fastest | Slower up front |
| Cost over time | Grows fast as it scales | Front-loaded, flatter later |

## The real fix is not more markdown

Here is where most "stop vibe coding" advice goes wrong. The prescription is usually "write a spec first," and people do, and then they are surprised when the agent still drifts. It always does. Writing the spec was never the hard part. Making the spec govern the code is.

Look back at the rigor spectrum. A spec-first tool generates a beautiful `requirements.md` and then hands off to an agent that treats it as a suggestion. The spec does not gate anything. EARS standardizes how a requirement is phrased; it does not turn that requirement into a test that fails when the code is wrong. A `validate` command that checks whether a markdown section exists is not checking behavior. You can write a thousand lines of spec and still be vibe coding, because nothing in the loop verifies the running code against what you wrote.

The fix is a spec that verifies. Two pieces have to be true. First, the spec has to be a gate: the code is not done until it satisfies the spec, and the system enforces that rather than trusting you to remember. Second, verification has to be real: not "the unit tests pass," but "the behavior described in the spec actually happens when the app runs." Those are different claims, and the gap between them is exactly where vibe coding bugs hide.

This is the design CodeMySpec is built around, and the reason I built it. BDD scenarios (written from acceptance criteria) are a mandatory gate, not an optional doc; spec quality is the explicit lever on code quality. And verification is built in: a QA subagent writes a brief from the BDD specs, boots the real app, drives a real browser through the [Vibium](https://vibium.dev) MCP, screenshots the result, and files issues with severity. Unit tests pass, the BDD specs pass, and then the QA agent clicks the actual button and finds the bug anyway. Prompting is praying. Verification is a guarantee.

To be fair about what is shared: repo-resident specs, bring-your-own-agent, and writing the spec before the code are not unique to any one tool. OpenSpec, Spec Kit, and others meet some of those bars, and portability is table stakes, not a moat. The defensible combination is the mandatory behavioral gate plus built-in live verification on the whole lifecycle, which is the line between "I wrote a spec" and "the spec is enforced." CodeMySpec also happens to be Phoenix and Elixir-native, a vertical no other tool occupies, which matters if that is your stack and not at all if it is not.

## The one-line version

Vibe coding is fine until someone has to maintain what it produced. Spec-driven development is the answer when they do, but only the kind of SDD where the spec actually gates and verifies the code. Everything short of that is vibe coding with more ceremony. If you want to understand the methodology end to end, start with the [pillar guide](/blog/spec-driven-development); if you want to see the verifying-spec model in practice, that is [CodeMySpec](/products/code-my-spec).

## Related Articles

- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [BDD Specs for AI-Generated Code](/blog/bdd-specs-for-ai-generated-code)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [CodeMySpec](/products/code-my-spec)

## Sources

- Vibe coding origin (Karpathy): https://x.com/karpathy/status/1886192184808149383
- GitHub Spec Kit launch and SDD definition: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Spec Kit canonical workflow and philosophy: https://github.com/github/spec-kit/blob/main/spec-driven.md
- Three-level rigor spectrum (Bockeler): https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- Academic SDD definition and taxonomy: https://arxiv.org/html/2602.00180v1
- EARS origin (Mavin / Rolls-Royce, IEEE RE09): https://reqassist.com/blog/ears-requirements-syntax
- Tessl spec-as-source vision: https://tessl.io/blog/announcing-our-series-a-for-ai-native-software-development/
- OpenSpec repo and docs: https://github.com/Fission-AI/OpenSpec
