# Anubis.Server

Build MCP servers that extend language model capabilities.

MCP servers are specialized processes that provide three core primitives to AI assistants:
**Resources** (contextual data like files or schemas), **Tools** (actions the model can invoke),
and **Prompts** (user-selectable templates). They operate in a secure, isolated architecture
where clients maintain 1:1 connections with servers, enabling composable functionality while
maintaining strict security boundaries.

## Quick Start

Create a server in three steps:

    defmodule MyServer do
      use Anubis.Server,
        name: "my-server",
        version: "1.0.0",
        capabilities: [:tools]

      component MyServer.Calculator
    end

    defmodule MyServer.Calculator do
      @moduledoc "Add two numbers"

      use Anubis.Server.Component, type: :tool

      schema do
        field :a, :number, required: true
        field :b, :number, required: true
      end

      def execute(%{a: a, b: b}, _frame) do
        {:ok, a + b}
      end
    end

    # In your supervision tree
    children = [Anubis.Server.Registry, {MyServer, transport: :stdio}]
    Supervisor.start_link(children, strategy: :one_for_one)

Your server is now a living process that AI assistants can connect to, discover available
tools, and execute calculations through a secure protocol boundary.

## Capabilities

Declare what your server can do:

- **`:tools`** - Execute functions with structured inputs and outputs
- **`:resources`** - Provide data that models can read (files, APIs, databases)
- **`:prompts`** - Offer reusable templates for common interactions
- **`:logging`** - Allow clients to configure verbosity levels

Configure capabilities with options:

    use Anubis.Server,
      capabilities: [
        :tools,
        {:resources, subscribe?: true},      # Enable resource update subscriptions
        {:prompts, list_changed?: true}      # Notify when prompts change
      ]

## Components

Register tools, resources, and prompts as components:

    component MyServer.FileReader           # Auto-named as "file_reader"
    component MyServer.ApiClient, name: "api"   # Custom name

Components are modules that implement specific behaviors
and are automatically discovered by clients through the protocol.

## Server Lifecycle

Your server follows a predictable lifecycle with callbacks you can hook into:

1. **`init/2`** - Set up initial state when the server starts
2. **`handle_request/2`** - Process MCP protocol requests from clients
3. **`handle_notification/2`** - React to one-way client messages
4. **`handle_info/2`** - Bridge external events into MCP notifications

Most protocol handling is automatic - you typically only implement `init/2` for setup
and occasionally override other callbacks for custom behavior.

## Sending Notifications

Notification functions use `send(self(), ...)` and must be called from within the
Session process (i.e., inside callbacks). For sending from external processes or tasks,
use `send/2` with the session PID directly.

    # Inside a callback:
    def handle_info(:data_changed, frame) do
      Anubis.Server.send_tools_list_changed()
      {:noreply, frame}
    end

## send_log_message(level, message, data \\ nil)

Sends a log message to the client.

**Must be called from within a Session callback** — see `send_resources_list_changed/0` for details.

## send_progress(progress_token, progress, opts \\ [])

Sends a progress notification for an ongoing operation.

## send_prompts_list_changed()

Sends a prompts list changed notification.

**Must be called from within a Session callback** — see `send_resources_list_changed/0` for details.

## send_resource_updated(uri, timestamp \\ nil)

Sends a resource updated notification for a specific resource.

**Must be called from within a Session callback** — see `send_resources_list_changed/0` for details.

## send_resources_list_changed()

Sends a resources list changed notification.

**Must be called from within a Session callback** — the current process must be
the Session GenServer. Calling from outside a callback will silently lose the message.

For external processes, use `send(session_pid, {:send_notification, "notifications/resources/list_changed", %{}})`.

## send_roots_request(opts \\ [])

Sends a roots/list request to the client.

## send_sampling_request(messages, opts \\ [])

Sends a sampling/createMessage request to the client.

This is an asynchronous operation. The response will be delivered to your
`handle_sampling/3` callback.

## send_tools_list_changed()

Sends a tools list changed notification.

**Must be called from within a Session callback** — see `send_resources_list_changed/0` for details.

## component(module, opts \\ [])

Registers a component (tool, prompt, or resource) with the server.

## handle_notification/2

Handles incoming MCP notifications from clients.

## handle_prompt_get/3

Handles a prompt get request.

## handle_request/2

Low-level handler for any MCP request.

When implemented, it bypasses automatic routing to specific handlers.

## handle_resource_read/2

Handles a resource read request.

## handle_tool_call/3

Handles a tool call request.

This callback is invoked when a client calls a specific tool. It receives the tool name,
the arguments provided by the client, and the current frame.

## init/2

Called after a client requests a `initialize` request.

This callback is invoked while the MCP handshake starts and so the client may not sent
the `notifications/initialized` message yet. For checking if the notification was already sent
and the MCP handshake was successfully completed, you can check the `context.initialized` field
in the frame.

It receives the client's information and
the current frame, allowing you to perform client-specific setup, validate capabilities,
or prepare resources based on the connected client.