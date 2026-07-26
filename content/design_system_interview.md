---
slug: design-system-interview
type: documentation
title: The Design System Interview, In Full

protected: false
publish_at: 2026-07-26T00:00:00Z
expires_at: null

meta_title: "The Design System Interview Prompt, In Full"
meta_description: The actual instructions CodeMySpec runs when it interviews you about how your project should look. Five sections, concrete options, and a validation gate.
og_title: The design system interview, published in full
og_description: The real prompt, not a paraphrase. Five sections, concrete options rather than open questions, and a check that fails on empty answers.
og_image: null

metadata:
  author: John Davenport
  category: Design

tags:
  - design-system
  - prompts
  - build-in-public
  - vibe-coding
---

# The design system interview, in full

This is the actual procedure CodeMySpec follows when it runs [the design system step](/design-system). Not a summary of it. If you want to know exactly what the agent is told to do before it asks you anything, it is below.

Publishing it is deliberate. The people who need this have usually been sold something vague once already, and a paraphrase would be one more thing to take on faith. It is also useful on its own: even if you never install anything, these are the five decisions worth making before you let a model build your pages.

## What it produces

A self-contained HTML file at `.code_my_spec/design/design_system.html`, built on the daisyUI CDN with a theme switcher. It is documentation and live preview in the same artifact, which is why it cannot drift from itself. See [three real examples](/documentation/design-system-examples).

The agent modifies a provided template rather than generating HTML from scratch, and it reads the project's component and utility references first.

## The rule that shapes the whole interview

> Concrete options, not open-ended questions. At each step, show concrete options and examples. Do not ask "what colors do you want?" — show palettes and let the user pick.

This is the part most people get wrong when they try to do it by prompting. Asked an open question, you describe a vibe, the model interprets the vibe, and you are back to the average. Asked to pick between named options, you decide.

## 1. Theme

Present the built-in themes by name: `corporate`, `nord`, `dracula`, `winter`, `cupcake`, `emerald`, `cyberpunk`, `valentine`, `garden`, `lofi`, `pastel`, `wireframe`, `luxury`, `night`, `coffee`, `dim`, `sunset`.

Pick a base theme or go custom. Custom means CSS variables under `[data-theme="my-brand"]` with oklch color values.

## 2. Colors

On a custom theme, walk through the primary, secondary, accent and neutral **roles**. On a built-in theme, confirm the palette works or adjust individual roles.

Swatches go into the HTML as you go, so you are looking at the colors rather than imagining them.

## 3. Typography

Heading scale: compact at 1.125, default at 1.25, or spacious at 1.333. Fonts: system, Inter, or custom.

## 4. Layout

- Navigation pattern: sidebar, top nav, or hybrid
- Content width: narrow, medium, or wide
- Page templates needed: list, form, detail, dashboard

## 5. Tone

- Density: minimal or information-dense
- Corners: rounded, slightly rounded, or sharp
- Shadows: none, subtle, or pronounced
- Overall feel: professional, playful, technical

## After every section

The file is rewritten with your choices, so you can keep it open in a browser and watch the palette and type appear as you decide. Changing your mind is cheap right up until pages exist.

## The gate

The step will not close until the file validates. The evaluator parses the HTML and checks that the `<html>` element carries a non-empty `data-theme`, that all five sections exist, and that **each one has content beyond its heading**.

Empty sections fail. That is deliberate, and it is the most important line in the whole procedure:

> The interview is the path to non-empty sections. Do not skip steps to land the file faster.

A design system with a blank colors section is the same vacuum you started with. The check exists so the fast path and the correct path are the same path.

## Using this without CodeMySpec

Nothing above is proprietary. Take the five sections, answer them in a document, and paste that document into whatever tool you are using before you ask for a page. You will lose the live preview and the validation gate, and you will have to remember to reference it every time. But the decisions are the part that matters, and the decisions are right here.

If you would rather it be enforced than remembered, that is [what the harness does](/design-system).
