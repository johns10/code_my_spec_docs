---
slug: spec-driven-development
type: page
title: What Is Spec-Driven Development with AI?

protected: false
publish_at: 2026-07-25T00:00:00Z
expires_at: null

meta_title: "What Is Spec-Driven Development? AI Coding, Explained"
meta_description: Spec-driven development means writing a specification first, then letting an AI agent build from it. Here is what it is, why it matters, and the tools that do it.
og_title: What is spec-driven development with AI?
og_description: Write the specification first, then let the agent build from it. The practice, where it came from, and the tools that do it.
og_image: null

metadata:

tags:
  - spec-driven-development
  - ai-coding
  - methodology
  - tdd
  - bdd
---

# What is spec-driven development with AI?

**Spec-driven development is a way of building software where you write a specification first, then an AI agent builds the code from it, instead of prompting the agent freeform.** The spec says what the software should do and how to structure it, and the agent's job is to satisfy it.

This reverses the usual AI-coding order. Most people open a chat window, describe a feature, and accept whatever the model returns. Spec-driven development puts a written, reviewable artifact between the idea and the code, so the agent has a fixed target and you have something to check its work against.

## How is it different from vibe coding?

**Vibe coding means prompting an AI for code and running with whatever works. Spec-driven development writes down the intended behavior and architecture first, then holds the code to it.** Vibe coding optimizes for speed to a running thing. Spec-driven development optimizes for code you can trust and maintain.

The gap shows up as the project grows. A vibe-coded app can look fine at five screens and come apart at fifty, because nothing pins down the architecture and no one wrote the behavior down. A spec is what keeps the tenth feature consistent with the first.

## Where did spec-driven development come from?

**The idea predates AI.** It grew out of test-driven development (TDD) and behavior-driven development (BDD), which also insist on writing intended behavior before the code. AI agents made the practice matter again, because now something else writes the code and needs a precise target.

Kent Beck popularized TDD as part of Extreme Programming around 2000: write a failing test, then the code that passes it. Dan North described BDD around 2006 as a way to state behavior in plain language, using the Given/When/Then form. For years, that discipline earned little when a human wrote the code anyway. With an agent writing the code, a precise spec is the difference between a correct result and a plausible-looking wrong one.

## Why does spec-driven development matter more with AI?

**AI writes code fast enough to bury a codebase in a few weeks, and volume without structure becomes debt.** A spec constrains the agent to a shape you chose. Without one, the agent invents its own structure on every task, and the pieces stop fitting together.

The failure mode is code that passes its tests but does not actually work, in a codebase that looks fine until you try to change it. [GitClear's 2025 study](https://www.gitclear.com/ai_assistant_code_quality_2025_research) of 211 million lines of code found copy-pasted code climbing and refactoring falling as teams adopted AI tools, with duplicated code passing refactored code for the first time in 2024. A spec does not slow the agent down. It points the speed at a target.

## What does the spec-driven workflow look like?

**You go from a user story to a spec, from the spec to tests, from tests to code, then verify and QA, in that order.** Each step produces an artifact the next step depends on, so the agent works one step at a time instead of doing everything in one prompt.

A typical loop:

1. Write the user story and its acceptance criteria.
2. Turn it into a specification: what the component does, and how it fits the architecture.
3. Generate tests from the spec.
4. Write code that passes the tests.
5. Review the design, and verify the build compiles and the tests pass.
6. QA the running app against the original story.

Some tools stop after step 2. Others carry all six.

## What tools do spec-driven development?

**The main ones are GitHub Spec Kit, AWS Kiro, OpenSpec, and CodeMySpec.** They differ mostly in how far they carry the work past the spec: Spec Kit and Kiro focus on producing the spec and the task plan, while CodeMySpec continues through tests, verification, and QA.

- **GitHub Spec Kit:** an open-source toolkit that scaffolds a spec, a plan, and a task list for your agent to build. Free, lightweight, works on any stack.
- **AWS Kiro:** a spec-driven IDE that turns a prompt into requirements, a design, and tasks inside its own editor. Stack-agnostic, backed by AWS.
- **OpenSpec:** an open-source, spec-first workflow for coding agents, made by Fission-AI.
- **CodeMySpec:** a harness that runs inside the coding agent you already use and carries the spec through generated tests, step-by-step verification, and browser QA. Deepest on Phoenix and Elixir. [See how it works](/developers).

## How do you start with spec-driven development?

**Start with one real feature: write down what it should do and how it fits your architecture before you let the agent write code.** You do not need a heavy process. One clear spec per feature, plus generated tests, is enough to feel the difference from freeform prompting.

Pick a tool that matches your stack and how far you want it to carry the work. Then try it on a feature you would otherwise vibe-code, and compare the two results side by side.

## Frequently asked questions

**Is spec-driven development the same as TDD?**

No, but they overlap. TDD writes tests before the code. Spec-driven development writes a specification before the code, and that spec can generate the tests. The spec sits a level above the tests.

**Do you still write code in spec-driven development?**

The agent writes most of it. You write the spec and review the result. On a full-lifecycle tool, the tool also generates and runs the tests, so your job is the intent and the sign-off, not the boilerplate.

**Is spec-driven development slower?**

Up front it costs a few minutes on a spec. It saves the hours of prompt iteration and rework that freeform prompting spends later, which is why it tends to be faster over a whole feature, not slower.

**What is the best spec-driven development tool?**

The answer depends on your stack and how far you want the tool to carry the work. Spec Kit fits a lightweight, any-stack workflow. Kiro gives you a full IDE. OpenSpec is open-source and stack-agnostic. CodeMySpec carries the spec through tests, verification, and QA, and goes deepest on Phoenix and Elixir.
