# Anubis.Client.State



## add_progress_token_to_params(params, progress_opts)

Helper function to add progress token to params if provided.

## add_root(state, uri, name \\ nil)

Adds a root directory to the state.

## Parameters

  * `state` - The current client state
  * `uri` - The URI of the root directory (must start with "file://")
  * `name` - Optional human-readable name for display purposes

## Examples

    iex> updated_state = Anubis.Client.State.add_root(state, "file:///home/user/project", "My Project")
    iex> updated_state.roots
    [%{uri: "file:///home/user/project", name: "My Project"}]

## clear_elicitation_callback(state)

Clears the elicitation callback function.

## clear_log_callback(state)

Clears the log callback.

## Parameters

  * `state` - The current client state

## Examples

    iex> updated_state = Anubis.Client.State.clear_log_callback(state)
    iex> is_nil(updated_state.log_callback)
    true

## clear_roots(state)

Clears all root directories.

## Parameters

  * `state` - The current client state

## Examples

    iex> updated_state = Anubis.Client.State.clear_roots(state)
    iex> updated_state.roots
    []

## clear_sampling_callback(state)

Clears the sampling callback function.

## Parameters

  * `state` - The current client state

## Examples

    iex> updated_state = Anubis.Client.State.clear_sampling_callback(state)
    iex> updated_state.sampling_callback
    nil

## get_elicitation_callback(state)

Gets the elicitation callback function.

## get_log_callback(state)

Gets the log callback.

## Parameters

  * `state` - The current client state

## Examples

    iex> callback = Anubis.Client.State.get_log_callback(state)
    iex> is_function(callback, 3) or is_nil(callback)
    true

## get_progress_callback(state, token)

Gets a progress callback for a token.

## Parameters

  * `state` - The current client state
  * `token` - The progress token to get the callback for

## Examples

    iex> callback = Anubis.Client.State.get_progress_callback(state, "token123")
    iex> is_function(callback, 3)
    true

## get_request(state, id)

Gets a request by ID.

## Parameters

  * `state` - The current client state
  * `id` - The request ID to retrieve

## Examples

    iex> Anubis.Client.State.get_request(state, "req_123")
    {{pid, ref}, "ping", timer_ref, start_time} # or nil if not found

## get_root_by_uri(state, uri)

Gets a root directory by its URI.

## Parameters

  * `state` - The current client state
  * `uri` - The URI of the root directory to get

## Examples

    iex> Anubis.Client.State.get_root_by_uri(state, "file:///home/user/project")
    %{uri: "file:///home/user/project", name: "My Project"}

## get_sampling_callback(state)

Gets the sampling callback function.

## Parameters

  * `state` - The current client state

## Examples

    iex> Anubis.Client.State.get_sampling_callback(state)
    nil

## get_server_capabilities(state)

Gets the server capabilities.

## Parameters

  * `state` - The current client state

## Examples

    iex> Anubis.Client.State.get_server_capabilities(state)
    %{"resources" => %{}, "tools" => %{}}

## get_server_info(state)

Gets the server info.

## Parameters

  * `state` - The current client state

## Examples

    iex> Anubis.Client.State.get_server_info(state)
    %{"name" => "TestServer", "version" => "1.0.0"}

## handle_request_timeout(state, id)

Handles a request timeout, cancelling the timer and returning the updated state.

## Parameters

  * `state` - The current client state
  * `id` - The request ID that timed out

## Examples

    iex> Anubis.Client.State.handle_request_timeout(state, "req_123")
    {%{from: from, method: "ping", elapsed_ms: 30000}, updated_state}

## list_pending_requests(state)

Returns a list of all pending requests.

## Parameters

  * `state` - The current client state

## Examples

    iex> requests = Anubis.Client.State.list_pending_requests(state)
    iex> length(requests) > 0
    true
    iex> hd(requests).method
    "ping"

## list_roots(state)

Lists all root directories.

## Parameters

  * `state` - The current client state

## Examples

    iex> Anubis.Client.State.list_roots(state)
    [%{uri: "file:///home/user/project", name: "My Project"}]

