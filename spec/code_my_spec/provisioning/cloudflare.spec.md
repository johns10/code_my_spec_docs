# CodeMySpec.Provisioning.Cloudflare

Domain and DNS against Cloudflare. Checks availability and price, registers on explicit confirmation only, adopts a domain Sam already owns as a first-class path, and hands off to the dashboard when the TLD is outside the Registrar API beta or billing prerequisites are missing. Creates unproxied records per environment so certificate issuance succeeds. Owns apex records carefully — inbound mail depends on them.

## Type

module

## Dependencies

- CodeMySpec.Integrations
