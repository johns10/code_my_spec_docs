# CodeMySpec.Integrations.Providers.Cloudflare

Cloudflare connection implementing Integrations.Providers.Behaviour — config/0, strategy/0 and normalize_user/1 — so the token lands in an Integration row encrypted at rest like every other provider. Covers the scopes the devops routine needs: DNS edit plus Registrar write. Provisioning.Cloudflare reads its token through Integrations rather than holding a credential of its own.

## Type

module
