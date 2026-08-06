# CodeMySpec.Resources.Inventory

Everything each provider says the account holds, enumerated once.

Asks each provider for its whole list — servers, firewalls and SSH keys from Hetzner, zones and records from Cloudflare, buckets from object storage, domains and webhooks from Resend — rather than verifying resources one at a time. Eleven projects times fifteen steps is a hundred and sixty-five calls that would rate-limit and take a minute; six list calls answer the same question.

Enumerating is also the only way to see a resource nobody recorded. A bucket created by hand is invisible to any check that starts from what setup wrote down, and it is billing exactly like the ones we know about.

Each provider is asked independently and a failure is confined to its own section: one provider being unreachable must not decide what the page can say about the other three.

## Type

module

## Dependencies

- CodeMySpec.Provisioning
