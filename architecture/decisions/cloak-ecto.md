# Use Cloak Ecto for field-level encryption at rest

## Status
Accepted

## Context
The application stores sensitive data such as API keys, OAuth tokens, and integration credentials that must be encrypted at rest to meet security best practices.

## Options Considered
- **Cloak Ecto** — Transparent field-level encryption via custom Ecto types. Encrypts before write, decrypts on read.
- **Database-level encryption** — Encrypt the entire database or specific columns at the DB layer. Less granular, varies by database engine.
- **Manual encryption** — Encrypt/decrypt in application code. Error-prone and repetitive.

## Decision
Use Cloak Ecto (`~> 1.3`) for transparent field-level encryption. Define encrypted Ecto types (e.g., `CodeMySpec.Encrypted.Binary`) and use them on schema fields that contain secrets. Key management via application config with support for key rotation.

## Consequences
- Encrypted fields are not queryable (can't WHERE on ciphertext)
- Must configure encryption keys in application environment
- Key rotation is supported but requires a migration sweep
- Fields appear as plaintext in application code after decryption
