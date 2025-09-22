---
component_type: "liveview"
session_type: "code"
---

# LiveView Coding Rules

When possible, include both the markup and the functions in a single .ex file, not split between an .ex file and a .html.heex file. The render function should be at the top.

Use the core_components.ex file wherever possible.

Use DaisyUI classes directly where it's not possible.

Use tailwind classes when you need to create a fully custom visual.