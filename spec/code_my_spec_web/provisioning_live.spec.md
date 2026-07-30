# CodeMySpecWeb.ProvisioningLive

Setup status page. Shows the whole step sequence in order, each step's state validated against the provider on demand rather than remembered from the last run, and a retry affordance per step. Streams state changes live while setup runs. Surfaces a paused step with what Sam must do elsewhere, and an errored step with what the agent could not fix. Also where Sam turns individual setup options on and off.

## Type

liveview

## Dependencies

- CodeMySpec.Provisioning
- CodeMySpec.Configurations
