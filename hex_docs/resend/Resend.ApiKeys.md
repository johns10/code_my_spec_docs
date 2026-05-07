# Resend.ApiKeys

Manage API keys in Resend.

## create(client \\ Resend.client(), opts)

Creates a new API key.

Parameter options:

  * `:name` - The API key name (required)
  * `:permission` - Access scope to assign to this key, one of: `["full_access", "sending_access"]`
  * `:domain_id` - Restrict sending to a specific domain. Only used when permission is set to `"sending_access"`

The `:token` field in the response struct is the only time you will see the token, keep it somewhere safe.

## list(client \\ Resend.client())

Lists all API keys.

## remove(client \\ Resend.client(), api_key_id)

Removes an API key. Caution: This can't be undone!