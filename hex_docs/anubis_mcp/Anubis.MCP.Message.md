# Anubis.MCP.Message

Handles parsing and validation of MCP (Model Context Protocol) messages using the Peri library.

This module provides functions to parse and validate MCP messages based on the Model Context Protocol schema

## build_error(error, id)

Builds an error message map without encoding to JSON.

## Examples

    iex> Message.build_error(%{"code" => -32600, "message" => "Invalid Request"}, "req_123")
    %{"jsonrpc" => "2.0", "error" => %{"code" => -32600, "message" => "Invalid Request"}, "id" => "req_123"}

## build_notification(method, params)

Builds a notification message map without encoding to JSON.

## Examples

    iex> Message.build_notification("notifications/message", %{"level" => "info", "data" => "test"})
    %{"jsonrpc" => "2.0", "method" => "notifications/message", "params" => %{"level" => "info", "data" => "test"}}

## build_response(result, id)

Builds a response message map without encoding to JSON.

## Examples

    iex> Message.build_response(%{"value" => 42}, "req_123")
    %{"jsonrpc" => "2.0", "result" => %{"value" => 42}, "id" => "req_123"}

## decode(data)

Decodes raw data (possibly containing multiple messages) into JSON-RPC messages.

Returns either:
- `{:ok, messages}` where messages is a list of parsed JSON-RPC messages
- `{:error, reason}` if parsing fails

## encode_error(response, id)

Encodes an error message to a JSON-RPC 2.0 compliant string.

Returns the encoded string with a newline character appended.

## encode_log_message(level, data, logger \\ nil)

Encodes a log message notification to be sent to the client.

## Parameters

  * `level` - The log level (debug, info, notice, warning, error, critical, alert, emergency)
  * `data` - The data to be logged (any JSON-serializable value)
  * `logger` - Optional name of the logger issuing the message

Returns the encoded notification string with a newline character appended.

## encode_notification(notification)

Encodes a notification message to a JSON-RPC 2.0 compliant string.

Returns the encoded string with a newline character appended.

## encode_notification(notification, schema)

Encodes a notification message using a custom schema.

## Parameters

  * `notification` - The notification map containing method and params
  * `schema` - The Peri schema to use for validation

Returns the encoded string with a newline character appended.

## encode_progress_notification(params, params_schema \\ %{"progress" => {:required, {:either, {:float, :integer}}}, "progressToken" => {:required, {:either, {:string, :integer}}}, "total" => {:either, {:float, :integer}}})

Encodes a progress notification message to a JSON-RPC 2.0 compliant string.

## Parameters

  * `params` - Map containing progress parameters:
    * `"progressToken"` - The token that was provided in the original request (string or integer)
    * `"progress"` - The current progress value (number)
    * `"total"` - Optional total value for the operation (number)
    * `"message"` - Optional descriptive message (string, for 2025-03-26)
  * `params_schema` - Optional Peri schema for params validation (defaults to @progress_notif_params_schema)

Returns the encoded string with a newline character appended.

## encode_progress_notification(progress_token, progress, total)

Legacy function for progress notifications with individual parameters.

**Deprecated**: Prefer using `encode_progress_notification/2` with a params map.

This function will be removed in a future release. Update your code to use the newer function:

    encode_progress_notification(%{
      "progressToken" => progress_token,
      "progress" => progress,
      "total" => total
    })

## encode_request(request, id)

Encodes a request message to a JSON-RPC 2.0 compliant string.

Returns the encoded string with a newline character appended.

## encode_request(request, id, schema)

Encodes a request message using a custom schema.

## Parameters

  * `request` - The request map containing method and params
  * `id` - The request ID
  * `schema` - The Peri schema to use for validation

Returns the encoded string with a newline character appended.

## encode_response(response, id)

Encodes a response message to a JSON-RPC 2.0 compliant string.

Returns the encoded string with a newline character appended.

## encode_response(response, id, schema)

Encodes a response message using a custom schema.

## Parameters

  * `response` - The response map containing result
  * `id` - The response ID
  * `schema` - The Peri schema to use for validation

Returns the encoded string with a newline character appended.

## progress_params_schema()

Returns the standard progress notification parameters schema for 2024-11-05.

## progress_params_schema_2025()

Returns the progress notification parameters schema for 2025-03-26 (with message field).

## progress_params_schema_for(version)

Returns the progress notification parameters schema for a given protocol version.

Delegates to the version module via `Anubis.Protocol.Registry`.

## Examples

    iex> Message.progress_params_schema_for("2024-11-05")
    %{"progressToken" => {:required, {:either, {:string, :integer}}}, ...}

    iex> Message.progress_params_schema_for("2025-03-26")
    %{"progressToken" => ..., "message" => :string}

## validate_message(message)

Validates a decoded JSON message to ensure it complies with the MCP schema.

## is_error(data)

Guard to determine if a JSON-RPC message is an error.

A message is considered an error if it contains both "error" and "id" fields.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "error" => %{"code" => -32600}, "id" => 1}
    iex> is_error(message)
    true

## is_initialize(data)

Guard to check if a request is an initialize request.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "method" => "initialize", "id" => 1, "params" => %{}}
    iex> is_initialize(message)
    true

## is_initialize_lifecycle(data)

Guard to check if a message is part of the initialization lifecycle.

This includes both the initialize request and the notifications/initialized notification.

## Examples

    iex> init_request = %{"jsonrpc" => "2.0", "method" => "initialize", "id" => 1, "params" => %{}}
    iex> is_initialize_lifecycle(init_request)
    true

    iex> init_notification = %{"jsonrpc" => "2.0", "method" => "notifications/initialized"}
    iex> is_initialize_lifecycle(init_notification)
    true

    iex> other_message = %{"jsonrpc" => "2.0", "method" => "tools/list", "id" => 2}
    iex> is_initialize_lifecycle(other_message)
    false

## is_notification(data)

Guard to determine if a JSON-RPC message is a notification.

A message is considered a notification if it contains a "method" field but no "id" field.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "method" => "notification"}
    iex> is_notification(message)
    true

    iex> request = %{"jsonrpc" => "2.0", "method" => "ping", "id" => 1}
    iex> is_notification(request)
    false

## is_ping(data)

Guard to check if a request is a ping request.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "method" => "ping", "id" => 1}
    iex> is_ping(message)
    true

## is_request(data)

Guard to determine if a JSON-RPC message is a request.

A message is considered a request if it contains both "method" and "id" fields.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "method" => "ping", "id" => 1}
    iex> is_request(message)
    true

    iex> notification = %{"jsonrpc" => "2.0", "method" => "notification"}
    iex> is_request(notification)
    false

## is_response(data)

Guard to determine if a JSON-RPC message is a response.

A message is considered a response if it contains both "result" and "id" fields.

## Examples

    iex> message = %{"jsonrpc" => "2.0", "result" => %{}, "id" => 1}
    iex> is_response(message)
    true