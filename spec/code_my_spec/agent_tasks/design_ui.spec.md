# CodeMySpec.AgentTasks.DesignUi

## Type

module

Interviews the user to establish the project's design system, producing a self-contained HTML file (`docs/design/design_system.html`) that serves as both documentation and live preview. The file uses the DaisyUI CDN with a theme switcher so colors, typography, and components render in the actual theme. Custom themes are defined as CSS variables (`[data-theme="my-brand"]`) directly in the file — the same values that go into `tailwind.config.js`. The agent walks the user through theme selection, color palette, typography scale, layout patterns, and tone, building the HTML as they go. All LiveView agent tasks (LiveViewSpec, LiveViewTest, LiveViewCode) reference this file for visual consistency.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Components.ComponentRepository
- Floki

## Functions

### command/3

Generate the prompt that guides the agent through interviewing the user about design decisions and producing the design system HTML file.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Check if `docs/design/design_system.html` already exists via `Environments.file_exists?/2`
2. If exists, read current content — the agent should walk through revisions rather than starting fresh
3. If not exists, load the HTML template from `priv/templates/design_system.html` — a complete, working HTML file with DaisyUI CDN, theme switcher, all required sections with placeholder content, a commented-out custom theme CSS block showing the oklch variable format, and live-rendered examples (swatches, typography, buttons, alerts, forms, tables, empty states). The agent modifies this template rather than generating HTML from scratch.
4. Read the project's `tailwind.config.js` for existing theme/color configuration
5. Read `core_components.ex` to understand available component primitives
6. Include the template (or existing file) content in the prompt
7. Build prompt instructing the agent to interview the user section by section:
   - **Theme**: present DaisyUI built-in themes (corporate, nord, dracula, etc.) by name, ask user to pick a base or go custom
   - **Colors**: if custom, walk through primary/secondary/accent/neutral roles with oklch values; if built-in, confirm the palette works
   - **Typography**: ask about heading scale, density, font preferences
   - **Layout**: ask about navigation pattern (sidebar, top nav), content width, page templates (list, form, detail, dashboard)
   - **Tone**: ask about visual personality — minimal vs dense, rounded vs sharp, shadow depth
8. Instruct agent to modify the template based on user's choices — update `data-theme`, fill in custom CSS variables, adjust section content — rather than writing HTML from scratch
9. Instruct agent to show options and examples at each step, not just open-ended questions
10. Return the prompt text

**Test Assertions**:
- returns ok tuple with prompt text
- loads template from priv/templates/design_system.html for new projects
- includes existing design system content when file already exists
- includes tailwind config when available
- includes core_components reference
- prompt includes the template or existing file content
- prompt instructs agent to interview user section by section
- prompt instructs agent to present DaisyUI theme options
- prompt instructs agent to modify template rather than generate from scratch
- includes project name and description for context

### evaluate/3

Validate the design system HTML file has all required sections and a theme definition.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Read `docs/design/design_system.html` via `Environments.read_file/2`
2. Parse HTML with Floki
3. Check `data-theme` attribute exists on `<html>` element
4. Check required `<section>` elements exist by id: theme, colors, typography, layout, tone
5. Check each section has content (not empty)
6. Return `:valid` if all checks pass
7. Return `:invalid` with feedback listing missing sections or empty content

**Test Assertions**:
- returns {:ok, :valid} when HTML has all required sections and theme
- returns {:ok, :invalid, feedback} when sections are missing
- returns {:ok, :invalid, feedback} when data-theme is not set
- returns {:ok, :invalid, feedback} when a section is empty
- returns error when file does not exist
- returns error when file cannot be parsed as HTML
