# CodeMySpec.Provisioning.Deploy

Repository, image and deploy. Creates the remote, lets CI publish the image, migrates before the traffic swap, and refuses to swap a version that fails its health check. Verifies each environment answers over HTTPS on its own hostname and installs an uptime monitor per public domain before calling the environment done. Also owns scheduled database dumps with retention, proven by a real restore during setup.

## Type

module
