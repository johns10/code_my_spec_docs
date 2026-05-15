# Future feature: user-defined component types with custom rules

Story 77 ("Component Type System") was retired on 2026-05-12. The
existing type system works — `Components.Registry` defines 15 types
(genserver, context, coordination_context, schema, repository,
service, task, registry, behaviour, controller, json, live_context,
liveview, liveview_component, other) with graph templates, parent/child
scoping, and document-type / display-metadata. It's plumbing the
architecture flow already exercises (story 70) so it doesn't need its
own story to assert that types exist.

## What the user actually wants someday

Ability to **define rules for custom types that get rolled into agent
prompts**. Today, type-specific rules live in code (Registry + rule
files keyed by type name). The user wants a path where a solo
developer can register a new type (or augment an existing one) with
custom rules, and those rules show up in the prompts for components
of that type during spec generation / code generation / review.

Not urgent — flagged on 2026-05-12 as "I'm not really sure that's
necessary at the moment." Park here until it is.

## Sketch (do not implement yet)

- Project-scoped "type extensions" or "custom types" record on the
  server (and pushed to the local DB)
- Schema: type name, parent type (or stand-alone), set of rules
  (markdown bodies keyed by lifecycle stage: design / spec / code /
  review)
- Registry-augmenting mechanism: at type-lookup time, look up
  Registry.@type_definitions first, then merge any project-scoped
  custom-type rules layered on top
- Spec/code prompt builders consult the merged rule set when
  emitting type-specific instructions
- MCP tool(s) for the agent (or architect) to manage custom types:
  `register_component_type`, `set_type_rules`, etc.

## Out of scope when this is built

- Project-level overriding of the **graph** for an existing type
  (parent/child structure, terminal requirements). That'd risk
  breaking the requirement-graph projector. Stick to rule-text
  overrides + new type registrations only.
