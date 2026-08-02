---
# Metadata for autocodebench-explained.md

# Required fields
slug: autocodebench-explained
type: blog
title: "AutoCodeBench Explained: The Benchmark That Ranks Languages, Not Just Models"

# Publishing control
protected: false
publish_at: 2026-07-10T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "AutoCodeBench Explained: How It Works"
meta_description: "AutoCodeBench is a 20-language, execution-graded code benchmark from Tencent. How AutoCodeGen builds its problems, what it found, and why Elixir topped it."
og_title: "AutoCodeBench Explained"
og_description: "A plain-English walkthrough of Tencent's 20-language code benchmark: the AutoCodeGen method, the three variants, and the surprising language rankings."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  featured: false

tags:
  - ai
  - ai-coding
  - autocodebench
  - benchmarks
  - llm
  - code-generation
  - elixir
---

# AutoCodeBench Explained: The Benchmark That Ranks Languages, Not Just Models

Most coding benchmarks ask one question: which model is best? AutoCodeBench asks a second one that turns out to be just as interesting: which language do models write best? Its answer surprised many people, so it is worth understanding how the benchmark works before you decide how much to trust it. This is a plain-English walkthrough of what AutoCodeBench is, how it builds its problems, what it found, and where its limits are.

## What AutoCodeBench is

AutoCodeBench is a code generation benchmark published by Tencent Hunyuan in August 2025. It contains 3,920 problems spread evenly across 20 programming languages, roughly 196 problems per language. More than 30 models were graded on it, both open and closed weights, in reasoning and non-reasoning modes.

The 20 languages are Python, C++, Java, JavaScript, Go, Shell, C#, Dart, Elixir, Julia, Kotlin, Perl, PHP, Racket, R, Ruby, Rust, Scala, Swift, and TypeScript. Grading is done by execution: the model writes code, the code runs against hidden test cases in a sandbox, and it either passes or it does not. No partial credit, and no model judging another model's prose. Either the tests go green or they do not.

That execution-first design is the whole point, and it is what separates AutoCodeBench from the benchmarks that came before it.

## The problem it was built to solve

Two things had gone wrong with earlier code benchmarks.

The first is saturation. HumanEval and MBPP, the benchmarks everyone quoted for years, are small and old, and the top models now score in the high nineties on them. When every model gets nearly every question right, the benchmark stops telling you anything. You need harder problems to see daylight between a good model and a great one.

The second is the multilingual problem. Most attempts to test more than one language took an existing English-and-Python benchmark and translated the problems into other languages. Translation introduces its own errors, and it tends to produce problems that feel like Python wearing a Rust costume rather than idiomatic Rust. You end up measuring translation quality as much as coding ability.

AutoCodeBench set out to fix both: harder problems, and genuinely multilingual ones, without an army of human annotators writing and checking thousands of questions by hand.

## How the problems get made: AutoCodeGen

The clever part is the construction method, which the authors call AutoCodeGen. Instead of writing a problem and then finding an answer, it works backwards.

The pipeline runs roughly like this. A model writes a candidate solution, a real function in a real language. The code executes in a sandbox to produce verified inputs and outputs. Only then does a model write the problem statement, working from code that is already known to run and known test cases that already pass. The problem is reverse-engineered from a working, executed solution rather than dreamed up and hopefully-solvable.

This ordering matters for two reasons. Because the solution ran first, every problem is guaranteed to be solvable and every test case is guaranteed to be correct, which is exactly the failure mode that makes hand-written benchmarks leak bad questions. And because the sandbox does the verification, the process scales to thousands of problems in 20 languages without a human checking each one. The authors argue this gives better test coverage than manual authoring, and the execution guarantee is hard to argue with.

## The three flavors

AutoCodeBench ships in three variants, and knowing which one a number came from saves you from comparing two figures that never measured the same thing.

- **AutoCodeBench** is the full 3,920-problem set. This is the headline benchmark.
- **AutoCodeBench-Lite** is a 1,586-problem subset, filtered to problems that at least two models solved. It is a cleaner, slightly easier set for quick comparisons.
- **AutoCodeBench-Complete** uses 1,000 problems with three-shot prompting, designed to evaluate raw base models, the pretrained models before any instruction tuning or reinforcement learning.

