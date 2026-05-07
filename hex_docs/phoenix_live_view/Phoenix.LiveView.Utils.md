# Phoenix.LiveView.Utils



## assign(socket, key, value)

Assigns a value if it changed.

## assign_new(socket, key, fun)

Assigns the given `key` with value from `fun` into `socket_or_assigns` if one does not yet exist.

## call_handle_params!(socket, view, exported? \\ true, params, uri)

Calls the `handle_params/3` callback, and returns the result.

This function expects the calling code has checked to see if this function has
been exported, otherwise it assumes the function has been exported.

Raises an `ArgumentError` on unexpected return types.

## changed?(socket)

Checks if the socket changed.

## changed?(socket, assign)

Checks if the given assign changed.

## changed_flash(socket)

Returns a map of the flash messages which have changed.

## cid(socket)

Returns the CID of the given socket.

## clear_changed(socket)

Clears the changes from the socket assigns.

## clear_flash(socket)

Clears the flash.

## clear_flash(socket, key)

Clears the key from the flash.

## clear_temp(socket)

Clears temporary data (flash, pushes, etc) from the socket privates.

## configure_socket(socket, private, action, flash, host_uri)

Configures the socket for use.

## force_assign(socket, key, val)

Forces an assign on a socket.

## force_assign(assigns, changed, key, val)

Forces an assign with the given changed map.

## get_flash(socket)

Returns the socket's flash messages.

## get_push_events(socket)

Returns the push events in the socket.

## get_reply(socket)

Returns the reply in the socket.

## handle_mount_options!(socket, opts, arg)

Handle all valid options on mount/on_mount.

## maybe_call_live_component_mount!(socket, component)

Calls the `c:Phoenix.LiveComponent.mount/1` callback, otherwise returns the socket as is.

## maybe_call_live_view_mount!(socket, view, params, session, uri \\ nil)

Calls the `c:Phoenix.LiveView.mount/3` callback, otherwise returns the socket as is.

## maybe_call_update!(socket, component, assigns)

Calls the optional `update/2` or `update_many/1` callback, otherwise update the socket(s) directly.

## normalize_layout(other)

Validate and normalizes the layout.

## post_mount_prune(socket)

Prunes any data no longer needed after mount.

## push_event(socket, event, payload, opts)

Annotates the changes with the event to be pushed.

By default, events are dispatched on the JavaScript side only after
the current patch is invoked. Therefore, if the LiveView
redirects, the events won't be invoked. If the `dispatch: :before` option
is passed, this event will be dispatched before patching the DOM.

## put_flash(socket, key, msg)

Puts a flash message in the socket.

## put_reply(socket, payload)

Annotates the reply in the socket changes.

## raise_bad_mount_and_live_patch!()

Raises error message for bad live patch on mount.

## random_id()

Returns a random ID with valid DOM tokens

## replace_flash(socket, new_flash)

Puts a new flash with the socket's flash messages.

## salt!(endpoint)

Returns the configured signing salt for the endpoint.

## sign_flash(endpoint_mod, flash)

Signs the socket's flash into a token if it has been set.

## verify_flash(endpoint_mod, flash_token)

Verifies the socket's flash token.