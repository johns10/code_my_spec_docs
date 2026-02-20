# No DevelopController Task Module

## Status

Workaround in place — controllers route to DevelopContext.

## Problem

`ManageImplementation` had no support for developing `controller` type components. When a story was linked to a controller (e.g., `TransactionWebhookController`), the story-focused orchestrator would report "Story Blocked: No developable component found in dependency chain" because `controller` was not in `@developable_types`.

## Current Workaround

Controllers are now included in `@developable_types` and routed to `DevelopContext` via `task_module_for_component/1`. This works because DevelopContext's lifecycle (spec → child specs → design review → implementation) is generic enough to handle controllers — it derives paths from `module_name`, checks child components, and orchestrates spec/test/implement phases.

## Limitations

DevelopContext makes assumptions that don't perfectly fit controllers:

1. **Naming/prompts** — Phase names reference "Context Specification" and "bounded context architecture". The orchestration prompt says "You are orchestrating the full development lifecycle for this context." This is confusing when developing a controller.

2. **Lifecycle phases** — DevelopContext runs: context_spec → component_specs → design_review → implementation. Controllers typically don't have child components or need a design review phase. The extra phases are harmless (they'll be marked complete if no children exist) but add unnecessary overhead.

3. **Status directory** — Files land in `docs/status/{root}/{controller}/develop_context.md` which is misleading.

## Future: DevelopController

A dedicated `DevelopController` task module would:

- Use controller-appropriate prompt language
- Have a simpler lifecycle: spec → implementation (no child specs, no design review)
- Generate status files under a controller-specific path
- Potentially handle controller-specific concerns (routes, plugs, request validation)

## Priority

Low — the workaround is functional. Controllers are typically thin (delegate to contexts) so the DevelopContext flow produces acceptable results despite the naming mismatch.