That third variant is the one people skip, and it is quietly the most interesting, for reasons I will come back to.

## What it found

The model rankings are what you would expect: frontier models from the big labs sit at the top, and Claude Opus 4 leads the overall average. Fine. The language findings are where it gets worth reading.

The headline is that language choice moves the numbers as much as model choice does. The benchmark reports an average across all languages of 74.8 percent on the "solved by at least one model" measure, but the per-language spread is enormous. The best language sits near the ceiling, and the worst languages drag well below the average.

And the ranking is not the one you would guess from training-data volume. Python, the most-written language on the internet and surely the most-represented in every model's training set, comes in last on that measure at 63.3 percent. Elixir, a comparatively niche functional language, comes in first at 97.5 percent, ahead of Kotlin, C#, and Racket. For most of the frontier models, Elixir is the single language they score highest on.

If raw corpus size drove performance, this ranking would be upside down. It is not, which means something other than "how much code the model saw" is doing the work. I dug into the why of that in the companion piece, [why Elixir is the best language for LLMs](/blog/why-elixir-is-the-best-language-for-llms); the short answer is that language design traits like immutability, stable APIs, and verified documentation help a model reason about code more than sheer volume does.

Here is the detail that rules out the easy objection. That effect shows up in AutoCodeBench-Complete too, the base-model variant. If a language's advantage only appeared after instruction tuning, you could dismiss it as something the labs polished in during alignment. When it shows up in pretrained base models that never went through that step, the advantage is coming from the language and the training data, not from the fine-tuning. That is why the Complete variant matters more than its small size suggests.

## What it means if you build with AI

Two practical takeaways.

First, treat language as a variable you can tune, not a fixed cost. If you are starting a greenfield project that an agent will do most of the typing on, the language you pick changes how good the first draft is, measurably. That is a lever most teams never think to pull.

Second, get literate about which benchmark number you are being shown. "Model X scores 82 percent on AutoCodeBench" is meaningless without knowing the variant, the language, and the mode. A frontier model's Elixir score and its JavaScript score can differ by 40 points on the same benchmark. Averages hide that, and averages are what get quoted in headlines.

{{enforced_boundary_cta shape="aside" headline="Elixir tops AutoCodeBench at 97.5 percent. Python finishes last at 63.3." sub="Both numbers come from self-contained functions, not from an application with architecture." body="CodeMySpec enforces context boundaries in Phoenix, so a violation fails the build instead of landing in review." label="Set it up on a Phoenix project you have" campaign="autocodebench-explained"}}

## Where AutoCodeBench stops

No benchmark is the last word, and this one has honest limits.

It is one benchmark with roughly 196 problems per language, a real sample but not a huge one. The problems are themselves LLM-generated through the AutoCodeGen loop, which could bias toward certain styles of problem, though the same method built every language set, so the cross-language comparison stays fair. And a benchmark of self-contained function-writing problems is not the same as building and maintaining a real application, where architecture, dependencies, and long-lived state matter more than solving a tidy puzzle.

The right way to hold the result is as strong, converging evidence rather than settled law. The language rankings line up with a coherent explanation and they reproduce across models and modes, which is about as much as any single benchmark can offer. Take it seriously, and keep the caveats attached.

## Related Articles

- [Why Elixir Is the Best Language for LLMs](/blog/why-elixir-is-the-best-language-for-llms)
- [Why Phoenix Contexts Are Great for LLMs](/blog/why-phoenix-contexts-are-great-for-llms)
- [Spec-Driven Development for Elixir and Phoenix](/blog/spec-driven-development-elixir)

## Sources

- AutoCodeBench: Large Language Models are Automatic Code Benchmark Generators (Tencent Hunyuan). Paper: https://arxiv.org/abs/2508.09101
- AutoCodeBench project page and leaderboard: https://autocodebench.github.io/
- AutoCodeBench code: https://github.com/Tencent-Hunyuan/AutoCodeBenchmark
- AutoCodeBench dataset: https://huggingface.co/datasets/tencent/AutoCodeBenchmark
- José Valim / Dashbit, "Why Elixir is the Best Language for AI": https://dashbit.co/blog/why-elixir-best-language-for-ai
