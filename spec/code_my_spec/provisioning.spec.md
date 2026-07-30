# CodeMySpec.Provisioning

Procedural infrastructure setup. Owns the ordered step sequence, each step's validated state, resumption after a fix or an external round-trip, and automatic escalation to the setup agent when a step fails. Steps are idempotent and converge rather than duplicating resources. State and ordering live server-side; shell steps execute on the device through the harness channel. Setup only — never tears anything down.

## Type

coordination_context
