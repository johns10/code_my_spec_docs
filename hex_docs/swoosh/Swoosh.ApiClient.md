# Swoosh.ApiClient

Specification for a Swoosh API client.

It can be set to your own client with:

    config :swoosh, :api_client, MyAPIClient

Swoosh comes with `Swoosh.ApiClient.Hackney`, `Swoosh.ApiClient.Finch`, and
`Swoosh.ApiClient.Req`.

## post(url, headers, body, email)

API used by adapters to post to a given URL with headers, body, and email.

## init/0

Callback to initializes the given api client.

## post/4

Callback invoked when posting to a given URL.