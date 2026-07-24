---
# Metadata for prevent_slop_elixir_codebases.md

# Required fields
slug: prevent-slop-elixir-codebases
type: blog
title: "How to Prevent Slop in AI-Generated Elixir Codebases"

# Publishing control
protected: false
publish_at: 2026-05-25T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "How to Prevent AI Slop in Elixir Codebases"
meta_description: "AI agents write Elixir fast but the codebase rots. A verification priority order that keeps Phoenix apps maintainable, from working-app down to code quality."
og_title: "How to Prevent Slop in AI-Generated Elixir Codebases"
og_description: "Expect the model to fail, then verify in priority order: does it work, does it perform, is it built right, is it clean. The Phoenix superpower is compile-time architecture enforcement."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  series: Preventing AI Slop in Elixir
  series_part: 1
  featured: true

tags:
  - elixir
  - phoenix
  - ai-coding
  - ai-slop
  - code-quality
  - bounded-contexts
  - boundary
  - bdd
  - verification
  - credo
---

# How to Prevent Slop in AI-Generated Elixir Codebases

_Part 1 of "Preventing AI Slop in Elixir," a series on the verification priority order that keeps Phoenix codebases maintainable when an LLM writes most of the code._

---

If you're building production Phoenix apps with AI agents, you know the failure mode. The agent writes code fast. The tests pass. Three weeks later your contexts have bled into each other, a LiveView is calling `Repo` directly, and changing one feature breaks three others. The codebase has turned to slop.

It's measured, not anecdotal. [GitClear's analysis of 211 million lines of code](https://www.gitclear.com/ai_assistant_code_quality_2025_research) found that in 2024 copy-pasted code outpaced refactored code for the first time, and the share of code discarded within two weeks keeps climbing. AI raises output and lowers reuse at the same time.

The instinct is to prompt harder, or read every diff and correct the model by hand. Neither scales. The agent will always drift, and you will run out of attention before it runs out of output.

The fix is to stop hoping the model behaves and start verifying that it did. You can't verify everything with equal rigor, so the real question is *what to verify first*. Here's the priority order I use.

## Expect the model to fail

Most tools in this space assume the model will succeed. They capture your intent, hand it to the agent, and trust the intent survived into the code. That's the spec-driven playbook: generate a pile of markdown, prompt the agent, hope. It's context management, not verification, and it's why those tools produce slop.

Invert the assumption. Expect the model to fail, and wrap it in checks it has to pass before anything ships. Martin Fowler calls this [harness engineering](https://martinfowler.com/articles/harness-engineering.html): guides that steer the agent before it acts, sensors that catch it after. Once you design for failure, the only question left is which failures cost you most. Rank those, and verify them in order.

## Priority 1: Does the application work?

The most expensive failure is shipping a feature that doesn't do what it should. The trap: passing unit tests do not mean a working application. An agent can green a unit suite for a feature that breaks the moment a real user touches it.

Test the original design intent *through the surface*: controllers, LiveViews, the real paths a user takes. I use executable BDD specs ([sexy_spex](https://github.com/Code-My-Spec/spex)) because they read as intent and stay executable as the code changes. Here's a real one, condensed, from an app I maintain:

```elixir
spex "install command is immediately accessible with no auth gate" do
  scenario "visitor sees the install command before any sign-up prompt" do
    given_ "an anonymous visitor on the landing page", context do
      {:ok, context}
    end

    when_ "they load the page", context do
      {:ok, view, html} = live(context.conn, "/")
      {:ok, Map.merge(context, %{view: view, html: html})}
    end

    then_ "the install command renders with a copy button and no auth gate", context do
      assert has_element?(context.view, "[data-test='install-command']")
      assert has_element?(context.view, "[data-test='copy-button']")
      refute has_element?(context.view, "[data-test='auth-gate']")
      {:ok, context}
    end
  end
end
```

It reads as intent and exercises the real surface, the LiveView and its rendered DOM, not internal functions. In review, this is where most of your attention belongs. Two checks: do the specs express what the feature should do, and do they exercise it through the surface without reaching into the domain to fix test data or force a pass? That second one is the tell. A test that mutates internal state to go green is the model gaming your verification, not satisfying it.

The full mechanics of designing the spec boundary, sealing the namespace at compile time, and the Credo rules that backstop both live in Part 2: [How to write BDD specs the LLM can't break](/blog/bdd-specs-llm-cant-break).

## Priority 2: Performance

Less critical than correctness, still worth mechanical verification: did the implementation hold the performance envelope you intended? Write performance tests, review them heavily, treat a regression like a failing spec. What was the intent, does the code hold it.

## Priority 3: Architecture (the Phoenix superpower)

Architecture is where slop accumulates fastest. An agent reaching across a domain boundary or collapsing your contexts turns a navigable codebase into mush. In Phoenix, you can make that a compile error.

Bounded contexts give you real architectural seams. [boundary](https://hex.pm/packages/boundary) (Saša Jurić) lets you declare them and enforce them at compile time:

```elixir
defmodule MyApp.Accounts do
  use Boundary, deps: [MyApp.Repo], exports: [User]
end
```

When the agent writes a LiveView that reaches into `Accounts` internals it shouldn't touch, the compiler rejects it. Not a review comment three days later. A red build, before the code ships. When an agent writes in your app every day, compile-time enforcement is the difference between a codebase that stays navigable and one that rots in a month. This is the biggest reason a Phoenix harness keeps AI output maintainable when a generic one can't.

## Priority 4: Code quality (lowest, cheapest)

Code quality matters least, and it costs little labor because you hand it back to the agent. Encode your standards as [Credo](https://github.com/rrrene/credo) rules and let the model clean up after itself:

```elixir
# .credo.exs: ban raising inside rescue, and similar smells
{Credo.Check.Warning.RaiseInsideRescue, []}
```

Point the agent at the violations and let it resolve them. The result isn't perfect, but the labor cost is minimal, which is what the lowest-priority concern deserves.

## Intent from the model, guarantees from the harness

Rank what you want out of your codebase, then verify it mechanically in that order:

1. Does it work? (BDD specs through the surface)
2. Does it perform? (performance tests)
3. Is it built right? (compile-time architecture enforcement)
4. Is it clean? (Credo rules the agent fixes itself)

The agent provides intent. The harness provides the guarantee. The model is free to fail at every step, because the checks catch it before the failure reaches production.

This priority order is the spine of [CodeMySpec](https://codemyspec.com/developers?utm_source=blog&utm_medium=inline&utm_campaign=prevent-slop-elixir), the Phoenix-native harness I build with. But the order stands on its own whether you adopt the harness or assemble the pieces yourself. Rank your outcomes and verify them mechanically, instead of prompting harder and hoping.

What's your verification priority order? If you're shipping Phoenix with agents, I'd bet it looks similar. If it doesn't, I want to know why.

## Related Articles

- [Why Phoenix Contexts Are Perfect for LLM-Based Code Generation](/blog/why-phoenix-contexts-are-great-for-llms)
- [How CodeMySpec Built and Verified a Fuel Card App in 5 Days](/blog/fuellytics-bdd-and-qa)
- [My first serious coding workflow with AI](/blog/my-first-serious-coding-workflow)
- [How I Built a Local Embedding Pipeline in Elixir That Searches My Own Docs](/blog/elixir-embedding-pipeline)
- [Spec Driven Development in Elixir](/blog/spec-driven-development-elixir)
