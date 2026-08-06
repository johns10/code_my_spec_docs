---
# Metadata for why-elixir-is-the-best-language-for-llms.md

# Required fields
slug: why-elixir-is-the-best-language-for-llms
type: blog
title: "Why Elixir Is the Best Language for LLMs (and What the Benchmarks Actually Show)"

# Publishing control
protected: false
publish_at: 2026-07-09T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Why Elixir Is the Best Language for LLMs"
meta_description: "AutoCodeBench tested 20 languages: LLMs solve Elixir better than any other, and it is the top language for nearly every frontier model. Here is why."
og_title: "Why Elixir Is the Best Language for LLMs"
og_description: "On a 20-language benchmark, LLMs do their best work in Elixir. A look at the data, the reasons, the honest limits, and what to build with it."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  featured: false

tags:
  - ai
  - ai-coding
  - elixir
  - phoenix
  - llm
  - code-generation
  - autocodebench
  - benchmarks
---

# Why Elixir Is the Best Language for LLMs (and What the Benchmarks Actually Show)

On the largest multi-language code generation benchmark published so far, large language models solve Elixir problems at a higher rate than any of the other nineteen languages tested. That is the short version. The longer version is more interesting, because Elixir is a low-resource language. The internet holds a fraction of the Elixir code it holds for Python or JavaScript, so the models had far less to learn from. They came out ahead anyway. This post walks through what the benchmark found, why it happens, where the claim stops being airtight, and what any of it means if you build software with AI.

## The evidence

The benchmark is AutoCodeBench, published by Tencent Hunyuan. It contains 3,920 problems spread evenly across 20 languages, roughly 196 problems each, and it grades answers by running the generated code in a sandbox rather than by eyeballing it. More than 30 models were evaluated, open and closed, in both reasoning and non-reasoning modes. Tencent has no stake in Elixir, which is part of what makes the result worth paying attention to.

Two numbers carry the story.

The first is the union upper bound: take every problem that at least one model solved, and ask what share of each language that covers. Elixir sits at 97.5 percent, the highest of all 20 languages, and the gap is wide.

| Rank | Language | Upper bound (%) |
|---|---|---|
| **1** | **Elixir** | **97.5** |
| 2 | Kotlin | 89.5 |
| 3 | C# | 88.4 |
| 4 | Racket | 88.3 |
| 5 | Ruby | 79.5 |
| n/a | Benchmark average | 74.8 |
| 20 | Python | 63.3 |

Python, the language with more training data than any other on earth, lands last at 63.3.

The second number is more telling, because it looks at individual models rather than the union. For nearly every frontier model, Elixir is the single language it scores highest on, by a margin of roughly 30 points over its own overall average.

| Model (reasoning mode) | Overall average (%) | Elixir (%) |
|---|---|---|
| Claude Opus 4 | 52.4 | 80.3 |
| Claude Sonnet 4 | 51.1 | 81.8 |
| OpenAI o4-mini | 50.0 | 82.3 |
| OpenAI o3-high | 51.1 | 80.8 |
| Grok-4 | 50.9 | 76.8 |
| DeepSeek-R1 | 50.2 | 77.3 |

Every model in that table does its best work in Elixir. The non-reasoning results tell the same story: Claude Opus 4 scores 82.3 on Elixir with reasoning turned off, again its top language. The effect, then, is not a quirk of one lab or one prompting mode. It shows up across labs, across model sizes, and across both modes.

The part that should stop you is the training-data angle. Language models learn from what they have seen, and they have seen an ocean of Python and JavaScript and a puddle of Elixir. If corpus size drove performance, Python would win and Elixir would sit near the bottom with the other niche languages. The opposite happened. Elixir beat languages with roughly ten times its training data. Whatever is going on, it is not "the model memorized more Elixir."

One more slice of the data rules out the easy counter-explanation that this is a chat-tuning artifact. AutoCodeBench includes a variant, Complete, that grades raw base models with three-shot prompting, before any instruction tuning or reinforcement learning from human feedback. Elixir lands in the upper half there too: DeepSeek-Coder-V2-Base scores 52.0 on it, Seed-Coder-8B-Base 48.0. If the advantage were something the labs polished in during alignment, it would not show up in models that never went through that step. It shows up anyway, which points back at the language itself.

