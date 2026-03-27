# Use Oban for background job processing

## Status
Accepted

## Context
The application needs reliable background job processing for tasks like static analysis runs, transcript replay, webhook delivery, and other async operations that shouldn't block request handling.

## Options Considered
- **Oban** — Full-featured job processing built on PostgreSQL/SQLite, with scheduling, retries, unique jobs, telemetry, and a web dashboard.
- **GenServer/Task** — Built-in Elixir primitives. Simple but no persistence, no retries across restarts, no observability.
- **Exq** — Redis-backed job processor. Adds Redis as a dependency.

## Decision
Use Oban (`~> 2.19`). It leverages the existing database (no new infrastructure), provides durable job persistence, automatic retries with backoff, cron scheduling, and excellent observability via telemetry. Its queue-based model maps well to the different workload types (analysis, notifications, integrations).

## Consequences
- Jobs survive application restarts
- Must define worker modules for each job type
- Database tables for job storage (migrations provided by Oban)
- Queue configuration in application config
