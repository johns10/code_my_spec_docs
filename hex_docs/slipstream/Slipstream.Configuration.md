# Slipstream.Configuration

Configuration for a Slipstream websocket connection

Slipstream server process configuration is passed in with
`Slipstream.connect/2` (or `Slipstream.connect!/2`), and so all configuration
is evauated and validated at runtime, as opposed to compile-time validation.
You should not expect to see validation errors on configuration unless you
force the validation at compile-time, e.g.:

    # you probably don't want to do this...
    defmodule MyClient do
      @config Application.compile_env!(:my_app, __MODULE__)

      use Slipstream

      def start_link(args) do
        Slipstream.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args), do: {:ok, connect!(@config)}

      ..
    end

This approach will validate the configuration at compile-time, but you
will be unable to change the configuration after compilation, so any
secrets contained in the configuration (e.g. a basic-auth request header)
will be compiled into the beam files.

See the docs for `c:Slipstream.init/1` for a safer approach.

## Options

* `:uri` - Required. The endpoint to which the websocket will connect. Schemes of "ws" and
  "wss" are supported, and a scheme must be provided. Either binaries or
  `URI` structs are accepted. E.g. `"ws://localhost:4000/socket/websocket"`.

* `:heartbeat_interval_msec` (`t:non_neg_integer/0`) - The time between heartbeat messages. A value of `0` will disable automatic
  heartbeat sending. Note that a Phoenix.Channel will close out a connection
  after 60 seconds of inactivity (`60_000`). The default value is `30000`.

* `:headers` - A set of headers to merge with the request headers when GETing the
  websocket URI. Headers must be provided as two-tuples where both elements
  are binaries. Casing of these headers is inconsequential. The default value is `[]`.

* `:serializer` (`t:atom/0`) - A serializer module which exports at least `encode!/1` and `decode!/2`. The default value is `Slipstream.Serializer.PhoenixSocketV2Serializer`.

* `:json_parser` (`t:atom/0`) - A JSON parser module which exports at least `encode!/1` and `decode!/1`. The default value is `Jason`.

* `:reconnect_after_msec` (list of `t:non_neg_integer/0`) - A list of times to reference for trying reconnection when
  `Slipstream.reconnect/1` is used to request reconnection. The msec time
  will be fetched based on its position in the list with
  `Enum.at(reconnect_after_msec, try_number)`. If the number of tries
  exceeds the length of the list, the final value will be repeated. The default value is `[10, 50, 100, 150, 200, 250, 500, 1000, 2000, 5000]`.

* `:rejoin_after_msec` (list of `t:non_neg_integer/0`) - A list of times to reference for trying to rejoin a topic when
  `Slipstream.rejoin/3` is used. The msec time
  will be fetched based on its position in the list with
  `Enum.at(rejoin_after_msec, try_number)`. If the number of tries
  exceeds the length of the list, the final value will be repeated. The default value is `[100, 500, 1000, 2000, 5000, 10000]`.

* `:mint_opts` (`t:keyword/0`) - A keywordlist of options to pass to `Mint.HTTP.connect/4` when opening
  connections. This can be used to set up custom TLS certificate
  configuration. See the `Mint.HTTP.connect/4` documentation for available
  options. The default value is `[protocols: [:http1]]`.

* `:extensions` (`t:term/0`) - A list of extensions to pass to `Mint.WebSocket.upgrade/4`. The default value is `[]`.

* `:test_mode?` (`t:boolean/0`) - Whether or not to start-up the client in test-mode. See
  `Slipstream.SocketTest` for notes on testing Slipstream clients. The default value is `false`.



Note that a Phoenix.Channel defined with

```elixir
socket "/socket", UserSocket, ..
```

Can be connected to at `/socket/websocket`.

## validate(opts)

Validates a proposed configuration

## validate!(opts)

Validates a proposed configuration, raising on error