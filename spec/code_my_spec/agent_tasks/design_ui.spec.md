# CodeMySpec.AgentTasks.DesignUi

## Type

skill

## Intent

Interview the engineer to establish the project's design system.
Produce a self-contained HTML file at
`.code_my_spec/design/design_system.html` that uses DaisyUI CDN with
a theme switcher — both documentation and live preview in one
artifact. The agent walks the engineer through theme / colors /
typography / layout / tone one at a time, modifying an HTML template
as choices are made.

## Done signal

The HTML file exists at `.code_my_spec/design/design_system.html`,
parses cleanly via Floki, has a non-empty `data-theme` attribute on
`<html>`, and contains required `<section id="...">` blocks for each
of `theme`, `colors`, `typography`, `layout`, `tone` — each section
non-empty beyond its heading.

## Dispatch shape

`componentless_task` — project-scoped. Currently not gated by a
specific upstream requirement; runs whenever the engineer wants to
establish the design system. Downstream UI/LiveView work reads the
generated design_system.html as the canonical theme reference.

## Out of scope

- The task does not implement components in code. The artifact is
  reference HTML + live preview, not application code.
- The task does not generate HTML from scratch. It modifies the
  template at `priv/templates/design_system.html` (or the existing
  `.code_my_spec/design/design_system.html` on re-runs).
- The task does not pick choices for the engineer. It presents
  concrete options; the engineer decides.

## Failure modes the agent should avoid

- Asking open-ended questions ("what colors do you want?") instead
  of presenting concrete options.
- Generating HTML from scratch instead of modifying the template.
- Leaving section bodies empty (validator rejects).
- Skipping sections to land the file faster.

## Resources

Required input:
- The active project (for name and description).
- The HTML template at `priv/templates/design_system.html` —
  loaded from disk; falls back to a built-in default template.

Optional input:
- Existing `.code_my_spec/design/design_system.html` — preserved
  and modified on re-runs.
- `assets/tailwind.config.js` — if present, shown to the agent for
  context.
- Existing `lib/**/*core_components*` file — shown so the design
  system complements the existing components.

Required reading:
- `priv/knowledge/design_ui/workflow.md` — the interview procedure
  (concrete options per step, no open-ended questions), required
  sections, done signal.
- `priv/knowledge/ui/daisyui.md` — DaisyUI theme system, components,
  semantic colors.
- `priv/knowledge/ui/tailwind.md` — Tailwind utility patterns.

Produced:
- `.code_my_spec/design/design_system.html` — the live-preview
  HTML, written incrementally as the interview progresses.

## Tools

No task-specific MCP tools. Built-ins (Read, Write, Edit) handle the
template + project file inspections.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Paths
- Floki (for HTML parsing in evaluate)
