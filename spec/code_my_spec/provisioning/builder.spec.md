# CodeMySpec.Provisioning.Builder

Builds a project's image on a Hetzner box that exists only for that build.

Created from a pre-warmed image so the shared toolchain layers are already there, destroyed when the build ends — including when it fails, since a builder left running is billed either way. Per-build isolation also means one customer's source never sits on a box that held another's.

Owns the box lifecycle and the build itself; publishing is Registry's. The architecture asked for is the architecture the servers run, because an image built for the wrong one fails at container start rather than at build time.

## Type

module
