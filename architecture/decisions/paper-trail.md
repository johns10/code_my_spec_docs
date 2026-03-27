# Use PaperTrail for audit logging

## Status
Accepted

## Context
The application manages project configurations, user stories, and architecture decisions that benefit from change tracking. Understanding who changed what and when is important for accountability and debugging.

## Options Considered
- **PaperTrail** — Ecto-integrated versioning. Stores change history in a versions table with metadata (who, what, when).
- **Custom audit log** — Build a bespoke audit trail. Full control but significant development effort.
- **Database triggers** — Database-level tracking. Harder to include application-level context (current user, reason).

## Decision
Use PaperTrail (`~> 1.1`) for audit logging on key entities. It integrates directly with Ecto changesets, automatically capturing insert/update/delete history with actor metadata.

## Consequences
- Versions table grows with every tracked change
- Must use `PaperTrail.insert/update/delete` instead of direct `Repo` calls for audited entities
- Provides built-in query functions for version history
