# CodeMySpec.Integrations.Providers.Hetzner

Hetzner connection implementing Integrations.Providers.Behaviour, covering the Cloud API token used for servers, firewalls and buckets. Note the object-storage S3 key pair cannot be minted through any Hetzner API — it is created in their console and pasted, so it does not fit the OAuth token shape and needs somewhere project-scoped to live.

## Type

module
