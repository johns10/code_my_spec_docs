# Use SQLite as the primary database via ecto_sqlite3

## Status
Accepted

## Context
The application needs a database for persistence. Both `ecto_sqlite3` and `postgrex` are present in dependencies. The app is designed to run locally (on developer machines via CLI) and as a hosted web service, requiring a database that works well in both contexts.

## Options Considered
- **SQLite** — Embedded, zero-config, file-based. Perfect for local/CLI usage. No separate server process needed.
- **PostgreSQL** — Full-featured RDBMS. Better for multi-user hosted deployments with concurrent writes.

## Decision
Use SQLite as the primary database via `ecto_sqlite3` (`~> 0.18`). The application's primary use case is local developer tooling where SQLite's zero-configuration, embedded nature is ideal. PostgreSQL support is retained (`postgrex`) for production hosted deployments where concurrent access matters.

## Consequences
- Local development requires no database server setup
- Must be mindful of SQLite's single-writer limitation in hosted mode
- Migrations must be compatible with both SQLite and PostgreSQL dialects
- `postgrex` remains as a dependency for production flexibility
