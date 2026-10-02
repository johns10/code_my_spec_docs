# Technology Decisions

What this project is built with, one entry per decision. An entry covers every
dependency that decision brought in — `ecto` is one choice, not four — so this
list is comparable to `mix.exs` procedurally: every dependency should be covered
by exactly one ADR here.

Only current decisions are listed. Superseded ADRs stay in `decisions/` with
their replacement named, so the reasoning survives without the list claiming we
still use them.

## Core Stack
- [Elixir](decisions/elixir.md) — Accepted (pre-made)
- [Phoenix](decisions/phoenix.md) — Accepted (pre-made)
- [LiveView](decisions/liveview.md) — Accepted (pre-made)
- [Bandit](decisions/bandit.md) — Accepted
- [SQLite / ecto_sqlite3](decisions/ecto-sqlite3.md) — Accepted

## Frontend
- [Tailwind CSS](decisions/tailwind.md) — Accepted (pre-made)
- [DaisyUI](decisions/daisyui.md) — Accepted (pre-made)

## Authentication & Security
- [phx.gen.auth](decisions/phx-gen-auth.md) — Accepted (pre-made)
- [Assent (OAuth providers)](decisions/assent.md) — Accepted
- [PowAssent generators (integrations, multi-tenancy, feedback)](decisions/pow-assent-integrations.md) — Accepted
- [Cloak Ecto (encryption at rest)](decisions/cloak-ecto.md) — Accepted

## Testing
- [BDD testing (SexySpex + LiveViewTest)](decisions/bdd-testing.md) — Accepted (pre-made, revised)
- [HTTP and CLI recording (ReqCassette + ExCliVcr)](decisions/http-recording.md) — Accepted

## Infrastructure
- [Oban (background jobs)](decisions/oban.md) — Accepted
- [Boundary (dependency enforcement)](decisions/boundary.md) — Accepted
- [Dotenvy (env config)](decisions/dotenvy.md) — Accepted (pre-made)
- [Hetzner Cloud + Docker Compose (deployment)](decisions/hetzner-deployment.md) — Accepted

## Content & Rendering
- [MDEx (Markdown rendering)](decisions/mdex.md) — Accepted

## Integrations
- [Resend (transactional email)](decisions/resend.md) — Accepted (pre-made)
- [web_push_elixir (push notifications)](decisions/web-push.md) — Accepted

## Audit & Observability
- [PaperTrail (audit logging)](decisions/paper-trail.md) — Accepted
