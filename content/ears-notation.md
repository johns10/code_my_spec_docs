---
# Metadata for ears-notation.md

# Required fields
slug: ears-notation
type: blog
title: "EARS Notation Explained: The Easy Approach to Requirements Syntax"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "EARS Notation Explained: Requirements Syntax"
meta_description: "What EARS notation is, the five patterns with examples, why AI coding revived it, and how the Easy Approach to Requirements Syntax differs from BDD."
og_title: "EARS Notation Explained"
og_description: "The Easy Approach to Requirements Syntax: the five patterns, examples, and how EARS differs from BDD for AI-generated code."
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
  - ears-notation
  - requirements
---

# EARS Notation Explained: The Easy Approach to Requirements Syntax

EARS stands for Easy Approach to Requirements Syntax, a constrained way of writing requirements in plain English so they come out precise, testable, and free of the usual ambiguity. It is not a new tool or a framework. It is a set of five sentence templates that force you to name the trigger, the system, and the exact required behavior every time. It went quiet for years as an aerospace requirements technique, and it came roaring back in 2025 and 2026 because AI coding agents need unambiguous requirements, and EARS is one of the cleanest ways to write them.

I build a spec-driven development harness, so I read many generated requirements docs. EARS is genuinely good at what it does. It is also narrower than the hype around it suggests. This explainer covers where EARS came from, the five patterns with a concrete example for each, why it resurfaced for AI coding, what it does well, what it does not do, and how it differs from BDD, which is the distinction that matters most if you are using requirements to drive code.

## What EARS Is and Where It Came From

EARS was developed by Alistair Mavin and colleagues at Rolls-Royce, first published in 2009 and presented at the IEEE Requirements Engineering conference (RE09). The team created it while analyzing airworthiness regulations for a jet engine control system, where a vague requirement is not a code-review nit, it is a safety problem. The goal was to take natural-language requirements, which are easy to read but easy to misread, and constrain them just enough to kill ambiguity without forcing engineers into a formal modeling language.

The result is a small grammar. Every EARS requirement follows one of five patterns, and each pattern is built around a single keyword that signals when the requirement applies. The system response always uses "shall." That is the whole idea: a handful of templates that a human can write by hand and a machine can parse.

## The Five EARS Patterns

Here are the five patterns, each with its template and a concrete example. The keyword at the front of each line tells you what kind of requirement it is.

| Pattern | Template | Example |
|---|---|---|
| **Ubiquitous** | The <system> shall <response> | The payment service shall record every transaction with a timestamp. |
| **Event-driven** | When <trigger>, the <system> shall <response> | When a user submits the signup form, the system shall send a verification email. |
| **State-driven** | While <state>, the <system> shall <response> | While the export is running, the system shall display a progress indicator. |
| **Unwanted behavior** | If <condition>, then the <system> shall <response> | If the card number is invalid, then the system shall display a re-enter message. |
| **Optional** | Where <feature is included>, the <system> shall <response> | Where two-factor authentication is enabled, the system shall prompt for a code at login. |

A few notes on how to read these. **Ubiquitous** requirements are always-on: no trigger, no condition, the system just does this. **Event-driven** requirements fire on a discrete trigger. **State-driven** requirements hold for the duration of a state rather than firing once. **Unwanted behavior** is the error and edge-case pattern, and it is the one teams most often forget to write, which is exactly why a template that prompts for it is useful. **Optional** requirements apply only when a feature is present in the build, which keeps configurable behavior from leaking into the always-on set.

A sixth pattern, **complex**, combines a state and a trigger ("While <state>, when <trigger>, the system shall <response>") for cases that need both. Most teams treat it as a composition of the core five rather than a separate pattern, and most introductions, including this one, lead with the five.

The discipline the templates enforce is the point. "Handle errors gracefully" tells an engineer, or an agent, nothing. "If the card number is invalid, then the system shall display a re-enter message" names the condition, the system, and the required behavior, so there is something concrete to build and something concrete to check.

## Why EARS Resurfaced for AI Coding

For most of its life EARS lived in safety-critical and systems-engineering circles. The thing that pulled it into mainstream developer vocabulary was AI coding agents, and specifically the rise of spec-driven development, where a structured specification, not a chat prompt, is the unit of work you hand to the agent.

Amazon's Kiro is the loudest example. Kiro is AWS's spec-first agentic IDE, and its core loop turns one prompt into three generated documents: a `requirements.md` written in EARS notation, a `design.md`, and a sequenced `tasks.md`. Amazon Q Developer used the same EARS-based spec mode before AWS began winding it down in favor of Kiro. When the requirements doc is going to be read by a model rather than only by a human, the constrained grammar pays off twice: it reduces the ambiguity the model would otherwise have to guess about, and it produces acceptance criteria that map cleanly onto individual tasks. I wrote a deeper breakdown of Kiro's spec system in [Kiro Specs Explained](/blog/kiro-specs-explained).

That is the resurgence in one sentence. EARS was built to make requirements unambiguous for humans, and unambiguous requirements turn out to be exactly what an AI agent needs to not drift.

## What EARS Does Well

The strengths are real, and they hold whether a human or an agent is on the receiving end.

- **It forces precision.** You cannot write a valid EARS requirement without naming the trigger or condition, the system, and the response. Vague intent does not survive the template.
- **It reduces ambiguity.** A constrained grammar removes most of the room for two readers, or a reader and a model, to interpret the same sentence differently.
- **It prompts for edge cases.** The unwanted-behavior pattern is a standing reminder to write the error paths, which are the requirements teams most often skip.
- **It is testable and traceable.** Because each requirement names a concrete behavior, you can write a check against it and trace a task back to the requirement that motivated it.
- **It costs almost nothing to adopt.** No tool to install and no runtime. It is a writing convention. You can start using it in your next requirements doc.

