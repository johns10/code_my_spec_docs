# CodeMySpec CLI

**An AI tool that writes Phoenix contexts through specification-driven development — and understands your existing project out of the box.**

---

## The Big Idea

Drop this into any Phoenix project that follows the prescriptive architecture, and it immediately knows:

- What contexts and components exist
- Which have specs, which have implementations, which have tests
- What's missing or incomplete
- The dependency relationships between modules

**No configuration. No setup. It reads your project and gets to work.**

---

## Agent Tasks (Specification-Driven Workflow)

| Task | What It Does |
|------|-------------|
| `context_spec` | Designs a context with all its child components |
| `context_component_specs` | Writes specs for every child in a context |
| `context_implementation` | Implements entire context + all children |
| `design_review` | Validates architecture against user stories |
| `component_spec/test/code` | Individual component workflows |

**The discipline:** Spec → Tests → Implementation, with validation gates. Tests must align 90%+ with specs. Code is blocked until tests pass.

---

## Phoenix Architecture Respect

- Contexts as **public API** via `defdelegate`
- Proper **layering**: Schemas → Repos → Services → Context
- Understands **parent-child** relationships from module namespaces
- Generates in correct dependency order

---

## Pitch

"CodeMySpec understands your Phoenix project structure instantly — specs, implementations, tests, what's done and what's missing. Then it writes your contexts with architectural discipline: spec-driven, test-validated, properly layered."