## Why it happens

The benchmark tells you Elixir wins. It does not tell you why. José Valim, the creator of Elixir, wrote the clearest explanation at Dashbit, and his argument is that the result is not luck. It falls out of design choices that happen to line up with what a language model needs. Five of them matter.

**Immutability keeps reasoning local.** In Elixir, data goes into a function and a new value comes out. Nothing mutates behind your back. Valim calls the absence of hidden side effects "no spooky action at a distance," and for a model with a finite context window that is the whole game. The less surrounding code the model has to pull in to be sure of what a function does, the fewer chances it has to be wrong. The pipe operator makes the data flow visible on one line:

```elixir
"Elixir is awesome" |> String.split() |> Enum.frequencies()
```

That transparency scales up to the module boundary too, which is the argument I made separately about [why Phoenix contexts are good for LLMs](/blog/why-phoenix-contexts-are-great-for-llms): a well-drawn context is a small, self-contained surface a model can reason about without loading the rest of the app.

**Documentation is a verified contract.** Elixir separates the public contract, written with the `@doc` attribute, from ordinary implementation comments. The examples inside those docs are runnable, and they execute as part of the test suite. The documentation cannot quietly drift out of sync with the code, because the build fails when it does. On top of that, the ecosystem centralizes on HexDocs with versioned, indexed search. The practical effect is that the text the models trained on was correct, and the text an agent retrieves at runtime is correct.

**A decade of stability keeps the signal clean.** Elixir has been on version 1.x since 2014. Phoenix went from 1.0 to 1.8 without breaking the app underneath you. Ecto has been on 3.x since 2018. Code written five or eight years ago still runs. That matters more than it sounds, because it means the training data is not polluted with three mutually incompatible ways to do the same thing. The model is not confused about which API is current, because the old one is still the current one. When something does get deprecated, the compiler emits a warning with a migration path, which an agent can act on directly.

**The feedback loop is fast, honest, and non-blocking.** Elixir compiles, and the compiler flags unused variables, undefined functions, and unreachable clauses. The recent type inference work catches more of these with few false alarms. Crucially, they arrive as warnings rather than hard stops, so an agent can keep working and clean them up in a pass instead of grinding to a halt on the first issue. Compilation and tests both run in parallel across cores. The agent gets a tight, trustworthy signal about whether it is on track.

**The operational surface is small, and the runtime is transparent.** The BEAM, the virtual machine Elixir shares with Erlang, ships concurrency, distribution, and pub/sub in the box. A typical Phoenix application is the framework plus a database, not a sprawl of Redis, a message queue, and three serverless functions for an agent to hold in its head. Development mirrors production. And the runtime is introspectable: every lightweight process exposes its state and current work, viewable in Phoenix LiveDashboard or through code. Tidewave, an MCP server, hands a running application to a coding agent so it can inspect live state while it debugs, rather than reading source and guessing.

Valim's larger point is that these compound. Immutability lowers the context a model needs to be correct. Verified docs and long stability keep the training signal clean and current. Fast feedback and live introspection let an agent correct itself quickly when it does slip. Getting the first draft right and iterating well from there is the exact shape of agentic coding.

## The honest limits

I want you to trust this, so here is where the claim stops being airtight.

It is one benchmark. 196 problems per language is a real sample, not an enormous one, and the problems were themselves generated by an LLM and sandbox loop, a method that could favor certain styles of problem. The same method built every one of the 20 language sets, so the comparison between languages is fair, but "won this benchmark" is not the same as "proven best for all time." Treat the result as strong, converging evidence, not a closed case.

The claim also needs care in the telling. Elixir does not win every cell of the table. For weaker models, languages like C# and Shell often score higher on average, probably because there is so much boilerplate for the model to have memorized. The two findings that hold up under scrutiny are the ones above: the union upper bound (97.5 percent, comfortably first) and the frontier-model pattern (Elixir is the top language for Opus 4, Sonnet 4, o3, o4-mini, Grok-4, and DeepSeek-R1). One frontier model breaks the pattern, Gemini 2.5 Pro, which edges Elixir out with C#. Flatten the story to "Elixir beats everything everywhere" and someone will pull up that column, and they will be right to. The precise version is the strong one.

