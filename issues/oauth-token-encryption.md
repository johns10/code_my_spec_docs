# OAuth Access Token Encryption at Rest

**Severity:** Critical — pre-public-launch blocker.
**Logged:** 2026-04-20 during pre-ship security audit.

## Problem

`oauth_access_tokens` and `oauth_access_grants` store bearer tokens as plaintext `:string` columns (`priv/repo/migrations/20250718022705_create_oauth_tables.exs:32-46`). Every other long-lived secret in the app (`client_users.oauth_token`, `integrations.access_token`) goes through `CodeMySpec.Encrypted.Binary` via `CodeMySpec.Vault`. OAuth tokens are the odd one out.

If the DB is compromised (backup leak, replica exposure, dump misplaced), every issued bearer token is immediately usable against the API until natural expiry.

## Why it's not a 10-minute migration

ExOauth2Provider looks tokens up via direct equality:

- `ExOauth2Provider.AccessTokens.get_by_token/2` at `deps/ex_oauth2_provider/lib/ex_oauth2_provider/access_tokens/access_tokens.ex:34` → `Repo.get_by(token: token)`
- `get_by_refresh_token/2` at line 52 → `Repo.get_by(refresh_token: refresh_token)`
- `get_by_previous_refresh_token_for/2` at line 249, same pattern
- `ExOauth2Provider.AccessGrants.get_by_token/2` → same pattern

Our Cloak config uses `AES.GCM` with random IV (`config/config.exs:118-126`). Same plaintext → different ciphertext on every encryption → equality lookups fail and you can't put a unique index on encrypted columns.

Naively swapping the field type to `CodeMySpec.Encrypted.Binary` will brick token validation. Don't.

## Options

### A. Blind-index pattern (production-correct)
- Add `token_hash` (SHA-256 of plaintext, unique-indexed) and keep `token` encrypted with `Cloak.Ecto.Binary`.
- Override `ExOauth2Provider.AccessTokens.get_by_token/2` and friends to query by hash, then decrypt to verify.
- Data migration: for each existing row, compute hash, encrypt token, populate new columns, drop old.
- ~4–8 hrs. Carries library-compat risk: library updates may add new query functions we need to mirror.

### B. Hashed-only tokens (GitHub-style, recommended)
- Generate token server-side, return plaintext to the client exactly once, store only SHA-256 hash.
- No encryption needed — hashes aren't reversible, so DB leak reveals nothing useful.
- Still requires overriding library lookup to query by `token_hash` instead of `token`.
- Loses the ability to display/recover tokens server-side (feature, not bug).
- ~2–4 hrs. Cleaner semantics.

### C. Defer (current choice)
- Ship, log this issue, gate the fix behind "before first production OAuth user."
- Pre-launch, solo-maintained: the only tokens in the DB are the dev's own. DB-leak threat model approximates "someone pwns my laptop," which implies everything is game anyway.

## Decision

Deferred 2026-04-20. Ship with plaintext storage, revisit before enabling public OAuth sign-up. When fixing, prefer **Option B** (hashed-only) — simpler, no encryption-key-rotation story, aligns with how first-class platforms (GitHub, GitLab, Stripe) handle API tokens.

## Done-when

- [ ] `oauth_access_tokens.token`, `refresh_token`, `previous_refresh_token` are SHA-256 hashes (or encrypted with blind-index), not plaintext.
- [ ] `oauth_access_grants.token` same.
- [ ] `ExOauth2Provider.AccessTokens.get_by_*` and `AccessGrants.get_by_token` overridden to query by hash.
- [ ] Integration test proves a client can authenticate with a real bearer token end-to-end after the migration.
- [ ] Existing tokens are either migrated in-place (if recoverable) or invalidated with a forced re-auth.
