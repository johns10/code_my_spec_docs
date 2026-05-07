# Phoenix.LiveView.Static



## nested_render(parent, view, opts)

Renders a nested live view without spawning a server.

  * `parent` - the parent `%Phoenix.LiveView.Socket{}`
  * `view` - the child LiveView module

Accepts the same options as `render/3`.

## render(_, map)

Acts as a view via put_view to maintain the
controller render + instrumentation stack.

## render(conn, view, opts)

Renders a live view without spawning a LiveView server.

  * `conn` - the Plug.Conn struct form the HTTP request
  * `view` - the LiveView module

## Options

  * `:router` - the router the live view was built at
  * `:action` - the router action
  * `:session` - the required map of session data
  * `:container` - the optional tuple for the HTML tag and DOM attributes

## sign_token(endpoint, data)

Signs a LiveView token.

## verify_token(endpoint, token)

Verifies a LiveView token.