# Phoenix.LiveViewTest.ClientProxy



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## encode!(msg)

Encoding used by the Channel serializer.

## report_upload_progress(proxy_pid, from, element, entry_ref, percent, cid)

Reports upload progress to the proxy.

## root_view(proxy_pid)

Returns the tokens of the root view.

## start_link(opts)

Starts a client proxy.

## Options

  * `:caller` - the required `{ref, pid}` pair identifying the caller.
  * `:view` - the required `%Phoenix.LiveViewTest.View{}`
  * `:html` - the required string of HTML for the document.

## stop(proxy_pid, reason)

Stops the client proxy gracefully.