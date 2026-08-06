# CodeMySpec.Servers

Servers an account owns, whether CodeMySpec created them or Sam did.

Account-scoped on purpose. `Provisioning` is project-scoped, and today a server is two denormalised strings — `server_name` and `ip` — on a `provisioning_environments` row, so a box cannot be shared between projects, an existing box cannot be adopted, and nothing owns a server's lifecycle. That last gap is the root of the environment-removal and dangling-DNS defects.

This context owns the server as a thing in its own right: listing what the provider actually reports, linking boxes Sam made himself, provisioning new ones, and keeping unlinked servers visible so none slips out of view. It reads through `Provisioning.Hetzner` rather than reimplementing the provider client.

Deliberately not a child of `Provisioning`: the grain is different, and that difference is what story 994 exists to fix.

## Type

context

## Dependencies

- CodeMySpec.Provisioning.Hetzner
