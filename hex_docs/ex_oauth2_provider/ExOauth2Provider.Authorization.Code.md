# ExOauth2Provider.Authorization.Code

Methods for authorization code flow.

The flow consists of three method calls:

1. `preauthorize(resource_owner, request)`

This validates the request. If a resource owner already have been
authenticated previously it'll respond with a redirect tuple.

2. `authorize(resource_owner, request)`

This confirms a resource owner authorization, and will generate an access
token.

3. `deny(resource_owner, request)`

This rejects a resource owner authorization.

---

In a controller it could look like this:

```elixir
alias ExOauth2Provider.Authorization

def new(conn, params) do
  case Authorization.preauthorize(current_resource_owner(conn), params) do
    {:ok, client, scopes} ->
      render(conn, "new.html", params: params, client: client, scopes: scopes)
    {:native_redirect, %{code: code}} ->
      redirect(conn, to: oauth_authorization_path(conn, :show, code))
    {:redirect, redirect_uri} ->
      redirect(conn, external: redirect_uri)
    {:error, error, status} ->
      conn
      |> put_status(status)
      |> render("error.html", error: error)
  end
end

def create(conn, params) do
  conn
  |> current_resource_owner
  |> Authorization.authorize(params)
  |> redirect_or_render(conn)
end

def delete(conn, params) do
  conn
  |> current_resource_owner
  |> Authorization.deny(params)
  |> redirect_or_render(conn)
end
```

## authorize(resource_owner, request, config \\ [])

Authorizes an authorization code flow request.

This is used when a resource owner has authorized access. If successful,
this will generate an access token grant.

## Example
    resource_owner
    |> ExOauth2Provider.Authorization.authorize(%{
      "client_id" => "Jf5rM8hQBc",
      "response_type" => "code",
      "scope" => "read write",                  # Optional
      "state" => "46012",                       # Optional
      "redirect_uri" => "https://example.com/"  # Optional
    }, otp_app: :my_app)

## Response
    {:ok, code}                                                  # A grant was generated
    {:error, %{error: error, error_description: _}, http_status} # Error occurred
    {:redirect, redirect_uri}                                    # Redirect
    {:native_redirect, %{code: code}}                            # Redirect to :show page

## deny(resource_owner, request, config \\ [])

Rejects an authorization code flow request.

This is used when a resource owner has rejected access.

## Example
    resource_owner
    |> ExOauth2Provider.Authorization.deny(%{
      "client_id" => "Jf5rM8hQBc",
      "response_type" => "code"
    }, otp_app: :my_app)

## Response type
    {:error, %{error: error, error_description: _}, http_status} # Error occurred
    {:redirect, redirect_uri}                                    # Redirect

## preauthorize(resource_owner, request, config \\ [])

Validates an authorization code flow request.

Will check if there's already an existing access token with same scope and client
for the resource owner.

## Example
    resource_owner
    |> ExOauth2Provider.Authorization.preauthorize(%{
      "client_id" => "Jf5rM8hQBc",
      "response_type" => "code"
    }, otp_app: :my_app)

## Response
    {:ok, client, scopes}                                         # Show request page with client and scopes
    {:error, %{error: error, error_description: _}, http_status}  # Show error page with error and http status
    {:redirect, redirect_uri}                                     # Redirect
    {:native_redirect, %{code: code}}                             # Redirect to :show page