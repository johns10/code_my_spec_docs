# CodeMySpec.Provisioning.Sops

Age-encrypted environment files committed to the project's repo, one key per environment so UAT's key cannot open production's secrets. The private key reaches the server through the deploy tool rather than a file placed on the host. Only the app process decrypts; a missing required secret fails the boot by name. Replaces both AWS SSM and Varlock.

## Type

module