Then the standard objection: Elixir is niche, and hiring for it is hard. That is true for humans, and it cuts the other way for agents. A model does not have a hiring problem. A small, stable, consistent language is easier for it to hold in context than a large one with ten competing dialects. The property that makes Elixir a harder sell to a staffing manager is the property that makes it easier for a coding agent.

## What a better language buys you, and what it does not

Here is the part that matters if you are deciding what to build with. A better language raises the floor of the first draft. On this evidence, an agent writing Elixir starts from a better place than the same agent writing Python. That is real, and it is worth having.

It is also not the whole job. A cleaner first draft is not a correct application. The model still writes code that looks right and is subtly wrong. It still needs a target, a written definition of what "done" means for the feature at hand, and it still needs a check that the running application actually behaves the way you intended. The language makes the draft better. It does not make the system correct. That gap exists whether you write Python or Elixir. Elixir hands you a better draft to start closing it from.

{{enforced_boundary_cta shape="aside" headline="Elixir tops AutoCodeBench at 97.5 percent while Python, with the most training data, lands last." sub="A better first draft is not a correct application, and the language cannot tell the model what done means." body="CodeMySpec makes BDD scenarios a required gate on Phoenix contexts, then a QA agent drives the running app." label="See how the boundary is enforced" campaign="why-elixir-is-the-best-language-for-llms"}}

## How CodeMySpec compounds the advantage

Closing that gap is where CodeMySpec sits. CodeMySpec is a specification-driven AI development harness built for Phoenix and Elixir, and it is Elixir-native in the literal sense: Phoenix contexts, LiveView, Ecto, and OTP are first-class, not a generic template with an Elixir mode bolted on. Stack-generic tools cannot stand on the AutoCodeBench floor, because they are not built on it. This is also the through-line of [spec-driven development for Elixir](/blog/spec-driven-development-elixir).

On top of that floor, CodeMySpec adds the two things the language cannot give you.

A target. Every feature starts as a behavioral specification, written as BDD scenarios in the Spex DSL, and those specs are mandatory rather than optional documentation. The model is not guessing what you meant; it is building toward acceptance criteria you wrote down. A requirement graph tracks every artifact, the spec, the tests, the implementation, and the results, and computes what to work on next.

A check. This is the part no other tool in the category does. After the unit tests pass and the behavioral specs pass, a QA agent boots the real application, drives a real browser, clicks the actual buttons, screenshots what it sees, and files issues with severity when the running app misbehaves. Unit tests pass, specs pass, and then the QA agent clicks the button and finds the bug anyway. That is verification on the live application, not a promise that the code looked correct.

And you bring your own agent, your own model, and your own keys, with no token markup. That means you can act on the AutoCodeBench result today: point Claude Opus 4, the model that does its single best work in Elixir, at an Elixir codebase, inside a harness that gives it a spec to aim at and a live QA pass to catch what it still gets wrong.

Elixir is why the model gets the draft right. The harness is why the app is right.

## Related Articles

- [EarWitness: A Local-First Build by the Harness](/case-studies/ear-witness)
- [Why Phoenix Contexts Are Great for LLMs](/blog/why-phoenix-contexts-are-great-for-llms)
- [Spec-Driven Development for Elixir and Phoenix](/blog/spec-driven-development-elixir)
- [Spec-Driven Development in 2026: The Complete Guide](/blog/spec-driven-development)

## Sources

- AutoCodeBench: Large Language Models are Automatic Code Benchmark Generators (Tencent Hunyuan). Paper: https://arxiv.org/abs/2508.09101
- AutoCodeBench project page and leaderboard: https://autocodebench.github.io/
- AutoCodeBench code: https://github.com/Tencent-Hunyuan/AutoCodeBenchmark
- AutoCodeBench dataset: https://huggingface.co/datasets/tencent/AutoCodeBenchmark
- José Valim / Dashbit, "Why Elixir is the Best Language for AI": https://dashbit.co/blog/why-elixir-best-language-for-ai
- Allan MacGregor, "Why AI Coding Agents Love Elixir": https://allanmacgregor.com/posts/why-ai-coding-agents-love-elixir
- ElixirForum discussion, "LLM Coding Benchmark by language": https://elixirforum.com/t/llm-coding-benchmark-by-language/72634
