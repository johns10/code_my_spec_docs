# WebPushElixir

Module to send web push notifications with an encrypted payload.

## send_notification(subscription, message)

Sends a web push notification with an encrypted payload.

## Arguments

* `subscription` - the subscription JSON string received from the client
* `message` - the message string to send

## Examples

    case WebPushElixir.send_notification(subscription, "Hello!") do
      {:ok, _response} ->
        :ok

      {:error, :expired} ->
        Repo.delete(subscription)

      {:error, {:http_error, status, body}} ->
        Logger.error("HTTP error #{status}: #{body}")
    end

## Return Values

* `{:ok, response}` - notification sent successfully (HTTP 200-202)
* `{:error, :expired}` - subscription expired/not found (HTTP 404 or 410)
* `{:error, {:http_error, status, body}}` - HTTP error from push service