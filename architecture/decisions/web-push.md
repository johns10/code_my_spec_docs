# Use web_push_elixir for browser push notifications

## Status
Accepted

## Context
The application needs to notify users of asynchronous events — completed analysis runs, session updates, QA results — even when they're not actively viewing the page.

## Options Considered
- **web_push_elixir** — Web Push Protocol (RFC 8030) implementation for Elixir. Standards-based, works across browsers.
- **LiveView push** — Use Phoenix PubSub/LiveView for real-time updates. Only works while the page is open.
- **Third-party push service** — Services like OneSignal or Firebase Cloud Messaging. Adds external dependency and cost.

## Decision
Use web_push_elixir (`~> 0.5`) for browser push notifications. It implements the Web Push Protocol directly, enabling notifications even when the browser tab is closed. LiveView remains the primary real-time channel for in-page updates.

## Consequences
- Must generate and manage VAPID keys
- Service worker registration required on the client
- Subscription management (store push endpoints per user/device)
- Complements LiveView real-time updates for background notifications
