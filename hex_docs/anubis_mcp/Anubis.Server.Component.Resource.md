# Anubis.Server.Component.Resource

Defines the behaviour for MCP resources.

Resources represent data that can be read by the client, such as files,
documents, or any other content. Each resource is identified by a URI
and can provide content in various formats.

## Example

    defmodule MyServer.Resources.Documentation do
      @behaviour Anubis.Server.Behaviour.Resource

      alias Anubis.Server.{Frame, Response}
      alias Anubis.MCP.Error

      @impl true
      def uri, do: "file:///docs/readme.md"

      @impl true
      def name, do: "Project README"

      @impl true
      def description, do: "The main documentation for this project"

      @impl true
      def mime_type, do: "text/markdown"

      @impl true
      def read(_params, frame) do
        case File.read("README.md") do
          {:ok, content} ->
            # Can track access in frame
            new_frame = Frame.assign(frame, :last_resource_access, DateTime.utc_now())
            {:reply, Response.text(Response.resource(), content), new_frame}

          {:error, reason} ->
            {:error, Error.domain_error("Failed to read README: #{inspect(reason)}"), frame}
        end
      end
    end

## Example with dynamic content

    defmodule MyServer.Resources.SystemStatus do
      @behaviour Anubis.Server.Behaviour.Resource

      @impl true
      def uri, do: "system://status"

      @impl true
      def name, do: "System Status"

      @impl true
      def description, do: "Current system status and metrics"

      @impl true
      def mime_type, do: "application/json"

      @impl true
      def read(_params, frame) do
        status = %{
          uptime: System.uptime(),
          memory: :erlang.memory(),
          user_id: frame.assigns[:user_id],
          timestamp: DateTime.utc_now()
        }

        {:reply, Response.json(Response.resource(), status), frame}
      end
    end

## description/0

Returns the description of this resource.

The description helps AI assistants understand what data the resource provides.
If not provided, the module's `@moduledoc` will be used automatically.

## Examples

    def description do
      "Application configuration settings"
    end

    # With dynamic content
    def description do
      {uptime_ms, _} = :erlang.statistics(:wall_clock)
      "System metrics (uptime: #{div(uptime_ms, 1000)}s)"
    end

## mime_type/0

Returns the MIME type of the resource content.

Common MIME types:
- `text/plain` for plain text
- `text/markdown` for Markdown
- `application/json` for JSON data
- `text/html` for HTML
- `application/octet-stream` for binary data

## name/0

Returns the `name` that identifies this resource.

Intended for programmatic or logical use, but used as a
display name in past specs or fallback (if title isn't present).

## read/2

Reads the resource content.

## Parameters

- `params` - Optional parameters from the client (typically empty for resources)
- `frame` - The server frame containing context and state

## Return Values

- `{:reply, %Response{}, frame}` - Resource read successfully
- `{:noreply, frame}` - No reply needed
- `{:error, %Error{}, frame}` - Failed to read resource

## Building Responses

Use `Response.resource/0` to create a resource response, then set content
with the appropriate builder:
- `Response.text/2` for text content (plain text, markdown, etc.)
- `Response.json/2` for JSON data (automatically encoded)
- `Response.blob/2` for binary data

## title/0

Returns the title that identifies this resource.

Intended for UI and end-user contexts — optimized to be human-readable and easily understood,
even by those unfamiliar with domain-specific terminology.

If not provided, the name should be used for display.

## uri/0

Returns the URI that identifies this resource.

The URI should be unique within the server and follow standard URI conventions.
Common schemes include:
- `file://` for file-based resources
- `http://` or `https://` for web resources
- Custom schemes for application-specific resources

Note: Either `uri/0` or `uri_template/0` must be implemented, but not both.

## uri_template/0

Returns the URI template that identifies this resource template.

URI templates follow RFC 6570 syntax and allow parameterized resource URIs.
For example: `file:///{path}` or `db:///{table}/{id}`

Note: Either `uri/0` or `uri_template/0` must be implemented, but not both.