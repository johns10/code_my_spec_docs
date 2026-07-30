# CodeMySpec.Provisioning.Hetzner

Servers, firewalls and object storage in the user's own Hetzner account. Provisions the box both environments start on and supports relocating one to its own server later without a rebuild. Creates per-environment buckets via the S3-compatible API; the S3 key pair is always pasted because Hetzner exposes no API for minting it.

## Type

module

## Dependencies

- CodeMySpec.Integrations
- CodeMySpec.ProjectSecrets
