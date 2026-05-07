# Swoosh.Adapters.AzureCommunicationServices

An adapter that sends email using the Azure Communication Services (ACS) Email API.

For reference:
[Azure Communication Services Email API docs](https://learn.microsoft.com/en-us/rest/api/communication/email/email/send?view=rest-communication-email-2025-09-01)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Configuration options

* `:endpoint` (required) - The ACS resource endpoint, e.g. `https://my-resource.communication.azure.com`
* `:access_key` - Base64-encoded HMAC access key for HMAC-SHA256 authentication (mutually exclusive with `:auth`)
* `:auth` - Bearer token for Azure RBAC authentication. Can be a string, a 0-arity function, or a `{mod, fun, args}` tuple (mutually exclusive with `:access_key`)

Exactly one of `:access_key` or `:auth` must be provided.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.AzureCommunicationServices,
      endpoint: "https://my-resource.communication.azure.com",
      access_key: "base64encodedkey=="

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with Bearer token auth

    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.AzureCommunicationServices,
      endpoint: "https://my-resource.communication.azure.com",
      auth: fn -> MyApp.TokenProvider.get_token() end

> #### HMAC Endpoint Matching {: .warning}
>
> HMAC signing uses the exact request URI. Configure `:endpoint` as the ACS resource root only.
> If you get `{"error":{"code":"Denied","message":"Denied by the resource provider."}}`,
> first check that the configured endpoint matches exactly and does not include a trailing slash
> or any extra path segments.

## Provider Options

  * `:user_engagement_tracking_disabled` (boolean) - Disables user engagement tracking for this email
  * `:operation_id` (string) - A UUID sent as the `Operation-Id` request header for idempotency
  * `:client_request_id` (string) - A client-provided request identifier sent as the `x-ms-client-request-id` request header