## What EARS Does Not Do

This is where the hype outruns the technique, so it is worth being precise.

EARS is requirement syntax. It standardizes how a requirement is phrased. It is not an executable specification, it is not a behavioral test, and it does not verify your code. An EARS requirement like "When a user submits the signup form, the system shall send a verification email" is a clear instruction, but nothing in EARS runs it, checks that the email actually sends, or fails a build when it does not. The acceptance criteria are not executable on their own. You still need tests, and you still need something to run them.

EARS also says nothing about whether the requirement is correct, complete, or consistent with the rest of the system. It makes a requirement well-formed, not well-chosen. You can write a perfectly grammatical EARS requirement for the wrong behavior, and the syntax will not warn you.

So the honest framing is: EARS is a high-quality way to write down what the system should do. Turning that into a guarantee that the system actually does it is a separate problem that EARS does not solve.

## EARS vs BDD

This is the comparison I get asked about most, and it is the one that decides whether EARS is enough for your situation.

EARS and BDD (Behavior-Driven Development, usually written as Given/When/Then) look similar on the page. Both are constrained-English templates. Both push you toward concrete, behavior-oriented statements. The difference is what happens after you write the sentence.

EARS phrases the requirement. BDD phrases the requirement and verifies the behavior. A Given/When/Then scenario is not only a description, it is the input to a test runner: the Given sets up state, the When performs an action, the Then asserts an outcome, and a framework executes all three and tells you pass or fail. EARS has no execution step. It stops at the well-formed sentence.

| | EARS | BDD (Given/When/Then) |
|---|---|---|
| What it is | Requirement syntax | Behavioral specification |
| Templates | When / While / If / Where / ubiquitous | Given / When / Then |
| Phrases the requirement | Yes | Yes |
| Executable | No | Yes (runs as a test) |
| Verifies behavior | No | Yes |
| Origin | Rolls-Royce, 2009 (aerospace) | Dan North, mid-2000s (agile/TDD) |

Roughly 15 to 20 percent of the practical gap between the two is exactly this: EARS gives you a precise statement of intent, and BDD gives you a precise statement of intent that is also the verification. If your only goal is clearer requirements docs, EARS is excellent and lighter weight. If your goal is requirements that prove themselves against running code, you want a behavioral spec that executes.

## Who Uses EARS Today

EARS has two distinct user bases. The original one is systems and safety-critical engineering: aerospace, automotive, defense, medical devices, and other domains where requirements go through formal review and ambiguity carries real cost. That community has used EARS steadily since 2009.

The newer base is AI-assisted development. Kiro and the now-deprecated Amazon Q Developer brought EARS to a much larger audience by generating requirements docs in it, and a wave of 2026 articles and tutorials frame EARS as a way to write better prompts and specs for coding agents. If you have used Kiro's spec mode, you have used EARS whether you noticed the name or not.

## How This Relates to CodeMySpec

I build [CodeMySpec](/products/code-my-spec), a full-lifecycle, specification-driven AI development harness for Phoenix and Elixir, so my view on EARS is shaped by where it sits in a real build pipeline.

EARS is a fine way to write requirements, and CodeMySpec agrees with its core instinct that precise, behavior-oriented requirements beat vague prose. But CodeMySpec's specs are mandatory BDD scenarios (written in a DSL called Spex) plus configurable module specs, not EARS requirement syntax. The reason is the gap above. EARS phrases the requirement; a BDD scenario phrases it and is executable as a test. In CodeMySpec the BDD specs are a mandatory gate, they generate acceptance criteria and tests, and then a QA step boots the real app and drives a real browser to check the behavior in practice. Unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. EARS, by design, has no equivalent of that last step.

The cleaner way to say it: EARS standardizes how you say what the system should do. CodeMySpec makes the behavioral spec a contract the code has to satisfy, then verifies it against the running app. If you want a lightweight requirements convention, EARS is a good one. If you want the requirement enforced and the result verified, that is a different and larger job. For the full picture of how Kiro's EARS-based approach stacks up against this, see [CodeMySpec vs Kiro EARS](/blog/codemyspec-vs-kiro-specs).

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [CodeMySpec vs Kiro EARS: Two Approaches to Spec-Driven AI Development](/blog/codemyspec-vs-kiro-specs)
- [BDD Specs for AI-Generated Code](/blog/bdd-specs-for-ai-generated-code)
- [CodeMySpec](/products/code-my-spec)

## Sources

- https://alistairmavin.com/ears/ : EARS origin (Alistair Mavin, Rolls-Royce, first published 2009), the five patterns with templates and examples, the complex pattern.
- https://kiro.dev/docs/specs/feature-specs/ : Kiro's EARS template and example, requirements.md structure.
- https://kiro.dev/blog/introducing-kiro/ : Kiro spec workflow (requirements/design/tasks), EARS in requirements.md.
- https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ : Amazon Q Developer EOL, Kiro named successor for spec-driven development.
- https://reqassist.com/blog/ears-requirements-syntax : EARS five requirement types, Mavin/Rolls-Royce origin, IEEE RE09.
- https://www.mdpi.com/2079-8954/13/7/567 : EARS in systems engineering, requirements-syntax framing.
- https://makerneo.com/en/articles/what-is-ears-requirements-syntax-how-to-write-better-ai-prompts.html : EARS for AI prompting and spec writing, 2026 framing.
