# Use MDEx for Markdown rendering

## Status
Accepted

## Context
The application renders Markdown content extensively — user stories, architecture documents, decision records, and content pages. A fast, spec-compliant renderer with syntax highlighting is needed.

## Options Considered
- **MDEx** — NIF-based CommonMark renderer (comrak) with built-in syntax highlighting (tree-sitter). Very fast.
- **Earmark** — Pure Elixir Markdown parser. Slower but no NIF compilation required.
- **md** — Lightweight Markdown parser. Limited feature set.

## Decision
Use MDEx (`~> 0.5`) as the primary Markdown renderer. It provides CommonMark compliance, GitHub Flavored Markdown extensions, and built-in syntax highlighting via tree-sitter — all critical for rendering code-heavy documentation. Earmark (`~> 1.4`) is retained as a fallback dependency.

## Consequences
- NIF compilation required (Rust toolchain needed for building from source)
- Excellent rendering performance for content-heavy pages
- Syntax highlighting works out of the box without client-side JavaScript
