# Anubis.Server.Component.Tool

Defines the behaviour for MCP tools.

Tools are functions that can be invoked by the client with specific parameters.
Each tool must define its name, description, and parameter schema, as well as
implement the execution logic.

## Example

    defmodule MyServer.Tools.Calculator do
      @behaviour Anubis.Server.Behaviour.Tool

      alias Anubis.Server.{Frame, Response}
      alias Anubis.MCP.Error

      @impl true
      def name, do: "calculator"

      @impl true
      def description, do: "Performs basic arithmetic operations"

      @impl true
      def input_schema do
        %{
          "type" => "object",
          "properties" => %{
            "operation" => %{
              "type" => "string",
              "enum" => ["add", "subtract", "multiply", "divide"]
            },
            "a" => %{"type" => "number"},
            "b" => %{"type" => "number"}
          },
          "required" => ["operation", "a", "b"]
        }
      end

      @impl true
      def execute(%{"operation" => "add", "a" => a, "b" => b}, frame) do
        result = a + b

        # Can return updated frame if needed
        new_frame = Frame.assign(frame, :last_calculation, result)

        {:reply, Response.text(Response.tool(), to_string(result)), new_frame}
      end

      @impl true
      def execute(%{"operation" => "divide", "a" => _a, "b" => 0}, frame) do
        {:error, Error.invalid_request("Cannot divide by zero"), frame}
      end
    end

## annotations/0

Returns optional annotations for the tool.

Annotations provide additional metadata about the tool that may be used
by clients for enhanced functionality. This is an optional callback.

## Examples

    def annotations do
      %{
        "confidence" => 0.95,
        "category" => "text-processing",
        "tags" => ["nlp", "text"]
      }
    end

## description/0

Returns the description of this tool.

The description helps AI assistants understand what the tool does and when to use it.
If not provided, the module's `@moduledoc` will be used automatically.

## Examples

    def description do
      "Performs arithmetic operations on two numbers"
    end

    # With dynamic content
    def description do
      interval = Application.get_env(:my_app, :cache_minutes, 15)
      "Fetches data (cached for #{interval} minutes)"
    end

## execute/2

Executes the tool with the given parameters.

## Parameters

- `params` - The validated input parameters from the client
- `frame` - The server frame containing:
  - `assigns` - Custom data like session_id, client_info, user permissions
  - `initialized` - Whether the server has been initialized

## Return Values

- `{:reply, %Response{}, frame}` - Tool executed successfully
- `{:noreply, frame}` - No reply needed
- `{:error, %Error{}, frame}` - Tool failed with the given error

## Frame Usage

The frame provides access to server state and context:

    def execute(params, frame) do
      # Access assigns
      user_id = frame.assigns[:user_id]
      permissions = frame.assigns[:permissions]

      # Update frame if needed
      new_frame = Frame.assign(frame, :last_tool_call, DateTime.utc_now())

      {:reply, Response.text(Response.tool(), "Result"), new_frame}
    end

## input_schema/0

Returns the JSON Schema for the tool's input parameters.

This schema is used to validate client requests and generate documentation.
The schema should follow the JSON Schema specification.

## meta/0

Returns optional metadata for the tool.

The _meta field allows tools to carry arbitrary metadata that is not
part of the core MCP protocol. This is an optional callback.

## output_schema/0

Returns the JSON Schema for the tool's output structure.

This schema defines the expected structure of the tool's output in the
structuredContent field. The schema should follow the JSON Schema specification.
This is an optional callback.

## title/0

Returns the title that identifies this resource.

Intended for UI and end-user contexts — optimized to be human-readable and easily understood,
even by those unfamiliar with domain-specific terminology.

If not provided, the name should be used for display, except if annotations.title is
defined, which takes precedence over `name` and `title`.