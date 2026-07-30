# CodeMySpec.Provisioning.Resend

Mail in both directions through Resend. Registers a sending subdomain per environment so test mail cannot pass for production mail, publishes the DKIM and bounce records, and polls to verified before calling email done. Sets up Resend Inbound on the apex so the app can act on received mail. Owns the apex-versus-send-subdomain split so outbound and inbound records never fight.

## Type

module

## Dependencies

- CodeMySpec.Integrations
