# OAuth2.Strategy



## __using__/1

Builds the URL to the token endpoint.

## Example

    def get_token(client, params, headers) do
      client
      |> put_param(:code, params[:code])
      |> put_param(:grant_type, "authorization_code")
      |> put_param(:client_id, client.client_id)
      |> put_param(:client_secret, client.client_secret)
      |> put_param(:redirect_uri, client.redirect_uri)
      |> merge_params(params)
      |> put_headers(headers)
    end