## merge_capabilities(state, additional_capabilities)

Merges additional capabilities into the client's capabilities.

## Parameters

  * `state` - The current client state
  * `additional_capabilities` - The capabilities to merge

## Examples

    iex> updated_state = Anubis.Client.State.merge_capabilities(state, %{"tools" => %{"execute" => true}})
    iex> updated_state.capabilities["tools"]["execute"]
    true

## register_progress_callback(state, token, callback)

Registers a progress callback for a token.

## Parameters

  * `state` - The current client state
  * `token` - The progress token to register a callback for
  * `callback` - The callback function to call when progress updates are received

## Examples

    iex> updated_state = Anubis.Client.State.register_progress_callback(state, "token123", fn token, progress, total -> IO.inspect({token, progress, total}) end)
    iex> Map.has_key?(updated_state.progress_callbacks, "token123")
    true

## register_progress_callback_from_opts(state, progress_opts)

Helper function to register progress callback from options.

## remove_request(state, id)

Removes a request and returns its info along with the updated state.

## Parameters

  * `state` - The current client state
  * `id` - The request ID to remove

## Examples

    iex> {request_info, updated_state} = Anubis.Client.State.remove_request(state, "req_123")
    iex> request_info.method
    "ping"
    iex> request_info.elapsed_ms > 0
    true

## remove_root(state, uri)

Removes a root directory from the state.

## Parameters

  * `state` - The current client state
  * `uri` - The URI of the root directory to remove

## Examples

    iex> updated_state = Anubis.Client.State.remove_root(state, "file:///home/user/project")
    iex> updated_state.roots
    []

## set_elicitation_callback(state, callback)

Sets the elicitation callback function.

Callback receives `(message, requested_schema)` and returns one of
`{:accept, content}`, `:decline`, `:cancel`, or `{:error, reason}`.

## set_log_callback(state, callback)

Sets the log callback.

## Parameters

  * `state` - The current client state
  * `callback` - The callback function to call when log messages are received

## Examples

    iex> updated_state = Anubis.Client.State.set_log_callback(state, fn level, data, logger -> IO.inspect({level, data, logger}) end)
    iex> is_function(updated_state.log_callback, 3)
    true

## set_sampling_callback(state, callback)

Sets the sampling callback function.

## Parameters

  * `state` - The current client state
  * `callback` - The callback function to handle sampling requests

## Examples

    iex> callback = fn params -> {:ok, %{role: "assistant", content: %{type: "text", text: "Hello"}}} end
    iex> updated_state = Anubis.Client.State.set_sampling_callback(state, callback)
    iex> is_function(updated_state.sampling_callback, 1)
    true

## unregister_progress_callback(state, token)

Unregisters a progress callback for a token.

## Parameters

  * `state` - The current client state
  * `token` - The progress token to unregister the callback for

## Examples

    iex> updated_state = Anubis.Client.State.unregister_progress_callback(state, "token123")
    iex> Map.has_key?(updated_state.progress_callbacks, "token123")
    false

## update_server_info(state, server_capabilities, server_info)

Updates server info and capabilities after initialization.

## Parameters

  * `state` - The current client state
  * `server_capabilities` - The server capabilities received from initialization
  * `server_info` - The server information received from initialization

## Examples

    iex> updated_state = Anubis.Client.State.update_server_info(state, %{"resources" => %{}}, %{"name" => "TestServer"})
    iex> updated_state.server_capabilities
    %{"resources" => %{}}
    iex> updated_state.server_info
    %{"name" => "TestServer"}

## validate_capability(map, method)

Validates if a method is supported by the server's capabilities.

## Parameters

  * `state` - The current client state
  * `method` - The method to validate

## Returns

  * `:ok` if the method is supported
  * `{:error, %Anubis.MCP.Error{}}` if the method is not supported

## Examples

    iex> Anubis.Client.State.validate_capability(state_with_resources, "resources/list")
    :ok
    
    iex> {:error, error} = Anubis.Client.State.validate_capability(state_without_tools, "tools/list")
    iex> error.reason
    :method_not_found