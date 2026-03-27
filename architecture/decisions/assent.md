# Use Assent for OAuth provider authentication

## Status
Accepted

## Context
The application needs to authenticate users via third-party providers (GitHub, Google) for single sign-on and to access external APIs on behalf of users (e.g., GitHub repositories).

## Options Considered
- **Assent** — Multi-provider OAuth/OIDC library. Supports GitHub, Google, and many others. Clean strategy pattern.
- **Ueberauth** — Popular Elixir OAuth library with per-provider strategy packages. More ecosystem packages but heavier per-provider dependency footprint.
- **oauth2 library directly** — Lower-level OAuth2 client. Requires manual flow implementation per provider.

## Decision
Use Assent (`~> 0.3`) for OAuth provider authentication. It provides a clean, consistent interface across providers with built-in support for GitHub and Google. The `oauth2` library (`~> 2.0`) remains as a transitive dependency.

## Consequences
- Adding new providers requires minimal code (strategy configuration only)
- Token refresh and storage must be handled by the application
- Works alongside `phx.gen.auth` for the local email/password flow
