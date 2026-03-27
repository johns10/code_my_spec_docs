# Use Boundary for compile-time dependency enforcement

## Status
Accepted

## Context
The application follows a strict bounded-context architecture where contexts are the public API boundary. Without enforcement, it's easy for modules to accidentally bypass context boundaries and call child modules directly.

## Options Considered
- **Boundary** — Compile-time dependency checking via `use Boundary` annotations. Integrates with `mix compile`.
- **Manual code review** — Rely on PR reviews to catch boundary violations. Error-prone and doesn't scale.
- **Credo custom checks** — Runtime/static analysis. Less precise than compile-time enforcement.

## Decision
Use Boundary (`~> 0.10`) with `use Boundary` in every module. Context modules export their public API; internal modules (schemas, repositories, services) are not accessible from outside their context.

## Consequences
- Boundary violations are compile errors, caught before code is merged
- Every new module must declare its boundary membership
- The `:boundary` compiler must be in the compiler chain (handled by spex compiler integration)
- Architecture constraints are self-documenting in code
